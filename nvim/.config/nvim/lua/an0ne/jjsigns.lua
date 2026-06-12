-- jjsigns: gutter change-hints + Zed-style foldable inline diff, backed by jj.
--
-- It diffs each buffer against its working-copy parent (`@-`) in the current
-- jj repo, so it shows exactly the changes in the current working copy and
-- nothing across commits. Pure-lua, no plugin deps (uses vim.diff + extmarks).

local M = {}
local api = vim.api
local uv = vim.uv or vim.loop

local ns = api.nvim_create_namespace("jjsigns")           -- gutter signs
local ns_inline = api.nvim_create_namespace("jjsigns_inline") -- folded old-line previews

local repo_root = nil
local enabled = false
local state = {} -- [buf] = { base = {lines}, hunks = {}, expanded = {key=extmark}, timer }

local cfg = {
  add = "▎",
  change = "▎",
  delete = "▁",   -- lines removed *below* this line
  topdelete = "▔", -- lines removed at the very top
}

----------------------------------------------------------------------
-- highlights
----------------------------------------------------------------------
local function apply_hl()
  local hls = {
    JjSignsAdd = { fg = "#4fbf4f" },
    JjSignsChange = { fg = "#d4a72c" },
    JjSignsDelete = { fg = "#e05252" },
  }
  for name, val in pairs(hls) do
    val.default = true
    api.nvim_set_hl(0, name, val)
  end
  -- the folded "old version" block reuses the colorscheme's deleted-diff look
  api.nvim_set_hl(0, "JjSignsDeletePreview", { link = "DiffDelete", default = true })
end

----------------------------------------------------------------------
-- helpers
----------------------------------------------------------------------
local function should_attach(buf)
  if not enabled or repo_root == nil then return false end
  if not api.nvim_buf_is_valid(buf) then return false end
  if vim.bo[buf].buftype ~= "" then return false end
  local name = api.nvim_buf_get_name(buf)
  if name == "" then return false end
  return name:sub(1, #repo_root + 1) == repo_root .. "/"
end

-- Pull the parent (`@-`) version of the file. New/untracked files error out,
-- which we treat as an empty base (the whole buffer reads as "added").
local function fetch_base(buf, cb)
  local name = api.nvim_buf_get_name(buf)
  vim.system(
    { "jj", "-R", repo_root, "file", "show", "-r", "@-", name },
    { text = true },
    function(res)
      vim.schedule(function()
        if not api.nvim_buf_is_valid(buf) then return end
        local base
        if res.code == 0 then
          base = vim.split(res.stdout or "", "\n", { plain = true })
          if base[#base] == "" then base[#base] = nil end -- drop trailing newline
        else
          base = {}
        end
        state[buf] = state[buf] or { expanded = {} }
        state[buf].base = base
        if cb then cb() end
      end)
    end
  )
end

local function place_sign(buf, lnum, text, hl)
  if lnum < 1 then lnum = 1 end
  pcall(api.nvim_buf_set_extmark, buf, ns, lnum - 1, 0, {
    sign_text = text,
    sign_hl_group = hl,
  })
end

local function render_signs(buf)
  api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  local s = state[buf]
  if not s or not s.hunks then return end
  local last = api.nvim_buf_line_count(buf)
  for _, h in ipairs(s.hunks) do
    if h.type == "add" then
      for l = h.start_b, h.start_b + h.count_b - 1 do
        place_sign(buf, l, cfg.add, "JjSignsAdd")
      end
    elseif h.type == "change" then
      for l = h.start_b, h.start_b + h.count_b - 1 do
        place_sign(buf, l, cfg.change, "JjSignsChange")
      end
    else -- delete
      if h.start_b == 0 then
        place_sign(buf, 1, cfg.topdelete, "JjSignsDelete")
      else
        place_sign(buf, math.min(h.start_b, last), cfg.delete, "JjSignsDelete")
      end
    end
  end
end

local function compute(buf)
  local s = state[buf]
  if not s or not s.base then return end
  local cur = table.concat(api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
  local base = table.concat(s.base, "\n")
  local diff = vim.diff(base, cur, { result_type = "indices", algorithm = "histogram" })
  local hunks = {}
  for _, d in ipairs(diff or {}) do
    local sa, ca, sb, cb = d[1], d[2], d[3], d[4]
    local h = { start_a = sa, count_a = ca, start_b = sb, count_b = cb }
    if ca == 0 then
      h.type = "add"
    elseif cb == 0 then
      h.type = "delete"
    else
      h.type = "change"
    end
    h.old_lines = {}
    for i = sa, sa + ca - 1 do
      h.old_lines[#h.old_lines + 1] = s.base[i]
    end
    hunks[#hunks + 1] = h
  end
  s.hunks = hunks
  -- recomputing invalidates folded previews (line numbers shift) -> collapse them
  api.nvim_buf_clear_namespace(buf, ns_inline, 0, -1)
  s.expanded = {}
  render_signs(buf)
end

local function schedule_compute(buf)
  local s = state[buf]
  if not s then return end
  if s.timer then
    s.timer:stop()
  else
    s.timer = uv.new_timer()
  end
  s.timer:start(120, 0, function()
    vim.schedule(function()
      if api.nvim_buf_is_valid(buf) then compute(buf) end
    end)
  end)
end

local function attach(buf)
  if not should_attach(buf) then return end
  state[buf] = state[buf] or { expanded = {} }
  fetch_base(buf, function() compute(buf) end)
end

----------------------------------------------------------------------
-- inline (foldable) previews
----------------------------------------------------------------------
local function hunk_key(h)
  return table.concat({ h.start_a, h.count_a, h.start_b, h.count_b }, ":")
end

local function expand_hunk(buf, h)
  if #h.old_lines == 0 then return end
  local virt = {}
  for _, line in ipairs(h.old_lines) do
    virt[#virt + 1] = { { line == "" and " " or line, "JjSignsDeletePreview" } }
  end
  local row, above
  if h.type == "delete" then
    row = math.max(h.start_b, 1) - 1
    above = (h.start_b == 0)
  else
    row = h.start_b - 1
    above = true
  end
  local id = api.nvim_buf_set_extmark(buf, ns_inline, row, 0, {
    virt_lines = virt,
    virt_lines_above = above,
  })
  state[buf].expanded[hunk_key(h)] = id
end

local function hunk_at(buf, lnum)
  local s = state[buf]
  if not s or not s.hunks then return nil end
  for _, h in ipairs(s.hunks) do
    local lo, hi
    if h.type == "delete" then
      lo = math.max(h.start_b, 1)
      hi = lo
    else
      lo = h.start_b
      hi = h.start_b + h.count_b - 1
    end
    if lnum >= lo and lnum <= hi then return h end
  end
  return nil
end

-- Toggle the folded "previous version" for the hunk under the cursor.
function M.toggle_inline()
  local buf = api.nvim_get_current_buf()
  local h = hunk_at(buf, api.nvim_win_get_cursor(0)[1])
  if not h then
    vim.notify("jjsigns: no change here", vim.log.levels.INFO)
    return
  end
  if #h.old_lines == 0 then
    vim.notify("jjsigns: added lines (no previous version)", vim.log.levels.INFO)
    return
  end
  local s = state[buf]
  local key = hunk_key(h)
  if s.expanded[key] then
    api.nvim_buf_del_extmark(buf, ns_inline, s.expanded[key])
    s.expanded[key] = nil
  else
    expand_hunk(buf, h)
  end
end

-- Expand every hunk's previous version, or collapse all if any are open.
function M.toggle_all()
  local buf = api.nvim_get_current_buf()
  local s = state[buf]
  if not s or not s.hunks then return end
  if next(s.expanded) then
    api.nvim_buf_clear_namespace(buf, ns_inline, 0, -1)
    s.expanded = {}
    return
  end
  for _, h in ipairs(s.hunks) do
    expand_hunk(buf, h)
  end
end

----------------------------------------------------------------------
-- navigation
----------------------------------------------------------------------
local function anchors(s)
  local a = {}
  for _, h in ipairs(s.hunks) do
    a[#a + 1] = (h.type == "delete") and math.max(h.start_b, 1) or h.start_b
  end
  table.sort(a)
  return a
end

function M.next_hunk()
  local buf = api.nvim_get_current_buf()
  local s = state[buf]
  if not s or not s.hunks or #s.hunks == 0 then return end
  local cur = api.nvim_win_get_cursor(0)[1]
  local a = anchors(s)
  for _, l in ipairs(a) do
    if l > cur then
      api.nvim_win_set_cursor(0, { l, 0 })
      return
    end
  end
  api.nvim_win_set_cursor(0, { a[1], 0 }) -- wrap to first
end

function M.prev_hunk()
  local buf = api.nvim_get_current_buf()
  local s = state[buf]
  if not s or not s.hunks or #s.hunks == 0 then return end
  local cur = api.nvim_win_get_cursor(0)[1]
  local a = anchors(s)
  for i = #a, 1, -1 do
    if a[i] < cur then
      api.nvim_win_set_cursor(0, { a[i], 0 })
      return
    end
  end
  api.nvim_win_set_cursor(0, { a[#a], 0 }) -- wrap to last
end

function M.refresh()
  local buf = api.nvim_get_current_buf()
  if should_attach(buf) then
    fetch_base(buf, function() compute(buf) end)
  end
end

----------------------------------------------------------------------
-- setup
----------------------------------------------------------------------
function M.setup()
  local out = vim.fn.systemlist({ "jj", "root" })
  if vim.v.shell_error ~= 0 or not out[1] or out[1] == "" then
    return -- not a jj repo (or jj missing): stay silent & disabled
  end
  repo_root = out[1]
  enabled = true

  apply_hl()
  vim.opt.signcolumn = "yes" -- keep the gutter stable like Zed

  local grp = api.nvim_create_augroup("JjSigns", { clear = true })
  api.nvim_create_autocmd({ "BufReadPost", "BufWinEnter" }, {
    group = grp,
    callback = function(a) attach(a.buf) end,
  })
  api.nvim_create_autocmd("BufWritePost", {
    group = grp,
    callback = function(a)
      if should_attach(a.buf) then
        fetch_base(a.buf, function() compute(a.buf) end)
      end
    end,
  })
  api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave" }, {
    group = grp,
    callback = function(a)
      if state[a.buf] and state[a.buf].base then schedule_compute(a.buf) end
    end,
  })
  api.nvim_create_autocmd("BufDelete", {
    group = grp,
    callback = function(a) state[a.buf] = nil end,
  })
  api.nvim_create_autocmd("ColorScheme", { group = grp, callback = apply_hl })

  local map = vim.keymap.set
  map("n", "<leader>gp", M.toggle_inline, { desc = "jj: fold/unfold inline diff for hunk" })
  map("n", "<leader>gP", M.toggle_all, { desc = "jj: fold/unfold all inline diffs" })
  map("n", "<leader>gr", M.refresh, { desc = "jj: refresh change signs" })
  map("n", "]h", M.next_hunk, { desc = "jj: next change hunk" })
  map("n", "[h", M.prev_hunk, { desc = "jj: prev change hunk" })

  -- attach buffers already open at startup
  for _, b in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_loaded(b) then attach(b) end
  end
end

return M
