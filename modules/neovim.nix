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
    ];

    extraPackages = with pkgs; [
      gopls
      rust-analyzer
      phpactor
      clang-tools
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      marksman
      ruff
      gofumpt
      rustfmt
      php
      prettierd
      shellcheck
      stylua
      shfmt
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
nnoremap <leader>2 <cmd>bnext<cr>
nnoremap <leader>3 <cmd>bprev<cr>
nnoremap <leader>q <cmd>bdelete<cr>      

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
-- NVIM-CMP: AUTOCOMPLETE CONFIGURATION
-- ========================================================================
local cmp = require('cmp')
local luasnip = require('luasnip')

require('luasnip.loaders.from_vscode').lazy_load()

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
    ['<Esc>'] = cmp.mapping.abort(),
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
      vim_item.kind = (kind_icons[vim_item.kind] or "") .. ' ' .. vim_item.kind
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
-- NVIM-LSPCONFIG: vim.lsp.config API
-- ========================================================================
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local function on_attach(client, bufnr)
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

-- Python (Pyright)
vim.lsp.config('pyright', {
  cmd = {'pyright-langserver', '--stdio'},
  root_markers = {'pyrightconfig.json', 'pyproject.toml', '.git'},
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
vim.lsp.config('gopls', {
  cmd = {'gopls'},
  root_markers = {'go.mod', '.git'},
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
vim.lsp.config('rust_analyzer', {
  cmd = {'rust-analyzer'},
  root_markers = {'Cargo.toml', '.git'},
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

-- PHP (PHPActor)
vim.lsp.config('phpactor', {
  cmd = {'phpactor', 'language-server'},
  root_markers = {'composer.json', '.git'},
  on_attach = on_attach,
  capabilities = capabilities,
})

-- C/C++ (Clangd)
vim.lsp.config('clangd', {
  cmd = {'clangd'},
  root_markers = {'compile_commands.json', '.git'},
  on_attach = on_attach,
  capabilities = capabilities,
})

-- TypeScript/JavaScript
vim.lsp.config('ts_ls', {
  cmd = {'typescript-language-server', '--stdio'},
  root_markers = {'package.json', 'tsconfig.json', '.git'},
  on_attach = on_attach,
  capabilities = capabilities,
})

-- HTML
vim.lsp.config('html', {
  cmd = {'html-languageserver', '--stdio'},
  root_markers = {'.git'},
  on_attach = on_attach,
  capabilities = capabilities,
})

-- CSS
vim.lsp.config('cssls', {
  cmd = {'css-languageserver', '--stdio'},
  root_markers = {'.git'},
  on_attach = on_attach,
  capabilities = capabilities,
})

-- JSON
vim.lsp.config('jsonls', {
  cmd = {'json-languageserver', '--stdio'},
  root_markers = {'.git'},
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Markdown
vim.lsp.config('marksman', {
  cmd = {'marksman'},
  root_markers = {'.git'},
  on_attach = on_attach,
  capabilities = capabilities,
})

-- ========================================================================
-- CONFORM.NVIM
-- ========================================================================
require('conform').setup({
  formatters_by_ft = {
    python = { 'black', 'isort' },
    go = { 'gofumpt' },
    rust = { 'rustfmt' },
    php = { 'php' },
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
    timeout_ms = 5000,
    lsp_fallback = true,
  },
})

-- ========================================================================
-- DIAGNOSTICS: ПОДСВЕТКА ОШИБОК И ПРЕДУПРЕЖДЕНИЙ
-- ========================================================================
vim.diagnostic.config({
  virtual_text = {
    prefix = '●',
    spacing = 4,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Кастомные иконки для диагностики
local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }
for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Подсветка цветов ошибок
vim.api.nvim_set_hl(0, 'DiagnosticSignError', { fg = '#ff5555' })
vim.api.nvim_set_hl(0, 'DiagnosticSignWarn', { fg = '#ffaa00' })
vim.api.nvim_set_hl(0, 'DiagnosticSignHint', { fg = '#00ffff' })
vim.api.nvim_set_hl(0, 'DiagnosticSignInfo', { fg = '#5b9bd5' })


-- ========================================================================
-- NVIM-TREESITTER
-- ========================================================================
require('nvim-treesitter.configs').setup({
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
})

-- ========================================================================
-- NVIM-AUTOPAIRS
-- ========================================================================
require('nvim-autopairs').setup({
  check_ts = true,
})

local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

-- ========================================================================
-- АВТОМАТИЧЕСКОЕ ОБНАРУЖЕНИЕ РАСШИРЕНИЙ
-- ========================================================================
vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
  callback = function(args)
    local buf = args.buf
    local filename = vim.api.nvim_buf_get_name(buf)
    local ext = vim.fn.fnamemodify(filename, ':e'):lower()

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

    if ft_map[ext] then
      vim.bo.filetype = ft_map[ext]
    else
      if not vim.bo.filetype or vim.bo.filetype == "" then
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
}

