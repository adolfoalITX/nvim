return {
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    cmd = 'Telescope',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- optional but recommended
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      'nvim-telescope/telescope-ui-select.nvim',
    },
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Find files' },
      { '<leader>fg', '<cmd>Telescope live_grep<cr>', desc = 'Find text' },
      { '<leader>fc', '<cmd>Telescope commands<cr>', desc = 'Find commands' },
      { '<leader>fh', '<cmd>Telescope help_tags<cr>', desc = 'Help tags' },
    },
    config = function()
      local telescope = require('telescope')

      telescope.setup({
        defaults = {
          file_ignore_patterns = { '.git/' },
          vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--hidden',
            '--follow',
            '--no-ignore',
          },
          preview = {
            treesitter = {
              enable = false,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            no_ignore = true,
            follow = true,
            find_command = {
              'rg',
              '--files',
              '--hidden',
              '--follow',
              '--no-ignore',
              '--glob',
              '!.git',
            },
          },
        },
        extensions = {
          ['ui-select'] = require('telescope.themes').get_dropdown({}),
        },
      })

      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'ui-select')
    end,
  },
}
