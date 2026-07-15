return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    lazy = false,
    build = ':TSUpdate',
    opts = {
      ensure_installed = {
        'java',
        'xml',
        'yaml',
        'toml',
        'json',
        'properties',
        'dockerfile',
        'bash',
        'sql',
        'javascript',
        'typescript',
        'tsx',
        'css',
        'html',
        'http',
        'markdown',
        'markdown_inline',
        'gitignore',
        'vim',
        'lua',
      },
      auto_install = true,
      sync_install = false,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
        disable = function(lang, bufnr)
          local max = 250 * 1024
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
          return ok and stats and stats.size > max
        end,
      },
      indent = {
        enable = true,
        disable = { 'yaml' },
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<C-=>',
          node_incremental = '<C-=>',
          scope_incremental = '<C-+>',
          node_decremental = '<C-->',
        },
      },
    },
    config = function(_, opts)
      local function patch_markdown_info_string_directive()
        if vim.fn.has('nvim-0.12') == 0 then
          return
        end

        local ok_query, query = pcall(require, 'vim.treesitter.query')
        if not ok_query then
          return
        end

        local aliases = {
          ex = 'elixir',
          pl = 'perl',
          sh = 'bash',
          ts = 'typescript',
          uxn = 'uxntal',
        }

        local directive_opts = vim.fn.has('nvim-0.10') == 1 and { force = true, all = false } or true
        query.add_directive('set-lang-from-info-string!', function(match, _, bufnr, pred, metadata)
          local capture_id = pred[2]
          local node = match[capture_id]
          if vim.islist(node) and node[1] ~= nil then
            node = node[1]
          end
          if not node then
            return
          end

          local ok_text, text = pcall(vim.treesitter.get_node_text, node, bufnr, {
            metadata = metadata and metadata[capture_id] or nil,
          })
          if not ok_text or type(text) ~= 'string' or text == '' then
            return
          end

          local injection_alias = text:lower()
          metadata['injection.language'] = vim.filetype.match({ filename = 'a.' .. injection_alias })
            or aliases[injection_alias]
            or injection_alias
        end, directive_opts)
      end

      local ok_configs, ts_configs = pcall(require, 'nvim-treesitter.configs')
      if ok_configs then
        ts_configs.setup(opts)
        patch_markdown_info_string_directive()
        return
      end

      local ok_ts, ts = pcall(require, 'nvim-treesitter')
      if ok_ts then
        ts.setup({
          install_dir = vim.fn.stdpath('data') .. '/site',
        })

        local ok_install, install = pcall(ts.install, opts.ensure_installed)
        if ok_install and install and install.wait then
          install:wait(300000)
        end

        vim.api.nvim_create_autocmd('FileType', {
          callback = function(ev)
            if vim.tbl_contains(opts.ensure_installed, ev.match) then
              pcall(vim.treesitter.start, ev.buf)
            end
          end,
        })

        patch_markdown_info_string_directive()
      end
    end,
  },
}
