vim.o.compatible = false
vim.o.backup = false
vim.o.writebackup = false
vim.o.number = true
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.signcolumn = 'yes'
vim.o.showmode = false
vim.o.encoding = 'utf-8'
vim.o.foldmethod = 'syntax'
vim.o.foldnestmax = 10
vim.o.foldenable = false
vim.o.foldlevel = 2
vim.o.backspace = 2
vim.o.incsearch = true
vim.o.updatetime = 300
vim.o.ttyfast = true
vim.o.shortmess = 'filnxtToOFc'
vim.o.scrolloff = 10
vim.o.guifont = 'Consolas:h8'
vim.o.listchars = 'tab:▸\\ ,eol:¬'
vim.o.fixeol = false
vim.o.completeopt = 'menu,menuone,noselect'

-- disable netrw the built-in vim file explorer 
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- enable highligh groups
vim.opt.termguicolors = true

Autocmd = vim.api.nvim_create_autocmd
Augroup = vim.api.nvim_create_augroup
Cmd = vim.api.nvim_command
Map = vim.api.nvim_set_keymap

Map('n', '<c-h>', '<c-w>h', {noremap = true})
Map('n', '<c-j>', '<c-w>j', {noremap = true})
Map('n', '<c-k>', '<c-w>k', {noremap = true})
Map('n', '<c-l>', '<c-w>l', {noremap = true})

local code_file_types = {'cpp', 'c', 'python', 'javascript', 'vim', 'rust', 'typescript', 'markdown', 'html', 'css', 'zig', 'lua'}
local neo_format_types = {'javascript', 'typescript', 'rust'}
local clang_format_black_pattern_list = { 'XTable', 'XBlobContainerServer' }

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = '\\'

require('lazy').setup({
   'dstein64/vim-startuptime',

   -- Languages
    'PProvost/vim-ps1',
    'rust-lang/rust.vim',
    'ziglang/zig.vim',

    -- Colorschemes
    { 'endel/vim-github-colorscheme', lazy = true },

    -- Lualine
    { 'nvim-lualine/lualine.nvim', config = true, opts = { options = { theme = 'ayu_light' } } },
    'kyazdani42/nvim-web-devicons',

    -- Editing
    { 'raimondi/delimitMate', lazy = true, ft = code_file_types },
    { 'kamykn/CCSpellCheck.vim', lazy = true, ft = code_file_types },
    {
        'github/copilot.vim',
        lazy = true,
        ft = code_file_types,
        config = function ()
            vim.api.nvim_set_keymap('i', '<C-J>', 'copilot#Accept("\\<CR>")', { silent = true, script = true, expr = true } )
            vim.g.copilot_no_tab_map = true
        end
    },
    {
        'sbdchd/neoformat',
        lazy = true,
        ft = neo_format_types,
        cmd = 'Neoformat',
        config = function ()
            local group = Augroup('NeoFormat', {})
            vim.api.Autocmd('BufWritePre', {
                pattern = neo_format_types,
                command = 'undojoin | Neoformat',
                group = group
            })
        end
    },

    -- Treesitter
    {
        'nvim-treesitter/nvim-treesitter',
        -- ft = code_file_types,
        build = ':TSUpdate',
        -- lazy = true,
        config = function()
            require('nvim-treesitter.install').compilers = { 'clang', 'gcc' }
            require('nvim-treesitter.install').prefer_git = false

            require('nvim-treesitter.configs').setup {
                ensure_installed = code_file_types,
                highlight = { enable = code_file_types },
                refactor = {
                    highlight_definitions = { enable = code_file_types },
                    highlight_current_scope = { enable = code_file_types },
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
        end
    },
    { 'nvim-treesitter/nvim-treesitter-textobjects', build = ':TSUpdate', lazy = true, dependencies = { 'nvim-treesitter/nvim-treesitter' } },
    {
        'nvim-treesitter/nvim-treesitter-context',
        lazy = true,
        opts = {
            enable = true,
            max_lines = 5,
            pattern = { cpp = { 'lambda_expression' } }
        }
    },
    { 'nvim-treesitter/playground', lazy = true, cmd = 'TSPlaygroundToggle' },

    -- File Management
    {
        'nvim-tree/nvim-tree.lua',
        lazy = true,
        keys = { '<c-/>' },
        cmd = { 'NvimTreeToggle', 'NvimTreeFocus', 'NvimTreeFindFile' },
        config = function () 
            require('nvim-tree').setup()
            Map('n', '<c-/>', ':NvimTreeToggle<cr>', { noremap = true, silent = true })
        end
    },
    { 'nvim-lua/plenary.nvim', lazy = true },
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        lazy = true,
        build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
    },
    {
        'nvim-telescope/telescope.nvim',
        lazy = true,
        tag = '0.1.1',
        keys = { '<backspace>' },
        dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-fzf-native.nvim' },
        config = function ()
            local builtin = require('telescope.builtin')
            local extending = require('extend-file-sorter')

            local smart_find_files = function ()
                extending.start()
                builtin.find_files()
            end

            vim.keymap.set('n', '<backspace>', smart_find_files, {})
            vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
            vim.keymap.set('n', '<leader>fr', builtin.lsp_references, {})
            vim.keymap.set('n', '<leader>fd', builtin.diagnostics, {})

            local actions = require('telescope.actions')

            require('telescope').setup {
                defaults = { },
                pickers = {
                    find_files = {
                        theme = "dropdown"
                    }
                },
                extensions = {
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case",
                    }
                }
            }

            require('telescope').load_extension('fzf')

            local config_values = require('telescope.config').values
            config_values.file_sorter = extending.wrap(config_values.file_sorter)
        end
    },
    { 'tpope/vim-fugitive', lazy = true, cmd = {'G', 'Git', 'Gcommit'} },

    -- LSP
    { 'ray-x/lsp_signature.nvim', lazy = true },
    {
        'neovim/nvim-lspconfig',
        lazy = true,
        ft = code_file_types,
        dependencies = { 'ray-x/lsp_signature.nvim', 'hrsh7th/nvim-cmp' },
        config = function ()
            local nvim_lsp = require('lspconfig');
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

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
                buf_set_keymap('n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
                buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
                buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
                buf_set_keymap('n', '<leader>=', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

                require "lsp_signature".on_attach({ bind = true }, bufnr)
            end

            -- clangd section
            local compile_commands_dir;
            if (vim.api.nvim_eval('getcwd() =~ "Storage.XStore.src"') ~= 0) then
                compile_commands_dir = "--compile-commands-dir=" .. vim.api.nvim_eval('expand("~/.compiledb/XStore")');
            elseif (vim.api.nvim_eval('filereadable(getcwd() . "/build/compile_commands.json")') ~= 0) then
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

            Autocmd('BufWritePre', {
                pattern = '*.cpp,*.h,*.hpp,*.c,*.cc',
                callback = function(args)
                    local path = vim.fn.expand('%:p:h')
                    for _, item in ipairs(clang_format_black_pattern_list) do
                        if string.find(path, item) then
                            return
                        end
                    end

                    if vim.fn.findfile('.clang-format', path .. ';') ~= '' then
                        vim.lsp.buf.formatting_sync(nil, 3000)
                    end
                end
            })
        end
    },

    { 'hrsh7th/vim-vsnip', lazy = true },
    { 'hrsh7th/vim-vsnip-integ', lazy = true },
    { 'hrsh7th/cmp-nvim-lsp', lazy = true },
    { 'hrsh7th/cmp-buffer', lazy = true },
    { 'hrsh7th/cmp-path', lazy = true },
    { 'hrsh7th/cmp-cmdline', lazy = true },
    {
        'hrsh7th/nvim-cmp',
        lazy = true,
        ft = code_file_types,
        config = function ()
            local cmp = require('cmp')

            local has_words_before = function()
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
            end

            local feedkey = function(key, mode)
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
            end

            cmp.setup({
                snippet = {
                    -- REQUIRED - you must specify a snippet engine
                    expand = function(args)
                        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
                    end,
                },
                window = { },
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = false }),
                    ['<Tab>'] = cmp.mapping(function (fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif vim.fn["vsnip#available"](1) == 1 then
                            feedkey("<Plug>(vsnip-expand-or-jump)", "")
                        elseif has_words_before() then
                            cmp.complete()
                        else
                            fallback()
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
                    { name = 'vsnip' },
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
        end
    }
})

Cmd('colorscheme github')
Cmd('highlight CCSpellBad cterm=reverse ctermfg=magenta gui=reverse guifg=magenta')

local markdownGroup = Augroup('Markdown', {})
Autocmd('InsertLeave', {
    pattern = 'markdown',
    callback = function ()
        if vim.api.nvim_get_mode().mode == 'normal' then
            vim.cmd([[gwap<CR>]])
        end
    end,
    group = markdownGroup
})
Autocmd('FileType', {
    pattern = 'markdown',
    command = 'set spell spelllang=en_us',
    group = markdownGroup
})
Autocmd('FileType', {
    pattern = 'markdown',
    command = 'set textwidth=120',
    group = markdownGroup
})
