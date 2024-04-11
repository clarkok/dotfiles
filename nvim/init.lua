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
vim.o.backspace = 'indent,eol,start'
vim.o.incsearch = true
vim.o.updatetime = 300
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

Map('n', '<c-h>', '<c-w>h', { noremap = true })
Map('n', '<c-j>', '<c-w>j', { noremap = true })
Map('n', '<c-k>', '<c-w>k', { noremap = true })
Map('n', '<c-l>', '<c-w>l', { noremap = true })

local code_file_types = { 'cpp', 'c', 'python', 'javascript', 'vim', 'rust', 'typescript', 'markdown', 'html', 'css',
    'zig', 'lua', 'cmake', 'json', 'jsonc', 'glsl', 'markdown_inline' }
local neo_format_types = { 'javascript', 'typescript', 'rust', 'json', 'jsonc' }
local clang_format_black_pattern_list = { 'XTable', 'XBlobContainerServer', 'quickjs' }
local lsp_ensure_installed = {  'clangd', 'rust_analyzer', 'tsserver', 'html', 'cssls', 'lua_ls', 'cmake' }

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
    'neoclide/jsonc.vim',
    'tikhomirov/vim-glsl',

    -- Colorschemes
    'endel/vim-github-colorscheme',

    -- Lualine
    { 'jcdickinson/wpm.nvim',    config = true },
    'nvim-tree/nvim-web-devicons',
    {
        'nvim-lualine/lualine.nvim',
        config = true,
        dependencies = {
            'nvim-tree/nvim-web-devicons',
            'jcdickinson/wpm.nvim',
        },
        config = function()
            local wpm = require('wpm')
            require('lualine').setup {
                options = {
                    theme                = 'ayu_light',
                    section_separators   = { left = '> ', right = ' <' },
                    component_separators = { left = '> ', right = ' <' }
                },
                sections = {
                    lualine_c = { function() return vim.fn.expand('%') end },
                    lualine_x = {
                        function() return 'WPM: ' .. require('wpm').wpm() .. require('wpm').historic_graph() end,
                        function() return 'Buf: ' .. table.getn(vim.api.nvim_list_bufs()) end
                    }
                }
            }
        end
    },

    -- Editing
    { 'kamykn/CCSpellCheck.vim', lazy = true,  ft = code_file_types },
    {
        'windwp/nvim-autopairs',
        lazy = true,
        ft = code_file_types,
        opts = {
            enable_check_bracket_line = false,
            ignored_next_char = "[%w%.]"
        }
    },
    {
        'windwp/nvim-ts-autotag',
        lazy = true,
        ft = 'html',
        config = true,
        dependencies = { 'nvim-treesitter/nvim-treesitter' }
    },
    {
        'github/copilot.vim',
        lazy = true,
        ft = code_file_types,
        config = function()
            vim.api.nvim_set_keymap('i', '<C-J>', 'copilot#Accept("\\<CR>")',
                { silent = true, script = true, expr = true })
            vim.g.copilot_no_tab_map = true
        end
    },
    {
        'sbdchd/neoformat',
        lazy = true,
        ft = neo_format_types,
        cmd = 'Neoformat',
        config = function()
            local group = Augroup('NeoFormat', {})
            Autocmd('FileType', {
                pattern = neo_format_types,
                command = 'autocmd! BufWritePre * undojoin | Neoformat',
                group = group
            })
            vim.g.neoformat_enabled_javascript = {'prettierd'}
            vim.g.neoformat_enabled_typescript = {'prettierd'}
        end
    },

    -- Treesitter
    { 'nvim-treesitter/nvim-treesitter-textobjects', build = ':TSUpdate', lazy = true },
    {
        'nvim-treesitter/nvim-treesitter',
        ft = code_file_types,
        build = ':TSUpdate',
        lazy = true,
        cmd = { 'TSInstall', 'TSUpdate', 'TSUpdateSync' },
        dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects', 'nvim-treesitter/nvim-treesitter-context' },
        config = function()
            require('nvim-treesitter.install').compilers = { 'clang', 'gcc' }

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
                    updatetime = 25,         -- Debounced time for highlighting nodes in the playground from source code
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
    {
        'nvim-treesitter/playground',
        lazy = true,
        cmd = 'TSPlaygroundToggle',
        dependencies = { 'nvim-treesitter/nvim-treesitter' }
    },

    -- File Management
    {
        'nvim-tree/nvim-tree.lua',
        lazy = true,
        keys = { '<c-/>' },
        cmd = { 'NvimTreeToggle', 'NvimTreeFocus', 'NvimTreeFindFile' },
        config = function()
            require('nvim-tree').setup()
            Map('n', '<c-/>', ':NvimTreeToggle<cr>', { noremap = true, silent = true })
        end
    },
    { 'nvim-lua/plenary.nvim',    lazy = true },
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        lazy = true,
        build =
        'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
    },
    {
        'nvim-telescope/telescope.nvim',
        lazy = true,
        keys = {
            {
                '<backspace>',
                function()
                    require('extend-file-sorter').start()
                    require('telescope.builtin').find_files()
                end,
                mode = 'n'
            }
        },
        dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-fzf-native.nvim' },
        config = function()
            local builtin = require('telescope.builtin')
            local extending = require('extend-file-sorter')

            vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
            vim.keymap.set('n', '<leader>fr', builtin.lsp_references, {})
            vim.keymap.set('n', '<leader>fd', builtin.diagnostics, {})
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})

            local actions = require('telescope.actions')

            require('telescope').setup {
                defaults = {},
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
    { 'tpope/vim-fugitive',       lazy = true, cmd = { 'G', 'Git', 'Gcommit' } },

    -- LSP
    { 'ray-x/lsp_signature.nvim', lazy = true },
    { 'williamboman/mason.nvim', command = { "Mason" }, lazy = true, config = true },
    {
        'williamboman/mason-lspconfig.nvim',
        lazy = true,
        dependencies = 'williamboman/mason.nvim',
        opts = {
            ensure_installed = lsp_ensure_installed
        }
    },
    { 'p00f/clangd_extensions.nvim', lazy = true, ft = { 'c', 'cpp' } },
    {
        'neovim/nvim-lspconfig',
        lazy = true,
        ft = code_file_types,
        dependencies = { 'ray-x/lsp_signature.nvim', 'hrsh7th/nvim-cmp', 'williamboman/mason-lspconfig.nvim' },
        config = function()
            local nvim_lsp = require('lspconfig');
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            -- keybindings
            local on_attach = function(client, bufnr)
                require "lsp_signature".on_attach({ bind = true }, bufnr)
            end

            for _, item in ipairs(lsp_ensure_installed) do
                if item ~= 'clangd' then
                    nvim_lsp[item].setup {
                        on_attach = on_attach,
                        capabilities = capabilities,
                    }
                end
            end

            nvim_lsp.html.setup {
                on_attach = on_attach,
                capabilities = capabilities,
            }

            nvim_lsp.cssls.setup {
                on_attach = on_attach,
                capabilities = capabilities,
            }

            -- clangd section
            local compile_commands_dir
            local root_dir
            -- local clangd_exeutable = 'clangd'

            --[[
            if (vim.fn.executable('C:\\Program Files\\LLVM\\bin\\clangd.exe') ~= 0) then
                clangd_exeutable = 'C:\\Program Files\\LLVM\\bin\\clangd.exe'
            end
            --]]

            local cwd = vim.fn.getcwd()
            if (vim.regex('\\cStorage.XStore.src'):match_str(cwd)) then
                compile_commands_dir = "--compile-commands-dir=" .. vim.fn.expand('~/.compiledb/XStore');
                root_dir = cwd

                --[[
                if (vim.fn.executable('E:\\llvm-project-llvmorg-15.0.7\\llvm-project-llvmorg-15.0.7\\build\\RelWithDebInfo\\bin\\clangd.exe') ~= 0) then
                    clangd_exeutable =
                    'E:\\llvm-project-llvmorg-15.0.7\\llvm-project-llvmorg-15.0.7\\build\\RelWithDebInfo\\bin\\clangd.exe'
                end
                --]]
            elseif (vim.fn.filereadable(cwd .. '/build/compile_commands.json') ~= 0) then
                compile_commands_dir = "--compile-commands-dir=" .. vim.fn.expand(cwd .. '/build')
                root_dir = cwd
            else
                compile_commands_dir = "--compile-commands-dir=./"
                root_dir = require('lspconfig.util').root_pattern(
                    '.clangd',
                    '.clang-tidy',
                    '.clang-format',
                    'compile_commands.json',
                    'compile_flags.txt',
                    'configure.ac',
                    '.git'
                )(cwd)
            end

            nvim_lsp.clangd.setup {
                on_attach = function(client, bufnr)
                    on_attach(client, bufnr);
                    require("clangd_extensions.inlay_hints").setup_autocmd()
                    require("clangd_extensions.inlay_hints").set_inlay_hints()
                    client.server_capabilities.semanticTokensProvider = nil
                end,
                capabilities = capabilities,
                root_dir = function() return root_dir end,
                cmd = { 'clangd', '--pch-storage=memory', compile_commands_dir, '--background-index', '--offset-encoding=utf-16', '--clang-tidy' },
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
                        vim.lsp.buf.format({
                            timeout_ms = 3000
                        })
                    end
                end
            })
        end
    },
    {
        'nvimdev/lspsaga.nvim',
        ft = code_file_types,
        dependencies = { 'nvim-tree/nvim-web-devicons', 'neovim/nvim-lspconfig' },
        config = function()
            require('lspsaga').setup({
                lightbulb = { enable = false }
            })

            vim.keymap.set('n', 'K', '<cmd>Lspsaga hover_doc ++keep<CR>')
            vim.keymap.set('n', 'gd', '<cmd>Lspsaga goto_definition<CR>')
            vim.keymap.set('n', '<leader>rn', '<cmd>Lspsaga rename<CR>')
            vim.keymap.set('n', '<leader>ca', '<cmd>Lspsaga code_action<CR>')
        end,
    },
    {
        'j-hui/fidget.nvim',
        ft = code_file_types,
        dependencies = { 'neovim/nvim-lspconfig' },
        config = true,
    },

    -- Completion
    { 'hrsh7th/vim-vsnip',           lazy = true },
    { 'hrsh7th/vim-vsnip-integ',     lazy = true },
    { 'hrsh7th/cmp-nvim-lsp',        lazy = true },
    { 'hrsh7th/cmp-buffer',          lazy = true },
    { 'hrsh7th/cmp-path',            lazy = true },
    { 'hrsh7th/cmp-cmdline',         lazy = true },
    {
        'hrsh7th/nvim-cmp',
        lazy = true,
        ft = code_file_types,
        dependencies = {
            'hrsh7th/vim-vsnip',
            'hrsh7th/vim-vsnip-integ',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'windwp/nvim-autopairs',
            'p00f/clangd_extensions.nvim',
        },
        config = function()
            local cmp = require('cmp')

            local has_words_before = function()
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0 and
                    vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
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
                window = {},
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = false }),
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif vim.fn["vsnip#available"](1) == 1 then
                            feedkey("<Plug>(vsnip-expand-or-jump)", "")
                        elseif has_words_before() then
                            cmp.complete()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
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
                }),
                sorting = {
                    comparators = {
                        cmp.config.compare.offset,
                        cmp.config.compare.exact,
                        cmp.config.compare.recently_used,
                        require("clangd_extensions.cmp_scores"),
                        cmp.config.compare.kind,
                        cmp.config.compare.sort_text,
                        cmp.config.compare.length,
                        cmp.config.compare.order,
                    }
                }
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

            local cmp_autopairs = require('nvim-autopairs.completion.cmp')
            cmp.event:on(
                'confirm_done',
                cmp_autopairs.on_confirm_done()
            )
        end
    },

    -- leetcode
    {
        "kawre/leetcode.nvim",
        lazy = "leetcode.nvim" ~= vim.fn.argv()[1],
        cmd = "Leet",
        build = ":TSUpdate html",
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "nvim-lua/plenary.nvim", -- required by telescope
            "MunifTanjim/nui.nvim",

            -- optional
            "nvim-treesitter/nvim-treesitter",
            "rcarriga/nvim-notify",
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            -- configuration goes here
            arg = "leetcode.nvim",

            lang = "cpp",

            cn = { -- leetcode.cn
                enabled = true, ---@type boolean
                translator = false, ---@type boolean
                translate_problems = false, ---@type boolean
            },

            storage = {
                home = vim.fn.stdpath("data") .. "/leetcode",
                cache = vim.fn.stdpath("cache") .. "/leetcode",
            },

            logging = true,

            keys = {
                toggle = { "q", "<Esc>" }, ---@type string|string[]
                confirm = { "<CR>" }, ---@type string|string[]

                reset_testcases = "r", ---@type string
                use_testcase = "U", ---@type string
                focus_testcases = "H", ---@type string
                focus_result = "L", ---@type string
            },
        },
    }
})

Cmd('colorscheme github')
Cmd('highlight CCSpellBad cterm=reverse ctermfg=magenta gui=reverse guifg=magenta')

local markdownGroup = Augroup('Markdown', {})
Autocmd('InsertLeave', {
    pattern = 'markdown',
    callback = function()
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

Autocmd('BufWritePost', {
    pattern = '*',
    callback = function(ev)
        vim.defer_fn(function()
            if vim.fn.bufwinnr(ev.buf) == -1 then
                vim.api.nvim_buf_delete(ev.buf, {})
            end
        end, 1000)
    end
})
