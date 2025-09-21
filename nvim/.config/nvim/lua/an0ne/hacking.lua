-- allow ":" in expand("<cfile>") to mean line/col
vim.opt.isfname:append(":")

-- Terminal cwd resolver (Linux via /proc, macOS via lsof)
local function term_cwd(bufnr)
  bufnr = bufnr or 0
  local pid = vim.b[bufnr].terminal_job_pid
  if not pid then return nil end

  local link = "/proc/" .. pid .. "/cwd"
  local stat = vim.loop.fs_stat(link)
  if stat then
    local ok, path = pcall(vim.loop.fs_readlink, link)
    if ok and path and #path > 0 then return path end
  end

  if vim.fn.executable("lsof") == 1 then
    local out = vim.fn.systemlist({ "lsof", "-a", "-p", tostring(pid), "-d", "cwd", "-Fn" })
    for _, line in ipairs(out) do
      local m = line:match("^n(.+)$")
      if m and #m > 0 then return m end
    end
  end
  return nil
end

-- Parse "file:line[:col]" or 'file(line,col)' (quotes ok)
local function parse_path_linecol(text)
  -- strip surrounding single/double quotes
  text = text:gsub("^%s*['\"]", ""):gsub("['\"]%s*$", "")

  -- match file(line,col)
  do
    local p, l, c = text:match("^(.-)%((%d+),%s*(%d+)%)$")
    if p then return (p:gsub("%s+$","")), tonumber(l), tonumber(c) end
    p, l = text:match("^(.-)%((%d+)%)$")
    if p then return (p:gsub("%s+$","")), tonumber(l), nil end
  end

  -- Greedy file part, then :line[:col] at the end.
  -- Keep Windows drive letters safe by preferring the *last* numeric :parts
  do
    local p, l, c = text:match("^(.-):(%d+):(%d+)%s*$")
    if p then return p, tonumber(l), tonumber(c) end
    p, l = text:match("^(.-):(%d+)%s*$")
    if p then return p, tonumber(l), nil end
  end

  -- Some tools print trailing ":" after filename
  text = text:gsub(":+%s*$", "")
  return text, nil, nil
end

local function is_abs(path)
  return path:sub(1,1) == "/" or path:match("^[A-Za-z]:[\\/]")
end

local function resolve_base_dir()
  if vim.bo.buftype == "terminal" then
    local tcwd = term_cwd(0)
    if tcwd and #tcwd > 0 then return tcwd end
  end
  return vim.fn.getcwd()
end

local function open_under_cursor_with_linecol()
  local raw = vim.fn.expand("<cfile>")
  if raw == nil or raw == "" then
    -- fallback: behave like stock gf
    vim.cmd.normal({ args = { "gf" }, bang = true })
    return
  end

  local path, line, col = parse_path_linecol(raw)

  -- tilde, absolute, or relative to chosen base
  local base = resolve_base_dir()
  local abs
  if path:sub(1,2) == "~/" then
    abs = vim.fn.fnamemodify(path, ":p")
  elseif is_abs(path) then
    abs = vim.fn.fnamemodify(path, ":p")
  else
    abs = vim.fn.fnamemodify(base .. "/" .. path, ":p")
  end

  -- open (even if not yet existing)
  vim.cmd.edit(vim.fn.fnameescape(abs))

  if line then
    local lnum = math.max(1, line)
    local col0 = (col and math.max(0, col - 1)) or 0
    pcall(vim.api.nvim_win_set_cursor, 0, { lnum, col0 })
  end
end

-- Map both gf and gF to our handler (line/col supported everywhere).
vim.keymap.set("n", "gf", open_under_cursor_with_linecol, { desc = "smart gf with line/col (terminal-aware base dir)" })
vim.keymap.set("n", "gF", open_under_cursor_with_linecol, { desc = "smart gF with line/col (terminal-aware base dir)" })

