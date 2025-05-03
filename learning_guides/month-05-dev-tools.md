# Month 5: Programming Languages and Development Tools

This month focuses on setting up professional development environments for programming languages (Python, JavaScript, and Ruby) and configuring Neovim as a powerful, customized IDE. You'll create language-specific workflows optimized for Linux.

## Time Commitment: ~10 hours/week for 4 weeks

## Learning Objectives

By the end of this month, you should be able to:

1. Configure Neovim as a full-featured development environment
2. Set up language-specific development tools and workflows
3. Implement language servers, debugging, and testing frameworks
4. Understand version control workflows with Git
5. Set up efficient project navigation and code search
6. Create a consistent development experience across projects

## Week 1: Neovim Configuration for Development

### Core Learning Activities

1. **Neovim Fundamentals** (2 hours)
   - Understand Neovim's architecture
   - Learn about Lua configuration
   - Set up basic editing preferences
   - Configure essential keybindings
   - Study Neovim's plugin architecture
   - Understand the differences between Vim and Neovim
   - Learn about Neovim's lua API

2. **Plugin Management** (2 hours)
   - Set up a plugin manager (packer.nvim, lazy.nvim)
   - Understand plugin dependencies
   - Install and configure core plugins
   - Learn to troubleshoot plugin issues
   - Study lazy-loading techniques
   - Configure plugin auto-installation
   - Learn to update and maintain plugins

3. **LSP Configuration** (3 hours)
   - Set up nvim-lspconfig
   - Configure language servers
   - Implement code completion with nvim-cmp
   - Set up linting and formatting
   - Configure diagnostics display
   - Learn about LSP capabilities and limitations
   - Implement signature help and hover documentation

4. **Navigation and Search** (3 hours)
   - Configure telescope.nvim for fuzzy finding
   - Set up file browsing with nvim-tree or similar
   - Implement symbol and reference navigation
   - Configure buffer and tab management
   - Set up efficient code navigation keybindings
   - Implement workspace symbol search
   - Configure search results preview

### Practical Exercises

#### Installing Neovim and Setting Up Basic Configuration

1. Install Neovim:

```bash
sudo pacman -S neovim python-pynvim
```

2. Create basic configuration structure:

```bash
mkdir -p ~/.config/nvim/{lua,plugin,after}
touch ~/.config/nvim/init.lua
```

3. Create a minimal init.lua:

```bash
nano ~/.config/nvim/init.lua
```

Add content:
```lua
-- Basic settings
vim.opt.number = true               -- Show line numbers
vim.opt.relativenumber = true       -- Show relative line numbers
vim.opt.mouse = 'a'                 -- Enable mouse support
vim.opt.ignorecase = true           -- Case insensitive search
vim.opt.smartcase = true            -- Case sensitive when using uppercase
vim.opt.wrap = false                -- Don't wrap lines
vim.opt.tabstop = 4                 -- Tab width
vim.opt.softtabstop = 4             -- Soft tab width
vim.opt.shiftwidth = 4              -- Indent width
vim.opt.expandtab = true            -- Use spaces instead of tabs
vim.opt.clipboard = 'unnamedplus'   -- Use system clipboard
vim.opt.swapfile = false            -- Don't use swap files
vim.opt.backup = false              -- Don't create backups
vim.opt.undofile = true             -- Use undo files
vim.opt.undodir = vim.fn.stdpath('config') .. '/undodir'
vim.opt.hlsearch = true             -- Highlight search results
vim.opt.incsearch = true            -- Show search results while typing
vim.opt.termguicolors = true        -- True color support
vim.opt.scrolloff = 8               -- Keep 8 lines above/below cursor
vim.opt.signcolumn = 'yes'          -- Always show sign column
vim.opt.updatetime = 300            -- Faster update time
vim.opt.timeoutlen = 500            -- Faster timeout
vim.opt.completeopt = 'menuone,noselect'  -- Better completion
vim.opt.cursorline = true           -- Highlight current line

-- Create a directory for undo history
local undodir = vim.fn.stdpath('config') .. '/undodir'
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, 'p')
end

-- Basic keymappings
vim.g.mapleader = ' '  -- Set leader key to space

-- Key mappings
local keymap = vim.keymap

-- Normal mode keymaps
keymap.set('n', '<leader>w', ':w<CR>', { noremap = true, desc = 'Save file' })
keymap.set('n', '<leader>q', ':q<CR>', { noremap = true, desc = 'Quit' })
keymap.set('n', '<leader>e', ':Explore<CR>', { noremap = true, desc = 'Explore files' })
keymap.set('n', '<C-h>', '<C-w>h', { noremap = true, desc = 'Move to left split' })
keymap.set('n', '<C-j>', '<C-w>j', { noremap = true, desc = 'Move to below split' })
keymap.set('n', '<C-k>', '<C-w>k', { noremap = true, desc = 'Move to above split' })
keymap.set('n', '<C-l>', '<C-w>l', { noremap = true, desc = 'Move to right split' })
keymap.set('n', '<leader>h', ':nohlsearch<CR>', { noremap = true, desc = 'Clear search highlight' })

-- Require the plugins module if it exists
local plugins_path = vim.fn.stdpath('config') .. '/lua/plugins.lua'
if vim.fn.filereadable(plugins_path) == 1 then
    require('plugins')
end
```

#### Setting Up Plugin Management with Packer

1. Install Packer.nvim:

```bash
git clone --depth 1 https://github.com/wbthomason/packer.nvim \
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

2. Create a plugins configuration file:

```bash
mkdir -p ~/.config/nvim/lua
nano ~/.config/nvim/lua/plugins.lua
```

Add content:
```lua
-- Plugin configuration
return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'
    
    -- Theme
    use 'folke/tokyonight.nvim'
    
    -- Status line
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }
    
    -- File explorer
    use {
        'kyazdani42/nvim-tree.lua',
        requires = { 'kyazdani42/nvim-web-devicons' }
    }
    
    -- Fuzzy finder
    use {
        'nvim-telescope/telescope.nvim',
        requires = { 'nvim-lua/plenary.nvim' }
    }
    
    -- Better syntax highlighting
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }
    
    -- LSP support
    use 'neovim/nvim-lspconfig'
    
    -- Autocomplete
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'
    
    -- Snippets
    use 'L3MON4D3/LuaSnip'
    use 'saadparwaiz1/cmp_luasnip'
    
    -- Git integration
    use 'lewis6991/gitsigns.nvim'
    
    -- Commenting
    use 'numToStr/Comment.nvim'
    
    -- Auto pairs
    use 'windwp/nvim-autopairs'
    
    -- Indentation guides
    use 'lukas-reineke/indent-blankline.nvim'
    
    -- Terminal
    use 'akinsho/toggleterm.nvim'
    
    -- Which key
    use 'folke/which-key.nvim'
end)
```

3. Create plugin configurations:

```bash
mkdir -p ~/.config/nvim/after/plugin
```

4. Configure the theme:

```bash
nano ~/.config/nvim/after/plugin/theme.lua
```

Add content:
```lua
-- Theme configuration
vim.cmd[[colorscheme tokyonight]]
```

5. Configure Telescope:

```bash
nano ~/.config/nvim/after/plugin/telescope.lua
```

Add content:
```lua
-- Telescope setup
local status_ok, telescope = pcall(require, 'telescope')
if not status_ok then
    return
end

telescope.setup {
    defaults = {
        file_ignore_patterns = { "node_modules", ".git" },
        prompt_prefix = " ",
        selection_caret = " ",
        path_display = { "smart" },
        dynamic_preview_title = true,
    }
}

-- Keymaps
local keymap = vim.keymap
keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = 'Find files' })
keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = 'Find text' })
keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = 'Find buffers' })
keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = 'Find help' })
keymap.set('n', '<leader>fr', '<cmd>Telescope oldfiles<cr>', { desc = 'Find recent files' })
keymap.set('n', '<leader>fs', '<cmd>Telescope grep_string<cr>', { desc = 'Find current word' })
```

6. Configure Treesitter:

```bash
nano ~/.config/nvim/after/plugin/treesitter.lua
```

Add content:
```lua
-- Treesitter setup
local status_ok, treesitter = pcall(require, 'nvim-treesitter.configs')
if not status_ok then
    return
end

treesitter.setup {
    ensure_installed = {
        "lua",
        "vim",
        "python",
        "javascript",
        "typescript",
        "html",
        "css",
        "json",
        "markdown",
        "bash",
        "ruby"
    },
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },
}
```

#### Setting Up LSP and Autocompletion

1. Configure LSP:

```bash
nano ~/.config/nvim/after/plugin/lsp.lua
```

Add content:
```lua
-- LSP setup
local lspconfig_status, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status then
    return
end

local cmp_status, cmp = pcall(require, "cmp")
if not cmp_status then
    return
end

local cmp_lsp_status, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if not cmp_lsp_status then
    return
end

local luasnip_status, luasnip = pcall(require, "luasnip")
if not luasnip_status then
    return
end

-- Set up keybindings for LSP
local on_attach = function(client, bufnr)
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    
    -- Mappings
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

-- nvim-cmp completion capabilities
local capabilities = cmp_lsp.default_capabilities()

-- Configure nvim-cmp
cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
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
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    }, {
        { name = 'buffer' },
        { name = 'path' },
    })
})

-- Set up cmdline completion
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})

-- Setup language servers
-- Python
lspconfig.pyright.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        python = {
            analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true
            }
        }
    }
}

-- JavaScript/TypeScript
lspconfig.tsserver.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
}

-- Ruby
lspconfig.solargraph.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}

-- Lua
lspconfig.lua_ls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' },
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
            },
            telemetry = {
                enable = false,
            },
        },
    },
}
```

2. Configure nvim-tree:

```bash
nano ~/.config/nvim/after/plugin/nvimtree.lua
```

Add content:
```lua
-- NvimTree setup
local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
    return
end

nvim_tree.setup {
    git = {
        enable = true,
        ignore = false,
    },
    view = {
        width = 30,
        side = "left",
    },
    renderer = {
        highlight_git = true,
        icons = {
            show = {
                git = true,
                folder = true,
                file = true,
            },
        },
    },
    filters = {
        dotfiles = false,
    },
}

-- Keymaps
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true, desc = 'Toggle file explorer' })
```

3. Install LSP servers:

```bash
# For Python
sudo pacman -S python-lsp-server python-pyflakes python-pycodestyle python-pylint python-rope python-jedi python-black

# For JavaScript/TypeScript
sudo npm install -g typescript typescript-language-server eslint prettier

# For Ruby
gem install solargraph

# For Lua (requires a more complex setup)
sudo pacman -S luarocks
luarocks install --server=https://luarocks.org/dev luaformatter
```

4. Configure git integration:

```bash
nano ~/.config/nvim/after/plugin/gitsigns.lua
```

Add content:
```lua
-- Gitsigns setup
local status_ok, gitsigns = pcall(require, "gitsigns")
if not status_ok then
    return
end

gitsigns.setup {
    signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
    },
    signcolumn = true,
    numhl = false,
    linehl = false,
    word_diff = false,
    watch_gitdir = {
        interval = 1000,
        follow_files = true,
    },
    attach_to_untracked = true,
    current_line_blame = true,
    current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 1000,
    },
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil,
    preview_config = {
        border = "single",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
    },
}

-- Keymaps
vim.keymap.set('n', '<leader>gb', ':Gitsigns blame_line<CR>', { noremap = true, silent = true, desc = 'Git blame line' })
vim.keymap.set('n', '<leader>gd', ':Gitsigns diffthis<CR>', { noremap = true, silent = true, desc = 'Git diff' })
vim.keymap.set('n', '<leader>gp', ':Gitsigns preview_hunk<CR>', { noremap = true, silent = true, desc = 'Git preview hunk' })
vim.keymap.set('n', '<leader>gr', ':Gitsigns reset_hunk<CR>', { noremap = true, silent = true, desc = 'Git reset hunk' })
vim.keymap.set('n', ']g', ':Gitsigns next_hunk<CR>', { noremap = true, silent = true, desc = 'Next git hunk' })
vim.keymap.set('n', '[g', ':Gitsigns prev_hunk<CR>', { noremap = true, silent = true, desc = 'Previous git hunk' })
```

5. Configure Which Key:

```bash
nano ~/.config/nvim/after/plugin/whichkey.lua
```

Add content:
```lua
-- Which Key setup
local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
    return
end

which_key.setup {
    plugins = {
        marks = true,
        registers = true,
        spelling = {
            enabled = false,
            suggestions = 20,
        },
        presets = {
            operators = true,
            motions = true,
            text_objects = true,
            windows = true,
            nav = true,
            z = true,
            g = true,
        },
    },
    window = {
        border = "single",
        position = "bottom",
        margin = { 1, 0, 1, 0 },
        padding = { 1, 1, 1, 1 },
    },
    layout = {
        height = { min = 4, max = 25 },
        width = { min = 20, max = 50 },
        spacing = 3,
        align = "center",
    },
    ignore_missing = false,
    hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " },
    show_help = true,
    triggers = "auto",
}

-- Register key groups
which_key.register({
    ["<leader>f"] = { name = "Find" },
    ["<leader>g"] = { name = "Git" },
    ["<leader>l"] = { name = "LSP" },
    ["<leader>w"] = { name = "Workspace" },
})
```

### Resources

- [Neovim Documentation](https://neovim.io/doc/)
- [From init.vim to init.lua](https://teukka.tech/luanvim.html)
- [LSP Configuration Guide](https://github.com/neovim/nvim-lspconfig)
- [Awesome Neovim](https://github.com/rockerBOO/awesome-neovim)
- [Lua Guide for Neovim](https://github.com/nanotee/nvim-lua-guide)
- [NvChad](https://github.com/NvChad/NvChad) - A Neovim config example
- [LunarVim](https://github.com/LunarVim/LunarVim) - Another Neovim distribution

## Week 2: Python Development Environment

### Core Learning Activities

1. **Python Installation and Management** (2 hours)
   - Set up pyenv for multiple Python versions
   - Configure virtual environments
   - Understand Python packaging
   - Install development tools (pip, poetry)
   - Learn about Python module paths
   - Configure Python environment variables
   - Set up Python version switching

2. **Python Language Server Configuration** (2 hours)
   - Set up pyright or python-lsp-server
   - Configure completion and type checking
   - Implement docstring support
   - Set up import sorting and formatting
   - Configure linting tools (pylint, flake8)
   - Set up static type checking with mypy
   - Implement autoformatting with black

3. **Testing and Debugging** (3 hours)
   - Configure pytest integration
   - Set up debugging with nvim-dap
   - Learn to use breakpoints effectively
   - Set up test running from Neovim
   - Configure code coverage tools
   - Implement test discovery and navigation
   - Set up mocking and fixtures

4. **Python Project Structure** (3 hours)
   - Learn best practices for Python projects
   - Set up project templates
   - Configure dependency management
   - Implement documentation tools
   - Configure packaging and distribution
   - Set up CI/CD for Python projects
   - Implement virtual environments for isolation

### Practical Exercises

#### Setting Up Python Environment Management

1. Install pyenv for managing Python versions:

```bash
# Install dependencies
sudo pacman -S base-devel openssl zlib xz curl

# Install pyenv
curl https://pyenv.run | bash
```

2. Add pyenv to your shell configuration (~/.zshrc):

```bash
# pyenv setup
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
```

3. Reload shell configuration:

```bash
source ~/.zshrc
```

4. Install Python versions:

```bash
# List available versions
pyenv install --list

# Install specific versions
pyenv install 3.10.0
pyenv install 3.11.0

# Set global version
pyenv global 3.11.0

# Verify installation
python --version
```

5. Install Poetry for dependency management:

```bash
curl -sSL https://install.python-poetry.org | python3 -
```

6. Add Poetry to your PATH in ~/.zshrc:

```bash
# Poetry setup
export PATH="$HOME/.local/bin:$PATH"
```

7. Configure Poetry:

```bash
# Configure poetry to create virtual environments inside projects
poetry config virtualenvs.in-project true
```

#### Creating a Python Project with Poetry

1. Initialize a new Python project:

```bash
# Create a new directory
mkdir -p ~/projects/python-demo
cd ~/projects/python-demo

# Initialize poetry project
poetry init

# Follow the interactive prompts to set up your project
```

2. Add development dependencies:

```bash
poetry add --dev pytest black isort mypy pylint pytest-cov
```

3. Create a basic project structure:

```bash
mkdir -p python_demo/tests
touch python_demo/__init__.py
touch python_demo/__main__.py
touch tests/__init__.py
```

4. Create a simple Python module:

```bash
nano python_demo/__main__.py
```

Add content:
```python
"""Main module for the python-demo package."""

def greet(name: str) -> str:
    """Return a greeting for the given name.
    
    Args:
        name: The name to greet
        
    Returns:
        A greeting string
    """
    return f"Hello, {name}!"

def main() -> None:
    """Run the main program."""
    print(greet("World"))

if __name__ == "__main__":
    main()
```

5. Create a test file:

```bash
nano tests/test_main.py
```

Add content:
```python
"""Tests for the main module."""

from python_demo.__main__ import greet

def test_greet():
    """Test the greet function."""
    assert greet("World") == "Hello, World!"
    assert greet("Python") == "Hello, Python!"
```

6. Run the tests:

```bash
poetry run pytest
```

7. Create configuration files for code quality tools:

```bash
# Create pyproject.toml configurations
nano pyproject.toml
```

Add to the existing file:
```toml
[tool.black]
line-length = 88
target-version = ["py310"]
include = '\.pyi?

[tool.isort]
profile = "black"
multi_line_output = 3

[tool.mypy]
python_version = "3.10"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true

[tool.pylint.messages_control]
disable = [
    "missing-module-docstring",
    "missing-class-docstring",
    "missing-function-docstring",
]

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = "test_*.py"
python_functions = "test_*"
python_classes = "Test*"
```

#### Setting Up Python Debugging in Neovim

1. Install DAP (Debug Adapter Protocol) for Neovim:

```bash
# Create nvim-dap configuration
nano ~/.config/nvim/after/plugin/dap.lua
```

Add content:
```lua
-- nvim-dap setup
local dap_status_ok, dap = pcall(require, "dap")
if not dap_status_ok then
    return
end

-- Python configuration
dap.adapters.python = {
    type = "executable",
    command = "python",
    args = { "-m", "debugpy.adapter" },
}

dap.configurations.python = {
    {
        type = "python",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        pythonPath = function()
            -- Use poetry or virtualenv python if available
            local venv_path = os.getenv("VIRTUAL_ENV")
            if venv_path then
                return venv_path .. "/bin/python"
            end
            
            -- Check if we're in a Poetry project
            local poetry_venv = vim.fn.getcwd() .. "/.venv/bin/python"
            if vim.fn.filereadable(poetry_venv) == 1 then
                return poetry_venv
            end
            
            -- Fall back to system Python
            return "python"
        end,
    },
    {
        type = "python",
        request = "launch",
        name = "Launch with arguments",
        program = "${file}",
        args = function()
            local args_string = vim.fn.input("Arguments: ")
            return vim.split(args_string, " ")
        end,
        pythonPath = function()
            -- Same as above
            local venv_path = os.getenv("VIRTUAL_ENV")
            if venv_path then
                return venv_path .. "/bin/python"
            end
            
            local poetry_venv = vim.fn.getcwd() .. "/.venv/bin/python"
            if vim.fn.filereadable(poetry_venv) == 1 then
                return poetry_venv
            end
            
            return "python"
        end,
    },
}

-- Install Python debug adapter if not installed
local function ensure_debugpy()
    local install_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy"
    if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
        vim.fn.system({ "pip", "install", "debugpy" })
    end
end

ensure_debugpy()

-- Keybindings
vim.keymap.set('n', '<leader>db', function() dap.toggle_breakpoint() end, { desc = 'Toggle breakpoint' })
vim.keymap.set('n', '<leader>dc', function() dap.continue() end, { desc = 'Continue' })
vim.keymap.set('n', '<leader>do', function() dap.step_over() end, { desc = 'Step over' })
vim.keymap.set('n', '<leader>di', function() dap.step_into() end, { desc = 'Step into' })
vim.keymap.set('n', '<leader>dr', function() dap.repl.open() end, { desc = 'Open REPL' })
```

2. Install the required packages:

```bash
pip install debugpy
```

3. Install plugins for DAP UI:

Add to your plugins.lua file:
```lua
use { 'mfussenegger/nvim-dap' }
use { 'rcarriga/nvim-dap-ui' }
use { 'mfussenegger/nvim-dap-python' }
```

4. Create UI configuration:

```bash
nano ~/.config/nvim/after/plugin/dapui.lua
```

Add content:
```lua
-- DAP UI setup
local dap_status_ok, dap = pcall(require, "dap")
if not dap_status_ok then
    return
end

local dapui_status_ok, dapui = pcall(require, "dapui")
if not dapui_status_ok then
    return
end

dapui.setup {
    icons = { expanded = "▾", collapsed = "▸" },
    mappings = {
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
    },
    expand_lines = true,
    layouts = {
        {
            elements = {
                "scopes",
                "breakpoints",
                "stacks",
                "watches",
            },
            size = 40,
            position = "left",
        },
        {
            elements = {
                "repl",
                "console",
            },
            size = 10,
            position = "bottom",
        },
    },
    floating = {
        max_height = nil,
        max_width = nil,
        border = "single",
        mappings = {
            close = { "q", "<Esc>" },
        },
    },
    windows = { indent = 1 },
    render = { 
        max_type_length = nil,
    }
}

-- Automatically open and close the DAP UI
dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end

-- Keybindings
vim.keymap.set('n', '<leader>du', function() dapui.toggle() end, { desc = 'Toggle DAP UI' })
```

5. Run the Neovim plugin installation:

```bash
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
```

### Resources

- [Python Guide for Neovim](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#pyright)
- [Python Development Environment](https://realpython.com/python-development-environment-101/)
- [Debugging Python with nvim-dap](https://github.com/mfussenegger/nvim-dap-python)
- [Python Project Structure Guide](https://docs.python-guide.org/writing/structure/)
- [Poetry Documentation](https://python-poetry.org/docs/)
- [Pyenv Guide](https://github.com/pyenv/pyenv#getting-pyenv)
- [Python Testing with Pytest](https://realpython.com/pytest-python-testing/)
- [Python Type Checking with Mypy](https://mypy.readthedocs.io/en/stable/)

## Week 3: JavaScript/TypeScript Development Environment

### Core Learning Activities

1. **Node.js and JavaScript Setup** (2 hours)
   - Configure nvm for Node.js version management
   - Set up npm/yarn/pnpm configuration
   - Install essential development tools
   - Configure .npmrc for Linux
   - Set up JavaScript module resolution
   - Configure package management strategies
   - Learn about Node.js event loop and debugging

2. **JavaScript/TypeScript LSP** (2 hours)
   - Set up tsserver language server
   - Configure ESLint and Prettier integration
   - Implement TypeScript support
   - Set up JSX/TSX support
   - Configure automatic imports
   - Set up code organization tools
   - Implement refactoring capabilities

3. **Web Development Workflow** (3 hours)
   - Configure browser integration
   - Set up live reloading
   - Implement API testing tools
   - Configure frontend frameworks
   - Set up bundlers and build tools
   - Configure hot module replacement
   - Implement JavaScript debugging

4. **JavaScript Testing and Debugging** (3 hours)
   - Set up Jest integration
   - Configure Chrome debugger
   - Implement console.log enhancement
   - Set up React DevTools
   - Configure test runners
   - Implement test coverage reporting
   - Set up continuous testing

### Practical Exercises

#### Setting Up Node.js with NVM

1. Install NVM (Node Version Manager):

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
```

2. Add NVM to your shell configuration (~/.zshrc):

```bash
# NVM configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
```

3. Reload shell configuration:

```bash
source ~/.zshrc
```

4. Install Node.js versions:

```bash
# Install LTS version
nvm install --lts

# Install specific version
nvm install 16

# Set default version
nvm alias default 16

# Verify installation
node --version
npm --version
```

5. Configure npm:

```bash
# Create npm configuration
nano ~/.npmrc
```

Add content:
```
prefix=${HOME}/.npm-packages
```

6. Install Yarn (optional):

```bash
npm install --global yarn
```

#### Creating a TypeScript Project

1. Create a new TypeScript project:

```bash
# Create directory
mkdir -p ~/projects/typescript-demo
cd ~/projects/typescript-demo

# Initialize npm project
npm init -y

# Install TypeScript and related tools
npm install --save-dev typescript ts-node @types/node eslint prettier eslint-config-prettier eslint-plugin-prettier
```

2. Create TypeScript configuration:

```bash
npx tsc --init
```

3. Modify tsconfig.json:

```bash
nano tsconfig.json
```

Update with:
```json
{
  "compilerOptions": {
    "target": "es2022",
    "module": "commonjs",
    "lib": ["es2022", "dom"],
    "allowJs": true,
    "outDir": "dist",
    "rootDir": "src",
    "strict": true,
    "noImplicitAny": true,
    "esModuleInterop": true,
    "resolveJsonModule": true,
    "sourceMap": true,
    "declaration": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

4. Create ESLint configuration:

```bash
nano .eslintrc.js
```

Add content:
```javascript
module.exports = {
  parser: '@typescript-eslint/parser',
  extends: [
    'plugin:@typescript-eslint/recommended',
    'prettier',
    'plugin:prettier/recommended',
  ],
  parserOptions: {
    ecmaVersion: 2022,
    sourceType: 'module',
  },
  rules: {
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/no-explicit-any': 'off',
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    'prettier/prettier': ['error', { singleQuote: true, semi: true }],
  },
};
```

5. Create Prettier configuration:

```bash
nano .prettierrc
```

Add content:
```json
{
  "semi": true,
  "trailingComma": "all",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2
}
```

6. Set up project structure:

```bash
mkdir -p src
touch src/index.ts
```

7. Create a simple TypeScript file:

```bash
nano src/index.ts
```

Add content:
```typescript
/**
 * Greet a person with a custom message
 * @param name - The person's name
 * @param greeting - The greeting to use (default: "Hello")
 * @returns The full greeting message
 */
export function greet(name: string, greeting: string = "Hello"): string {
  return `${greeting}, ${name}!`;
}

/**
 * Main function to demonstrate the application
 */
function main(): void {
  console.log(greet("TypeScript"));
  console.log(greet("World", "Greetings"));
}

// Run the main function if this file is executed directly
if (require.main === module) {
  main();
}
```

8. Add scripts to package.json:

```bash
nano package.json
```

Add to the "scripts" section:
```json
"scripts": {
  "start": "ts-node src/index.ts",
  "build": "tsc",
  "lint": "eslint src --ext .ts",
  "format": "prettier --write 'src/**/*.ts'",
  "test": "echo \"Error: no test specified\" && exit 1"
}
```

9. Run the TypeScript project:

```bash
npm start
```

#### Setting Up Jest for Testing

1. Install Jest for TypeScript:

```bash
npm install --save-dev jest ts-jest @types/jest
```

2. Create Jest configuration:

```bash
nano jest.config.js
```

Add content:
```javascript
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  testMatch: ['**/__tests__/**/*.ts', '**/?(*.)+(spec|test).ts'],
  transform: {
    '^.+\\.ts: 'ts-jest',
  },
  moduleFileExtensions: ['ts', 'js', 'json', 'node'],
  collectCoverage: true,
  coverageDirectory: 'coverage',
  collectCoverageFrom: ['src/**/*.ts'],
};
```

3. Create a test file:

```bash
mkdir -p src/__tests__
nano src/__tests__/index.test.ts
```

Add content:
```typescript
import { greet } from '../index';

describe('greet function', () => {
  it('should greet with the default greeting', () => {
    expect(greet('TypeScript')).toBe('Hello, TypeScript!');
  });

  it('should greet with a custom greeting', () => {
    expect(greet('World', 'Greetings')).toBe('Greetings, World!');
  });
});
```

4. Update package.json test script:

```json
"scripts": {
  "test": "jest",
  "test:watch": "jest --watch"
}
```

5. Run tests:

```bash
npm test
```

#### Configuring TypeScript in Neovim

1. Install necessary language servers:

```bash
sudo npm install -g typescript typescript-language-server eslint_d prettier
```

2. Ensure LSP is properly configured in Neovim:

Check the LSP configuration in ~/.config/nvim/after/plugin/lsp.lua to ensure TypeScript is configured, as shown in the previous LSP setup.

3. Create a Neovim plugin configuration for JavaScript/TypeScript:

```bash
mkdir -p ~/.config/nvim/ftplugin
nano ~/.config/nvim/ftplugin/typescript.lua
```

Add content:
```lua
-- TypeScript specific settings
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.expandtab = true
vim.opt_local.formatoptions = vim.opt_local.formatoptions - 'o' + 'r'
vim.opt_local.autoindent = true
vim.opt_local.smartindent = true

-- Key mappings specific to TypeScript
vim.keymap.set('n', '<leader>tf', '<cmd>TypescriptFixAll<CR>', { buffer = true, desc = 'Fix all TypeScript errors' })
vim.keymap.set('n', '<leader>to', '<cmd>TypescriptOrganizeImports<CR>', { buffer = true, desc = 'Organize imports' })
vim.keymap.set('n', '<leader>tr', '<cmd>TypescriptRenameFile<CR>', { buffer = true, desc = 'Rename file' })
```

4. Create similar file for JavaScript:

```bash
nano ~/.config/nvim/ftplugin/javascript.lua
```

Add similar content as the TypeScript file.

### Resources

- [JavaScript/TypeScript Configuration Guide](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#tsserver)
- [nvm Documentation](https://github.com/nvm-sh/nvm)
- [Modern JavaScript Development](https://developer.mozilla.org/en-US/docs/Learn/Tools_and_testing/Understanding_client-side_tools/Overview)
- [TypeScript Project References](https://www.typescriptlang.org/docs/handbook/project-references.html)
- [ESLint Configuration](https://eslint.org/docs/user-guide/configuring/)
- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)

## Week 4: Version Control and Workflow Integration

### Core Learning Activities

1. **Advanced Git Configuration** (3 hours)
   - Set up global Git configuration
   - Configure Git hooks
   - Implement commit signing
   - Configure multi-account setup
   - Create useful Git aliases
   - Learn advanced Git commands
   - Configure branch management strategies

2. **Neovim Git Integration** (2 hours)
   - Configure fugitive.vim
   - Set up git signs for line changes
   - Implement diffview.nvim
   - Configure git blame integration
   - Set up merge conflict resolution
   - Create Git workflow commands
   - Implement commit browser

3. **Project-Specific Workflows** (2 hours)
   - Create project-specific settings
   - Implement per-project configuration
   - Set up project templates
   - Configure task automation
   - Implement project-specific commands
   - Set up workspace configurations
   - Create project documentation

4. **Integrated Development Environment** (3 hours)
   - Set up terminal integration in Neovim
   - Configure database clients
   - Implement API tools
   - Set up documentation viewers
   - Configure project-specific terminals
   - Implement build system integration
   - Set up integrated debugging

### Practical Exercises

#### Advanced Git Configuration

1. Configure global Git settings:

```bash
# Set your identity
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set default branch name
git config --global init.defaultBranch main

# Set up helpful defaults
git config --global core.editor "nvim"
git config --global pull.rebase true
git config --global fetch.prune true
git config --global diff.colorMoved default

# Enable auto-correction
git config --global help.autocorrect 20

# Set up commit signing (if you use GPG)
git config --global commit.gpgsign true
git config --global user.signingkey YOUR_GPG_KEY_ID
```

2. Create useful Git aliases:

```bash
# Useful aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'
git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
git config --global alias.please 'push --force-with-lease'
git config --global alias.commend 'commit --amend --no-edit'
git config --global alias.it '!git init && git commit -m "Initial commit" --allow-empty'
```

3. Create global Git hooks directory:

```bash
mkdir -p ~/.git-hooks
git config --global core.hooksPath ~/.git-hooks
```

4. Create a pre-commit hook:

```bash
nano ~/.git-hooks/pre-commit
```

Add content:
```bash
#!/bin/bash
# Pre-commit hook to run checks before allowing commit

# Check for staged changes
if git diff --cached --quiet ; then
    echo "No changes to commit"
    exit 1
fi

# Get list of staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

# Python checks
PYTHON_FILES=$(echo "$STAGED_FILES" | grep '\.py || true)
if [ -n "$PYTHON_FILES" ]; then
    echo "Running Python checks..."
    
    # Check if tools are installed
    command -v black >/dev/null 2>&1 || { echo "black not installed. Skipping Python checks."; }
    command -v flake8 >/dev/null 2>&1 || { echo "flake8 not installed. Skipping Python checks."; }
    
    if command -v black >/dev/null 2>&1 && command -v flake8 >/dev/null 2>&1; then
        echo "$PYTHON_FILES" | xargs black --check
        if [ $? -ne 0 ]; then
            echo "Black check failed. Please format your Python code."
            exit 1
        fi
        
        echo "$PYTHON_FILES" | xargs flake8
        if [ $? -ne 0 ]; then
            echo "Flake8 check failed. Please fix Python code style issues."
            exit 1
        fi
    fi
fi

# JavaScript/TypeScript checks
JS_FILES=$(echo "$STAGED_FILES" | grep -E '\.js$|\.ts$|\.jsx$|\.tsx || true)
if [ -n "$JS_FILES" ]; then
    echo "Running JavaScript/TypeScript checks..."
    
    # Check if tools are installed
    command -v eslint >/dev/null 2>&1 || { echo "eslint not installed. Skipping JS checks."; }
    command -v prettier >/dev/null 2>&1 || { echo "prettier not installed. Skipping JS checks."; }
    
    if command -v eslint >/dev/null 2>&1 && command -v prettier >/dev/null 2>&1; then
        echo "$JS_FILES" | xargs eslint
        if [ $? -ne 0 ]; then
            echo "ESLint check failed. Please fix JavaScript/TypeScript code style issues."
            exit 1
        fi
        
        echo "$JS_FILES" | xargs prettier --check
        if [ $? -ne 0 ]; then
            echo "Prettier check failed. Please format your JavaScript/TypeScript code."
            exit 1
        fi
    fi
fi

# All checks passed
echo "All checks passed! 🎉"
exit 0
```

5. Make the hook executable:

```bash
chmod +x ~/.git-hooks/pre-commit
```

#### Setting Up Git Integration in Neovim

1. Install vim-fugitive and other Git plugins:

Add to your plugins.lua:
```lua
use 'tpope/vim-fugitive'
use 'tpope/vim-rhubarb'  -- GitHub integration
use 'sindrets/diffview.nvim'
```

2. Configure diffview.nvim:

```bash
nano ~/.config/nvim/after/plugin/diffview.lua
```

Add content:
```lua
-- Diffview.nvim setup
local status_ok, diffview = pcall(require, "diffview")
if not status_ok then
    return
end

diffview.setup {
    diff_binaries = false,
    enhanced_diff_hl = true,
    use_icons = true,
    icons = {
        folder_closed = "",
        folder_open = "",
    },
    signs = {
        fold_closed = "",
        fold_open = "",
    },
    view = {
        default = {
            layout = "diff2_horizontal",
            winbar_info = false,
        },
        merge_tool = {
            layout = "diff3_horizontal",
            disable_diagnostics = true,
        },
        file_history = {
            layout = "diff2_horizontal",
        },
    },
    file_panel = {
        listing_style = "tree",
        tree_options = {
            flatten_dirs = true,
            folder_statuses = "only_folded",
        },
        win_config = {
            position = "left",
            width = 35,
        },
    },
    file_history_panel = {
        log_options = {
            git = {
                single_file = {
                    max_count = 256,
                    follow = true,
                },
                multi_file = {
                    max_count = 128,
                },
            },
        },
        win_config = {
            position = "bottom",
            height = 16,
        },
    },
    default_args = {
        DiffviewOpen = {},
        DiffviewFileHistory = {},
    },
    hooks = {},
}

-- Keymaps
vim.keymap.set('n', '<leader>gd', ':DiffviewOpen<CR>', { noremap = true, silent = true, desc = 'Open Diffview' })
vim.keymap.set('n', '<leader>gh', ':DiffviewFileHistory<CR>', { noremap = true, silent = true, desc = 'Open file history' })
vim.keymap.set('n', '<leader>gc', ':DiffviewClose<CR>', { noremap = true, silent = true, desc = 'Close Diffview' })
```

3. Configure fugitive keybindings:

```bash
nano ~/.config/nvim/after/plugin/fugitive.lua
```

Add content:
```lua
-- Fugitive setup
-- Keymaps
vim.keymap.set('n', '<leader>gs', ':Git<CR>', { noremap = true, silent = true, desc = 'Git status' })
vim.keymap.set('n', '<leader>gc', ':Git commit<CR>', { noremap = true, silent = true, desc = 'Git commit' })
vim.keymap.set('n', '<leader>gp', ':Git push<CR>', { noremap = true, silent = true, desc = 'Git push' })
vim.keymap.set('n', '<leader>gl', ':Git pull<CR>', { noremap = true, silent = true, desc = 'Git pull' })
vim.keymap.set('n', '<leader>gb', ':Git blame<CR>', { noremap = true, silent = true, desc = 'Git blame' })
vim.keymap.set('n', '<leader>gd', ':Gvdiffsplit<CR>', { noremap = true, silent = true, desc = 'Git diff split' })
vim.keymap.set('n', '<leader>gr', ':Gread<CR>', { noremap = true, silent = true, desc = 'Git read (checkout)' })
vim.keymap.set('n', '<leader>gw', ':Gwrite<CR>', { noremap = true, silent = true, desc = 'Git write (add)' })
```

4. Configure Which Key group for Git:

```bash
nano ~/.config/nvim/after/plugin/whichkey.lua
```

Add to the register section:
```lua
which_key.register({
    ["<leader>g"] = {
        name = "Git",
        s = { "<cmd>Git<CR>", "Status" },
        c = { "<cmd>Git commit<CR>", "Commit" },
        p = { "<cmd>Git push<CR>", "Push" },
        l = { "<cmd>Git pull<CR>", "Pull" },
        b = { "<cmd>Git blame<CR>", "Blame" },
        d = { "<cmd>Gvdiffsplit<CR>", "Diff split" },
        r = { "<cmd>Gread<CR>", "Read (checkout)" },
        w = { "<cmd>Gwrite<CR>", "Write (add)" },
        h = { "<cmd>DiffviewFileHistory<CR>", "File history" },
    },
})
```

#### Setting Up Terminal Integration

1. Install toggleterm.nvim:

Add to your plugins.lua:
```lua
use 'akinsho/toggleterm.nvim'
```

2. Configure toggleterm:

```bash
nano ~/.config/nvim/after/plugin/toggleterm.lua
```

Add content:
```lua
-- ToggleTerm setup
local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
    return
end

toggleterm.setup {
    size = 20,
    open_mapping = [[<c-\>]],
    hide_numbers = true,
    shade_filetypes = {},
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = true,
    persist_size = true,
    direction = "float",
    close_on_exit = true,
    shell = vim.o.shell,
    float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
            border = "Normal",
            background = "Normal",
        },
    },
}

-- Terminal utilities
local Terminal = require("toggleterm.terminal").Terminal

-- Create specialized terminals
local lazygit = Terminal:new {
    cmd = "lazygit",
    hidden = true,
    direction = "float",
    float_opts = {
        border = "double",
    },
}

local function _lazygit_toggle()
    lazygit:toggle()
end

local python = Terminal:new {
    cmd = "python",
    hidden = true,
    direction = "horizontal",
}

local function _python_toggle()
    python:toggle()
end

local node = Terminal:new {
    cmd = "node",
    hidden = true,
    direction = "horizontal",
}

local function _node_toggle()
    node:toggle()
end

-- Keymaps
vim.keymap.set('n', '<leader>tg', _lazygit_toggle, { noremap = true, silent = true, desc = 'Toggle LazyGit' })
vim.keymap.set('n', '<leader>tp', _python_toggle, { noremap = true, silent = true, desc = 'Toggle Python REPL' })
vim.keymap.set('n', '<leader>tn', _node_toggle, { noremap = true, silent = true, desc = 'Toggle Node REPL' })
vim.keymap.set('n', '<leader>tt', '<cmd>ToggleTerm<CR>', { noremap = true, silent = true, desc = 'Toggle Terminal' })

-- Configure which-key group
local which_key_ok, which_key = pcall(require, "which-key")
if which_key_ok then
    which_key.register({
        ["<leader>t"] = {
            name = "Terminal",
            t = { "<cmd>ToggleTerm<CR>", "Toggle Terminal" },
            g = { _lazygit_toggle, "LazyGit" },
            p = { _python_toggle, "Python REPL" },
            n = { _node_toggle, "Node REPL" },
        },
    })
end
```

3. Install LazyGit for Git terminal UI:

```bash
# For Arch Linux
sudo pacman -S lazygit
```

#### Creating Project-Specific Settings

1. Install a project-specific configuration plugin:

Add to your plugins.lua:
```lua
use 'klen/nvim-config-local'
```

2. Configure the plugin:

```bash
nano ~/.config/nvim/after/plugin/config-local.lua
```

Add content:
```lua
-- Local config setup
local status_ok, config_local = pcall(require, "config-local")
if not status_ok then
    return
end

config_local.setup {
    -- Config file patterns to load (lua supported)
    config_files = { ".nvim.lua", ".nvimrc", ".lvimrc" },
    
    -- Where the config files are stored
    hashfile = vim.fn.stdpath("data") .. "/config-local",
    
    -- Set to `true` to automatically detect changes and load them
    autocommands_create = true,
    
    -- Are we silent when we load a local configuration
    silent = false,
    
    -- Display a message when loading a configuration
    lookup_parents = false,
}
```

3. Create a project-specific configuration file:

```bash
cd ~/projects/python-demo
nano .nvim.lua
```

Add content:
```lua
-- Project-specific Neovim settings for Python Demo

-- Python specific settings
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = true
vim.opt_local.fileformat = 'unix'
vim.opt_local.colorcolumn = '88'  -- Black's line length

-- Project specific mappings
vim.keymap.set('n', '<leader>pr', ':!python -m python_demo<CR>', { noremap = true, buffer = true, desc = 'Run project' })
vim.keymap.set('n', '<leader>pt', ':!pytest<CR>', { noremap = true, buffer = true, desc = 'Run tests' })
vim.keymap.set('n', '<leader>pi', ':!python -m python_demo.__main__<CR>', { noremap = true, buffer = true, desc = 'Import and run' })

-- Set up Python specific LSP options for this project
if vim.fn.getcwd() == vim.fn.expand('~/projects/python-demo') then
    local lspconfig = require('lspconfig')
    lspconfig.pyright.setup {
        settings = {
            python = {
                analysis = {
                    extraPaths = { "." },
                    typeCheckingMode = "basic",
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
                    diagnosticMode = "workspace"
                }
            }
        }
    }
end

-- Configure path for this project
vim.opt_local.path:append("python_demo")
vim.opt_local.path:append("tests")

print("Loaded Python Demo project configuration")
```

4. Do the same for the TypeScript project:

```bash
cd ~/projects/typescript-demo
nano .nvim.lua
```

Add content:
```lua
-- Project-specific Neovim settings for TypeScript Demo

-- TypeScript specific settings
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.expandtab = true
vim.opt_local.fileformat = 'unix'
vim.opt_local.colorcolumn = '80'

-- Project specific mappings
vim.keymap.set('n', '<leader>pr', ':!npm start<CR>', { noremap = true, buffer = true, desc = 'Run project' })
vim.keymap.set('n', '<leader>pt', ':!npm test<CR>', { noremap = true, buffer = true, desc = 'Run tests' })
vim.keymap.set('n', '<leader>pb', ':!npm run build<CR>', { noremap = true, buffer = true, desc = 'Build project' })
vim.keymap.set('n', '<leader>pf', ':!npm run format<CR>', { noremap = true, buffer = true, desc = 'Format code' })
vim.keymap.set('n', '<leader>pl', ':!npm run lint<CR>', { noremap = true, buffer = true, desc = 'Lint code' })

-- Configure path for this project
vim.opt_local.path:append("src")
vim.opt_local.path:append("dist")

-- Set up TypeScript specific LSP options for this project
if vim.fn.getcwd() == vim.fn.expand('~/projects/typescript-demo') then
    local lspconfig = require('lspconfig')
    lspconfig.tsserver.setup {
        settings = {
            typescript = {
                inlayHints = {
                    includeInlayParameterNameHints = 'all',
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                }
            }
        }
    }
end

print("Loaded TypeScript Demo project configuration")
```

### Resources

- [Git Documentation](https://git-scm.com/doc)
- [Fugitive.vim Documentation](https://github.com/tpope/vim-fugitive)
- [Git Workflows Guide](https://www.atlassian.com/git/tutorials/comparing-workflows)
- [Project-Specific Configuration in Neovim](https://github.com/klen/nvim-config-local)
- [Terminal Integration in Neovim](https://github.com/akinsho/toggleterm.nvim)
- [Advanced Git Techniques](https://git-scm.com/book/en/v2/Git-Tools-Advanced-Merging)
- [Git Hooks Documentation](https://git-scm.com/docs/githooks)
- [Git Workflow Best Practices](https://www.git-tower.com/learn/git/ebook/en/command-line/advanced-topics/git-flow)

## Projects and Exercises

1. **Neovim Configuration Overhaul**
   - Create a complete Lua-based Neovim configuration
   - Implement language-specific settings
   - Configure efficient keybindings
   - Document your setup with comments
   - Create a Git repository for your configuration
   - Implement modular organization
   - Set up automated installation

2. **Polyglot Project Development**
   - Create a project using multiple languages
   - Implement consistent formatting across languages
   - Configure testing for all components
   - Set up an automated build process
   - Integrate with Git workflows
   - Create a comprehensive README
   - Implement continuous integration

3. **Custom Development Toolkit**
   - Create scripts for common development tasks
   - Implement project scaffolding tools
   - Build a documentation generator
   - Create custom linting rules
   - Develop task automation scripts
   - Set up environment management tools
   - Create a unified command interface

4. **Git Workflow Enhancement**
   - Create custom Git hooks for quality control
   - Implement automated testing before commits
   - Configure branch policies
   - Create a PR template and review process
   - Set up commit message templates
   - Implement automated changelog generation
   - Configure a Git-based deployment pipeline

## Cross-References

- **Previous Month**: [Month 4: Terminal Tools and Shell Customization](month-04-terminal-tools.md) - Foundational terminal skills for development
- **Next Month**: [Month 6: Containerization and Virtual Environments](month-06-containers.md) - Building on development skills with containerization
- **Related Guides**: 
  - [Troubleshooting Guide](/troubleshooting/README.md) - For resolving development environment issues
  - [Development Environment Configuration](/configuration/development/README.md) - For further configuration options
  - [Python Development Environment](/configuration/development/languages/python/README.md) - For Python-specific configuration
- **Reference Resources**:
  - [Linux Shortcuts & Commands Reference](linux-shortcuts.md) - For development shortcuts
  - [Linux Mastery Journey - Glossary](linux-glossary.md) - For development terminology

## Assessment

You should now be able to:

1. Configure and use Neovim as a complete IDE
2. Set up language-specific development environments
3. Implement effective testing and debugging workflows
4. Use Git efficiently with IDE integration
5. Navigate and search codebases effectively
6. Create consistent development environments across projects

## Next Steps

In Month 6, we'll focus on:
- Setting up containerization with Docker
- Managing virtual environments and isolation
- Creating reproducible development environments
- Implementing local/development services
- Building efficient deployment pipelines

## Acknowledgements

This learning guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Learning path structure and organization
- Resource recommendations
- Project suggestions

Claude was used as a development aid while all final implementation decisions and verification were performed by Joshua Michael Hall.

## Disclaimer

This guide is provided "as is", without warranty of any kind. Follow all instructions carefully and always make backups before making system changes.
