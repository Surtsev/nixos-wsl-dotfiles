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
set completeopt=menu,menuone,noselect
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
highlight NonText guibg=NONE ctermbg=NONE
highlight Normal guibg=NONE ctermbg=NONE
highlight NormalFloat  ctermbg=none guibg=none
highlight FloatBorder  ctermbg=none guibg=none
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
" KEY MAPPINGS - AUTOCOMPLETE
" ============================================================================
inoremap <silent><expr> <C-Space> (col('.')==1 && getline('.')=~'^\s*$'?'<C-h>':"")."\<C-x>\<C-o>"

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

      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
      vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
      vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })

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

      local function get_completion_sources()
        return {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer", keyword_length = 3 },
          { name = "path" },
          { name = "cmdline" },
        }
      end

      cmp.setup({
        completion = { autocomplete = false },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = {
            border = "rounded",
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu, CursorLine:PmenuSel,Search:PmenuSel",
          },
          documentation = {
            border = "rounded",
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu",
          },
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<Esc>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = get_completion_sources(),
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

      require('nvim-autopairs').setup({ check_ts = true })
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    '';
  };
}

