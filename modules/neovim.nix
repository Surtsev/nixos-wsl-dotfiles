programs.neovim = {
  enable = true;
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;
  
  plugins = with pkgs.vimPlugins; [
    # UI and themes
    vim-airline
    vim-airline-themes
    
    # File type and language support
    vim-nix
    vim-polyglot
    vim-python-pep8-indent
    
    # Fuzzy finder
    telescope-nvim
    plenary-nvim
    
    # LSP
    nvim-lspconfig
    mason-nvim
    mason-lspconfig-nvim
    
    # Completion
    nvim-cmp
    cmp-nvim-lsp
    cmp-buffer
    cmp-path
    cmp-cmdline
    luasnip
    cmp_luasnip
    friendly-snippets
    
    # Treesitter for better syntax highlighting
    nvim-treesitter.withAllGrammars
    
    # Auto pairs and formatting
    nvim-autopairs
    conform-nvim
  ];

  extraPackages = with pkgs; [
    # LSP servers
    pyright                    # Python
    gopls                      # Go
    rust-analyzer              # Rust
    intelephense               # PHP
    clangd                     # C/C++
    nodePackages.typescript-language-server  # TypeScript/JavaScript
    nodePackages.vscode-langservers-extracted # HTML/CSS/JSON
    marksman                   # Markdown
    
    # Formatters and linters
    black                      # Python formatter
    isort                      # Python import sorting
    ruff                       # Python linter
    gofumpt                    # Go formatter
    rustfmt                    # Rust formatter
    php                        # PHP
    prettierd                  # JS/TS/HTML/CSS formatter
    shellcheck                 # Bash linter
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
    set completeopt=menu,menuone,noselect
    set updatetime=300
    set signcolumn=yes
    set cmdheight=2
    
    " ============================================================================
    " COLOR SCHEME - Habamax для согласованности с editor theme
    " ============================================================================
    colorscheme habamax
    
    " Улучшение внешнего вида автокомплита
    highlight Pmenu ctermfg=15 ctermbg=8 guifg=#ffffff guibg=#2e2e3e
    highlight PmenuSel ctermfg=0 ctermbg=7 guifg=#2e2e3e guibg=#5b9bd5
    highlight PmenuThumb ctermbg=7 guibg=#5b9bd5
    highlight PmenuSbar ctermbg=8 guibg=#2e2e3e
    
    " ============================================================================
    " LEADER KEY
    " ============================================================================
    let mapleader = " "
    let maplocalleader = " "
    
    " ============================================================================
    " KEY MAPPINGS - FUZZY FINDER
    " ============================================================================
    nnoremap <leader>ff <cmd>Telescope find_files<cr>
    nnoremap <leader>fg <cmd>Telescope live_grep<cr>
    nnoremap <leader>fb <cmd>Telescope buffers<cr>
    nnoremap <leader>fh <cmd>Telescope help_tags<cr>
    nnoremap <leader>fd <cmd>Telescope diagnostics<cr>
    
    " ============================================================================
    " KEY MAPPINGS - AUTOCOMPLETE (согласованные с Telescope)
    " ============================================================================
    " <leader>ca - show completion menu
    inoremap <silent><expr> <leader>ca coc#refresh()
    
    " <leader>cc - trigger manual completion
    inoremap <leader>cc <C-n>
    
    " <leader>cy - accept completion and expand snippet
    inoremap <silent><expr> <leader>cy pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
    
    " <leader>cn/cp - navigate completions
    inoremap <silent><expr> <leader>cn pumvisible() ? "\<C-n>" : "\<C-n>"
    inoremap <silent><expr> <leader>cp pumvisible() ? "\<C-p>" : "\<C-p>"
    
    " <C-Space> - быстрый доступ к автокомплиту
    inoremap <silent><expr> <C-Space> cmp#complete()
    
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
    nnoremap <leader>e <cmd>lua vim.diagnostic.open_float()<CR>
    nnoremap <leader>dn <cmd>lua vim.diagnostic.goto_next()<CR>
    nnoremap <leader>dp <cmd>lua vim.diagnostic.goto_prev()<CR>
    
    " ============================================================================
    " KEY MAPPINGS - FORMATTING
    " ============================================================================
    nnoremap <leader>fm <cmd>lua require("conform").format()<CR>
    vnoremap <leader>fm <cmd>lua require("conform").format()<CR>
    
    " ============================================================================
    " AIRLINE CONFIGURATION
    " ============================================================================
    let g:airline#extensions#tabline#enabled = 1
    let g:airline_theme = 'dark'
    let g:airline_powerline_fonts = 0
  '';

  extraLuaConfig = ''
    -- ========================================================================
    -- NVIM-CMP: AUTOCOMPLETE CONFIGURATION
    -- ========================================================================
    local cmp = require('cmp')
    local luasnip = require('luasnip')
    
    -- Загрузка friendly-snippets
    require('luasnip.loaders.from_vscode').lazy_load()
    
    -- Пользовательские источники для неизвестных расширений
    local function get_completion_sources()
      return {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer', keyword_length = 3 },
        { name = 'path' },
        { name = 'cmdline' },
      }
    end
    
    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      window = {
        completion = {
          border = 'rounded',
          winhighlight = 'Normal:Pmenu,FloatBorder:PmenuBorder,CursorLine:PmenuSel',
        },
        documentation = {
          border = 'rounded',
          winhighlight = 'Normal:Pmenu,FloatBorder:PmenuBorder',
        },
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'i', 's' }),
      }),
      sources = get_completion_sources(),
      formatting = {
        format = function(entry, vim_item)
          -- Добавление иконок для разных типов
          local kind_icons = {
            Text = '📄',
            Method = 'ƒ',
            Function = '🔧',
            Constructor = '⚙️',
            Field = '📋',
            Variable = '📦',
            Class = '📚',
            Interface = '🎯',
            Module = '📦',
            Property = '🔑',
            Unit = '🧮',
            Value = '💾',
            Enum = '📊',
            Keyword = '🔑',
            Snippet = '✂️',
            Color = '🎨',
            File = '📁',
            Reference = '🔗',
            Folder = '📂',
            EnumMember = '🔢',
            Constant = '🔐',
            Struct = '🏗️',
            Event = '🎉',
            Operator = '➕',
            TypeParameter = '🔤',
          }
          vim_item.kind = (kind_icons[vim_item.kind] or '') .. ' ' .. vim_item.kind
          vim_item.menu = ({
            nvim_lsp = '[LSP]',
            luasnip = '[Snippet]',
            buffer = '[Buffer]',
            path = '[Path]',
            cmdline = '[Cmd]',
          })[entry.source.name]
          return vim_item
        end,
      },
    })
    
    -- ========================================================================
    -- MASON: УПРАВЛЕНИЕ LSP SERVERS И TOOLS
    -- ========================================================================
    require('mason').setup({
      ui = {
        icons = {
          package_installed = '✓',
          package_pending = '➜',
          package_uninstalled = '✗'
        }
      }
    })
    
    require('mason-lspconfig').setup({
      ensure_installed = {
        'pyright',           -- Python
        'gopls',             -- Go
        'rust_analyzer',     -- Rust
        'intelephense',      -- PHP
        'clangd',            -- C/C++
        'tsserver',          -- TypeScript/JavaScript
        'html',              -- HTML
        'cssls',             -- CSS
        'jsonls',            -- JSON
        'marksman',          -- Markdown
      },
      automatic_installation = true,
    })
    
    -- ========================================================================
    -- NVIM-LSPCONFIG: КОНФИГУРАЦИЯ LSP SERVERS
    -- ========================================================================
    local lspconfig = require('lspconfig')
    local on_attach = function(client, bufnr)
      -- Автоматическое форматирование при сохранении
      if client.supports_method('textDocument/formatting') then
        vim.api.nvim_create_autocmd('BufWritePre', {
          group = vim.api.nvim_create_augroup('LSPFormatting', { clear = true }),
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format()
          end,
        })
      end
    end
    
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    
    -- Python (Pyright)
    lspconfig.pyright.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        python = {
          analysis = {
            typeCheckingMode = 'basic',
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
          }
        }
      }
    })
    
    -- Go (Gopls)
    lspconfig.gopls.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        gopls = {
          usePlaceholders = true,
          completeUnimported = true,
        }
      }
    })
    
    -- Rust (Rust Analyzer)
    lspconfig.rust_analyzer.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        ['rust-analyzer'] = {
          checkOnSave = {
            command = 'clippy'
          }
        }
      }
    })
    
    -- PHP (Intelephense)
    lspconfig.intelephense.setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })
    
    -- C/C++ (Clangd)
    lspconfig.clangd.setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })
    
    -- TypeScript/JavaScript
    lspconfig.tsserver.setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })
    
    -- HTML
    lspconfig.html.setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })
    
    -- CSS
    lspconfig.cssls.setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })
    
    -- Markdown
    lspconfig.marksman.setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })
    
    -- ========================================================================
    -- CONFORM.NVIM: ФОРМАТИРОВАНИЕ КОДА
    -- ========================================================================
    require('conform').setup({
      formatters_by_ft = {
        python = { 'black', 'isort' },
        go = { 'gofumpt' },
        rust = { 'rustfmt' },
        php = { 'php_cs_fixer' },
        c = { 'clang_format' },
        cpp = { 'clang_format' },
        javascript = { 'prettierd' },
        typescript = { 'prettierd' },
        jsx = { 'prettierd' },
        tsx = { 'prettierd' },
        html = { 'prettierd' },
        css = { 'prettierd' },
        json = { 'prettierd' },
        markdown = { 'prettierd' },
        yaml = { 'prettierd' },
        lua = { 'stylua' },
        bash = { 'shfmt' },
        sh = { 'shfmt' },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    })
    
    -- ========================================================================
    -- NVIM-TREESITTER: ЛУЧШЕЕ ПОДСВЕЧИВАНИЕ СИНТАКСИСА
    -- ========================================================================
    require('nvim-treesitter.configs').setup({
      ensure_installed = {
        'python', 'go', 'rust', 'php', 'c', 'cpp',
        'javascript', 'typescript', 'html', 'css',
        'markdown', 'json', 'yaml', 'bash', 'lua',
        'nix',
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
    })
    
    -- ========================================================================
    -- NVIM-AUTOPAIRS: АВТОМАТИЧЕСКОЕ ЗАКРЫТИЕ СКОБОК
    -- ========================================================================
    require('nvim-autopairs').setup({
      check_ts = true,
    })
    
    -- Интеграция с cmp
    local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    
    -- ========================================================================
    -- АВТОМАТИЧЕСКОЕ ОБНАРУЖЕНИЕ РАСШИРЕНИЙ И ВКЛЮЧЕНИЕ LSP
    -- ========================================================================
    vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
      callback = function(args)
        local buf = args.buf
        local filename = vim.api.nvim_buf_get_name(buf)
        local ext = vim.fn.fnamemodify(filename, ':e'):lower()
        
        -- Маппинг расширений на языки
        local ft_map = {
          py = 'python',
          go = 'go',
          rs = 'rust',
          php = 'php',
          c = 'c',
          h = 'c',
          cpp = 'cpp',
          cc = 'cpp',
          cxx = 'cpp',
          hpp = 'cpp',
          js = 'javascript',
          jsx = 'jsx',
          ts = 'typescript',
          tsx = 'tsx',
          html = 'html',
          css = 'css',
          md = 'markdown',
          json = 'json',
          yaml = 'yaml',
          yml = 'yaml',
          bash = 'bash',
          sh = 'bash',
          lua = 'lua',
          nix = 'nix',
        }
        
        -- Если расширение известно
        if ft_map[ext] then
          vim.bo.filetype = ft_map[ext]
        else
          -- Если расширение неизвестно, пытаемся автоматически определить
          if not vim.bo.filetype or vim.bo.filetype == '' then
            -- Проверяем шебанг
            local first_line = vim.fn.getline(1)
            if string.find(first_line, '^#!') then
              if string.find(first_line, 'python') then
                vim.bo.filetype = 'python'
              elseif string.find(first_line, 'bash') or string.find(first_line, 'sh') then
                vim.bo.filetype = 'bash'
              elseif string.find(first_line, 'node') then
                vim.bo.filetype = 'javascript'
              end
            end
          end
        end
      end,
    })
  '';
};
