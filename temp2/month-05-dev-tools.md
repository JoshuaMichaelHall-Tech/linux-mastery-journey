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

2. **Plugin Management** (2 hours)
   - Set up a plugin manager (packer.nvim, lazy.nvim)
   - Understand plugin dependencies
   - Install and configure core plugins
   - Learn to troubleshoot plugin issues

3. **LSP Configuration** (3 hours)
   - Set up nvim-lspconfig
   - Configure language servers
   - Implement code completion with nvim-cmp
   - Set up linting and formatting

4. **Navigation and Search** (3 hours)
   - Configure telescope.nvim for fuzzy finding
   - Set up file browsing with nvim-tree or similar
   - Implement symbol and reference navigation
   - Configure buffer and tab management

### Resources

- [Neovim Documentation](https://neovim.io/doc/)
- [From init.vim to init.lua](https://teukka.tech/luanvim.html)
- [LSP Configuration Guide](https://github.com/neovim/nvim-lspconfig)
- [Awesome Neovim](https://github.com/rockerBOO/awesome-neovim)
- [Lua Guide for Neovim](https://github.com/nanotee/nvim-lua-guide)

## Week 2: Python Development Environment

### Core Learning Activities

1. **Python Installation and Management** (2 hours)
   - Set up pyenv for multiple Python versions
   - Configure virtual environments
   - Understand Python packaging
   - Install development tools (pip, poetry)

2. **Python Language Server Configuration** (2 hours)
   - Set up pyright or python-lsp-server
   - Configure completion and type checking
   - Implement docstring support
   - Set up import sorting and formatting

3. **Testing and Debugging** (3 hours)
   - Configure pytest integration
   - Set up debugging with nvim-dap
   - Learn to use breakpoints effectively
   - Set up test running from Neovim

4. **Python Project Structure** (3 hours)
   - Learn best practices for Python projects
   - Set up project templates
   - Configure dependency management
   - Implement documentation tools

### Resources

- [Python Guide for Neovim](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#pyright)
- [Python Development Environment](https://realpython.com/python-development-environment-101/)
- [Debugging Python with nvim-dap](https://github.com/mfussenegger/nvim-dap-python)
- [Python Project Structure Guide](https://docs.python-guide.org/writing/structure/)
- [Poetry Documentation](https://python-poetry.org/docs/)

## Week 3: JavaScript/TypeScript Development Environment

### Core Learning Activities

1. **Node.js and JavaScript Setup** (2 hours)
   - Configure nvm for Node.js version management
   - Set up npm/yarn/pnpm configuration
   - Install essential development tools
   - Configure .npmrc for Linux

2. **JavaScript/TypeScript LSP** (2 hours)
   - Set up tsserver language server
   - Configure ESLint and Prettier integration
   - Implement TypeScript support
   - Set up JSX/TSX support

3. **Web Development Workflow** (3 hours)
   - Configure browser integration
   - Set up live reloading
   - Implement API testing tools
   - Configure frontend frameworks

4. **JavaScript Testing and Debugging** (3 hours)
   - Set up Jest integration
   - Configure Chrome debugger
   - Implement console.log enhancement
   - Set up React DevTools

### Resources

- [JavaScript/TypeScript Configuration Guide](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#tsserver)
- [nvm Documentation](https://github.com/nvm-sh/nvm)
- [Modern JavaScript Development](https://developer.mozilla.org/en-US/docs/Learn/Tools_and_testing/Understanding_client-side_tools/Overview)
- [TypeScript Project References](https://www.typescriptlang.org/docs/handbook/project-references.html)
- [ESLint Configuration](https://eslint.org/docs/user-guide/configuring/)

## Week 4: Version Control and Workflow Integration

### Core Learning Activities

1. **Advanced Git Configuration** (3 hours)
   - Set up global Git configuration
   - Configure Git hooks
   - Implement commit signing
   - Configure multi-account setup
   - Create useful Git aliases

2. **Neovim Git Integration** (2 hours)
   - Configure fugitive.vim
   - Set up git signs for line changes
   - Implement diffview.nvim
   - Configure git blame integration

3. **Project-Specific Workflows** (2 hours)
   - Create project-specific settings
   - Implement per-project configuration
   - Set up project templates
   - Configure task automation

4. **Integrated Development Environment** (3 hours)
   - Set up terminal integration in Neovim
   - Configure database clients
   - Implement API tools
   - Set up documentation viewers

### Resources

- [Git Documentation](https://git-scm.com/doc)
- [Fugitive.vim Documentation](https://github.com/tpope/vim-fugitive)
- [Git Workflows Guide](https://www.atlassian.com/git/tutorials/comparing-workflows)
- [Project-Specific Configuration in Neovim](https://github.com/klen/nvim-config-local)
- [Terminal Integration in Neovim](https://github.com/akinsho/toggleterm.nvim)

## Projects and Exercises

1. **Neovim Configuration Overhaul**
   - Create a complete Lua-based Neovim configuration
   - Implement language-specific settings
   - Configure efficient keybindings
   - Document your setup with comments

2. **Polyglot Project Development**
   - Create a project using multiple languages
   - Implement consistent formatting across languages
   - Configure testing for all components
   - Set up an automated build process

3. **Custom Development Toolkit**
   - Create scripts for common development tasks
   - Implement project scaffolding tools
   - Build a documentation generator
   - Create custom linting rules

4. **Git Workflow Enhancement**
   - Create custom Git hooks for quality control
   - Implement automated testing before commits
   - Configure branch policies
   - Create a PR template and review process

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
