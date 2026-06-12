return {
    'nvim-telescope/telescope.nvim',
    tag = 'v0.2.2',
    dependencies = {
        'nvim-lua/plenary.nvim',
        -- C sorter: fast on huge candidate lists (the monorepo win) and
        -- ranks contiguous substring matches highest (fixes scattered matching).
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    }
}
