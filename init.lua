-- ==========================================================================
-- 1. PRE-LAZY STARTUP PARAMETERS
-- ==========================================================================
-- Ensure lazy.nvim is installed automatically if it's missing
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end

-- set before LAZY
-- vim.g.scratch_file_dir = vim.fn.expand("$HOME") .. "/.scratch"


-- This has to be set above Lazy
vim.g.mapleader = " "             -- Sets leader to Spacebar

-- this is set for neorg
vim.g.maplocalleader = ","

-- set for neorg
vim.opt.conceallevel = 2   -- Completely hides markup characters (like * / _)
vim.opt.concealcursor = "nc" -- Keeps characters hidden in Normal and Command modes

-- Enable true colors so italics can render properly
vim.o.termguicolors = true

-- Combined list of older and newer built-in Markdown highlight groups
local groups = {
  "Comment",                 -- Quick test: Comments usually italicize
  "markdownItalic",          -- Classic Vim Markdown syntax group
  "@markup.italic",          -- Modern Neovim Treesitter style
  "@markup.italic.markdown", -- Specific Markdown Treesitter style
  "@markup.emphasis",        -- Core Vim/Neovim italic style
}

for _, group in ipairs(groups) do
  vim.api.nvim_set_hl(0, group, { italic = true })
end


-- ==========================================================================
-- INSTANT ABBREVIATIONS (AAA -> â etc.)
-- Fully operational in BOTH buffers and the Command-Line (Minibuffer)
-- ==========================================================================

local abbrevs = {
  AAA = "â", NGG = "ŋ", GLL = "ʔ", LHH = "ɬ", UHH = "ʌ",
  SHH = "ʃ", NYY = "ɲ", ZHH = "ʒ", THH = "þ", DHH = "ð",
  EEE = "ê", III = "î", OOO = "ô", UUU = "û",
}

-- 1. Insert Mode (Standard File Buffers)
vim.api.nvim_create_autocmd("TextChangedI", {
  pattern = "*",
  callback = function()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    if col < 3 then return end -- 0-indexed byte guard

    local line_text = vim.api.nvim_get_current_line()
    local last_three = string.sub(line_text, col - 2, col)
    local replacement = abbrevs[last_three]

    if replacement then
      local new_line = string.sub(line_text, 1, col - 3) .. replacement .. string.sub(line_text, col + 1)
      vim.api.nvim_set_current_line(new_line)
      local new_col = col - #last_three + #replacement
      vim.api.nvim_win_set_cursor(0, { row, new_col })
    end
  end,
})

-- 2. Command-Line Mode (The Minibuffer prompt on /, ?, and :)
vim.api.nvim_create_autocmd("CmdlineChanged", {
  pattern = "*",
  callback = function()
    local pos = vim.fn.getcmdpos() -- Returns a 1-indexed string character marker
    if pos < 4 then return end      -- Requires at least 3 characters before the index slot

    local cmd_text = vim.fn.getcmdline()
    -- Pull the 3 letters left of the cursor index boundary
    local last_three = string.sub(cmd_text, pos - 3, pos - 1)
    local replacement = abbrevs[last_three]

    if replacement then
      -- Rebuild the string layout dynamically
      local new_cmd = string.sub(cmd_text, 1, pos - 4) .. replacement .. string.sub(cmd_text, pos)
      vim.fn.setcmdline(new_cmd)
      
      -- Update the cursor position using 1-based index rules
      local new_pos = pos - #last_three + #replacement
      vim.fn.setcmdpos(new_pos)
    end
  end,
})


vim.opt.rtp:prepend(lazypath)

-- ==========================================================================
-- 2. PLUGIN STACK SETUP (lazy.nvim)
-- ==========================================================================
require("lazy").setup({

-- Paste this directly into your lazy.nvim setup array:
-- {

  -- 1. THE COMPLETION ENGINE
  {
    'Saghen/blink.cmp',
    lazy = false,
    dependencies = 'rafamadriz/friendly-snippets',
    version = 'v0.*',
    opts = {
      -- Disables code completion inside markdown and text files
      enabled = function()
        local disabled_filetypes = { "markdown", "text" }
        return not vim.tbl_contains(disabled_filetypes, vim.bo.filetype)
          and vim.bo.buftype ~= "prompt"
      end,

      keymap = {
        preset = 'default',
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
      },
      cmdline = { enabled = true }, -- Command line completion stays active
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
    },
  },

{
    "tpope/vim-fugitive",
},

  -- 2. AUTOMATIC PACKAGE MANAGER FOR LSP
  {
    "williamboman/mason.nvim",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "clangd" }, -- Auto-installs the C language server
    },
  },

  -- 3. LSP CONFIGURATION
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      lspconfig.clangd.setup({
        capabilities = capabilities,
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
        },
      })

      -- Quick diagnostic keybind to see errors on a line
      vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = "Line Diagnostics" })
    end,
  },
-- }




   
   -- 1. Install the luarocks runner first
    {
        "vhyrro/luarocks.nvim",
        priority = 1000, -- Load this before everything else
        config = true,
    },

{
  "ibhagwan/fzf-lua",
  -- optional for icon support
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- or if using mini.icons/mini.nvim
  -- dependencies = { "nvim-mini/mini.icons" },
  ---@module "fzf-lua"
  ---@type fzf-lua.Config|{}
  ---@diagnostic disable: missing-fields
  opts = {}
  ---@diagnostic enable: missing-fields
},

{
  'stevearc/oil.nvim',
  cmd = "Oil",
  keys = {
    { "<leader>f", "<cmd>Oil --float<cr>", desc = "Open Oil in Floating Window" },
  },
  opts = {
    skip_confirm_for_simple_edits = true,
    
    -- SPEED FIX 1: Turn off columns (like icons) that require parsing every file line
    columns = {}, 

    float = {
      padding = 2,
      max_width = 80,
      max_height = 20,
      border = "rounded",
      win_options = {
        -- SPEED FIX 2: Opaque background (0) prevents heavy blending redraw lag
        winblend = 0, 
      },
    },
    view_options = {
      show_hidden = true,
    },
  },
  config = function(_, opts)
    require("oil").setup(opts)

    -- SPEED FIX 3: Force global garbage cleanup instantly when spawning an oil tree
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "oil",
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        vim.diagnostic.enable(false, { bufnr = bufnr })
        vim.b[bufnr].matchparen_disable = 1
        
        -- Forces old machines to drop background Lua memory baggage right away
        collectgarbage("collect")
      end,
    })
  end,
},




    { url = 'https://gitlab.com/sxwpb/halfspace.nvim', },


    {
        "sontungexpt/witch",
        priority = 1000,
        lazy = false,
        config = function(_, opts)
            require("witch").setup(opts)
        end,
    },

{
  "0xstepit/flow.nvim",
  lazy = false,
  priority = 1000,
  -- tag = "vX.0.0",
  opts = {
        -- Your configuration options here.
    },
},


{
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true
},

{
  "dhruvasagar/vim-table-mode",
  ft = { "norg", "markdown" }, -- Lazy load only on note files
  init = function()
    -- Set the table corner separator to match Neorg/Markdown styles
    vim.g.table_mode_corner = '|'
  end
},



    {
        "nvim-neorg/neorg",
        lazy = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-neorg/tree-sitter-norg",
            "nvim-neorg/tree-sitter-norg-meta",
            "nvim-neorg/lua-utils.nvim",
            "pysan3/pathlib.nvim",
            "nvim-neotest/nvim-nio",
        },
        config = function()
            -- 1. Structural compatibility fix for unpack
            if not unpack then
                unpack = table.unpack
            end

            -- 2. COMPLETE CAPTURE PROTECTION:
            -- Intercept global unpack specifically when processing the tempus module.
            -- If the date capture fails due to locale string lengths, this returns an 
            -- empty table instead of breaking the entire link-following layout stack.
            local original_unpack = unpack
            _G.unpack = function(t, ...)
                if t == nil then
                    local trace = debug.traceback()
                    if trace:find("tempus") or trace:find("parse_date") then
                        return {} -- Returns a structural table placeholder to suppress the error
                    end
                end
                return original_unpack(t, ...)
            end
            table.unpack = _G.unpack

            -- 3. Downstream protection for string extraction
            local lu = require("lua-utils")
            if lu and lu.title then
                local original_title = lu.title
                lu.title = function(str, ...)
                    if type(str) ~= "string" then
                        str = tostring(str or "")
                    end
                    return original_title(str, ...)
                end
            end

            -- 4. Execute Standard Configuration Routine
            require("neorg").setup({
                load = {
                    ["core.defaults"] = {},
                    ["core.tempus"] = {},
                    ["core.esupports.metagen"] = {},
                    ["core.esupports.hop"] = {},
                    ["core.concealer"] = {},
                    ["core.dirman"] = {
                        config = {
                            workspaces = {
                                conlang = "~/Notes/conlang",
                                notes = "~/Notes/notes",
                            },
                            default_workspace = "notes",
                        },
                    },
                },
            })
        end,
    },

-- 
-- {
--   "nvim-neorg/neorg",
--   lazy = false, -- Highly discouraged to lazy-load Neorg
--   -- version = "*",
--   dependencies = {
--     "nvim-lua/plenary.nvim",
--     "nvim-neorg/tree-sitter-norg",
--     "nvim-neorg/tree-sitter-norg-meta",
--     "nvim-neorg/lua-utils.nvim",
--     "pysan3/pathlib.nvim",
--     "nvim-neotest/nvim-nio",
-- { "luarocks.nvim" }, 
--   },
--   config = function()
-- 
--     -- FIX: Native fallback patch for older Neorg date parsing scripts
--     unpack = unpack or table.unpack 
-- 
--     require("neorg").setup({
--       load = {
--         ["core.defaults"] = {},      -- Automatically grabs your global maplocalleader
--         ["core.tempus"] = {},        -- Explicitly ensure the date engine is loaded
--         ["core.esupports.metagen"] = {}, -- Enables automatic metadata generation
--         ["core.esupports.hop"] = {},     -- Crucial: Handles the link-following (Enter key) execution
--         ["core.concealer"] = {},     -- Toggles icons and formatted elements
--         
--         -- Forces Neorg to manage and track its own parsers separate from nvim-treesitter
--         ["core.integrations.treesitter"] = {}, 
-- 
--         ["core.dirman"] = {
--           config = {
--             workspaces = {
--               conlang = "~/Notes/conlang",
--               notes = "~/Notes/notes",
--             },
--             default_workspace = "notes",
--           },
--         },
--       },
--     })
--   end,
-- 
-- },








-- Using lazy.nvim
{
  'ribru17/bamboo.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('bamboo').setup {
      -- optional configuration here
    }
    require('bamboo').load()
  end,
},

    { 'ThorstenRhau/token' },

  -- 🛠️ Language Server Protocol (LSP) Engine Configuration (Modern v0.11+ API)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- LSP package manager
      { "williamboman/mason.nvim", config = true },
      -- Automatic setup bridge
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local mason_lspconfig = require("mason-lspconfig")

      -- Tell Mason to automatically download Marksman if it is missing
      mason_lspconfig.setup({
        ensure_installed = { "marksman" },
      })

      -- Create standard keybindings when an LSP attaches to a buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(event)
          local bufnr = event.buf
          
          -- Core Navigational Shortcuts
          vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, { desc = "Go to Link/Definition", buffer = bufnr })
          vim.keymap.set("n", "K",  function() vim.lsp.buf.hover() end,      { desc = "Show Information/Hover", buffer = bufnr })
          vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, { desc = "Rename Token/File References", buffer = bufnr })
          vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end,   { desc = "Go to Previous Error/Warning", buffer = bufnr })
          vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end,   { desc = "Go to Next Error/Warning", buffer = bufnr })
        end,
      })

      -- FIXED: Uses the modern native Neovim config framework instead of require('lspconfig')
      if vim.lsp.config then
        vim.lsp.config("marksman", {})
      else
        -- Fallback fallback for older tracking tags if needed
        require("lspconfig").marksman.setup({})
      end
    end,
  },

{
  "gmcusaro/ma.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    { "nvim-tree/nvim-web-devicons", opts = {} },
  },
  opts = {
    vaults = {
      { name = "My Notes", path = "~/Ma-Notes" },
    },
  },
},



--   {
--     "nvim-treesitter/nvim-treesitter",
--     build = ":TSUpdate",
--     config = function()
--       -- FIXED: Changed 'nvim-treesitter.configs' to the new 'nvim-treesitter' path
--       local treesitter = require("nvim-treesitter")
--       
--       treesitter.setup({
--         -- Automatically install missing parsers when opening unsupported file types
--         auto_install = true, 
--         
--         -- Safe baseline of standard parsers
--         ensure_installed = { "lua", "vim", "vimdoc", "markdown", "bash", "norg", "norg_meta" },
--         
--         highlight = {
--           enable = true, -- Turns on the modern color text parsing engine
--           
--           -- Disables Treesitter on massive files to maintain performance
--           disable = function(lang, buf)
--               local max_filesize = 100 * 1024 -- 100 KB
--               local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
--               if ok and stats and stats.size > max_filesize then
--                   return true
--               end
--           end,
--         },
--       })
--     end,
--   },
--
--


        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            config = function()
                -- Execute standard configuration safely across versions
                local status_config, config_mod = pcall(require, "nvim-treesitter.config")
                if not status_config then
                    config_mod = require("nvim-treesitter.configs")
                end

                config_mod.setup({
                    -- Kept only core parsers; norg and norg_meta are completely removed
                    ensure_installed = { "lua", "c", "vim", "vimdoc", "query" },
                    highlight = { enable = true },
                })
            end,
        },


  {
    'nvim-telescope/telescope.nvim', 
    branch = 'master', -- Forces Lazy to grab the active development branch with the fix
    dependencies = { 
      'nvim-lua/plenary.nvim',
      -- Optional but highly recommended: Native FZF sorter for blazing speed
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
    },
    config = function()
      local telescope = require('telescope')
      
      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
            },
          },
          -- Integrated Fail-safe: Prevents Treesitter crashes inside the preview panes
          preview = {
            treesitter = false,
          },
        },
        pickers = {
          find_files = {
            hidden = true, -- Tells fd to find hidden files
          },
          live_grep = {
            additional_args = function(opts)
              return { "--hidden" } -- Tells ripgrep to search inside hidden files
            end,
          },
        },
      })
      -- Load the native FZF sorting extension if it compiled successfully
      pcall(telescope.load_extension, 'fzf')
    end
  },

  { 'glacambre/firenvim', build = ":call firenvim#install(0)" },

  {
    'uloco/bluloco.nvim',
    lazy = false,
    priority = 1000,
    dependencies = { 'rktjmp/lush.nvim' },
    config = function()
      -- Custom Bluloco config handles theme variables down below
      require("bluloco").setup({
        italics = true, 
        rainbow_headings = true,
      }) -- This closing line was missing
    end,
  },

  {
    "junegunn/goyo.vim",
    cmd = "Goyo",
    dependencies = { "junegunn/limelight.vim" },
    keys = {
      -- Press <leader>g to toggle distraction-free mode on/off
      { "<leader>g", "<cmd>Goyo<cr>", desc = "Toggle Goyo + Limelight" },
    },
    config = function()
      -- Dynamically match Limelight to your dark theme color
      vim.g.limelight_paragraph_hl = "Normal"
      
      -- Adjust dimming intensity (0.0 to 1.0)
      vim.g.limelight_default_coefficient = 0.6

      -- Setup Goyo Automation Group for both Limelight and Prose hooks
      local goyo_prose_group = vim.api.nvim_create_augroup("GoyoProseIntegration", { clear = true })

      -- Link Goyo and Limelight events + Prose optimizations
      vim.api.nvim_create_autocmd("User", {
        group = goyo_prose_group,
        pattern = "GoyoEnter",
        callback = function()
          vim.cmd("Limelight")
          
          -- ✍️ Prose Quality of Life ON
          vim.opt_local.wrap = true             -- Soft wrap long lines
          vim.opt_local.linebreak = true        -- Breaks lines at spaces instead of mid-word
          vim.opt_local.spell = false           -- Turn off spellcheck
          vim.opt_local.scrolloff = 999         -- Center cursor vertically (Typewriter mode)
          vim.opt_local.number = false          -- Hide line numbers
          vim.opt_local.relativenumber = false  -- Hide relative line numbers
          
          -- Text formatting constraints
          vim.opt_local.textwidth = 70          -- Hard-wrap text at 70 characters
          vim.opt_local.formatoptions:append("a") -- Auto-reformats the paragraph as you type
          vim.opt_local.formatoptions:append("n") -- Recognizes numbered lists and indents them
          vim.opt_local.formatoptions:append("t") -- Auto-wrap text using textwidth

          -- Visual navigation for wrapped text
          vim.keymap.set('n', 'j', 'gj', { buffer = true })
          vim.keymap.set('n', 'k', 'gk', { buffer = true })
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        group = goyo_prose_group,
        pattern = "GoyoLeave",
        callback = function()
          vim.cmd("Limelight!")
          
          -- 💻 Coding Settings (Restore System Defaults)
          vim.opt_local.wrap = true             -- Restores your default base wrap behavior
          vim.opt_local.linebreak = false       -- Turn off line breaking logic
          vim.opt_local.spell = false           -- Turn off spell check
          vim.opt_local.scrolloff = 8           -- Restore normal scrolling margins
          vim.opt_local.number = true           -- Bring line numbers back
          vim.opt_local.relativenumber = false  -- Restore your base relative preference
          
          -- Restore coding width standards
          vim.opt_local.textwidth = 0           
          vim.opt_local.formatoptions:remove("a")
          vim.opt_local.formatoptions:remove("n")
          vim.opt_local.formatoptions:remove("t")
        end,
      })
    end,
  },

{
    "github-main-user/lytmode.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        require('lytmode').setup()
    end
},

  {
    "eldritch-theme/eldritch.nvim",
    lazy = false,
    priority = 1000,
    opts = { italics = true },
  },

-- },
    -- Configure lazy to talk directly to your system's luarocks
    rocks = {
        enabled = true,
        hererocks = false, -- Disables the buggy sandboxed compilation step
    },


})
 

  -- ==========================================================================
-- 3. BASIC CODING SYSTEM OPTIONS
-- ==========================================================================
vim.opt.number = true             -- Show line numbers
vim.opt.relativenumber = false    -- Relative line numbers for easier jumping
vim.opt.mouse = 'a'               -- Enable mouse support
vim.opt.ignorecase = true         -- Case-insensitive search
vim.opt.smartcase = true          -- Case-sensitive if search contains uppercase
vim.opt.hlsearch = false          -- Clear highlights after search
vim.opt.wrap = true               -- Your custom choice to handle files
vim.opt.tabstop = 3               -- 4 spaces per tab
vim.opt.shiftwidth = 3            -- 4 spaces for indentation
vim.opt.expandtab = true          -- Use spaces instead of tabs
vim.opt.termguicolors = true      -- Better color support for Ghostty

-- CLIPBOARD FIX
vim.opt.clipboard = "unnamedplus" -- Synchronize Neovim's clipboard with your system clipboard

-- ==========================================================================
-- 4. KEYMAPS & ENVIRONMENT OVERRIDES
-- ==========================================================================

local set = vim.keymap.set

-- Open fff on press of 'f'
-- nnoremap f :F<CR>
set('n', 'f', ':F<CR>', { silent = true })

-- Map Ctrl + h/j/k/l to move between split windows directly
set('n', '<C-h>', '<C-w>h') -- Move left
set('n', '<C-j>', '<C-w>j') -- Move down
set('n', '<C-k>', '<C-w>k') -- Move up
set('n', '<C-l>', '<C-w>l') -- Move right

-- Resize splits with Ctrl + Arrows
set('n', '<C-Up>', ':resize +2<CR>', { silent = true })
set('n', '<C-Down>', ':resize -2<CR>', { silent = true })
set('n', '<C-Left>', ':vertical resize -2<CR>', { silent = true })
set('n', '<C-Right>', ':vertical resize +2<CR>', { silent = true })

-- Quick Split creation
set('n', '<leader>v', ':vsplit<CR>', { silent = true }) -- Vertical split
set('n', '<leader>s', ':split<CR>', { silent = true })  -- Horizontal split

-- Open init.lua instantly from anywhere with Space + e + v
set('n', '<leader>ev', '<cmd>edit $MYVIMRC<cr>', { desc = 'Open init.lua configuration' })

-- Open the big Ma window
set('n', '<leader>M', '<cmd>Ma<cr>', { desc = "Open Ma notes main window" })

-- Open todays Ma daily note
set('n', '<leader>md', '<cmd>Ma daily<cr>', { desc = "OPen todays Ma daily note" })

-- Create new Ma note
set('n', '<leader>mc', '<cmd>Ma create<cr>', { desc = "Create new Ma note" })

-- Rename Ma note
set('n', '<leader>mr', '<cmd>Ma rename<cr>', { desc = "Rename Ma note" })

-- term related keymaps
set('n', '<leader>T', '<cmd>vsplit term://fish<cr>', { desc = "Open fish shell in Vsplit"})

-- tab related keymaps
set('n', '<leader>tn', '<cmd>tabnew<cr>', { desc = "Open new tab"})
set('n', '<leader>tN', '<cmd>tabNext<cr>', { desc = "Go to next tab"})
set('n', '<leader>tc', '<cmd>tabclose<cr>', { desc = "Close current tab"})

-- show time
set("n", "<leader>tt", function() print(os.date("%I:%M %p")) end, { desc = "Show current time" })

-- show weather
set ("n", "<leader>wn", "<cmd>WeatherNow<cr>", {desc = "Show WeatherNow"})



-- Press 'space' then 'b' to instantly backup the current text file to GitHub
vim.keymap.set("n", "<leader>mb", ":w | Git add % | Git commit -m 'Manual Note Backup' | Git push<CR>", { silent = true })
-- ==========================================================================
-- TELESCOPE KEYMAPS
-- ==========================================================================
local builtin = require('telescope.builtin')

set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope Find Files' })
set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope Live Grep (Search text)' })
set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope Open Buffers' })
set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope Help Tags' })
set('n', '<leader>fr', builtin.oldfiles, { desc = 'Telescope Recent Files' })

-- Bluloco Color Theme Setup
require("bluloco").setup({
  style = "dark",               
  transparent = false,
  italics = true,
  terminal = vim.fn.has("gui_running") == 1, 
  guicursor = true,
  rainbow_headings = true,     
  float_window = "default" 
})

vim.opt.termguicolors = true 
-- vim.cmd[[colorscheme nightcity-kabuki]]
-- vim.cmd[[colorscheme flow]]
-- vim.cmd[[colorscheme space_vim_theme]]
-- vim.cmd[[colorscheme carbonized-dark]]
-- vim.cmd[[colorscheme bamboo]]
vim.cmd[[colorscheme bluloco]]


-- Create a clean, error-free text replacer for IPA symbols
local ipa_targets = {
  [";I"] = "ɪ",
  [";eps"] = "ε",
  [";sch"] = "ə",
  [";ng"] = "ŋ",
  [";awe"] = "ɒ",
  [";U"] = "ʊ",
  [";uh"] = "ʌ",
}

vim.api.nvim_create_autocmd("TextChangedI", {
  pattern = "*",
  callback = function()
    local line_num = vim.api.nvim_win_get_cursor(0)[1]
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    
    -- Check the text directly behind your cursor
    for shortcut, unicode_char in pairs(ipa_targets) do
      local len = #shortcut
      if col >= len then
        local sub = string.sub(line, col - len + 1, col)
        if sub == shortcut then
          -- Replace the shortcut with the actual unicode character
          local new_line = string.sub(line, 1, col - len) .. unicode_char .. string.sub(line, col + 1)
          vim.api.nvim_set_current_line(new_line)
          -- Move cursor back to the correct spot
          vim.api.nvim_win_set_cursor(0, {line_num, col - len + #unicode_char})
          break
        end
      end
    end
  end,
})


-- vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
--     pattern = "*.norg",
--     callback = function()
--         vim.wo.conceallevel = 2   -- Erases the technical link syntax brackets
--         vim.wo.concealcursor = "nc" -- Keeps it hidden unless you are in Insert mode on top of it
--     end
-- })
--
--

vim.api.nvim_create_autocmd("FileType", {
    pattern = "norg",
    callback = function()
        -- Forcibly binds gO to Neorg's Table of Contents locally inside this file buffer
        vim.keymap.set("n", "gO", "<cmd>Neorg toc<CR>", { 
            buffer = true, 
            silent = true, 
            desc = "Neorg Table of Contents" 
        })
    end,
})


vim.api.nvim_create_autocmd({ "BufWinEnter", "BufEnter" }, {
    pattern = "*",
    callback = function()
        -- 1. Get the current buffer name and filetype
        local buf_name = vim.api.nvim_buf_get_name(0)
        local filetype = vim.bo.filetype

        -- 2. Intercept if it's a standard Norg file OR the floating/split TOC window
        if filetype == "norg" or buf_name:find("Table of Contents") or buf_name:find("neorg://") then
            vim.wo.conceallevel = 2      -- Forces markdown wrappers and anchors to hide cleanly
            vim.wo.concealcursor = "nc"  -- Keeps text concealed unless you go into Insert mode
        end
    end,
})


