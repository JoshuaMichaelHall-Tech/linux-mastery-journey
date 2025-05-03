# Python Development Environment Setup

This guide provides a comprehensive approach to setting up a professional Python development environment on Linux (Arch and NixOS), with a focus on terminal-centric workflows using Neovim, tmux, and related tools.

## Table of Contents

1. [Python Installation](#python-installation)
2. [Virtual Environment Management](#virtual-environment-management)
3. [Package Management](#package-management)
4. [Neovim Configuration for Python](#neovim-configuration-for-python)
5. [Linting and Formatting](#linting-and-formatting)
6. [Testing Tools](#testing-tools)
7. [Debugging Setup](#debugging-setup)
8. [Project Scaffolding](#project-scaffolding)
9. [Development Workflow](#development-workflow)
10. [Performance Optimization](#performance-optimization)

## Python Installation

### Arch Linux

Install the latest Python version:

```bash
sudo pacman -S python python-pip
```

To install multiple Python versions:

```bash
# Install base packages
sudo pacman -S base-devel

# Install and use pyenv for Python version management
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init --path)"' >> ~/.zshrc
source ~/.zshrc

# Install Python versions
pyenv install 3.11.5
pyenv install 3.9.18
pyenv global 3.11.5
```

### NixOS

In configuration.nix:

```nix
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    python311
    python311Packages.pip
    python311Packages.setuptools
    python311Packages.wheel
    # Additional Python packages
    poetry
    pipenv
  ];
}
```

For a development shell with specific Python versions:

```nix
# Create shell.nix in your project directory
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python311
    python311Packages.pip
    python311Packages.virtualenv
    # Project-specific dependencies
    python311Packages.numpy
    python311Packages.pandas
    python311Packages.pytest
  ];
}
```

Enter the development environment:

```bash
nix-shell
```

## Virtual Environment Management

### Using venv (Built-in)

Create and activate a virtual environment:

```bash
# Create a new virtual environment
python -m venv .venv

# Activate the environment
source .venv/bin/activate

# Deactivate when done
deactivate
```

### Using Poetry (Recommended)

Install Poetry:

```bash
# Arch Linux
sudo pacman -S poetry

# Alternative installation
curl -sSL https://install.python-poetry.org | python3 -
```

Configure Poetry to create virtual environments within projects:

```bash
poetry config virtualenvs.in-project true
```

Initialize a new project:

```bash
poetry new my-project
cd my-project
```

Or add Poetry to an existing project:

```bash
cd existing-project
poetry init
```

Install dependencies:

```bash
# Add dependencies
poetry add pandas numpy matplotlib

# Add dev dependencies
poetry add --group dev pytest black mypy

# Install all dependencies
poetry install
```

Activate the environment:

```bash
poetry shell
```

### Using Pipenv

Install Pipenv:

```bash
# Arch Linux
sudo pacman -S python-pipenv
```

Use Pipenv for dependency management:

```bash
# Create a new project
mkdir my-project
cd my-project
pipenv --python 3.11

# Install packages
pipenv install numpy pandas
pipenv install --dev pytest black

# Activate the environment
pipenv shell
```

## Package Management

### Using pip

Basic package management:

```bash
# Install packages
pip install package-name

# Install from requirements.txt
pip install -r requirements.txt

# Generate requirements.txt
pip freeze > requirements.txt

# Upgrade a package
pip install --upgrade package-name
```

### Using Poetry (Recommended)

Manage dependencies with Poetry:

```bash
# Add dependencies
poetry add package-name

# Add dev dependencies
poetry add --group dev package-name

# Update dependencies
poetry update

# Remove dependencies
poetry remove package-name

# Export dependencies
poetry export -f requirements.txt > requirements.txt
```

### Using Pipenv

Manage dependencies with Pipenv:

```bash
# Install packages
pipenv install package-name

# Install dev packages
pipenv install --dev package-name

# Update dependencies
pipenv update

# Remove packages
pipenv uninstall package-name

# Generate requirements.txt
pipenv requirements > requirements.txt
```

## Neovim Configuration for Python

### Basic Setup

Install Neovim and dependencies:

```bash
# Arch Linux
sudo pacman -S neovim python-pynvim nodejs npm ripgrep fd

# NixOS
# Add to configuration.nix
environment.systemPackages = with pkgs; [
  neovim
  python311Packages.pynvim
  nodejs
  ripgrep
  fd
];
```

Create a basic Neovim configuration for Python:

```bash
mkdir -p ~/.config/nvim
```

Create init.lua:

```lua
-- ~/.config/nvim/init.lua

-- Basic Settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Install packer if not installed
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd [[packadd packer.nvim]]
end

-- Plugin setup
require('packer').startup(function(use)
  -- Package manager
  use 'wbthomason/packer.nvim'
  
  -- LSP
  use 'neovim/nvim-lspconfig'
  
  -- Autocompletion
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  
  -- Snippets
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'
  
  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  
  -- File navigation
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  
  -- Status line
  use 'nvim-lualine/lualine.nvim'
  
  -- Theme
  use 'folke/tokyonight.nvim'
end)

-- Theme configuration
vim.cmd[[colorscheme tokyonight]]

-- LSP configuration
local lspconfig = require('lspconfig')
lspconfig.pyright.setup{}

-- Autocompletion setup
local cmp = require('cmp')
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
  })
})

-- Telescope key mappings
vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { noremap = true })
```

### Install Python LSP Server

Install pyright for Python language server support:

```bash
# Using npm
npm install -g pyright

# Using pip
pip install pyright
```

### Advanced Configuration

Create language-specific settings:

```lua
-- ~/.config/nvim/ftplugin/python.lua

-- Python-specific settings
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4
vim.opt_local.expandtab = true
vim.opt_local.colorcolumn = '88'  -- Black's default line length

-- Key mappings for Python development
vim.api.nvim_buf_set_keymap(0, 'n', '<leader>r', ':!python %<CR>', { noremap = true })
vim.api.nvim_buf_set_keymap(0, 'n', '<leader>t', ':!pytest %<CR>', { noremap = true })
```

## Linting and Formatting

### Using Black and isort

Install formatters:

```bash
pip install black isort
```

Configure Neovim to format Python files on save:

```lua
-- Add to your init.lua or ftplugin/python.lua

-- Format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function()
    vim.cmd("silent !black %")
    vim.cmd("silent !isort %")
  end,
})
```

### Using flake8 and mypy

Install linters:

```bash
pip install flake8 mypy
```

Create configuration files:

```bash
# ~/.config/flake8
[flake8]
max-line-length = 88
extend-ignore = E203
exclude = .git,__pycache__,build,dist

# ~/.config/mypy/config
[mypy]
python_version = 3.11
warn_return_any = True
warn_unused_configs = True
disallow_untyped_defs = True
disallow_incomplete_defs = True
```

Configure Neovim to use Null-LS for linting:

```lua
-- Add to your init.lua
use 'jose-elias-alvarez/null-ls.nvim'

-- Configure null-ls
local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.isort,
    null_ls.builtins.diagnostics.flake8,
    null_ls.builtins.diagnostics.mypy,
  },
})
```

## Testing Tools

### Setting Up pytest

Install pytest and related packages:

```bash
pip install pytest pytest-cov pytest-mock
```

Create a pytest configuration:

```ini
# pytest.ini
[pytest]
testpaths = tests
python_files = test_*.py
python_functions = test_*
python_classes = Test*
addopts = --verbose --cov=src --cov-report=term-missing
```

Create a basic test structure:

```bash
mkdir -p tests/unit tests/integration
touch tests/__init__.py tests/unit/__init__.py tests/integration/__init__.py
```

Example test file:

```python
# tests/unit/test_example.py
import pytest
from src.example import add_numbers

def test_add_numbers():
    assert add_numbers(1, 2) == 3
    assert add_numbers(-1, 1) == 0
    assert add_numbers(0, 0) == 0

def test_add_numbers_with_non_numbers():
    with pytest.raises(TypeError):
        add_numbers("1", 2)
```

Configure Neovim for test running:

```lua
-- Add to your init.lua or ftplugin/python.lua
vim.api.nvim_buf_set_keymap(0, 'n', '<leader>tt', ':!pytest<CR>', { noremap = true })
vim.api.nvim_buf_set_keymap(0, 'n', '<leader>tf', ':!pytest %<CR>', { noremap = true })
vim.api.nvim_buf_set_keymap(0, 'n', '<leader>tc', ':!pytest --cov=src<CR>', { noremap = true })
```

### Setting Up Hypothesis for Property-Based Testing

Install Hypothesis:

```bash
pip install hypothesis
```

Example of property-based testing:

```python
# tests/unit/test_property_based.py
from hypothesis import given, strategies as st
from src.example import add_numbers

@given(st.integers(), st.integers())
def test_add_numbers_properties(a, b):
    # Commutativity
    assert add_numbers(a, b) == add_numbers(b, a)
    
    # Identity element
    assert add_numbers(a, 0) == a
    
    # Associativity
    if abs(a) < 1000 and abs(b) < 1000:  # Avoid integer overflow
        c = 42
        assert add_numbers(add_numbers(a, b), c) == add_numbers(a, add_numbers(b, c))
```

## Debugging Setup

### Using pdb

Basic debugging with Python's built-in debugger:

```python
# Insert this line where you want to break
import pdb; pdb.set_trace()
```

For Python 3.7+, use the built-in breakpoint:

```python
# Insert this line where you want to break
breakpoint()
```

Common pdb commands:
- `n` - Execute the next line
- `s` - Step into a function call
- `c` - Continue execution until the next breakpoint
- `p variable` - Print the value of a variable
- `q` - Quit debugging

### Using ipdb

Install ipdb for an enhanced debugging experience:

```bash
pip install ipdb
```

Set ipdb as the default debugger:

```bash
# Add to ~/.bashrc or ~/.zshrc
export PYTHONBREAKPOINT=ipdb.set_trace
```

### Neovim Debugger Integration

Install nvim-dap for debugger integration:

```lua
-- Add to your plugin setup in init.lua
use 'mfussenegger/nvim-dap'
use 'mfussenegger/nvim-dap-python'
use { "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap"} }

-- Configure Python debugger
require('dap-python').setup('~/.virtualenvs/debugpy/bin/python')
require("dapui").setup()

-- Key mappings for debugging
vim.api.nvim_set_keymap('n', '<leader>db', ':lua require("dap").toggle_breakpoint()<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>dc', ':lua require("dap").continue()<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>do', ':lua require("dap").step_over()<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>di', ':lua require("dap").step_into()<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>dr', ':lua require("dap").repl.open()<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>du', ':lua require("dapui").toggle()<CR>', { noremap = true })
```

Set up debugpy:

```bash
python -m venv ~/.virtualenvs/debugpy
~/.virtualenvs/debugpy/bin/pip install debugpy
```

## Project Scaffolding

### Creating a New Python Project Structure

Basic project structure:

```
project_name/
├── .git/
├── .gitignore
├── README.md
├── LICENSE
├── pyproject.toml
├── src/
│   └── project_name/
│       ├── __init__.py
│       ├── main.py
│       └── module1/
│           ├── __init__.py
│           └── module1.py
├── tests/
│   ├── __init__.py
│   ├── unit/
│   │   ├── __init__.py
│   │   └── test_module1.py
│   └── integration/
│       ├── __init__.py
│       └── test_integration.py
└── docs/
    ├── conf.py
    ├── index.rst
    └── api.rst
```

Create a script to scaffold new projects:

```bash
#!/bin/bash
# create_python_project.sh

if [ $# -ne 1 ]; then
    echo "Usage: $0 project_name"
    exit 1
fi

PROJECT_NAME=$1
SNAKE_CASE_NAME=$(echo $PROJECT_NAME | tr '-' '_')

mkdir -p $PROJECT_NAME/src/$SNAKE_CASE_NAME
mkdir -p $PROJECT_NAME/tests/unit
mkdir -p $PROJECT_NAME/tests/integration
mkdir -p $PROJECT_NAME/docs

# Create basic files
touch $PROJECT_NAME/src/$SNAKE_CASE_NAME/__init__.py
touch $PROJECT_NAME/src/$SNAKE_CASE_NAME/main.py
touch $PROJECT_NAME/tests/__init__.py
touch $PROJECT_NAME/tests/unit/__init__.py
touch $PROJECT_NAME/tests/integration/__init__.py

# Create README
cat > $PROJECT_NAME/README.md << EOF
# $PROJECT_NAME

## Description
A brief description of your project.

## Installation
\`\`\`bash
pip install $PROJECT_NAME
\`\`\`

## Usage
\`\`\`python
from $SNAKE_CASE_NAME import main

main.run()
\`\`\`

## License
MIT
EOF

# Create pyproject.toml
cat > $PROJECT_NAME/pyproject.toml << EOF
[build-system]
requires = ["poetry-core>=1.0.0"]
build-backend = "poetry.core.masonry.api"

[tool.poetry]
name = "$PROJECT_NAME"
version = "0.1.0"
description = ""
authors = ["Your Name <your.email@example.com>"]
readme = "README.md"
packages = [{include = "$SNAKE_CASE_NAME", from = "src"}]

[tool.poetry.dependencies]
python = "^3.11"

[tool.poetry.group.dev.dependencies]
pytest = "^7.3.1"
black = "^23.3.0"
isort = "^5.12.0"
mypy = "^1.3.0"
flake8 = "^6.0.0"

[tool.black]
line-length = 88

[tool.isort]
profile = "black"

[tool.mypy]
python_version = "3.11"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = "test_*.py"
python_functions = "test_*"
python_classes = "Test*"
addopts = "--verbose --cov=$SNAKE_CASE_NAME --cov-report=term-missing"
EOF

# Create .gitignore
cat > $PROJECT_NAME/.gitignore << EOF
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# Distribution / packaging
dist/
build/
*.egg-info/

# Unit test / coverage reports
htmlcov/
.tox/
.coverage
.coverage.*
.cache
coverage.xml
*.cover

# Environments
.env
.venv
env/
venv/
ENV/

# mypy
.mypy_cache/

# IDE
.idea/
.vscode/
*.swp
*.swo
EOF

# Create main.py
cat > $PROJECT_NAME/src/$SNAKE_CASE_NAME/main.py << EOF
"""Main module for $PROJECT_NAME."""

def run():
    """Run the main application."""
    print("Hello from $PROJECT_NAME!")

if __name__ == "__main__":
    run()
EOF

# Create sample test
cat > $PROJECT_NAME/tests/unit/test_main.py << EOF
"""Tests for the main module."""
from $SNAKE_CASE_NAME import main

def test_run(capsys):
    """Test that run() prints the expected message."""
    main.run()
    captured = capsys.readouterr()
    assert "Hello from $PROJECT_NAME!" in captured.out
EOF

# Initialize git repository
cd $PROJECT_NAME
git init
git add .
git commit -m "Initial commit"

echo "Project $PROJECT_NAME created successfully!"
```

Make the script executable:

```bash
chmod +x create_python_project.sh
```

### Using Cookiecutter for Project Templates

Install Cookiecutter:

```bash
pip install cookiecutter
```

Use a template:

```bash
cookiecutter https://github.com/audreyfeldroy/cookiecutter-pypackage
```

## Development Workflow

### Terminal-Centric Workflow with tmux

Install tmux:

```bash
# Arch Linux
sudo pacman -S tmux

# NixOS
# Add to configuration.nix
environment.systemPackages = with pkgs; [
  tmux
];
```

Create a tmux configuration:

```bash
# ~/.tmux.conf
# Use C-a as prefix
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# Reload config
bind r source-file ~/.tmux.conf \; display "Config reloaded!"

# Split panes using | and -
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# Switch panes using Alt-arrow
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Enable mouse mode
set -g mouse on

# Set vi mode
setw -g mode-keys vi

# Increase history limit
set -g history-limit 10000

# Set base index to 1
set -g base-index 1
setw -g pane-base-index 1

# Status bar
set -g status-bg black
set -g status-fg white
set -g status-left "#[fg=green]#S #[fg=yellow]#I #[fg=cyan]#P"
set -g status-right "#[fg=cyan]%d %b %R"
```

Create a Python development session script:

```bash
#!/bin/bash
# pydev.sh

SESSION="python-dev"
VENV=".venv"

# Check if the session already exists
tmux has-session -t $SESSION 2>/dev/null

if [ $? != 0 ]; then
    # Create a new session
    tmux new-session -d -s $SESSION

    # Split window into panes
    tmux split-window -h -t $SESSION:0
    tmux split-window -v -t $SESSION:0.1

    # Activate virtual environment in all panes
    tmux send-keys -t $SESSION:0.0 "if [ -d $VENV ]; then source $VENV/bin/activate; fi" C-m
    tmux send-keys -t $SESSION:0.1 "if [ -d $VENV ]; then source $VENV/bin/activate; fi" C-m
    tmux send-keys -t $SESSION:0.2 "if [ -d $VENV ]; then source $VENV/bin/activate; fi" C-m

    # Set up editor
    tmux send-keys -t $SESSION:0.0 "nvim" C-m

    # Set up test runner
    tmux send-keys -t $SESSION:0.1 "clear && echo 'Test Runner'" C-m

    # Set up Python REPL
    tmux send-keys -t $SESSION:0.2 "python" C-m
fi

# Attach to the session
tmux attach-session -t $SESSION
```

Make the script executable:

```bash
chmod +x pydev.sh
```

### Using Git Hooks for Code Quality

Create a pre-commit hook for code quality checks:

```bash
mkdir -p .git/hooks
```

Create a pre-commit hook file:

```bash
# .git/hooks/pre-commit
#!/bin/bash

# Get all Python files that are staged for commit
files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.py)

if [ -z "$files" ]; then
    exit 0
fi

echo "Running pre-commit checks on Python files..."

# Check for syntax errors
for file in $files; do
    python -m py_compile "$file"
    if [ $? -ne 0 ]; then
        echo "Syntax error in $file. Fix errors before committing."
        exit 1
    fi
done

# Run isort
isort --check-only $files
if [ $? -ne 0 ]; then
    echo "isort check failed. Run 'isort $files' to fix imports."
    exit 1
fi

# Run black
black --check $files
if [ $? -ne 0 ]; then
    echo "black check failed. Run 'black $files' to format code."
    exit 1
fi

# Run flake8
flake8 $files
if [ $? -ne 0 ]; then
    echo "flake8 check failed. Fix linting issues before committing."
    exit 1
fi

# Run mypy
mypy $files
if [ $? -ne 0 ]; then
    echo "mypy check failed. Fix type issues before committing."
    exit 1
fi

echo "All pre-commit checks passed!"
exit 0
```

Make the hook executable:

```bash
chmod +x .git/hooks/pre-commit
```

### Automating with Makefiles

Create a Makefile for common tasks:

```makefile
# Makefile

.PHONY: setup test lint format clean build docs

PYTHON = python
PIP = $(PYTHON) -m pip
PYTEST = pytest
BLACK = black
ISORT = isort
FLAKE8 = flake8
MYPY = mypy
SPHINX_BUILD = sphinx-build

SRC_DIR = src
TEST_DIR = tests
DOC_DIR = docs
BUILD_DIR = build

PACKAGE_NAME = your_package_name
PYTHON_FILES = $(SRC_DIR) $(TEST_DIR) setup.py

# Setup development environment
setup:
	$(PIP) install -e ".[dev]"

# Run tests
test:
	$(PYTEST) $(TEST_DIR) --cov=$(SRC_DIR) --cov-report=term-missing

# Run linting
lint:
	$(FLAKE8) $(PYTHON_FILES)
	$(MYPY) $(PYTHON_FILES)

# Format code
format:
	$(BLACK) $(PYTHON_FILES)
	$(ISORT) $(PYTHON_FILES)

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)
	rm -rf dist
	rm -rf *.egg-info
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type d -name .pytest_cache -exec rm -rf {} +
	find . -type d -name .coverage -exec rm -rf {} +

# Build package
build: clean
	$(PYTHON) -m build

# Generate documentation
docs:
	$(SPHINX_BUILD) $(DOC_DIR) $(BUILD_DIR)/docs

# Run all checks
check: lint test

# Default target
all: format lint test
```

## Performance Optimization

### Profile Python Code

Use cProfile to profile your code:

```python
import cProfile
import pstats
from pstats import SortKey

# Profile a function
def profile_function(func, *args, **kwargs):
    profiler = cProfile.Profile()
    profiler.enable()
    result = func(*args, **kwargs)
    profiler.disable()
    stats = pstats.Stats(profiler).sort_stats(SortKey.CUMULATIVE)
    stats.print_stats(20)  # Print top 20 functions
    return result

# Example usage
if __name__ == "__main__":
    def example_function():
        total = 0
        for i in range(1000000):
            total += i
        return total
            
    profile_function(example_function)
```

Using memory-profiler:

```bash
pip install memory-profiler
```

Add the @profile decorator to functions:

```python
from memory_profiler import profile

@profile
def memory_intensive_function():
    big_list = [i for i in range(10000000)]
    del big_list
    return "Done"

if __name__ == "__main__":
    memory_intensive_function()
```

Run with:

```bash
python -m memory_profiler script.py
```

### Using Numba for Performance

Install Numba:

```bash
pip install numba
```

Example of just-in-time compilation:

```python
from numba import jit
import numpy as np
import time

# Function without JIT
def sum_array_python(arr):
    result = 0
    for i in range(len(arr)):
        result += arr[i]
    return result

# Function with JIT
@jit(nopython=True)
def sum_array_numba(arr):
    result = 0
    for i in range(len(arr)):
        result += arr[i]
    return result

# Benchmark
arr = np.random.rand(10000000)

start = time.time()
sum_array_python(arr)
python_time = time.time() - start

start = time.time()
sum_array_numba(arr)  # First run includes compilation
numba_time = time.time() - start

start = time.time()
sum_array_numba(arr)  # Second run uses compiled code
numba_time_compiled = time.time() - start

print(f"Python time: {python_time:.4f}s")
print(f"Numba time (with compilation): {numba_time:.4f}s")
print(f"Numba time (compiled): {numba_time_compiled:.4f}s")
```

## Acknowledgements

This guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Documentation writing and organization
- Code structure suggestions
- Configuration examples

Claude was used as a development aid while all final implementation decisions and code review were performed by Joshua Michael Hall.

## Disclaimer

This guide is provided "as is", without warranty of any kind, express or implied. The authors or copyright holders shall not be liable for any claim, damages or other liability arising from the use of the software.

This project is a work in progress and may contain bugs or incomplete features. Users are encouraged to report any issues they encounter.
