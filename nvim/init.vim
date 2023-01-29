set nocompatible
set hidden
set nobackup
set nowritebackup
set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar
set number
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set signcolumn=yes
set noshowmode
set encoding=utf-8
set foldmethod=syntax
set foldnestmax=10
set nofoldenable
set foldlevel=2
set backspace=2
set incsearch
set lazyredraw
set updatetime=300
set ttyfast
set shortmess+=c
set ruler
set scrolloff=10
set guifont=Consolas:h8
set listchars=tab:▸\ ,eol:¬
set nofixeol

map! jj <esc>

let g:code_file_types = ['cpp', 'c', 'python', 'javascript', 'xml', 'vim', 'rust', 'typescript', 'markdown', 'html', 'css', 'zig', 'ps1']
let g:neo_format_types = ['javascript', 'typescript', 'rust']

call plug#begin()

Plug 'dstein64/vim-startuptime'

" Languages
Plug 'PProvost/vim-ps1'
Plug 'rust-lang/rust.vim'
Plug 'ziglang/zig.vim'

" Colorschemes
Plug 'endel/vim-github-colorscheme'

" Lualine
Plug 'nvim-lualine/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'

" Treesitter
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
Plug 'nvim-treesitter/nvim-treesitter-textobjects', { 'do': ':TSUpdate' }
Plug 'nvim-treesitter/nvim-treesitter-context'
Plug 'nvim-treesitter/playground'

" File management
Plug 'scrooloose/nerdtree', { 'on': ['NERDTree', 'NERDTreeToggle'] }
Plug 'Yggdroot/LeaderF', { 'do': '.\install.bat' }
Plug 'tpope/vim-fugitive', { 'on': ['G', 'Git'] }

" Editing
Plug 'raimondi/delimitMate', { 'for': g:code_file_types }
Plug 'kamykn/CCSpellCheck.vim', { 'for': g:code_file_types }
Plug 'github/copilot.vim', { 'for': g:code_file_types }
Plug 'sbdchd/neoformat', { 'for': g:code_file_types }

" Lsp
Plug 'neovim/nvim-lspconfig'
Plug 'ray-x/lsp_signature.nvim'

" Completion
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

call plug#end()

colorscheme github

augroup Markdown
    autocmd!
    autocmd InsertLeave *.md normal gwap<CR>
    autocmd FileType markdown set spell spelllang=en_us
    autocmd FileType markdown set textwidth=120
augroup END

au GUIEnter * simalt ~x

highlight CCSpellBad cterm=reverse ctermfg=magenta gui=reverse guifg=magenta

noremap <c-z> <NOP>

nnoremap <leader>t :Leaderf --popup tag<cr>
nnoremap <backspace> :Leaderf --popup file<cr>

nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l

" ============================================================================================
" = NeoFormat Config
" ============================================================================================

augroup NeoFormat
    autocmd!
    execute "autocmd FileType " . join(g:neo_format_types, ',') . " autocmd BufWritePre <buffer> undojoin | Neoformat"
augroup END

" ============================================================================================
" = nvim-cmp Config
" ============================================================================================
set completeopt=menu,menuone,noselect

lua <<EOF

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

-- Setup nvim-cmp.
local cmp = require'cmp'

cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        end,
    },
    window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ['<Tab>'] = cmp.mapping(function (fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif vim.fn["vsnip#available"](1) == 1 then
                feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
                cmp.complete()
            else
                fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
            end
        end, {"i", "s"}),
        ["<S-Tab>"] = cmp.mapping(function()
            if cmp.visible() then
                cmp.select_prev_item()
            elseif vim.fn["vsnip#jumpable"](-1) == 1 then
                feedkey("<Plug>(vsnip-jump-prev)", "")
            end
        end, { "i", "s" }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'vsnip' }, -- For vsnip users.
        -- { name = 'luasnip' }, -- For luasnip users.
        -- { name = 'ultisnips' }, -- For ultisnips users.
        -- { name = 'snippy' }, -- For snippy users.
    }, {
        { name = 'buffer' },
    })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})

EOF

" ============================================================================================
" = LSP config
" ============================================================================================

lua << EOF

local nvim_lsp = require('lspconfig');
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

-- keybindings
local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    -- buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    local opts = { noremap=true, silent=true }

    buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', '<leader>=', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

    require "lsp_signature".on_attach({ bind = true }, bufnr)
end

-- clangd section
local compile_commands_dir;
if (vim.api.nvim_eval('getcwd() =~ "Storage.XStore.src"') ~= 0)
then
    compile_commands_dir = "--compile-commands-dir=" .. vim.api.nvim_eval('expand("~/.compiledb/XStore")');
elseif (vim.api.nvim_eval('filereadable(getcwd() . "/build/compile_commands.json")') ~= 0)
then
    compile_commands_dir = "--compile-commands-dir=" .. vim.api.nvim_eval('expand(getcwd() . "/build")')
else
    compile_commands_dir = "--compile-commands-dir=./"
end

nvim_lsp.clangd.setup {
    on_attach = on_attach,
    cmd = { 'C:\\Program Files\\LLVM\\bin\\clangd.exe', '--pch-storage=memory', compile_commands_dir, '--background-index' },
    capabilities
}

nvim_lsp.tsserver.setup {
    on_attach = on_attach,
    capabilities
}

nvim_lsp.rust_analyzer.setup {
    on_attach = on_attach,
    capabilities,
    cmd = { 'rustup.exe', 'run', 'stable', 'rust-analyzer' }
}

EOF

autocmd FileType c,cpp
    \ autocmd BufWritePre <buffer> call <SID>format_if_dot_clang_format()

function! s:format_if_dot_clang_format()
    if expand("%:p:h") =~ "XTable"
        return
    endif

    if expand("%:p:h") =~ "XBlobContainerServer"
        return
    endif

    let current_path = expand("%:p:h") . ';'
    if !empty(findfile(".clang-format", current_path))
        lua vim.lsp.buf.formatting_sync(nil, 3000)
    endif
endfunction


" ============================================================================================
" = Tree Sitter config
" ============================================================================================
autocmd FileType c,cpp set foldmethod=expr
autocmd FileType c,cpp set foldexpr=nvim_treesitter#foldexpr()

lua <<EOF
require'nvim-treesitter.configs'.setup {
    ensure_installed = { "c", "cpp", "rust", "typescript" },
    highlight = {
        enable = { "c", "cpp", "rust", "typescript" },
    },
    refactor = {
        highlight_definitions = { enable = { "c", "cpp", "rust", "typescript" } },
        highlight_current_scope = { enable = { "c", "cpp", "rust", "typescript" } },
    },
    textobjects = {
        select = {
            enable = true,

            -- Automatically jump forward to textobj, similar to targets.vim 
            lookahead = true,

            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
                ["ab"] = "@block.outer",
                ["ib"] = "@block.inner",
                ["ac"] = "@comment.outer",
                ["aa"] = "@parameter.outer",
                ["ia"] = "@parameter.inner",
            },
        },
    },
    playground = {
        enable = true,
        disable = {},
        updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
        persist_queries = false, -- Whether the query persists across vim sessions
        keybindings = {
            toggle_query_editor = 'o',
            toggle_hl_groups = 'i',
            toggle_injected_languages = 't',
            toggle_anonymous_nodes = 'a',
            toggle_language_display = 'I',
            focus_language = 'f',
            unfocus_language = 'F',
            update = 'R',
            goto_node = '<cr>',
            show_help = '?',
        },
    }
}

local parser_configs = require'nvim-treesitter.parsers'.get_parser_configs();
parser_configs.cyan = {
    install_info = {
        url = "~/Documents/cyan/tree-sitter-cyan",
        files = { "src/parser.c" }
    },
}

require'treesitter-context'.setup{
    enable = true,
    max_lines = 5,
    pattern = {
        cpp = {
            'lambda_expression'
        }
    }
}

EOF

autocmd BufNewFile,BufRead *.cy set filetype=cyan


" ============================================================================================
" = Copilot settings
" ============================================================================================

imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true


" ============================================================================================
" = Lualine settings
" ============================================================================================
lua << END
require('lualine').setup {
    options = {
        theme = 'ayu_light'
    }
}
END
