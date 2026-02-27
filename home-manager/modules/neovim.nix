{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
 
    plugins = with pkgs.vimPlugins; [
      vim-airline
      vim-airline-themes
      nvim-tree-lua
      nvim-web-devicons
      vim-nix
      vim-polyglot
      vim-python-pep8-indent
      telescope-nvim
      plenary-nvim
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      luasnip
      cmp_luasnip
      friendly-snippets
      nvim-treesitter
      nvim-autopairs
      conform-nvim
      direnv-vim
      ollama-nvim
      render-markdown-nvim
    ];

    extraPackages = with pkgs; [
      gopls
      rust-analyzer
      phpactor
      clang-tools
      ccls
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      marksman
      ruff
      gofumpt
      rustfmt
      phpPackages.php-cs-fixer
      prettierd
      shellcheck
      stylua
      shfmt
      fswatch
      fd
      inotify-tools
      nodejs_20
      tree-sitter
    ];

    extraConfig = ''
" ============================================================================
" BASIC SETTINGS
" ============================================================================
set number
set relativenumber
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set smartindent
set hidden
set ignorecase
set smartcase
set incsearch
set hlsearch
set splitbelow
set splitright
set clipboard=unnamedplus
set completeopt=menu,menuone,noinsert,noselect
set updatetime=300
set signcolumn=yes
set cmdheight=2

" ============================================================================
" COLOR SCHEME
" ============================================================================
colorscheme habamax

highlight Pmenu ctermfg=15 ctermbg=8 guifg=#ffffff guibg=#2e2e3e
highlight PmenuSel ctermfg=15 ctermbg=4 guifg=#ffffff guibg=#5b9bd5
highlight PmenuThumb ctermbg=7 guibg=#5b9bd5
highlight PmenuSbar ctermbg=8 guibg=#2e2e3e

" === Transparent background ===
highlight NonText ctermbg=NONE
highlight Normal ctermbg=NONE
highlight NormalFloat  ctermbg=none guibg=none
highlight FloatBorder  ctermbg=none guifg=#5b9bd5 guibg=none
highlight CmpBorder    ctermbg=none guifg=#5b9bd5 guibg=none
highlight SignColumn   ctermbg=none guibg=none
highlight LineNr       ctermbg=none guibg=none
highlight CursorLineNr ctermbg=none guibg=none
highlight StatusLine   ctermbg=none guibg=none
highlight StatusLineNC ctermbg=none guibg=none
highlight TabLine      ctermbg=none guibg=none
highlight VertSplit    ctermbg=none guibg=none
highlight WinSeparator ctermbg=none guibg=none

" ============================================================================
" LEADER KEY
" ============================================================================
let mapleader = " "
let maplocalleader = " "

" ============================================================================
" KEY MAPPINGS - FILE TREE
" ============================================================================
nnoremap <leader>e <cmd>NvimTreeToggle<cr>
nnoremap <leader>1 <cmd>NvimTreeFocus<cr>

" ============================================================================
" KEY MAPPINGS - BUFFER NAVIGATION
" ============================================================================
nnoremap <leader>2 <cmd>bprev<cr>
nnoremap <leader>3 <cmd>bnext<cr>
nnoremap <leader>q <cmd>bdelete<cr>      
nnoremap <leader>w <cmd>w<cr>

" ============================================================================
" KEY MAPPINGS - FUZZY FINDER
" ============================================================================
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>fd <cmd>Telescope diagnostics<cr>

" ============================================================================
" KEY MAPPINGS - LSP
" ============================================================================
nnoremap <leader>gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <leader>gh <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <leader>gr <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <leader>gi <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <leader>gs <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <leader>rn <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <leader>ca <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <leader>E <cmd>lua vim.diagnostic.open_float()<CR>
nnoremap <leader>dn <cmd>lua vim.diagnostic.goto_next()<CR>
nnoremap <leader>dp <cmd>lua vim.diagnostic.goto_prev()<CR>

" ============================================================================
" KEY MAPPINGS - FORMATTING
" ============================================================================
nnoremap <leader>fm <cmd>lua require("conform").format()<CR>
vnoremap <leader>fm <cmd>lua require("conform").format()<CR>

" ============================================================================
" KEY MAPPINGS - DIAGNOSTICS (Ошибки и предупреждения)
" ============================================================================
nnoremap <leader>xx <cmd>Telescope diagnostics<cr>
nnoremap <leader>xd <cmd>lua vim.diagnostic.setloclist()<CR>
nnoremap <leader>xl <cmd>lua vim.diagnostic.setqflist()<CR>


" ============================================================================
" AIRLINE CONFIGURATION
" ============================================================================
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme = 'dark'
let g:airline_powerline_fonts = 0
    '';

    extraLuaConfig = ''

      -- Добавляем пути к плагинам из home-manager в runtimepath
      local plugin_paths = {
        vim.fn.expand("~/.local/share/nvim/site/pack/home-manager/start"),
        vim.fn.expand("~/.local/share/nvim/site/pack/home-manager/opt"),
      }
      
      for _, path in ipairs(plugin_paths) do
        if vim.fn.isdirectory(path) == 1 then
          for _, plugin in ipairs(vim.fn.glob(path .. "/*", false, true)) do
            vim.opt.rtp:prepend(plugin)
          end
        end
      end

      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
      vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
      vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })

      vim.api.nvim_set_hl(0, "CmpBorder", {
        fg = "#5b9bd5",  -- такой же синий как PmenuSel
        bg = "none",
      })
      -- рамка документации:
      vim.api.nvim_set_hl(0, "FloatBorder", {
        fg = "#5b9bd5",
        bg = "none",
      })

      vim.g.direnv_silent = 1
      vim.g.direnv_always = 1

      -- Автокоманда: direnv allow после правки .envrc
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = ".envrc",
        callback = function()
          vim.cmd("silent !direnv allow " .. vim.fn.expand("%:p:h"))
          vim.cmd("redraw!")
        end,
      })

      -- ========================================================================
      -- NVIM-TREE: FILE EXPLORER (ПЕРВЫМ!)
      -- ========================================================================
      require('nvim-tree').setup({
        view = {
          width = 30,
          side = 'left',
        },
        ...
      })
      -- ========================================================================
      -- DIAGNOSTICS: НОВЫЙ ФОРМАТ (без sign_define!)
      -- ========================================================================
      vim.diagnostic.config({
        virtual_text = {
          prefix = '●',
          spacing = 4,
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "E",
            [vim.diagnostic.severity.WARN] = "W",
            [vim.diagnostic.severity.HINT] = "H",
            [vim.diagnostic.severity.INFO] = "I",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- Подсветка цветов (без sign_define)
      vim.api.nvim_set_hl(0, 'DiagnosticSignError', { fg = '#ff5555' })
      vim.api.nvim_set_hl(0, 'DiagnosticSignWarn', { fg = '#ffaa00' })
      vim.api.nvim_set_hl(0, 'DiagnosticSignHint', { fg = '#00ffff' })
      vim.api.nvim_set_hl(0, 'DiagnosticSignInfo', { fg = '#5b9bd5' })

      -- ========================================================================
      -- NVIM-CMP AUTOCOMPLETE CONFIGURATION
      -- ========================================================================
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        -- Автокомплит включён
        completion = {
          autocomplete = { cmp.TriggerEvent.TextChanged },
          preselect = cmp.PreselectMode.Item,
        },

        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        window = {
          completion = {
            border = "rounded",
            winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
          },
          documentation = {
            border = "rounded",
            winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder",
          },
        },

        mapping = {
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-e>"] = cmp.mapping.abort(),

          -- Ручное открытие (опционально)
          ["<C-Space>"] = cmp.mapping.complete(),
        },

        -- Показывать только если предыдущий символ — буква/цифра/_
        enabled = function()
          local col = vim.fn.col(".") - 1
          if col <= 0 then
            return false
          end

          local line = vim.fn.getline(".")
          local prev_char = line:sub(col, col)

          return prev_char:match("[%w_]") ~= nil
        end,

        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer", keyword_length = 3 },
          { name = "path" },
        },
      })
      -- ========================================================================
      -- LSP CAPABILITIES + ON_ATTACH (ИСПРАВЛЕН supports_method)
      -- ========================================================================
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      capabilities.workspace = {
        didChangeWatchedFiles = { dynamicRegistration = true },
      }

      local function on_attach(client, bufnr)
        -- ✅ ИСПРАВЛЕНО: client:supports_method (новый синтаксис)
        if client:supports_method('textDocument/formatting') then
          vim.api.nvim_create_autocmd('BufWritePre', {
            group = vim.api.nvim_create_augroup('LSPFormatting', { clear = true }),
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format()
            end,
          })
        end
      end

      vim.lsp.config("pyright", {
        cmd = { "pyright-langserver", "--stdio" },

        root_dir = vim.fs.root(0, {
          "pyproject.toml",
          ".git",
        }),

        capabilities = capabilities,
        on_attach = on_attach,

        settings = {
          python = {
            venvPath = ".",
            venv = ".venv",
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })
      -- Остальные LSP (без изменений)
      vim.lsp.config('gopls', { cmd = {'gopls'}, root_dir = vim.fs.root(0, {'go.mod', '.git'}), on_attach = on_attach, capabilities = capabilities })
      vim.lsp.config('rust_analyzer', { cmd = {'rust-analyzer'}, root_dir = vim.fs.root(0, {'Cargo.toml', '.git'}), on_attach = on_attach, capabilities = capabilities })
      vim.lsp.config('phpactor', { cmd = {'phpactor', 'language-server'}, root_dir = vim.fs.root(0, {'composer.json', '.git'}), on_attach = on_attach, capabilities = capabilities })
      vim.lsp.config("ccls", {
        cmd = { 
          "ccls"
        },
        root_dir = vim.fs.root(0, {
          "compile_commands.json",
          "compile_flags.txt",
          ".git",
        }),
        capabilities = capabilities,
        on_attach = on_attach,
      })
      vim.lsp.config('ts_ls', { cmd = {'typescript-language-server', '--stdio'}, root_dir = vim.fs.root(0, {'package.json', 'tsconfig.json', '.git'}), on_attach = on_attach, capabilities = capabilities })
      vim.lsp.config('html', { on_attach = on_attach, capabilities = capabilities })
      vim.lsp.config('cssls', { on_attach = on_attach, capabilities = capabilities })
      vim.lsp.config('jsonls', { on_attach = on_attach, capabilities = capabilities })
      vim.lsp.config('marksman', { on_attach = on_attach, capabilities = capabilities })

      -- АКТИВАЦИЯ LSP
      vim.lsp.enable('pyright')
      vim.lsp.enable('gopls')
      vim.lsp.enable('rust_analyzer')
      vim.lsp.enable('phpactor')
      vim.lsp.enable('ccls')
      vim.lsp.enable('ts_ls')
      vim.lsp.enable('html')
      vim.lsp.enable('cssls')
      vim.lsp.enable('jsonls')
      vim.lsp.enable('marksman')

      -- ========================================================================
      -- CONFORM.NVIM, TREESITTER, AUTOPAIRS (без изменений)
      -- ========================================================================
      require('conform').setup({
        formatters_by_ft = {
          python = { 'black', 'isort' }, go = { 'gofumpt' }, rust = { 'rustfmt' },
          php = { 'php-cs-fixer' }, c = { 'clang_format' }, cpp = { 'clang_format' },
          javascript = { 'prettierd' }, typescript = { 'prettierd' }, jsx = { 'prettierd' },
          tsx = { 'prettierd' }, html = { 'prettierd' }, css = { 'prettierd' },
          json = { 'prettierd' }, markdown = { 'prettierd' }, yaml = { 'prettierd' },
          lua = { 'stylua' }, bash = { 'shfmt' }, sh = { 'shfmt' },
        },
        format_on_save = { timeout_ms = 5000, lsp_fallback = true },
      })

      require('nvim-treesitter.configs').setup({
        highlight = { enable = true, additional_vim_regex_highlighting = false },
        indent = { enable = true },
      })

      require('nvim-autopairs').setup({
        check_ts = true,
        disable_filetype = { "TelescopePrompt", "vim" },
        fast_wrap = {},
        map_cr = false,  -- отключаем собственный маппинг Enter
      })

      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))

      -- Удаляем старые маппинги
      pcall(vim.keymap.del, 'i', '<Tab>')
      pcall(vim.keymap.del, 'i', '<S-Tab>')
      pcall(vim.keymap.del, 'i', '<Down>')
      pcall(vim.keymap.del, 'i', '<Up>')
      pcall(vim.keymap.del, 'i', '<C-n>')
      pcall(vim.keymap.del, 'i', '<C-p>')

      -- Tab - навигация или вставка табуляции
      vim.keymap.set('i', '<Tab>', function()
        if cmp.visible() then
          -- Просто перемещаем выделение, ничего не подтверждаем
          cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
          -- Возвращаем nil, так как это не expr маппинг
          return
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
          return
        else
          -- Вставляем табуляцию
          vim.api.nvim_put({ '\t' }, 'c', false, true)
        end
      end, { noremap = true, silent = true })

      -- Shift-Tab - навигация вверх
      vim.keymap.set('i', '<S-Tab>', function()
        if cmp.visible() then
          cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
          return
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
          return
        end
        -- Shift-Tab обычно ничего не делает, просто игнорируем
      end, { noremap = true, silent = true })

      -- Стрелки и Ctrl+n/p - только навигация
      vim.keymap.set('i', '<Down>', function()
        if cmp.visible() then
          cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
        else
          -- Передаём стрелку дальше
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Down>', true, false, true), 'n', false)
        end
      end, { noremap = true, silent = true })

      vim.keymap.set('i', '<Up>', function()
        if cmp.visible() then
          cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Up>', true, false, true), 'n', false)
        end
      end, { noremap = true, silent = true })

      vim.keymap.set('i', '<C-n>', function()
        if cmp.visible() then
          cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-n>', true, false, true), 'n', false)
        end
      end, { noremap = true, silent = true })

      vim.keymap.set('i', '<C-p>', function()
        if cmp.visible() then
          cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-p>', true, false, true), 'n', false)
        end
      end, { noremap = true, silent = true })

      vim.keymap.set('i', '<CR>', function()
        if cmp.visible() then
          if cmp.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace }) then
            return
          end
        end
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
      end, { noremap = true, silent = true })

			require('ollama').setup({
        model = "qwen2.5-coder:7b",
        
        host = "127.0.0.1",
        port = 11434,  
        
        prompts = {
          explain = {
            prompt = "Объясни этот код простыми словами: \n```$ftype\n$sel\n```",
            model = "qwen2.5-coder:7b",            
          },
          review = {
            prompt = "Проведи code review этого фрагмента. Укажи потенциальные проблемы и предложи улучшения: \n```$ftype\n$sel\n```",
            model = "qwen2.5-coder:7b",
          },
          optimize = {
            prompt = "Оптимизируй этот код для лучшей производительности: \n```$ftype\n$sel\n```",
            model = "qwen2.5-coder:7b",
          },
          tests = {
            prompt = "Напиши unit-тесты для этого кода: \n```$ftype\n$sel\n```",
            model = "qwen2.5-coder:7b",
          },
          comments = {
            prompt = "Добавь подробные комментарии к этому коду на русском языке: \n```$ftype\n$sel\n```",
            model = "qwen2.5-coder:7b",
          },
        },
        
        window = {
          width = 0.6,
          height = 0.4,
          border = "rounded", 
        },
        
        prefix = "<leader>f",          
        syntax = true,
      })
      
      local opts = { noremap = true, silent = true }
      
      vim.keymap.set('v', '<leader>fe', function()
        require('ollama').prompt('explain')
      end, opts)
      
      vim.keymap.set('v', '<leader>fr', function()
				require('ollama').prompt('review')
      end, opts)

      vim.keymap.set('v', '<leader>fo', function()
        require('ollama').prompt('optimize')
      end, opts)
      
      vim.keymap.set('v', '<leader>ft', function()
        require('ollama').prompt('tests')
      end, opts)
    '';
  };
  home.file.".config/nvim/ginit.vim".text = ''
		GuiWindowOpacity 0.5
  '';
  # Настройка nvim-qt одинаковая с настройкой обычного nvim
  home.packages = with pkgs; [
    # Добавляем nvim-qt, который будет использовать настроенный Neovim
    (neovim-qt.override { 
        neovim = config.programs.neovim.finalPackage; 
    })
  ];
}

