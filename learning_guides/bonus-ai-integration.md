# Bonus Month: AI Integration for Linux Development

This bonus module extends the Linux Mastery Journey by exploring how to effectively integrate AI tools and services into your Linux development environment. By the end of this month, you'll have a sophisticated AI-augmented workflow that enhances productivity and enables new capabilities in your software development process.

## Time Commitment: ~10 hours/week for 4 weeks

## AI Integration Learning Path

```
Week 1                 Week 2                 Week 3                 Week 4
┌─────────────┐       ┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│ Foundation  │       │ Code        │       │ Content     │       │ Custom      │
│    &        │──────▶│ Assistance  │──────▶│ Generation  │──────▶│ Integration │
│ Setup       │       │ Tools       │       │ Workflows   │       │ Projects    │
└─────────────┘       └─────────────┘       └─────────────┘       └─────────────┘
```

## Learning Objectives

By the end of this bonus month, you should be able to:

1. Configure and optimize AI services and APIs within a Linux environment
2. Implement efficient CLI-based AI workflows using terminal tools
3. Integrate AI assistants into your code editor and development environment
4. Create custom scripts that leverage AI capabilities for specific development tasks
5. Implement effective prompt engineering techniques for different development scenarios
6. Design and implement AI-powered automation for repetitive coding tasks
7. Develop a personal knowledge management system enhanced by AI capabilities
8. Evaluate and mitigate ethical and security concerns when using AI in development
9. Create custom AI-powered tools specific to your development workflow
10. Implement a comprehensive AI-augmented development environment

## Week 1: Foundation and Setup

### Core Learning Activities

1. **Understanding AI Services and APIs** (2 hours)
   - Overview of available AI services (OpenAI, Anthropic, Hugging Face, etc.)
   - API access patterns and authentication methods
   - Rate limits, pricing, and usage considerations
   - Evaluating service capabilities and limitations

2. **Setting Up API Access** (2 hours)
   - Creating API keys and managing credentials securely
   - Storing API tokens using environment variables
   - Setting up credential management with pass or gpg
   - Implementing token rotation and security best practices

3. **Terminal-Based AI Interfaces** (3 hours)
   - Installing and configuring AI CLI tools
   - Setting up shell integrations for AI assistance
   - Creating custom aliases and functions for common AI operations
   - Configuring completion and suggestion tools

4. **Environment Configuration** (3 hours)
   - Creating a dedicated Python virtual environment for AI tools
   - Setting up Docker containers for local AI services
   - Configuring shell startup files with AI tool initializations
   - Implementing tooling for offline fallbacks

### Environment Setup Instructions

#### Installing Core AI CLI Tools

```bash
# Create a dedicated Python environment for AI tools
python -m venv ~/.local/share/ai-tools
source ~/.local/share/ai-tools/bin/activate

# Install essential packages
pip install openai anthropic llama-index langchain httpx pydantic

# Install CLI tools
pip install shell-gpt aichat llm

# Create a secure directory for AI configurations
mkdir -p ~/.config/ai-tools
chmod 700 ~/.config/ai-tools
```

#### Setting Up API Credentials

```bash
# Create a secure environment file
touch ~/.config/ai-tools/credentials.env
chmod 600 ~/.config/ai-tools/credentials.env

# Add your API keys
cat > ~/.config/ai-tools/credentials.env << EOF
OPENAI_API_KEY=your_openai_key_here
ANTHROPIC_API_KEY=your_anthropic_key_here
HUGGINGFACE_API_KEY=your_huggingface_key_here
EOF

# Add to your shell configuration (.zshrc, .bashrc)
echo 'source ~/.config/ai-tools/credentials.env' >> ~/.zshrc
```

#### Shell Integration Setup

```bash
# Add to your .zshrc or .bashrc
cat >> ~/.zshrc << 'EOF'

# AI Assistant Functions
ai() {
  llm "$@" | bat --style=plain
}

ai_explain() {
  llm "Explain this code: $@" | bat --style=plain
}

ai_improve() {
  llm "Improve this code. Show the improved version and explain your changes: $@" | bat --style=plain
}

# Pipe support
aifilter() {
  input=$(cat)
  llm "$1: $input" | bat --style=plain
}

# Example usage:
# cat file.py | aifilter "explain this code"
EOF
```

### Resources

- [OpenAI API Documentation](https://platform.openai.com/docs/api-reference)
- [Anthropic Claude API Documentation](https://docs.anthropic.com/claude/reference/getting-started-with-the-api)
- [LangChain Documentation](https://python.langchain.com/docs/get_started/introduction)
- [Shell-GPT GitHub Repository](https://github.com/TheR1D/shell_gpt)

## Week 2: Code Assistance Tools

### Core Learning Activities

1. **Code Editor Integration** (3 hours)
   - Installing and configuring AI code assistants for Neovim
   - Setting up GitHub Copilot or alternatives
   - Customizing code completion behavior
   - Implementing keybindings for AI operations

2. **AI-Assisted Code Generation** (2 hours)
   - Effective prompt engineering for code generation
   - Using AI to scaffold projects and boilerplate
   - Implementing test generation workflows
   - Creating documentation with AI assistance

3. **Code Analysis and Improvement** (2 hours)
   - Using AI for code review and suggestions
   - Setting up automated code analysis workflows
   - Implementing refactoring assistance
   - Creating custom AI-based linting tools

4. **Multi-Language Support** (3 hours)
   - Configuring language-specific AI assistance
   - Setting up translation between programming languages
   - Using AI for cross-language documentation
   - Implementing language-specific code snippets

### Neovim Integration Setup

#### Basic Copilot Setup for Neovim

```lua
-- Install with Packer
use {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      suggestion = { enabled = false },
      panel = { enabled = false },
    })
  end,
}

-- Use with cmp
use {
  "zbirenbaum/copilot-cmp",
  after = { "copilot.lua" },
  config = function()
    require("copilot_cmp").setup()
  end,
}

-- Add to your cmp configuration
local cmp = require('cmp')
cmp.setup({
  sources = {
    { name = "copilot" },
    { name = "nvim_lsp" },
    -- other sources
  }
})
```

#### Custom AI Code Helper for Neovim

```lua
-- Add to your init.lua
-- AI Assistant Helper
vim.api.nvim_create_user_command('AI', function(opts)
  local prompt = opts.args
  local input = vim.fn.join(vim.fn.getline(1, '$'), '\n')
  local cmd = string.format('llm "Given this code:\n\n%s\n\n%s"', input, prompt)
  
  -- Create a new buffer for the result
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
  
  -- Open the buffer in a new window
  vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = math.floor(vim.o.columns * 0.8),
    height = math.floor(vim.o.lines * 0.8),
    row = math.floor(vim.o.lines * 0.1),
    col = math.floor(vim.o.columns * 0.1),
    style = 'minimal',
    border = 'rounded',
  })
  
  -- Run the command and capture output
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, data)
      end
    end,
  })
end, { nargs = '+' })

-- Add useful keymappings
vim.keymap.set('v', '<leader>ae', ":'<,'>:AI explain this code<CR>", { noremap = true, silent = true })
vim.keymap.set('v', '<leader>ai', ":'<,'>:AI improve this code<CR>", { noremap = true, silent = true })
vim.keymap.set('v', '<leader>at', ":'<,'>:AI write tests for this code<CR>", { noremap = true, silent = true })
vim.keymap.set('v', '<leader>ad', ":'<,'>:AI document this code<CR>", { noremap = true, silent = true })
```

### Custom Script: AI Code Reviewer

```bash
#!/bin/bash
# ai-code-review.sh - AI-powered code review tool

# Check if file is provided
if [ $# -lt 1 ]; then
  echo "Usage: $0 <file_path>"
  exit 1
fi

FILE_PATH="$1"
FILE_NAME=$(basename "$FILE_PATH")
FILE_EXT="${FILE_NAME##*.}"
FILE_CONTENT=$(cat "$FILE_PATH")

echo "🔍 Reviewing $FILE_NAME..."
echo

# Create a prompt based on file type
case "$FILE_EXT" in
  py)
    PROMPT="Review this Python code for: 1) Bugs and potential errors, 2) PEP8 compliance, 3) Performance issues, 4) Security vulnerabilities, 5) Suggested improvements. Format your response with markdown headers for each section."
    ;;
  js|ts)
    PROMPT="Review this JavaScript/TypeScript code for: 1) Bugs and potential errors, 2) Code style (ESLint), 3) Performance issues, 4) Security vulnerabilities, 5) Suggested improvements. Format your response with markdown headers for each section."
    ;;
  *)
    PROMPT="Review this code for: 1) Bugs and potential errors, 2) Code style, 3) Performance issues, 4) Security vulnerabilities, 5) Suggested improvements. Format your response with markdown headers for each section."
    ;;
esac

# Send to AI service and display results
echo "$FILE_CONTENT" | llm "$PROMPT" | bat --style=plain --language=markdown

echo
echo "✅ Review complete for $FILE_NAME"
```

Make it executable:
```bash
chmod +x ai-code-review.sh
sudo mv ai-code-review.sh /usr/local/bin/ai-code-review
```

### Resources

- [Copilot.lua GitHub Repository](https://github.com/zbirenbaum/copilot.lua)
- [Neovim LSP Configuration Guide](https://github.com/neovim/nvim-lspconfig)
- [Prompt Engineering for Developers](https://github.com/dair-ai/Prompt-Engineering-Guide)
- [OpenAI Code Examples](https://platform.openai.com/examples?category=code)

## Week 3: Content Generation Workflows

### Core Learning Activities

1. **Documentation Generation** (3 hours)
   - Using AI to create project documentation
   - Setting up automated README generation
   - Implementing docstring and comment generation
   - Creating user guides and technical documentation

2. **AI-Assisted Writing Tools** (2 hours)
   - Integrating AI writing assistants in your workflow
   - Setting up grammar and style improvement tools
   - Implementing technical blog post generation
   - Creating presentation and teaching materials

3. **Data Analysis and Visualization** (2 hours)
   - Using AI to generate data analysis scripts
   - Setting up automated report generation
   - Implementing dataset exploration workflows
   - Creating visualization code with AI

4. **Internationalization and Localization** (3 hours)
   - Using AI for translation of documentation
   - Setting up multi-language support workflows
   - Implementing culturally appropriate content generation
   - Creating region-specific versions of content

### Automation Scripts

#### Automatic README Generator

```bash
#!/bin/bash
# ai-readme-gen.sh - Generate project README with AI

# Check if directory is provided
if [ $# -lt 1 ]; then
  DIR="."
else
  DIR="$1"
fi

# Gather project info
PROJECT_NAME=$(basename "$(realpath "$DIR")")
LANG_FILES=$(find "$DIR" -type f -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" -o -name "*.rs" -o -name "*.cpp" -o -name "*.c" | wc -l)
MAIN_LANG=$(find "$DIR" -type f -name "*.*" | grep -v "node_modules\|venv\|.git" | sed 's/.*\.//' | sort | uniq -c | sort -nr | head -n1 | awk '{print $2}')

# Find core files
MAIN_FILES=$(find "$DIR" -maxdepth 2 -type f -name "*.py" -o -name "package.json" -o -name "Cargo.toml" -o -name "go.mod" -o -name "CMakeLists.txt" | head -n3)

# Collect sample content
SAMPLE=""
for file in $MAIN_FILES; do
  SAMPLE+="File: $file\n\n"
  SAMPLE+=$(head -n30 "$file")
  SAMPLE+="\n\n------\n\n"
done

echo "🔍 Analyzing project: $PROJECT_NAME"
echo "📊 Detected $LANG_FILES code files, primarily $MAIN_LANG"
echo "🔄 Generating README.md..."

# Create prompt for AI
PROMPT="Generate a comprehensive README.md file for this project called '$PROJECT_NAME'. It appears to be primarily a $MAIN_LANG project.

Here are some sample files from the codebase:

$SAMPLE

Your README should include:
1. A clear project title and concise description
2. Installation instructions
3. Usage examples
4. Features list
5. Contribution guidelines
6. License information
7. Acknowledgements (including 'developed with assistance from Anthropic's Claude')

Format everything in professional markdown. Focus on being informative and clear."

# Generate README
echo -e "$PROMPT" | llm | tee "$DIR/README.md.generated"

echo
echo "✅ README.md generated as 'README.md.generated'"
echo "📝 Review the generated content before renaming it to README.md"
```

Make it executable:
```bash
chmod +x ai-readme-gen.sh
sudo mv ai-readme-gen.sh /usr/local/bin/ai-readme-gen
```

#### Documentation Generator

```bash
#!/bin/bash
# ai-docs-gen.sh - Generate code documentation with AI

# Check if file is provided
if [ $# -lt 1 ]; then
  echo "Usage: $0 <file_path>"
  exit 1
fi

FILE_PATH="$1"
FILE_NAME=$(basename "$FILE_PATH")
FILE_EXT="${FILE_NAME##*.}"
FILE_CONTENT=$(cat "$FILE_PATH")
OUTPUT_FILE="${FILE_PATH%.*}.docs.md"

echo "🔍 Generating documentation for $FILE_NAME..."
echo

# Create a prompt based on file type
case "$FILE_EXT" in
  py)
    PROMPT="Generate comprehensive documentation for this Python code. Include:
1. Overview of what this code does
2. Detailed explanation of each class and function
3. Parameters, return values, and exceptions for each function
4. Examples of how to use the main functions
5. Dependencies and requirements
6. Any edge cases or limitations

Format as markdown with proper headers, code blocks, and tables where appropriate."
    ;;
  js|ts)
    PROMPT="Generate comprehensive documentation for this JavaScript/TypeScript code. Include:
1. Overview of what this code does
2. Detailed explanation of each class, function, and component
3. Parameters, return values, and exceptions for each function
4. Examples of how to use the main functions
5. Dependencies and requirements
6. Any edge cases or limitations

Format as markdown with proper headers, code blocks, and tables where appropriate."
    ;;
  *)
    PROMPT="Generate comprehensive documentation for this code. Include:
1. Overview of what this code does
2. Detailed explanation of each part of the code
3. Parameters, return values, and exceptions for functions
4. Examples of how to use the code
5. Dependencies and requirements
6. Any edge cases or limitations

Format as markdown with proper headers, code blocks, and tables where appropriate."
    ;;
esac

# Send to AI service and save results
echo "$FILE_CONTENT" | llm "$PROMPT" > "$OUTPUT_FILE"

echo
echo "✅ Documentation generated: $OUTPUT_FILE"
```

Make it executable:
```bash
chmod +x ai-docs-gen.sh
sudo mv ai-docs-gen.sh /usr/local/bin/ai-docs-gen
```

### Resources

- [Awesome Markdown Guide](https://github.com/BubuAnabelas/awesome-markdown)
- [Technical Writing with AI Course](https://developers.google.com/tech-writing)
- [Data Visualization Best Practices](https://www.tableau.com/learn/articles/data-visualization-best-practices)
- [Internationalization (i18n) Best Practices](https://www.w3.org/International/quicktips/doc/i18n-quicktips)

## Week 4: Custom Integration Projects

### Core Learning Activities

1. **Custom AI Tools Development** (3 hours)
   - Designing personalized AI tools for your workflow
   - Building CLI applications with AI capabilities
   - Creating workflow automation with AI components
   - Implementing custom prompt templates

2. **Embedding AI in Applications** (3 hours)
   - Integrating AI APIs into your applications
   - Building AI-enhanced features for your projects
   - Implementing semantic search capabilities
   - Creating AI-powered user interfaces

3. **AI Development Assistant Bot** (2 hours)
   - Creating a custom development assistant
   - Setting up context-aware help systems
   - Implementing project-specific assistance
   - Building learning and feedback mechanisms

4. **Project: AI-Powered Development Environment** (2 hours)
   - Designing comprehensive AI integration for your workflow
   - Setting up a consistent AI assistance layer
   - Implementing cross-tool compatibility
   - Creating a personal development copilot

### Custom Development Assistant Project

#### AI Development Assistant Script

```python
#!/usr/bin/env python3
# devassist.py - AI-powered development assistant

import argparse
import os
import sys
import json
import subprocess
from pathlib import Path
from typing import Dict, List, Optional, Union
import httpx

# Configuration
CONFIG_DIR = Path.home() / '.config' / 'devassist'
CONFIG_FILE = CONFIG_DIR / 'config.json'
HISTORY_FILE = CONFIG_DIR / 'history.json'
DEFAULT_MODEL = "claude-3-opus-20240229"
DEFAULT_CONFIG = {
    "api_key": os.environ.get("ANTHROPIC_API_KEY", ""),
    "model": DEFAULT_MODEL,
    "max_tokens": 2000,
    "temperature": 0.7,
    "project_contexts": {},
    "common_tools": ["git", "docker", "python", "javascript", "linux"],
    "command_history_size": 50
}

# Ensure config directory exists
CONFIG_DIR.mkdir(parents=True, exist_ok=True)

# Load or create configuration
def load_config() -> Dict:
    if CONFIG_FILE.exists():
        with open(CONFIG_FILE, 'r') as f:
            return json.load(f)
    else:
        # Create default config
        with open(CONFIG_FILE, 'w') as f:
            json.dump(DEFAULT_CONFIG, f, indent=2)
        return DEFAULT_CONFIG

# Save configuration
def save_config(config: Dict) -> None:
    with open(CONFIG_FILE, 'w') as f:
        json.dump(config, f, indent=2)

# Load command history
def load_history() -> List[Dict]:
    if HISTORY_FILE.exists():
        with open(HISTORY_FILE, 'r') as f:
            return json.load(f)
    return []

# Save command history
def save_history(history: List[Dict]) -> None:
    with open(HISTORY_FILE, 'w') as f:
        json.dump(history, f, indent=2)

# Add to command history
def add_to_history(query: str, response: str, config: Dict) -> None:
    history = load_history()
    history.append({"query": query, "response": response})
    # Limit history size
    if len(history) > config['command_history_size']:
        history = history[-config['command_history_size']:]
    save_history(history)

# Get project context
def get_project_context(config: Dict) -> str:
    # Get current directory
    current_dir = os.getcwd()
    
    # Check if we have a stored context for this directory
    if current_dir in config['project_contexts']:
        return config['project_contexts'][current_dir]
    
    # Try to detect project type
    context = "Project information:\n"
    
    # Check for git repo
    try:
        if os.path.exists(os.path.join(current_dir, '.git')):
            # Get remote URL
            result = subprocess.run(['git', 'remote', 'get-url', 'origin'], 
                                    capture_output=True, text=True, check=False)
            if result.returncode == 0:
                context += f"Git repository: {result.stdout.strip()}\n"
            
            # Get active branch
            result = subprocess.run(['git', 'branch', '--show-current'], 
                                    capture_output=True, text=True, check=False)
            if result.returncode == 0:
                context += f"Current branch: {result.stdout.strip()}\n"
                
            # Get last commit
            result = subprocess.run(['git', 'log', '-1', '--oneline'], 
                                    capture_output=True, text=True, check=False)
            if result.returncode == 0:
                context += f"Last commit: {result.stdout.strip()}\n"
    except Exception:
        pass
    
    # Check for common project files
    for file, description in [
        ('package.json', 'Node.js project'),
        ('requirements.txt', 'Python project'),
        ('Cargo.toml', 'Rust project'),
        ('go.mod', 'Go project'),
        ('pom.xml', 'Java Maven project'),
        ('build.gradle', 'Java Gradle project'),
        ('CMakeLists.txt', 'C/C++ CMake project'),
        ('Dockerfile', 'Docker project'),
        ('docker-compose.yml', 'Docker Compose project')
    ]:
        if os.path.exists(os.path.join(current_dir, file)):
            context += f"Detected {description} ({file})\n"
    
    # Store context for future use
    config['project_contexts'][current_dir] = context
    save_config(config)
    
    return context

# Call AI API
def ask_ai(query: str, config: Dict, system_prompt: Optional[str] = None) -> str:
    api_key = config.get('api_key')
    
    if not api_key:
        return "Error: API key not set. Set it using 'devassist config --api-key YOUR_API_KEY'"
    
    # Build prompt with context and query
    if not system_prompt:
        system_prompt = """You are a helpful AI development assistant integrated into a Linux development environment. 
Your purpose is to provide concise, relevant assistance for software development tasks.
When answering:
1. Be direct and to the point - developers value brevity
2. Include code examples where appropriate
3. For commands, show both the command and a brief explanation
4. Use proper markdown formatting for code blocks and command syntax
5. Assume a terminal environment unless specified otherwise"""
    
    # Get project context
    project_context = get_project_context(config)
    
    # Create API payload
    payload = {
        "model": config['model'],
        "max_tokens": config['max_tokens'],
        "temperature": config['temperature'],
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": f"{project_context}\n\nQuestion: {query}"}
        ]
    }
    
    # Call API
    try:
        response = httpx.post(
            "https://api.anthropic.com/v1/messages",
            headers={
                "x-api-key": api_key,
                "anthropic-version": "2023-06-01",
                "content-type": "application/json"
            },
            json=payload,
            timeout=30.0
        )
        response.raise_for_status()
        result = response.json()
        return result['content'][0]['text']
    except Exception as e:
        return f"Error calling AI API: {str(e)}"

# Command handlers
def handle_ask(args: argparse.Namespace, config: Dict) -> None:
    query = args.query if args.query else input("What would you like to know? ")
    response = ask_ai(query, config)
    print(response)
    add_to_history(query, response, config)

def handle_explain(args: argparse.Namespace, config: Dict) -> None:
    if args.file:
        # Explain code from file
        try:
            with open(args.file, 'r') as f:
                code = f.read()
            query = f"Explain this code:\n\n```\n{code}\n```"
        except Exception as e:
            print(f"Error reading file: {e}")
            return
    else:
        # Get code from stdin
        if sys.stdin.isatty():
            print("Enter code to explain (Ctrl+D to finish):")
            code = sys.stdin.read()
        else:
            code = sys.stdin.read()
        query = f"Explain this code:\n\n```\n{code}\n```"
    
    response = ask_ai(query, config)
    print(response)
    add_to_history(query, response, config)

def handle_command(args: argparse.Namespace, config: Dict) -> None:
    task = args.task
    query = f"I need a command to {task}. Please provide just the command with a brief explanation."
    response = ask_ai(query, config)
    print(response)
    add_to_history(query, response, config)

def handle_history(args: argparse.Namespace, config: Dict) -> None:
    history = load_history()
    if not history:
        print("No command history found.")
        return
    
    # Show last n entries
    count = min(args.count, len(history))
    for i, entry in enumerate(history[-count:]):
        index = len(history) - count + i
        print(f"\n[{index}] Query: {entry['query']}")
        if args.full:
            print(f"\nResponse:\n{entry['response']}\n")
            print("-" * 80)

def handle_config(args: argparse.Namespace, config: Dict) -> None:
    if args.list:
        # Print current configuration
        for key, value in config.items():
            if key == 'api_key':
                print(f"api_key: {'*' * 10}")
            elif key == 'project_contexts':
                print(f"project_contexts: {len(value)} stored contexts")
            else:
                print(f"{key}: {value}")
    else:
        # Update configuration
        changes = False
        for key, value in vars(args).items():
            if key not in ['command', 'list'] and value is not None:
                if key == 'clear_contexts':
                    if value:
                        config['project_contexts'] = {}
                        changes = True
                else:
                    config[key] = value
                    changes = True
        
        if changes:
            save_config(config)
            print("Configuration updated successfully.")

# Main function
def main():
    config = load_config()
    
    # Create argument parser
    parser = argparse.ArgumentParser(description="AI-powered Development Assistant")
    subparsers = parser.add_subparsers(dest='command', help='Command to execute')
    
    # Ask command
    ask_parser = subparsers.add_parser('ask', help='Ask a development question')
    ask_parser.add_argument('query', nargs='*', help='Question to ask')
    
    # Explain command
    explain_parser = subparsers.add_parser('explain', help='Explain code')
    explain_parser.add_argument('-f', '--file', help='File containing code to explain')
    
    # Command generator
    cmd_parser = subparsers.add_parser('cmd', help='Generate a command for a task')
    cmd_parser.add_argument('task', help='Task to accomplish')
    
    # History command
    history_parser = subparsers.add_parser('history', help='View command history')
    history_parser.add_argument('-c', '--count', type=int, default=5, help='Number of history items to show')
    history_parser.add_argument('-f', '--full', action='store_true', help='Show full responses')
    
    # Config command
    config_parser = subparsers.add_parser('config', help='Configure the assistant')
    config_parser.add_argument('-l', '--list', action='store_true', help='List current configuration')
    config_parser.add_argument('--api-key', help='Set API key')
    config_parser.add_argument('--model', help='Set AI model')
    config_parser.add_argument('--max-tokens', type=int, help='Set maximum response tokens')
    config_parser.add_argument('--temperature', type=float, help='Set response temperature')
    config_parser.add_argument('--clear-contexts', action='store_true', help='Clear stored project contexts')
    
    # Parse arguments
    args = parser.parse_args()
    
    # Handle commands
    if args.command == 'ask':
        handle_ask(args, config)
    elif args.command == 'explain':
        handle_explain(args, config)
    elif args.command == 'cmd':
        handle_command(args, config)
    elif args.command == 'history':
        handle_history(args, config)
    elif args.command == 'config':
        handle_config(args, config)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
```

Make it executable and install:
```bash
chmod +x devassist.py
sudo cp devassist.py /usr/local/bin/devassist
```

#### AI-Enhanced Git Hooks

Create a pre-commit hook that uses AI to check your code:

```bash
#!/bin/bash
# .git/hooks/pre-commit
# AI-powered code quality checker

# Get staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(py|js|ts|jsx|tsx|go|rs|cpp|c)$')

if [ -z "$STAGED_FILES" ]; then
    exit 0
fi

echo "🔍 AI Code Quality Check"
echo "======================="

# Check if devassist is available
if ! command -v devassist &> /dev/null; then
    echo "devassist not found, skipping AI code check"
    exit 0
fi

# Check each file
CHECK_FAILED=0
for FILE in $STAGED_FILES; do
    echo "Checking $FILE..."
    
    # Get only the staged changes
    STAGED_CONTENT=$(git show ":$FILE")
    
    # Run AI check
    RESULT=$(echo "$STAGED_CONTENT" | devassist ask "Review this code for critical issues only. If there are any potential bugs, security issues, or performance problems, describe them briefly. If the code looks good, just respond with 'PASS'. Keep your response under 200 characters.")
    
    # Check if passed
    if [[ $RESULT == *"PASS"* ]]; then
        echo "✅ $FILE: Passed AI review"
    else
        echo "⚠️ $FILE: Potential issues found:"
        echo "$RESULT"
        CHECK_FAILED=1
    fi
done

if [ $CHECK_FAILED -eq 1 ]; then
    echo
    echo "AI review detected potential issues with your code."
    echo "You can continue with the commit by using git commit --no-verify"
    echo "or fix the issues and commit again."
    exit 1
fi

exit 0
```

Make it executable:
```bash
chmod +x .git/hooks/pre-commit
```

### Resources

- [HTTPX Documentation](https://www.python-httpx.org/)
- [Git Hooks Documentation](https://git-scm.com/docs/githooks)
- [Anthropic API Documentation](https://docs.anthropic.com/claude/reference/)
- [Building CLIs with Python](https://realpython.com/command-line-interfaces-python-argparse/)

## Projects and Exercises

1. **AI-Powered Code Generator** [Intermediate]
   - Create a CLI tool that generates boilerplate code from natural language descriptions
   - Implement language-specific templates and project structures
   - Add validation and testing of generated code

2. **Intelligent Documentation System** [Advanced]
   - Build a documentation generator that analyzes code and produces comprehensive documentation
   - Implement automatic updates when code changes
   - Create a search interface for accessing generated documentation

3. **Personal Coding Assistant** [Advanced]
   - Develop a custom assistant that learns from your coding patterns
   - Implement project-specific context awareness
   - Create a feedback mechanism to improve suggestions over time

4. **AI Development Dashboard** [Expert]
   - Build a web interface for monitoring and interacting with AI services
   - Implement usage tracking and optimization recommendations
   - Create visualization for AI service performance and costs

## Assessment

You should now be able to:

1. Configure and use AI services effectively in your development environment
2. Integrate AI capabilities into your existing tools and workflows
3. Create custom scripts and applications leveraging AI capabilities
4. Design prompts that effectively communicate your development needs
5. Implement automated AI-powered quality checks
6. Generate documentation and code with AI assistance
7. Use AI to analyze and improve existing code
8. Balance AI assistance with personal skill development

## Self-Assessment Quiz

Test your knowledge with these questions:

1. What environment variable is typically used to store the OpenAI API key?
2. How would you securely store API credentials in a Linux environment?
3. What is the purpose of a system prompt when working with AI assistants?
4. How can you integrate AI code completion into Neovim?
5. What are the key considerations when designing a CLI tool that uses AI services?
6. How would you implement project-specific context awareness in an AI assistant?
7. What are the security concerns when using AI in a development workflow?
8. How can you balance AI assistance with maintaining and developing your coding skills?
9. What strategies can you use to reduce API costs when using AI services extensively?
10. How would you approach the design of a custom AI tool for a specific development task?

## Next Steps

After completing this bonus month, consider these advanced applications:

1. **Explore Local LLM Deployment**: Set up local models like Llama 3 for privacy and cost reduction
2. **Implement Semantic Code Search**: Create tools to search your codebase using natural language
3. **Develop Custom Models**: Fine-tune models specifically for your development domains
4. **Implement Collaborative AI**: Build tools that enable team-based AI assistance
5. **Create Learning Systems**: Design AI tools that improve based on your feedback and usage patterns

## Acknowledgements

This AI integration guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Documentation organization and structure
- Code examples and script development
- Integration strategies and best practices

Claude was used as a development aid while all final implementation decisions and review were performed by Joshua Michael Hall.

## Disclaimer

This guide is provided "as is", without warranty of any kind. Always evaluate the AI-generated code and suggestions before implementing them in production environments. Consider the privacy implications of sending code or sensitive information to external AI services, and implement appropriate safeguards.

---

> "Master the basics. Then practice them every day without fail." - John C. Maxwell