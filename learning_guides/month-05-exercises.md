# Month 5: Programming Languages and Development Tools - Exercises

This document contains practical exercises to accompany the Month 5 learning guide. Complete these exercises to build your skills with Neovim, language-specific development environments, and professional programming workflows.

## Exercise 1: Neovim Configuration Project

Create a comprehensive Neovim configuration with LSP support, navigation tools, and plugin management.

### Installation and Initial Configuration

1. **Install Neovim and Create Configuration Structure**:
   ```bash
   # Install Neovim
   sudo pacman -S neovim python-pynvim
   
   # Create configuration directory structure
   mkdir -p ~/.config/nvim/{lua,plugin,after}
   
   # Create init.lua file
   touch ~/.config/nvim/init.lua
   ```

2. **Create Basic Configuration**:
   ```bash
   # Edit init.lua
   nvim ~/.config/nvim/init.lua
   ```

   Add the following content to init.lua:
   ```lua
   -- Base configuration
   vim.g.mapleader = " "  -- Set leader key to space
   
   -- Basic settings
   vim.opt.number = true
   vim.opt.relativenumber = true
   vim.opt.mouse = 'a'
   vim.opt.ignorecase = true
   vim.opt.smartcase = true
   vim.opt.hlsearch = true
   vim.opt.wrap = false
   vim.opt.breakindent = true
   vim.opt.tabstop = 4
   vim.opt.shiftwidth = 4
   vim.opt.expandtab = true
   vim.opt.clipboard = 'unnamedplus'
   vim.opt.termguicolors = true
   vim.opt.updatetime = 300
   vim.opt.timeoutlen = 500
   vim.opt.completeopt = 'menuone,noselect'
   vim.opt.signcolumn = 'yes'
   vim.opt.cursorline = true
   
   -- Create module structure to load other configuration files
   require('plugins')  -- Will be created next
   ```

3. **Set Up Plugin Management**:
   ```bash
   # Install Packer
   git clone --depth 1 https://github.com/wbthomason/packer.nvim \
     ~/.local/share/nvim/site/pack/packer/start/packer.nvim
   
   # Create plugins.lua
   touch ~/.config/nvim/lua/plugins.lua
   ```

   Add this content to plugins.lua:
   ```lua
   -- plugins.lua
   return require('packer').startup(function(use)
     -- Packer can manage itself
     use 'wbthomason/packer.nvim'
     
     -- Color scheme
     use 'folke/tokyonight.nvim'
     
     -- LSP Configuration & Plugins
     use {
       'neovim/nvim-lspconfig',
       requires = {
         -- LSP Support
         {'williamboman/mason.nvim'},
         {'williamboman/mason-lspconfig.nvim'},
         
         -- Autocompletion
         {'hrsh7th/nvim-cmp'},
         {'hrsh7th/cmp-buffer'},
         {'hrsh7th/cmp-path'},
         {'hrsh7th/cmp-nvim-lsp'},
         {'hrsh7th/cmp-nvim-lua'},
         
         -- Snippets
         {'L3MON4D3/LuaSnip'},
         {'saadparwaiz1/cmp_luasnip'},
       }
     }
     
     -- Telescope for fuzzy finding
     use {
       'nvim-telescope/telescope.nvim',
       requires = { {'nvim-lua/plenary.nvim'} }
     }
     
     -- Treesitter for better syntax highlighting
     use {
       'nvim-treesitter/nvim-treesitter',
       run = ':TSUpdate'
     }
     
     -- File explorer
     use {
       'kyazdani42/nvim-tree.lua',
       requires = {
         'kyazdani42/nvim-web-devicons',
       }
     }
     
     -- Git integration
     use 'lewis6991/gitsigns.nvim'
     
     -- Status line
     use {
       'nvim-lualine/lualine.nvim',
       requires = { 'kyazdani42/nvim-web-devicons' }
     }
     
     -- Comment toggling
     use 'numToStr/Comment.nvim'
     
     -- Autopairs
     use 'windwp/nvim-autopairs'
   end)
   ```

4. **Install Plugins**:
   ```bash
   # Open Neovim and install plugins
   nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
   ```

### Setting Up LSP and Core Plugins

1. **Create Configuration for LSP**:
   ```bash
   # Create LSP configuration file
   mkdir -p ~/.config/nvim/lua/config
   touch ~/.config/nvim/lua/config/lsp.lua
   ```

   Add this content:
   ```lua
   -- lsp.lua
   return function()
     local mason = require('mason')
     local mason_lspconfig = require('mason-lspconfig')
     local lspconfig = require('lspconfig')
     local cmp = require('cmp')
     local luasnip = require('luasnip')
     
     -- Set up Mason for installing LSP servers
     mason.setup()
     mason_lspconfig.setup({
       ensure_installed = {
         'pyright',        -- Python
         'tsserver',       -- TypeScript/JavaScript
         'lua_ls',         -- Lua
         'html',           -- HTML
         'cssls',          -- CSS
         'jsonls',         -- JSON
       },
       automatic_installation = true,
     })
     
     -- Configure nvim-cmp
     cmp.setup({
       snippet = {
         expand = function(args)
           luasnip.lsp_expand(args.body)
         end,
       },
       mapping = cmp.mapping.preset.insert({
         ['<C-Space>'] = cmp.mapping.complete(),
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
         { name = 'buffer' },
         { name = 'path' },
       }),
     })
     
     -- Common capabilities for all LSP servers
     local capabilities = require('cmp_nvim_lsp').default_capabilities()
     
     -- Common on_attach for all LSP servers
     local on_attach = function(client, bufnr)
       local opts = { noremap = true, silent = true, buffer = bufnr }
       
       -- Mappings for LSP functionality
       vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
       vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
       vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
       vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
       vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
       vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
       vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
       vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
       vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, opts)
     end
     
     -- Configure LSP servers
     lspconfig.pyright.setup({
       capabilities = capabilities,
       on_attach = on_attach,
     })
     
     lspconfig.tsserver.setup({
       capabilities = capabilities,
       on_attach = on_attach,
     })
     
     lspconfig.lua_ls.setup({
       capabilities = capabilities,
       on_attach = on_attach,
       settings = {
         Lua = {
           diagnostics = {
             globals = { 'vim' },
           },
         },
       },
     })
     
     -- Configure other servers
     for _, server in ipairs({ 'html', 'cssls', 'jsonls' }) do
       lspconfig[server].setup({
         capabilities = capabilities,
         on_attach = on_attach,
       })
     end
   end
   ```

2. **Create Configuration for Telescope**:
   ```bash
   touch ~/.config/nvim/lua/config/telescope.lua
   ```

   Add this content:
   ```lua
   -- telescope.lua
   return function()
     local telescope = require('telescope')
     
     telescope.setup {
       defaults = {
         file_ignore_patterns = { "node_modules", ".git" },
         prompt_prefix = " ",
         selection_caret = " ",
         path_display = { "smart" },
       },
     }
     
     -- Keymaps for Telescope
     local opts = { noremap = true, silent = true }
     vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>', opts)
     vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', opts)
     vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>', opts)
     vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<CR>', opts)
   end
   ```

3. **Create Configuration for Treesitter**:
   ```bash
   touch ~/.config/nvim/lua/config/treesitter.lua
   ```

   Add this content:
   ```lua
   -- treesitter.lua
   return function()
     require('nvim-treesitter.configs').setup {
       ensure_installed = {
         "lua", "python", "typescript", "javascript", 
         "html", "css", "json", "bash"
       },
       sync_install = false,
       auto_install = true,
       highlight = {
         enable = true,
       },
       indent = {
         enable = true,
       },
     }
   end
   ```

4. **Create Configuration for NvimTree**:
   ```bash
   touch ~/.config/nvim/lua/config/nvimtree.lua
   ```

   Add this content:
   ```lua
   -- nvimtree.lua
   return function()
     require('nvim-tree').setup {
       sort_by = "case_sensitive",
       view = {
         width = 30,
       },
       renderer = {
         group_empty = true,
       },
       filters = {
         dotfiles = false,
       },
     }
     
     -- Keymaps for NvimTree
     vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { noremap = true, silent = true })
   end
   ```

5. **Create Configuration for GitSigns**:
   ```bash
   touch ~/.config/nvim/lua/config/gitsigns.lua
   ```

   Add this content:
   ```lua
   -- gitsigns.lua
   return function()
     require('gitsigns').setup {
       signs = {
         add = { text = '+' },
         change = { text = '~' },
         delete = { text = '_' },
         topdelete = { text = '‾' },
         changedelete = { text = '~' },
       },
       signcolumn = true,
       numhl = false,
       linehl = false,
       word_diff = false,
       current_line_blame = true,
       current_line_blame_opts = {
         virt_text = true,
         virt_text_pos = 'eol',
         delay = 500,
       },
     }
   end
   ```

6. **Create Configuration for Other Plugins**:
   ```bash
   touch ~/.config/nvim/lua/config/misc.lua
   ```

   Add this content:
   ```lua
   -- misc.lua
   return function()
     -- Lualine
     require('lualine').setup {
       options = {
         theme = 'tokyonight',
         component_separators = { left = '', right = '' },
         section_separators = { left = '', right = '' },
       },
     }
     
     -- Comment
     require('Comment').setup()
     
     -- Autopairs
     require('nvim-autopairs').setup()
     
     -- Theme
     vim.cmd[[colorscheme tokyonight]]
   end
   ```

7. **Update init.lua to Load All Configurations**:
   ```bash
   nvim ~/.config/nvim/init.lua
   ```

   Add at the bottom of the file:
   ```lua
   -- Load all plugin configurations
   require('config.lsp')()
   require('config.telescope')()
   require('config.treesitter')()
   require('config.nvimtree')()
   require('config.gitsigns')()
   require('config.misc')()
   ```

8. **Test Your Configuration**:
   ```bash
   # Open Neovim with new configuration
   nvim
   
   # Install LSP servers through Mason
   :MasonInstall pyright tsserver lua-language-server
   ```

### Tasks

1. **Verify LSP functionality** by opening a Python or JavaScript file and checking for completion and diagnostics.

2. **Customize key mappings** to match your workflow preferences:
   ```lua
   -- Add to init.lua or create a new file for custom mappings
   vim.keymap.set('n', '<leader>w', '<cmd>w<CR>', { noremap = true, desc = 'Save file' })
   vim.keymap.set('n', '<leader>q', '<cmd>q<CR>', { noremap = true, desc = 'Quit' })
   vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true, desc = 'Move to left window' })
   vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true, desc = 'Move to down window' })
   vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true, desc = 'Move to up window' })
   vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true, desc = 'Move to right window' })
   ```

3. **Create a documentation file** explaining your Neovim configuration, including:
   - Plugin list and purpose
   - Key mapping reference
   - LSP server configurations
   - Installation instructions
   - Troubleshooting section

4. **Version Your Configuration with Git**:
   ```bash
   cd ~/.config/nvim
   git init
   git add .
   git commit -m "Initial Neovim configuration"
   
   # Create a GitHub repository and push
   git remote add origin https://github.com/yourusername/nvim-config.git
   git push -u origin main
   ```

## Exercise 2: Python Development Environment Setup

Create a complete Python development environment with proper version management, virtual environments, and advanced tooling.

### Setting Up Python Environment

1. **Install pyenv for Python Version Management**:
   ```bash
   # Install dependencies
   sudo pacman -S --needed base-devel openssl zlib xz
   
   # Install pyenv
   curl https://pyenv.run | bash
   
   # Add to your shell configuration
   echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
   echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
   echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
   echo 'eval "$(pyenv init -)"' >> ~/.bashrc
   
   # Reload shell
   source ~/.bashrc
   ```

2. **Install Multiple Python Versions**:
   ```bash
   # List available versions
   pyenv install --list
   
   # Install specific versions
   pyenv install 3.8.16
   pyenv install 3.11.3
   
   # Set global version
   pyenv global 3.11.3
   
   # Verify installation
   python --version
   ```

3. **Install Poetry for Dependency Management**:
   ```bash
   # Install Poetry
   curl -sSL https://install.python-poetry.org | python3 -
   
   # Add to your PATH
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   
   # Configure Poetry
   poetry config virtualenvs.in-project true
   ```

4. **Install Global Python Development Tools**:
   ```bash
   # Install useful global tools
   pip install ipython pytest black isort mypy flake8
   ```

### Creating a Python Project

1. **Initialize a New Poetry Project**:
   ```bash
   # Create project directory
   mkdir -p ~/projects/data-analyzer
   cd ~/projects/data-analyzer
   
   # Initialize Poetry project
   poetry init --no-interaction \
     --name "data-analyzer" \
     --description "A data analysis toolkit" \
     --author "Your Name <your.email@example.com>" \
     --python "^3.8"
   ```

2. **Add Dependencies**:
   ```bash
   # Add main dependencies
   poetry add pandas numpy matplotlib seaborn

   # Add development dependencies
   poetry add --group dev pytest pytest-cov black isort mypy flake8
   ```

3. **Create Project Structure**:
   ```bash
   # Create source and test directories
   mkdir -p data_analyzer/tests
   touch data_analyzer/__init__.py
   touch data_analyzer/analyzer.py
   touch tests/__init__.py
   touch tests/test_analyzer.py
   ```

4. **Create Basic Implementation**:
   ```bash
   # Edit analyzer.py
   nvim data_analyzer/analyzer.py
   ```

   Add this content:
   ```python
   """Data analysis module."""
   
   from typing import Dict, List, Union
   
   import numpy as np
   import pandas as pd
   
   
   class DataAnalyzer:
       """A class for analyzing numerical data."""
       
       def __init__(self, data: Union[List, np.ndarray, pd.DataFrame]):
           """Initialize the analyzer with data.
           
           Args:
               data: The data to analyze
           """
           if isinstance(data, pd.DataFrame):
               self.data = data
           else:
               self.data = pd.DataFrame(data)
           
       def summary_statistics(self) -> Dict:
           """Calculate summary statistics for the data.
           
           Returns:
               A dictionary of summary statistics
           """
           stats = {
               'mean': self.data.mean().to_dict(),
               'median': self.data.median().to_dict(),
               'std': self.data.std().to_dict(),
               'min': self.data.min().to_dict(),
               'max': self.data.max().to_dict(),
           }
           return stats
       
       def correlation_matrix(self) -> pd.DataFrame:
           """Calculate the correlation matrix for the data.
           
           Returns:
               A DataFrame containing the correlation matrix
           """
           return self.data.corr()
       
       def detect_outliers(self, threshold: float = 3.0) -> pd.DataFrame:
           """Detect outliers in the data using z-score.
           
           Args:
               threshold: The z-score threshold for outliers
               
           Returns:
               A DataFrame containing the outliers
           """
           z_scores = (self.data - self.data.mean()) / self.data.std()
           outliers = self.data[(z_scores.abs() > threshold).any(axis=1)]
           return outliers
   ```

5. **Create Tests**:
   ```bash
   # Edit test_analyzer.py
   nvim tests/test_analyzer.py
   ```

   Add this content:
   ```python
   """Tests for the analyzer module."""
   
   import numpy as np
   import pandas as pd
   import pytest
   
   from data_analyzer.analyzer import DataAnalyzer
   
   
   @pytest.fixture
   def sample_data():
       """Create sample data for testing."""
       return {
           'A': [1, 2, 3, 4, 5],
           'B': [5, 4, 3, 2, 1],
           'C': [2, 4, 6, 8, 10]
       }
   
   
   @pytest.fixture
   def analyzer(sample_data):
       """Create a DataAnalyzer instance for testing."""
       return DataAnalyzer(sample_data)
   
   
   def test_initialization_with_dict(sample_data):
       """Test initialization with dictionary."""
       analyzer = DataAnalyzer(sample_data)
       assert isinstance(analyzer.data, pd.DataFrame)
       assert analyzer.data.shape == (5, 3)
   
   
   def test_initialization_with_dataframe(sample_data):
       """Test initialization with DataFrame."""
       df = pd.DataFrame(sample_data)
       analyzer = DataAnalyzer(df)
       assert isinstance(analyzer.data, pd.DataFrame)
       assert analyzer.data.equals(df)
   
   
   def test_summary_statistics(analyzer):
       """Test summary statistics calculation."""
       stats = analyzer.summary_statistics()
       assert stats['mean']['A'] == 3.0
       assert stats['median']['B'] == 3.0
       assert stats['std']['C'] == pytest.approx(3.16, abs=0.1)
       assert stats['min']['A'] == 1.0
       assert stats['max']['C'] == 10.0
   
   
   def test_correlation_matrix(analyzer):
       """Test correlation matrix calculation."""
       corr = analyzer.correlation_matrix()
       assert corr.loc['A', 'B'] == -1.0  # Perfect negative correlation
       assert corr.loc['A', 'C'] == 1.0   # Perfect positive correlation
   
   
   def test_detect_outliers():
       """Test outlier detection."""
       data = pd.DataFrame({
           'X': [1, 2, 3, 4, 100]  # 100 is an outlier
       })
       analyzer = DataAnalyzer(data)
       outliers = analyzer.detect_outliers(threshold=2.0)
       assert outliers.shape[0] == 1
       assert outliers.iloc[0, 0] == 100
   ```

6. **Configure Development Tools**:
   ```bash
   # Create pyproject.toml additional configuration
   nvim pyproject.toml
   ```

   Add this content below the existing configuration:
   ```toml
   [tool.black]
   line-length = 88
   target-version = ["py38"]
   
   [tool.isort]
   profile = "black"
   multi_line_output = 3
   
   [tool.mypy]
   python_version = "3.8"
   warn_return_any = true
   warn_unused_configs = true
   disallow_untyped_defs = true
   disallow_incomplete_defs = true
   
   [tool.pytest.ini_options]
   testpaths = ["tests"]
   python_files = "test_*.py"
   python_functions = "test_*"
   ```

7. **Run Tests and Quality Checks**:
   ```bash
   # Activate virtual environment
   poetry shell
   
   # Run tests
   pytest
   
   # Run formatting
   black data_analyzer tests
   isort data_analyzer tests
   
   # Run linting
   flake8 data_analyzer tests
   
   # Run type checking
   mypy data_analyzer
   ```

8. **Create a Project-Specific Neovim Configuration**:
   ```bash
   # Create project-specific Neovim config
   nvim .nvim.lua
   ```

   Add this content:
   ```lua
   -- Project-specific Neovim settings for data-analyzer
   
   -- Python specific settings
   vim.opt_local.tabstop = 4
   vim.opt_local.softtabstop = 4
   vim.opt_local.shiftwidth = 4
   vim.opt_local.expandtab = true
   vim.opt_local.fileformat = 'unix'
   vim.opt_local.colorcolumn = '88'  -- Black's line length
   
   -- Project specific mappings
   vim.keymap.set('n', '<leader>pt', ':!poetry run pytest<CR>', { noremap = true, buffer = true, desc = 'Run tests' })
   vim.keymap.set('n', '<leader>pc', ':!poetry run pytest --cov=data_analyzer<CR>', { noremap = true, buffer = true, desc = 'Run tests with coverage' })
   vim.keymap.set('n', '<leader>pf', ':!poetry run black data_analyzer tests<CR>', { noremap = true, buffer = true, desc = 'Format code with black' })
   vim.keymap.set('n', '<leader>pi', ':!poetry run isort data_analyzer tests<CR>', { noremap = true, buffer = true, desc = 'Sort imports with isort' })
   vim.keymap.set('n', '<leader>pl', ':!poetry run flake8 data_analyzer tests<CR>', { noremap = true, buffer = true, desc = 'Lint code with flake8' })
   vim.keymap.set('n', '<leader>pm', ':!poetry run mypy data_analyzer<CR>', { noremap = true, buffer = true, desc = 'Type check with mypy' })
   
   -- Configure path for this project
   vim.opt_local.path:append("data_analyzer")
   vim.opt_local.path:append("tests")
   
   print("Loaded data-analyzer project configuration")
   ```

9. **Create a README.md for the Project**:
   ```bash
   nvim README.md
   ```

   Add this content:
   ```markdown
   # Data Analyzer
   
   A Python library for data analysis and visualization.
   
   ## Features
   
   - Summary statistics calculation
   - Correlation analysis
   - Outlier detection
   
   ## Installation
   
   ```bash
   poetry install
   ```
   
   ## Usage
   
   ```python
   from data_analyzer.analyzer import DataAnalyzer
   import pandas as pd
   
   # Create data
   data = pd.DataFrame({
       'A': [1, 2, 3, 4, 5],
       'B': [5, 4, 3, 2, 1]
   })
   
   # Initialize analyzer
   analyzer = DataAnalyzer(data)
   
   # Get summary statistics
   stats = analyzer.summary_statistics()
   print(stats)
   
   # Get correlation matrix
   corr = analyzer.correlation_matrix()
   print(corr)
   
   # Detect outliers
   outliers = analyzer.detect_outliers(threshold=2.0)
   print(outliers)
   ```
   
   ## Development
   
   ### Setup
   
   ```bash
   # Clone repository
   git clone https://github.com/yourusername/data-analyzer.git
   cd data-analyzer
   
   # Install dependencies
   poetry install
   ```
   
   ### Testing
   
   ```bash
   poetry run pytest
   
   # With coverage
   poetry run pytest --cov=data_analyzer
   ```
   
   ### Code Quality
   
   ```bash
   # Formatting
   poetry run black data_analyzer tests
   poetry run isort data_analyzer tests
   
   # Linting
   poetry run flake8 data_analyzer tests
   
   # Type checking
   poetry run mypy data_analyzer
   ```
   
   ## License
   
   MIT
   ```

10. **Set Up Git for the Project**:
    ```bash
    # Initialize Git
    git init
    
    # Create .gitignore
    nvim .gitignore
    ```

    Add this content to .gitignore:
    ```
    # Python
    __pycache__/
    *.py[cod]
    *$py.class
    *.so
    .Python
    env/
    build/
    develop-eggs/
    dist/
    downloads/
    eggs/
    .eggs/
    lib/
    lib64/
    parts/
    sdist/
    var/
    *.egg-info/
    .installed.cfg
    *.egg
    
    # Virtual Environments
    .env
    .venv
    venv/
    ENV/
    
    # Testing
    .coverage
    htmlcov/
    .pytest_cache/
    
    # Mypy
    .mypy_cache/
    
    # IDE
    .idea/
    .vscode/
    *.swp
    *.swo
    
    # OS
    .DS_Store
    Thumbs.db
    ```

    Complete the setup:
    ```bash
    # Add and commit
    git add .
    git commit -m "Initial project setup"
    ```

### Tasks

1. **Add a Visualization Module**: Create a new module for data visualization.
   ```bash
   touch data_analyzer/visualizer.py
   ```

   Add this content:
   ```python
   """Data visualization module."""
   
   from typing import Optional, Tuple, Union
   
   import matplotlib.pyplot as plt
   import pandas as pd
   import seaborn as sns
   
   
   class DataVisualizer:
       """A class for visualizing data."""
       
       def __init__(self, data: pd.DataFrame):
           """Initialize the visualizer with data.
           
           Args:
               data: The data to visualize
           """
           self.data = data
           
       def histogram(self, column: str, bins: int = 10, figsize: Tuple[int, int] = (10, 6)):
           """Create a histogram for a column.
           
           Args:
               column: The column to plot
               bins: The number of bins
               figsize: The figure size
           """
           plt.figure(figsize=figsize)
           sns.histplot(self.data[column], bins=bins, kde=True)
           plt.title(f'Histogram of {column}')
           plt.xlabel(column)
           plt.ylabel('Frequency')
           plt.grid(True, alpha=0.3)
           return plt.gcf()
           
       def scatter_plot(self, x: str, y: str, hue: Optional[str] = None, 
                         figsize: Tuple[int, int] = (10, 6)):
           """Create a scatter plot.
           
           Args:
               x: The column for x-axis
               y: The column for y-axis
               hue: Optional column for color coding
               figsize: The figure size
           """
           plt.figure(figsize=figsize)
           sns.scatterplot(data=self.data, x=x, y=y, hue=hue)
           plt.title(f'Scatter Plot: {y} vs {x}')
           plt.grid(True, alpha=0.3)
           return plt.gcf()
           
       def correlation_heatmap(self, figsize: Tuple[int, int] = (10, 8)):
           """Create a correlation heatmap.
           
           Args:
               figsize: The figure size
           """
           plt.figure(figsize=figsize)
           corr = self.data.corr()
           mask = np.triu(np.ones_like(corr, dtype=bool))
           sns.heatmap(corr, mask=mask, annot=True, cmap='coolwarm', 
                       vmin=-1, vmax=1, center=0, square=True, linewidths=.5)
           plt.title('Correlation Heatmap')
           return plt.gcf()
           
       def boxplot(self, columns: Union[str, list], figsize: Tuple[int, int] = (10, 6)):
           """Create a boxplot.
           
           Args:
               columns: The column(s) to plot
               figsize: The figure size
           """
           plt.figure(figsize=figsize)
           if isinstance(columns, str):
               sns.boxplot(y=self.data[columns])
               plt.title(f'Boxplot of {columns}')
           else:
               melted_data = self.data[columns].melt()
               sns.boxplot(x='variable', y='value', data=melted_data)
               plt.title('Boxplot Comparison')
               plt.xlabel('Variables')
               plt.ylabel('Values')
           plt.grid(True, alpha=0.3)
           return plt.gcf()
   ```

2. **Add Tests for the Visualization Module**:
   ```bash
   touch tests/test_visualizer.py
   ```

   Add this content:
   ```python
   """Tests for the visualizer module."""
   
   import matplotlib.pyplot as plt
   import pandas as pd
   import pytest
   
   from data_analyzer.visualizer import DataVisualizer
   
   
   @pytest.fixture
   def sample_data():
       """Create sample data for testing."""
       return pd.DataFrame({
           'A': [1, 2, 3, 4, 5],
           'B': [5, 4, 3, 2, 1],
           'C': [2, 4, 6, 8, 10]
       })
   
   
   @pytest.fixture
   def visualizer(sample_data):
       """Create a DataVisualizer instance for testing."""
       return DataVisualizer(sample_data)
   
   
   def test_initialization(sample_data):
       """Test initialization."""
       visualizer = DataVisualizer(sample_data)
       assert visualizer.data.equals(sample_data)
   
   
   def test_histogram(visualizer):
       """Test histogram creation."""
       fig = visualizer.histogram('A')
       assert isinstance(fig, plt.Figure)
       plt.close(fig)
   
   
   def test_scatter_plot(visualizer):
       """Test scatter plot creation."""
       fig = visualizer.scatter_plot('A', 'B')
       assert isinstance(fig, plt.Figure)
       plt.close(fig)
   
       # Test with hue
       fig = visualizer.scatter_plot('A', 'B', hue='C')
       assert isinstance(fig, plt.Figure)
       plt.close(fig)
   
   
   def test_correlation_heatmap(visualizer):
       """Test correlation heatmap creation."""
       fig = visualizer.correlation_heatmap()
       assert isinstance(fig, plt.Figure)
       plt.close(fig)
   
   
   def test_boxplot(visualizer):
       """Test boxplot creation."""
       # Single column
       fig = visualizer.boxplot('A')
       assert isinstance(fig, plt.Figure)
       plt.close(fig)
   
       # Multiple columns
       fig = visualizer.boxplot(['A', 'B', 'C'])
       assert isinstance(fig, plt.Figure)
       plt.close(fig)
   ```

3. **Implement a CLI for the Project**:
   ```bash
   touch data_analyzer/cli.py
   ```

   Add this content:
   ```python
   """Command line interface for data analyzer."""
   
   import argparse
   import json
   import sys
   from pathlib import Path
   
   import pandas as pd
   
   from data_analyzer.analyzer import DataAnalyzer
   from data_analyzer.visualizer import DataVisualizer
   
   
   def main():
       """Run the command line interface."""
       parser = argparse.ArgumentParser(description='Data Analyzer CLI')
       parser.add_argument('file', help='CSV file to analyze')
       
       subparsers = parser.add_subparsers(dest='command', help='Command to run')
       
       # Stats command
       stats_parser = subparsers.add_parser('stats', help='Calculate summary statistics')
       stats_parser.add_argument('--output', '-o', help='Output JSON file')
       
       # Correlation command
       corr_parser = subparsers.add_parser('correlation', help='Calculate correlation matrix')
       corr_parser.add_argument('--output', '-o', help='Output CSV file')
       
       # Outliers command
       outliers_parser = subparsers.add_parser('outliers', help='Detect outliers')
       outliers_parser.add_argument('--threshold', '-t', type=float, default=3.0,
                                    help='Z-score threshold for outliers')
       outliers_parser.add_argument('--output', '-o', help='Output CSV file')
       
       # Visualization commands
       hist_parser = subparsers.add_parser('histogram', help='Create histogram')
       hist_parser.add_argument('column', help='Column to plot')
       hist_parser.add_argument('--bins', '-b', type=int, default=10, help='Number of bins')
       hist_parser.add_argument('--output', '-o', help='Output image file')
       
       scatter_parser = subparsers.add_parser('scatter', help='Create scatter plot')
       scatter_parser.add_argument('x', help='X-axis column')
       scatter_parser.add_argument('y', help='Y-axis column')
       scatter_parser.add_argument('--hue', '-c', help='Column for color coding')
       scatter_parser.add_argument('--output', '-o', help='Output image file')
       
       heatmap_parser = subparsers.add_parser('heatmap', help='Create correlation heatmap')
       heatmap_parser.add_argument('--output', '-o', help='Output image file')
       
       boxplot_parser = subparsers.add_parser('boxplot', help='Create boxplot')
       boxplot_parser.add_argument('columns', nargs='+', help='Columns to plot')
       boxplot_parser.add_argument('--output', '-o', help='Output image file')
       
       args = parser.parse_args()
       
       # Load data
       try:
           data = pd.read_csv(args.file)
       except Exception as e:
           print(f"Error loading file: {e}", file=sys.stderr)
           return 1
       
       # Initialize analyzers
       analyzer = DataAnalyzer(data)
       visualizer = DataVisualizer(data)
       
       # Run command
       if args.command == 'stats':
           result = analyzer.summary_statistics()
           if args.output:
               with open(args.output, 'w') as f:
                   json.dump(result, f, indent=2)
           else:
               print(json.dumps(result, indent=2))
       
       elif args.command == 'correlation':
           result = analyzer.correlation_matrix()
           if args.output:
               result.to_csv(args.output)
           else:
               print(result)
       
       elif args.command == 'outliers':
           result = analyzer.detect_outliers(threshold=args.threshold)
           if args.output:
               result.to_csv(args.output, index=False)
           else:
               print(result)
       
       elif args.command == 'histogram':
           fig = visualizer.histogram(args.column, bins=args.bins)
           if args.output:
               fig.savefig(args.output, dpi=300, bbox_inches='tight')
           else:
               plt.show()
       
       elif args.command == 'scatter':
           fig = visualizer.scatter_plot(args.x, args.y, hue=args.hue)
           if args.output:
               fig.savefig(args.output, dpi=300, bbox_inches='tight')
           else:
               plt.show()
       
       elif args.command == 'heatmap':
           fig = visualizer.correlation_heatmap()
           if args.output:
               fig.savefig(args.output, dpi=300, bbox_inches='tight')
           else:
               plt.show()
       
       elif args.command == 'boxplot':
           fig = visualizer.boxplot(args.columns)
           if args.output:
               fig.savefig(args.output, dpi=300, bbox_inches='tight')
           else:
               plt.show()
       
       else:
           parser.print_help()
           return 1
       
       return 0
   
   
   if __name__ == '__main__':
       sys.exit(main())
   ```

4. **Update pyproject.toml to Include CLI**:
   ```bash
   nvim pyproject.toml
   ```

   Add this content:
   ```toml
   [tool.poetry.scripts]
   data-analyzer = "data_analyzer.cli:main"
   ```

5. **Create Example Dataset for Testing**:
   ```bash
   mkdir -p examples
   nvim examples/sample_data.csv
   ```

   Add this content:
   ```
   id,age,income,education,experience
   1,32,65000,16,8
   2,45,85000,18,20
   3,28,52000,16,5
   4,36,72000,16,12
   5,52,95000,20,25
   6,29,48000,14,6
   7,42,78000,18,18
   8,31,62000,16,7
   9,55,110000,20,30
   10,24,42000,12,2
   ```

6. **Test the CLI**:
   ```bash
   # Install the package in development mode
   poetry install
   
   # Run CLI commands
   poetry run data-analyzer examples/sample_data.csv stats
   poetry run data-analyzer examples/sample_data.csv correlation
   poetry run data-analyzer examples/sample_data.csv outliers --threshold 2.0
   
   # Create visualizations
   poetry run data-analyzer examples/sample_data.csv histogram age --output age_histogram.png
   poetry run data-analyzer examples/sample_data.csv scatter age income --output age_income_scatter.png
   poetry run data-analyzer examples/sample_data.csv heatmap --output correlation_heatmap.png
   poetry run data-analyzer examples/sample_data.csv boxplot age income experience --output boxplot.png
   ```

## Exercise 3: JavaScript/TypeScript Development Environment

Create a professional TypeScript project with modern tools, testing framework, and build configuration.

### Setting Up Node.js Environment

1. **Install NVM for Node.js Version Management**:
   ```bash
   # Install NVM
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
   
   # Add to your shell configuration
   echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
   echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
   echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc
   
   # Reload shell
   source ~/.bashrc
   ```

2. **Install Node.js Versions**:
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

3. **Configure npm**:
   ```bash
   # Create .npmrc
   nvim ~/.npmrc
   ```

   Add this content:
   ```
   init-author-name=Your Name
   init-author-email=your.email@example.com
   init-license=MIT
   save-exact=true
   ```

### Creating a TypeScript Project

1. **Create Project Structure**:
   ```bash
   # Create project directory
   mkdir -p ~/projects/task-manager
   cd ~/projects/task-manager
   
   # Initialize npm project
   npm init -y
   ```

2. **Install TypeScript and Development Dependencies**:
   ```bash
   # Install TypeScript and related tools
   npm install --save-dev typescript ts-node @types/node
   
   # Install linting and formatting tools
   npm install --save-dev eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin
   npm install --save-dev prettier eslint-config-prettier eslint-plugin-prettier
   
   # Install testing framework
   npm install --save-dev jest ts-jest @types/jest
   ```

3. **Configure TypeScript**:
   ```bash
   # Create tsconfig.json
   npx tsc --init
   ```

   Edit tsconfig.json:
   ```bash
   nvim tsconfig.json
   ```

   Update with this content:
   ```json
   {
     "compilerOptions": {
       "target": "es2022",
       "module": "commonjs",
       "lib": ["es2022"],
       "outDir": "dist",
       "rootDir": "src",
       "strict": true,
       "esModuleInterop": true,
       "skipLibCheck": true,
       "forceConsistentCasingInFileNames": true,
       "declaration": true,
       "sourceMap": true,
       "resolveJsonModule": true
     },
     "include": ["src/**/*"],
     "exclude": ["node_modules", "**/*.test.ts", "dist"]
   }