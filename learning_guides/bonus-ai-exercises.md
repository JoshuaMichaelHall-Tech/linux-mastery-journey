# Bonus Month: AI Integration for Linux Development - Exercises

This document contains practical exercises to accompany the Bonus Month learning guide. Complete these exercises to strengthen your understanding of AI integration in Linux development environments and build real-world skills with AI-augmented workflows.

## Exercise 1: AI Services and CLI Setup

### Task 1: Setting Up API Access

1. **Create accounts and obtain API keys**:
   ```bash
   # Create a secure directory for API keys
   mkdir -p ~/.config/ai-tools
   chmod 700 ~/.config/ai-tools
   
   # Create credential file
   touch ~/.config/ai-tools/credentials.env
   chmod 600 ~/.config/ai-tools/credentials.env
   ```

2. **Register for API access**:
   - Sign up for an Anthropic API key
   - Sign up for an OpenAI API key
   - Configure your shell environment:
   ```bash
   # Add to your ~/.zshrc or ~/.bashrc
   export ANTHROPIC_API_KEY="your_key_here"
   export OPENAI_API_KEY="your_key_here"
   ```

3. **Test API access**:
   ```bash
   # Using curl to test Anthropic API
   curl -X POST https://api.anthropic.com/v1/messages \
     -H "x-api-key: $ANTHROPIC_API_KEY" \
     -H "anthropic-version: 2023-06-01" \
     -H "content-type: application/json" \
     -d '{
       "model": "claude-3-opus-20240229",
       "max_tokens": 100,
       "messages": [
         {"role": "user", "content": "Hello, Claude! Please respond with a short greeting."}
       ]
     }' | jq
   
   # Using curl to test OpenAI API
   curl -X POST https://api.openai.com/v1/chat/completions \
     -H "Authorization: Bearer $OPENAI_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{
       "model": "gpt-4",
       "messages": [
         {"role": "user", "content": "Hello, GPT! Please respond with a short greeting."}
       ],
       "max_tokens": 100
     }' | jq
   ```

### Task 2: Installing AI CLI Tools

1. **Set up a Python virtual environment**:
   ```bash
   # Create a dedicated virtual environment
   python -m venv ~/.local/ai-tools
   
   # Activate the environment
   source ~/.local/ai-tools/bin/activate
   
   # Add activation to your shell startup
   echo 'source ~/.local/ai-tools/bin/activate' >> ~/.zshrc
   ```

2. **Install essential Python packages**:
   ```bash
   # Basic packages
   pip install anthropic openai httpx langchain pydantic rich

   # CLI tools
   pip install shell-gpt llm aichat ghapi
   ```

3. **Configure shell-gpt**:
   ```bash
   # Initialize shell-gpt configuration
   sgpt --configure
   ```

### Task 3: Creating Basic Shell Functions

Create a file `~/.ai-functions.sh` with the following content:

```bash
#!/bin/bash
# AI Helper Functions

# Simple AI query function
ai() {
  if [ $# -eq 0 ]; then
    echo "Usage: ai <your question>"
    return 1
  fi
  
  local prompt="$*"
  echo "Thinking..."
  llm "$prompt" | less
}

# Explain shell command
explain_cmd() {
  if [ $# -eq 0 ]; then
    echo "Usage: explain_cmd <command>"
    return 1
  fi
  
  local cmd="$*"
  echo "Explaining: $cmd"
  llm "Explain this shell command in detail: $cmd" | less
}

# Code explainer (pipe or file)
explain_code() {
  if [ -t 0 ]; then
    # If not receiving input from pipe, check for file argument
    if [ $# -eq 0 ]; then
      echo "Usage: explain_code <file> OR cat file | explain_code"
      return 1
    fi
    
    if [ ! -f "$1" ]; then
      echo "Error: File not found: $1"
      return 1
    fi
    
    local code=$(cat "$1")
  else
    # Reading from pipe
    local code=$(cat)
  fi
  
  echo "Analyzing code..."
  echo "$code" | llm "Explain this code in detail:" | less
}

# Git commit message generator
ai_commit() {
  local diff=$(git diff --staged)
  
  if [ -z "$diff" ]; then
    echo "No staged changes to commit."
    return 1
  fi
  
  echo "Generating commit message..."
  local message=$(echo "$diff" | llm "Generate a concise, descriptive commit message for these changes. Follow conventional commits format (feat, fix, docs, style, refactor, test, chore). Keep it under 80 characters.")
  
  echo -e "\nGenerated commit message:"
  echo -e "$message\n"
  
  read -p "Use this message? (y/n): " confirm
  if [[ $confirm == [yY] ]]; then
    git commit -m "$message"
  else
    echo "Commit aborted. You can modify the message:"
    read -p "Enter your commit message: " custom_message
    if [ ! -z "$custom_message" ]; then
      git commit -m "$custom_message"
    else
      echo "No message provided, commit aborted."
    fi
  fi
}

# Add your functions to shell
source_ai_functions() {
  # Add to your .zshrc or .bashrc
  echo 'source ~/.ai-functions.sh' >> ~/.zshrc
  echo "AI functions added to your shell. Restart your shell or run 'source ~/.zshrc'"
}
```

Make it executable and add to your shell:
```bash
chmod +x ~/.ai-functions.sh
source ~/.ai-functions.sh
source_ai_functions
```

### Task 4: Testing Your Setup

1. **Test your AI query function**:
   ```bash
   ai "What's the difference between TCP and UDP protocols?"
   ```

2. **Test command explanation**:
   ```bash
   explain_cmd "find . -type f -name '*.py' -exec grep -l 'import os' {} \;"
   ```

3. **Test code explanation**:
   ```bash
   # Create a sample Python file
   cat > test.py << 'EOF'
   def fibonacci(n):
       if n <= 0:
           return []
       elif n == 1:
           return [0]
       elif n == 2:
           return [0, 1]
       
       fib = [0, 1]
       for i in range(2, n):
           fib.append(fib[i-1] + fib[i-2])
       
       return fib
   
   if __name__ == "__main__":
       print(fibonacci(10))
   EOF
   
   # Explain the code
   explain_code test.py
   ```

4. **Test commit message generation**:
   ```bash
   # Create a git repository for testing
   mkdir -p ~/ai-test
   cd ~/ai-test
   git init
   
   # Create a sample file
   echo "# AI Test Repository" > README.md
   
   # Stage the file
   git add README.md
   
   # Generate commit message
   ai_commit
   ```

## Exercise 2: Editor Integration and Code Assistance

### Task 1: Setting up Neovim with AI Integration

1. **Create a basic Neovim plugin for AI assistance**:

Create the directory structure:
```bash
mkdir -p ~/.config/nvim/lua/ai_assistant
```

Create the main plugin file `~/.config/nvim/lua/ai_assistant/init.lua`:
```lua
local M = {}

-- Configuration
M.config = {
  api_key = vim.env.ANTHROPIC_API_KEY,
  model = "claude-3-opus-20240229",
  max_tokens = 1000,
}

-- Send a request to the AI API
local function query_ai(prompt)
  -- Check for API key
  if not M.config.api_key or M.config.api_key == "" then
    vim.notify("API key not set. Please set ANTHROPIC_API_KEY environment variable.", vim.log.levels.ERROR)
    return nil
  end
  
  -- Create temporary files for input and output
  local input_file = os.tmpname()
  local output_file = os.tmpname()
  
  -- Write prompt to input file
  local f = io.open(input_file, "w")
  f:write(prompt)
  f:close()
  
  -- Construct the API call
  local cmd = string.format([[
  curl -s -X POST https://api.anthropic.com/v1/messages \
    -H "x-api-key: %s" \
    -H "anthropic-version: 2023-06-01" \
    -H "content-type: application/json" \
    -d '{
      "model": "%s",
      "max_tokens": %d,
      "messages": [
        {"role": "user", "content": "%s"}
      ]
    }' > %s
  ]], 
  M.config.api_key, 
  M.config.model, 
  M.config.max_tokens,
  vim.fn.shellescape(prompt):gsub("\"", "\\\""):gsub("\n", "\\n"), 
  output_file)
  
  -- Execute the command
  os.execute(cmd)
  
  -- Read the response
  local response_file = io.open(output_file, "r")
  local response = response_file:read("*all")
  response_file:close()
  
  -- Clean up temporary files
  os.remove(input_file)
  os.remove(output_file)
  
  -- Parse the JSON response
  local json_ok, json_result = pcall(vim.json.decode, response)
  if not json_ok then
    vim.notify("Failed to parse API response: " .. response, vim.log.levels.ERROR)
    return nil
  end
  
  -- Extract content
  if json_result and json_result.content and json_result.content[0] and json_result.content[0].text then
    return json_result.content[0].text
  else
    vim.notify("Unexpected API response format", vim.log.levels.ERROR)
    return nil
  end
end

-- Create a new buffer with AI response
function M.ask_ai()
  -- Get input from the user
  vim.ui.input({ prompt = "Ask AI: " }, function(input)
    if not input or input == "" then
      return
    end
    
    -- Show that we're working
    vim.notify("Generating response...", vim.log.levels.INFO)
    
    -- Query the AI
    local response = query_ai(input)
    if not response then
      return
    end
    
    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
    
    -- Set the buffer content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(response, "\n"))
    
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
  end)
end

-- Get help with the current file
function M.explain_file()
  -- Get the current buffer content
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n")
  
  -- Create the prompt
  local prompt = "Explain this code and suggest any improvements:\n\n```\n" .. content .. "\n```"
  
  -- Show that we're working
  vim.notify("Analyzing code...", vim.log.levels.INFO)
  
  -- Query the AI
  local response = query_ai(prompt)
  if not response then
    return
  end
  
  -- Create a new buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
  
  -- Set the buffer content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(response, "\n"))
  
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
end

-- Get help with the current selection
function M.explain_selection()
  -- Get visual selection
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  
  -- Convert to 0-indexed
  local start_line = start_pos[2] - 1
  local start_col = start_pos[3] - 1
  local end_line = end_pos[2] - 1
  local end_col = end_pos[3] - 1
  
  -- Get the selected lines
  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line + 1, false)
  
  -- Adjust first and last line for column positions
  if #lines > 0 then
    if #lines == 1 then
      lines[1] = string.sub(lines[1], start_col + 1, end_col)
    else
      lines[1] = string.sub(lines[1], start_col + 1)
      lines[#lines] = string.sub(lines[#lines], 1, end_col)
    end
  end
  
  local content = table.concat(lines, "\n")
  
  -- Create the prompt
  local prompt = "Explain this code and suggest any improvements:\n\n```\n" .. content .. "\n```"
  
  -- Show that we're working
  vim.notify("Analyzing selection...", vim.log.levels.INFO)
  
  -- Query the AI
  local response = query_ai(prompt)
  if not response then
    return
  end
  
  -- Create a new buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
  
  -- Set the buffer content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(response, "\n"))
  
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
end

-- Generate docstrings for a function
function M.generate_docstring()
  -- Get the current line number
  local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1
  
  -- Try to find the function definition
  local line_content = vim.api.nvim_buf_get_lines(0, current_line, current_line + 1, false)[1]
  
  -- Check if we're on a function definition line
  if not line_content:match("^%s*def%s+") then
    vim.notify("Please position cursor on a function definition line", vim.log.levels.ERROR)
    return
  end
  
  -- Get the function and the lines that follow
  local function_lines = {}
  local i = current_line
  local indent_level = line_content:match("^(%s*)")
  
  -- Add the function definition
  table.insert(function_lines, line_content)
  
  -- Collect the function body
  while true do
    i = i + 1
    if i >= vim.api.nvim_buf_line_count(0) then
      break
    end
    
    local line = vim.api.nvim_buf_get_lines(0, i, i + 1, false)[1]
    if line:match("^%s*$") then
      -- Empty line, skip it
      table.insert(function_lines, line)
    elseif #line:match("^(%s*)") <= #indent_level then
      -- Line with less indentation than the function definition, we're out of the function
      break
    else
      -- Line is part of the function
      table.insert(function_lines, line)
    end
  end
  
  -- Create the prompt
  local function_code = table.concat(function_lines, "\n")
  local prompt = "Generate a comprehensive docstring for this Python function. Use Google-style docstring format:\n\n```python\n" .. function_code .. "\n```"
  
  -- Show that we're working
  vim.notify("Generating docstring...", vim.log.levels.INFO)
  
  -- Query the AI
  local response = query_ai(prompt)
  if not response then
    return
  end
  
  -- Extract just the docstring from the response
  local docstring = response:match("```python%s*([^`]+)```") or response
  
  -- Clean up the docstring
  docstring = docstring:gsub("^%s*def%s+.-:%s*", ""):gsub("^%s*\"\"\"", ""):gsub("\"\"\"%s*$", ""):gsub("^%s*'''", ""):gsub("'''%s*$", "")
  
  -- Add indentation to match the function
  local indent = line_content:match("^(%s*)")
  local docstring_lines = vim.split(docstring, "\n")
  for i = 1, #docstring_lines do
    docstring_lines[i] = indent .. "    " .. docstring_lines[i]:gsub("^%s*", "")
  end
  
  -- Create the full docstring
  local full_docstring = {
    indent .. "    \"\"\"",
  }
  for _, line in ipairs(docstring_lines) do
    table.insert(full_docstring, line)
  end
  table.insert(full_docstring, indent .. "    \"\"\"")
  
  -- Insert the docstring after the function definition
  vim.api.nvim_buf_set_lines(0, current_line + 1, current_line + 1, false, full_docstring)
  
  vim.notify("Docstring added", vim.log.levels.INFO)
end

-- Setup function
function M.setup(opts)
  -- Merge configs
  if opts then
    M.config = vim.tbl_deep_extend("force", M.config, opts)
  end
  
  -- Set up commands
  vim.api.nvim_create_user_command("AIAsk", M.ask_ai, {})
  vim.api.nvim_create_user_command("AIExplain", M.explain_file, {})
  vim.api.nvim_create_user_command("AIDoc", M.generate_docstring, {})
  
  -- Set up keymaps
  vim.keymap.set("n", "<leader>aa", M.ask_ai, { noremap = true, silent = true })
  vim.keymap.set("n", "<leader>ae", M.explain_file, { noremap = true, silent = true })
  vim.keymap.set("v", "<leader>ae", M.explain_selection, { noremap = true, silent = true })
  vim.keymap.set("n", "<leader>ad", M.generate_docstring, { noremap = true, silent = true })
end

return M
```

2. **Add the plugin to your Neovim configuration**:

Update your `~/.config/nvim/init.lua` (or create it if it doesn't exist):
```lua
-- Add AI assistant to your configuration
require('ai_assistant').setup({
  -- Optional configuration
  model = "claude-3-haiku-20240307", -- Use a faster model for quicker responses
})
```

3. **Test the integration**:
   - Open Neovim
   - Use `:AIAsk` to ask a question
   - Use `:AIExplain` to explain the current file
   - Use `:AIDoc` to generate docstrings
   - Use Visual mode selection + `<leader>ae` to explain a code selection

### Task 2: Create a Git Commit Helper

1. **Create a Git hook for commit message generation**:

Create file `~/.config/git_hooks/prepare-commit-msg`:
```bash
#!/bin/bash
# Git hook to generate commit messages

# Check if this is a commit created by a merge or another operation
# that already has a message
if [ "$2" != "" ]; then
  exit 0
fi

# Check if we have an AI API key
if [ -z "$ANTHROPIC_API_KEY" ]; then
  echo "No API key found. Skipping AI commit message generation."
  exit 0
fi

# Get the staged changes
DIFF=$(git diff --staged)

# If there are no staged changes, exit
if [ -z "$DIFF" ]; then
  exit 0
fi

# Generate a commit message
echo "Generating AI commit message..."
COMMIT_MSG=$(curl -s -X POST https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d "{
    \"model\": \"claude-3-haiku-20240307\",
    \"max_tokens\": 200,
    \"messages\": [
      {\"role\": \"user\", \"content\": \"Generate a concise, descriptive commit message for these changes. Follow conventional commits format (feat, fix, docs, style, refactor, test, chore). Keep it under 72 characters. Here's the git diff:\n\n$DIFF\"}
    ]
  }" | jq -r '.content[0].text')

# Check if we got a response
if [ -z "$COMMIT_MSG" ]; then
  echo "Failed to generate commit message. Using empty message."
  exit 0
fi

# Write the message to the commit file
echo "$COMMIT_MSG" > "$1"
echo -e "\n# AI generated commit message. You can modify it before committing." >> "$1"
```

Make it executable:
```bash
chmod +x ~/.config/git_hooks/prepare-commit-msg
```

2. **Create a script to install the hook to any git repository**:

```bash
#!/bin/bash
# install-git-hooks.sh
# Install AI-powered git hooks to current repository

set -e

HOOK_DIR=$(git rev-parse --git-dir)/hooks
HOOK_SOURCE=~/.config/git_hooks

# Create hook source directory if it doesn't exist
mkdir -p $HOOK_SOURCE

# Install the prepare-commit-msg hook
if [ -f "$HOOK_DIR/prepare-commit-msg" ]; then
  echo "Backing up existing prepare-commit-msg hook..."
  cp "$HOOK_DIR/prepare-commit-msg" "$HOOK_DIR/prepare-commit-msg.bak"
fi

echo "Installing prepare-commit-msg hook..."
cp "$HOOK_SOURCE/prepare-commit-msg" "$HOOK_DIR/prepare-commit-msg"
chmod +x "$HOOK_DIR/prepare-commit-msg"

echo "Git hooks installed successfully!"
```

Make it executable:
```bash
chmod +x install-git-hooks.sh
sudo cp install-git-hooks.sh /usr/local/bin/install-git-hooks
```

3. **Test the Git hook**:
```bash
# Create a test repository
mkdir -p ~/ai-git-test
cd ~/ai-git-test
git init

# Install the git hooks
install-git-hooks

# Create a sample file
echo "# Test Repository" > README.md

# Stage the file
git add README.md

# Try to commit (this should invoke the hook)
git commit
```

## Exercise 3: AI-Powered Content Generation

### Task 1: Building a Documentation Generator

1. **Create an automatic documentation generator script**:

```bash
#!/bin/bash
# ai-docgen.sh - Generate comprehensive project documentation

# Check arguments
if [ $# -lt 1 ]; then
  echo "Usage: $0 <project_directory>"
  exit 1
fi

PROJECT_DIR=$(realpath "$1")
if [ ! -d "$PROJECT_DIR" ]; then
  echo "Error: Directory not found: $PROJECT_DIR"
  exit 1
fi

# Create docs directory
DOCS_DIR="$PROJECT_DIR/docs"
mkdir -p "$DOCS_DIR"

echo "🔍 Analyzing project structure..."

# Get project name and language information
PROJECT_NAME=$(basename "$PROJECT_DIR")
FILE_COUNT=$(find "$PROJECT_DIR" -type f -name "*.*" | grep -v "node_modules\|venv\|.git" | wc -l)

# Detect languages
echo "📊 Detecting programming languages..."
LANGUAGES=$(find "$PROJECT_DIR" -type f -name "*.*" | grep -v "node_modules\|venv\|.git" | sed 's/.*\.//' | sort | uniq -c | sort -nr | head -n 5 | awk '{print $2 "(" $1 ")"}' | tr '\n' ' ')

# Find key files
echo "🔎 Locating key project files..."
README=$(find "$PROJECT_DIR" -maxdepth 2 -type f -name "README*" | head -n 1)
PACKAGE_JSON=$(find "$PROJECT_DIR" -maxdepth 2 -type f -name "package.json" | head -n 1)
REQUIREMENTS=$(find "$PROJECT_DIR" -maxdepth 2 -type f -name "requirements.txt" | head -n 1)
SETUP_PY=$(find "$PROJECT_DIR" -maxdepth 2 -type f -name "setup.py" | head -n 1)
CARGO_TOML=$(find "$PROJECT_DIR" -maxdepth 2 -type f -name "Cargo.toml" | head -n 1)
GEMFILE=$(find "$PROJECT_DIR" -maxdepth 2 -type f -name "Gemfile" | head -n 1)

# Gather project information
PROJECT_INFO="Project Name: $PROJECT_NAME\n"
PROJECT_INFO+="File Count: $FILE_COUNT\n"
PROJECT_INFO+="Languages: $LANGUAGES\n\n"

if [ -n "$README" ]; then
  PROJECT_INFO+="README contents:\n$(cat "$README")\n\n"
fi

if [ -n "$PACKAGE_JSON" ]; then
  PROJECT_INFO+="package.json contents:\n$(cat "$PACKAGE_JSON")\n\n"
fi

if [ -n "$REQUIREMENTS" ]; then
  PROJECT_INFO+="requirements.txt contents:\n$(cat "$REQUIREMENTS")\n\n"
fi

if [ -n "$SETUP_PY" ]; then
  PROJECT_INFO+="setup.py contents:\n$(cat "$SETUP_PY")\n\n"
fi

if [ -n "$CARGO_TOML" ]; then
  PROJECT_INFO+="Cargo.toml contents:\n$(cat "$CARGO_TOML")\n\n"
fi

if [ -n "$GEMFILE" ]; then
  PROJECT_INFO+="Gemfile contents:\n$(cat "$GEMFILE")\n\n"
fi

# Sample code files (for context)
echo "📝 Sampling key code files..."
MAIN_FILES=$(find "$PROJECT_DIR" -maxdepth 3 -type f -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" -o -name "*.rs" -o -name "*.c" -o -name "*.cpp" | grep -v "node_modules\|venv\|.git" | head -n 5)

for file in $MAIN_FILES; do
  rel_path="${file#$PROJECT_DIR/}"
  PROJECT_INFO+="File: $rel_path\n\n"
  PROJECT_INFO+="$(head -n 50 "$file")\n\n"
  PROJECT_INFO+="...\n\n"
done

# List directories and file structure
echo "📂 Analyzing directory structure..."
PROJECT_INFO+="Directory structure:\n\n"
PROJECT_INFO+="$(find "$PROJECT_DIR" -type d -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/venv/*" | sort | head -n 20 | sed "s|$PROJECT_DIR/||")\n"
PROJECT_INFO+="...\n\n"

echo "🤖 Generating documentation with AI..."

# Generate main documentation using AI
PROMPT="Generate comprehensive project documentation for this project. Here's information about the project:

$PROJECT_INFO

Create the following documentation files:
1. overview.md - A high-level overview of the project
2. architecture.md - The architectural design and components
3. setup.md - Installation and setup instructions
4. usage.md - Usage examples and API documentation
5. development.md - Guide for developers contributing to the project

Format everything in professional markdown with proper headings, code blocks, and formatting. Be concise but thorough."

# Run the AI query and save to a variable to avoid passing too much to shell at once
AI_RESPONSE=$(echo "$PROMPT" | llm)

# Extract documentation files from the AI response
echo "$AI_RESPONSE" | awk '/^## overview.md/,/^## architecture.md/ {if (!/^## architecture.md/) print}' | sed '1s/^## overview.md//' > "$DOCS_DIR/overview.md"
echo "$AI_RESPONSE" | awk '/^## architecture.md/,/^## setup.md/ {if (!/^## setup.md/) print}' | sed '1s/^## architecture.md//' > "$DOCS_DIR/architecture.md"
echo "$AI_RESPONSE" | awk '/^## setup.md/,/^## usage.md/ {if (!/^## usage.md/) print}' | sed '1s/^## setup.md//' > "$DOCS_DIR/setup.md"
echo "$AI_RESPONSE" | awk '/^## usage.md/,/^## development.md/ {if (!/^## development.md/) print}' | sed '1s/^## usage.md//' > "$DOCS_DIR/usage.md"
echo "$AI_RESPONSE" | awk '/^## development.md/,0 {print}' | sed '1s/^## development.md//' > "$DOCS_DIR/development.md"

# Create an index file
cat > "$DOCS_DIR/index.md" << EOF
# $PROJECT_NAME Documentation

Generated documentation for $PROJECT_NAME project.

## Contents

- [Project Overview](overview.md)
- [Architecture](architecture.md)
- [Setup Instructions](setup.md)
- [Usage Guide](usage.md)
- [Development Guide](development.md)

This documentation was automatically generated using AI assistance.

---

Generated on $(date)
EOF

echo "✅ Documentation generated in $DOCS_DIR"
echo "📚 Files created:"
ls -la "$DOCS_DIR"
```

Make it executable and install:
```bash
chmod +x ai-docgen.sh
sudo cp ai-docgen.sh /usr/local/bin/ai-docgen
```

2. **Test the documentation generator**:
```bash
# Create a test project
mkdir -p ~/ai-test-project
cd ~/ai-test-project

# Add some sample files
echo "# Test Project" > README.md
mkdir -p src
echo "def main():\n    print('Hello, world!')" > src/main.py
mkdir -p tests
echo "def test_main():\n    assert True" > tests/test_main.py

# Generate documentation
ai-docgen ~/ai-test-project
```

### Task 2: Creating a README Generator

1. **Create a README generator script**:

```bash
#!/bin/bash
# ai-readme.sh - Generate comprehensive README.md files

# Check arguments
if [ $# -lt 1 ]; then
  echo "Usage: $0 <project_directory>"
  exit 1
fi

PROJECT_DIR=$(realpath "$1")
if [ ! -d "$PROJECT_DIR" ]; then
  echo "Error: Directory not found: $PROJECT_DIR"
  exit 1
fi

echo "🔍 Analyzing project..."

# Get project name and language information
PROJECT_NAME=$(basename "$PROJECT_DIR")
FILE_COUNT=$(find "$PROJECT_DIR" -type f -name "*.*" | grep -v "node_modules\|venv\|.git" | wc -l)

# Detect languages
echo "📊 Detecting programming languages..."
LANGUAGES=$(find "$PROJECT_DIR" -type f -name "*.*" | grep -v "node_modules\|venv\|.git" | sed 's/.*\.//' | sort | uniq -c | sort -nr | head -n 5 | awk '{print $2 "(" $1 ")"}' | tr '\n' ' ')

# Find key files
echo "🔎 Finding key configuration files..."
PACKAGE_JSON=$(find "$PROJECT_DIR" -maxdepth 2 -type f -name "package.json" | head -n 1)
REQUIREMENTS=$(find "$PROJECT_DIR" -maxdepth 2 -type f -name "requirements.txt" | head -n 1)
SETUP_PY=$(find "$PROJECT_DIR" -maxdepth 2 -type f -name "setup.py" | head -n 1)
CARGO_TOML=$(find "$PROJECT_DIR" -maxdepth 2 -type f -name "Cargo.toml" | head -n 1)
GEMFILE=$(find "$PROJECT_DIR" -maxdepth 2 -type f -name "Gemfile" | head -n 1)

# Gather project information
PROJECT_INFO="Project Name: $PROJECT_NAME\n"
PROJECT_INFO+="File Count: $FILE_COUNT\n"
PROJECT_INFO+="Languages: $LANGUAGES\n\n"

if [ -n "$PACKAGE_JSON" ]; then
  PROJECT_INFO+="package.json contents:\n$(cat "$PACKAGE_JSON")\n\n"
fi

if [ -n "$REQUIREMENTS" ]; then
  PROJECT_INFO+="requirements.txt contents:\n$(cat "$REQUIREMENTS")\n\n"
fi

if [ -n "$SETUP_PY" ]; then
  PROJECT_INFO+="setup.py contents:\n$(cat "$SETUP_PY")\n\n"
fi

if [ -n "$CARGO_TOML" ]; then
  PROJECT_INFO+="Cargo.toml contents:\n$(cat "$CARGO_TOML")\n\n"
fi

if [ -n "$GEMFILE" ]; then
  PROJECT_INFO+="Gemfile contents:\n$(cat "$GEMFILE")\n\n"
fi

# Sample code files (for context)
echo "📝 Sampling key code files..."
MAIN_FILES=$(find "$PROJECT_DIR" -maxdepth 3 -type f -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" -o -name "*.rs" -o -name "*.c" -o -name "*.cpp" | grep -v "node_modules\|venv\|.git" | head -n 3)

for file in $MAIN_FILES; do
  rel_path="${file#$PROJECT_DIR/}"
  PROJECT_INFO+="File: $rel_path\n\n"
  PROJECT_INFO+="$(head -n 30 "$file")\n\n"
  PROJECT_INFO+="...\n\n"
done

# List directories
PROJECT_INFO+="Directory structure:\n\n"
PROJECT_INFO+="$(find "$PROJECT_DIR" -type d -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/venv/*" | sort | head -n 10 | sed "s|$PROJECT_DIR/||")\n"
PROJECT_INFO+="...\n\n"

echo "🤖 Generating README.md with AI..."

# Generate README using AI
PROMPT="Generate a comprehensive README.md file for this project. Here's information about the project:

$PROJECT_INFO

The README should include:
1. Project title and description
2. Installation instructions
3. Usage examples
4. Features
5. Contributing guidelines
6. License information (assume MIT License)
7. Acknowledgements (including 'developed with assistance from Anthropic's Claude')

Format everything in professional markdown with proper headings, code blocks, and badges. Make it visually appealing and informative for developers. Include appropriate badges at the top for version, license, etc."

# Run the AI query and save the result
README_CONTENT=$(echo "$PROMPT" | llm)

# Write to README file
echo "$README_CONTENT" > "$PROJECT_DIR/README.md.generated"

echo "✅ README.md generated as ${PROJECT_DIR}/README.md.generated"
echo "📝 Review the generated content before using it as your main README.md"
```

Make it executable and install:
```bash
chmod +x ai-readme.sh
sudo cp ai-readme.sh /usr/local/bin/ai-readme
```

2. **Test the README generator**:
```bash
# Use the test project from the previous task
cd ~/ai-test-project

# Generate README
ai-readme ~/ai-test-project

# Compare with existing README (if any)
diff README.md README.md.generated
```

### Task 3: Blog Post Generator

1. **Create a technical blog post generator**:

```bash
#!/bin/bash
# ai-blog.sh - Generate technical blog posts about coding projects

# Check arguments
if [ $# -lt 1 ]; then
  echo "Usage: $0 <project_directory> [topic]"
  exit 1
fi

PROJECT_DIR=$(realpath "$1")
if [ ! -d "$PROJECT_DIR" ]; then
  echo "Error: Directory not found: $PROJECT_DIR"
  exit 1
fi

# Get topic if provided
if [ $# -ge 2 ]; then
  TOPIC="$2"
else
  # Default topic is about the project itself
  TOPIC="Introducing the project and its features"
fi

echo "🔍 Analyzing project for blog post about: $TOPIC"

# Get project name and language information
PROJECT_NAME=$(basename "$PROJECT_DIR")
PRIMARY_LANG=$(find "$PROJECT_DIR" -type f -name "*.*" | grep -v "node_modules\|venv\|.git" | sed 's/.*\.//' | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')

# Look for existing README
README=$(find "$PROJECT_DIR" -maxdepth 2 -type f -name "README*" | head -n 1)
README_CONTENT=""
if [ -n "$README" ]; then
  README_CONTENT=$(cat "$README")
fi

# Sample code files (for context)
echo "📝 Sampling key code files..."
MAIN_FILES=$(find "$PROJECT_DIR" -maxdepth 3 -type f -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" -o -name "*.rs" -o -name "*.c" -o -name "*.cpp" | grep -v "node_modules\|venv\|.git" | head -n 3)

CODE_SAMPLES=""
for file in $MAIN_FILES; do
  rel_path="${file#$PROJECT_DIR/}"
  CODE_SAMPLES+="File: $rel_path\n\n"
  CODE_SAMPLES+="$(head -n 30 "$file")\n\n"
  CODE_SAMPLES+="...\n\n"
done

echo "🤖 Generating blog post with AI..."

# Current date for the blog post
CURRENT_DATE=$(date +"%B %d, %Y")

# Generate blog post using AI
PROMPT="Generate a professional technical blog post about the following project and topic:

Project Name: $PROJECT_NAME
Primary Language: $PRIMARY_LANG
Topic: $TOPIC
Date: $CURRENT_DATE

README Content:
$README_CONTENT

Code Samples:
$CODE_SAMPLES

Requirements for the blog post:
1. Create an engaging, technical blog post of about 1000-1500 words
2. Include a title, introduction, and proper structure with headings
3. Include code snippets with proper formatting and explanations
4. Explain the technical architecture and design decisions
5. Discuss challenges and solutions
6. Include a conclusion with future development ideas
7. Format everything in markdown with proper headings, code blocks, and emphasis
8. Make it engaging for technical readers but also accessible to those with basic programming knowledge
9. Include a short author bio at the end mentioning that you're a software engineer specializing in $PRIMARY_LANG development

The tone should be professional, informative, and slightly conversational - like a technical post on a developer blog."

# Run the AI query and save the result
BLOG_CONTENT=$(echo "$PROMPT" | llm)

# Create blog posts directory if it doesn't exist
mkdir -p "$PROJECT_DIR/blog_posts"

# Create a filename based on the date and project
FILENAME="$PROJECT_DIR/blog_posts/$(date +"%Y-%m-%d")-$PROJECT_NAME.md"

# Write to blog file
echo "$BLOG_CONTENT" > "$FILENAME"

echo "✅ Blog post generated at: $FILENAME"
echo "📝 Review and edit the content before publishing"
```

Make it executable and install:
```bash
chmod +x ai-blog.sh
sudo cp ai-blog.sh /usr/local/bin/ai-blog
```

2. **Test the blog post generator**:
```bash
# Use the test project from the previous tasks
cd ~/ai-test-project

# Generate a blog post
ai-blog ~/ai-test-project "Building a Python Test Project with AI Integration"

# Check the result
cat ~/ai-test-project/blog_posts/*.md | head -n 20
```

## Exercise 4: Custom AI Integration Projects

### Task 1: Create an AI-Powered Development Assistant

This exercise involves creating a comprehensive AI development assistant that integrates with your workflow.

1. **Install dependencies**:
```bash
pip install rich typer pydantic openai anthropic httpx
```

2. **Create the development assistant script**:

Save this as `~/bin/dev-assist.py`:

```python
#!/usr/bin/env python3
# dev-assist.py - AI-powered development assistant

import os
import sys
import json
import subprocess
import tempfile
from pathlib import Path
from typing import Dict, List, Optional, Any, Union
import datetime

import typer
import httpx
from rich.console import Console
from rich.markdown import Markdown
from rich.panel import Panel
from rich.syntax import Syntax

# Initialize console
console = Console()
app = typer.Typer(help="AI-powered development assistant")

# Configuration
CONFIG_DIR = Path.home() / ".config" / "dev-assist"
CONFIG_FILE = CONFIG_DIR / "config.json"
HISTORY_FILE = CONFIG_DIR / "history.json"
SNIPPETS_DIR = CONFIG_DIR / "snippets"

# Default configuration
DEFAULT_CONFIG = {
    "api_key": os.environ.get("ANTHROPIC_API_KEY", ""),
    "model": "claude-3-opus-20240229",
    "max_tokens": 2000,
    "temperature": 0.2,
    "context_files": 3,
    "context_lines": 50,
    "snippets": {},
}

# Setup directories
CONFIG_DIR.mkdir(parents=True, exist_ok=True)
SNIPPETS_DIR.mkdir(parents=True, exist_ok=True)

# Load configuration
def load_config() -> Dict[str, Any]:
    """Load configuration from file or create default"""
    if CONFIG_FILE.exists():
        with open(CONFIG_FILE, "r") as f:
            return json.load(f)
    else:
        with open(CONFIG_FILE, "w") as f:
            json.dump(DEFAULT_CONFIG, f, indent=2)
        return DEFAULT_CONFIG

# Save configuration
def save_config(config: Dict[str, Any]) -> None:
    """Save configuration to file"""
    with open(CONFIG_FILE, "w") as f:
        json.dump(config, f, indent=2)

# Load command history
def load_history() -> List[Dict[str, str]]:
    """Load command history from file"""
    if HISTORY_FILE.exists():
        with open(HISTORY_FILE, "r") as f:
            return json.load(f)
    return []

# Save command history
def save_history(history: List[Dict[str, str]]) -> None:
    """Save command history to file"""
    with open(HISTORY_FILE, "w") as f:
        json.dump(history, f, indent=2)

# Add to command history
def add_to_history(query: str, response: str) -> None:
    """Add query and response to history"""
    history = load_history()
    history.append({
        "timestamp": datetime.datetime.now().isoformat(),
        "query": query,
        "response": response
    })
    # Limit history size to 100 entries
    if len(history) > 100:
        history = history[-100:]
    save_history(history)

# Call AI API
def query_ai(prompt: str, system_prompt: Optional[str] = None) -> str:
    """Send query to AI API and return response"""
    config = load_config()
    api_key = config.get("api_key")
    
    if not api_key:
        return "Error: API key not set. Use 'dev-assist config --api-key YOUR_KEY' to set it."
    
    if not system_prompt:
        system_prompt = """You are an AI-powered development assistant that helps with programming, system administration, and technical tasks. You provide clear, concise, and practical advice for developers. When appropriate, include code examples with proper syntax highlighting."""
    
    # Create payload for API
    payload = {
        "model": config["model"],
        "max_tokens": config["max_tokens"],
        "temperature": config["temperature"],
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": prompt}
        ]
    }
    
    try:
        # Make API call
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
        return result["content"][0]["text"]
    except Exception as e:
        return f"Error calling AI API: {str(e)}"

# Get relevant project context
def get_project_context(max_files: int = 3, max_lines: int = 50) -> str:
    """Get context information about the current project"""
    cwd = os.getcwd()
    context = f"Working directory: {cwd}\n\n"
    
    # Check if this is a git repository
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--is-inside-work-tree"],
            cwd=cwd,
            capture_output=True,
            text=True,
            check=False
        )
        
        if result.stdout.strip() == "true":
            # Get git info
            context += "Git repository information:\n"
            
            # Get remote URL
            try:
                result = subprocess.run(
                    ["git", "remote", "get-url", "origin"],
                    cwd=cwd,
                    capture_output=True,
                    text=True,
                    check=False
                )
                if result.returncode == 0:
                    context += f"Remote URL: {result.stdout.strip()}\n"
            except Exception:
                pass
            
            # Get current branch
            try:
                result = subprocess.run(
                    ["git", "branch", "--show-current"],
                    cwd=cwd,
                    capture_output=True,
                    text=True,
                    check=False
                )
                if result.returncode == 0:
                    context += f"Current branch: {result.stdout.strip()}\n"
            except Exception:
                pass
    except Exception:
        pass
    
    # Find important project files
    context += "\nProject files:\n"
    important_files = []
    
    # Look for specific files
    for filename in ["README.md", "package.json", "setup.py", "requirements.txt", "Cargo.toml", "go.mod", "Makefile"]:
        file_path = os.path.join(cwd, filename)
        if os.path.isfile(file_path):
            important_files.append(file_path)
            if len(important_files) >= max_files:
                break
    
    # If we don't have enough important files yet, look for source code files
    if len(important_files) < max_files:
        for ext in [".py", ".js", ".ts", ".go", ".rs", ".c", ".cpp", ".java"]:
            if len(important_files) >= max_files:
                break
                
            # Find files with this extension
            try:
                result = subprocess.run(
                    ["find", cwd, "-type", "f", "-name", f"*{ext}", "-not", "-path", "*/node_modules/*", "-not", "-path", "*/.git/*", "-not", "-path", "*/venv/*"],
                    capture_output=True,
                    text=True,
                    check=False
                )
                
                for file_path in result.stdout.strip().split("\n"):
                    if file_path and os.path.isfile(file_path):
                        important_files.append(file_path)
                        if len(important_files) >= max_files:
                            break
            except Exception:
                pass
    
    # Add file contents to context
    for file_path in important_files:
        try:
            rel_path = os.path.relpath(file_path, cwd)
            context += f"\nFile: {rel_path}\n"
            
            with open(file_path, "r") as f:
                lines = f.readlines()
                
            # Limit to max_lines
            if len(lines) > max_lines:
                file_content = "".join(lines[:max_lines]) + f"\n... (truncated, {len(lines)} total lines)"
            else:
                file_content = "".join(lines)
                
            context += f"```\n{file_content}\n```\n"
        except Exception as e:
            context += f"Error reading file: {str(e)}\n"
    
    return context

# Command handlers
@app.command()
def ask(
    query: List[str] = typer.Argument(None, help="Question to ask the AI assistant"),
    context: bool = typer.Option(True, "--context/--no-context", "-c/-n", help="Include project context"),
    edit: bool = typer.Option(False, "--edit", "-e", help="Edit query in editor before sending"),
):
    """Ask a question to the AI assistant"""
    config = load_config()
    
    # Get query from arguments or prompt the user
    if query:
        query_text = " ".join(query)
    else:
        query_text = typer.prompt("What would you like to know?")
    
    # Edit query if requested
    if edit:
        query_text = edit_in_editor(query_text)
    
    # Get project context if requested
    if context:
        context_text = get_project_context(
            max_files=config.get("context_files", 3),
            max_lines=config.get("context_lines", 50)
        )
        full_query = f"{context_text}\n\nQuestion: {query_text}"
    else:
        full_query = query_text
    
    # Show that we're working
    with console.status("Thinking..."):
        response = query_ai(full_query)
    
    # Display the response
    console.print(Markdown(response))
    
    # Add to history
    add_to_history(query_text, response)

@app.command()
def explain(
    file: str = typer.Argument(None, help="File to explain"),
):
    """Explain a code file"""
    if not file:
        console.print("Please provide a file to explain")
        return
    
    file_path = os.path.abspath(file)
    if not os.path.isfile(file_path):
        console.print(f"File not found: {file_path}")
        return
    
    # Read the file
    try:
        with open(file_path, "r") as f:
            code = f.read()
    except Exception as e:
        console.print(f"Error reading file: {str(e)}")
        return
    
    # Prepare query
    query = f"Explain this code in detail:\n\n```\n{code}\n```\n\nPlease provide:\n1. An overview of what the code does\n2. Explanation of key functions and components\n3. Any potential issues or improvements"
    
    # Show that we're working
    with console.status("Analyzing code..."):
        response = query_ai(query)
    
    # Display the response
    console.print(Markdown(response))
    
    # Add to history
    add_to_history(f"Explain {file}", response)

@app.command()
def command(
    task: List[str] = typer.Argument(None, help="Task to accomplish"),
):
    """Generate a command for a specific task"""
    if not task:
        task_text = typer.prompt("What task do you need a command for?")
    else:
        task_text = " ".join(task)
    
    # Prepare query
    query = f"Generate a command line command to accomplish this task: {task_text}\n\nProvide the command itself along with a brief explanation of how it works and any options used. If there are multiple ways to accomplish this, show the best or most common approach."
    
    # Show that we're working
    with console.status("Generating command..."):
        response = query_ai(query)
    
    # Display the response
    console.print(Markdown(response))
    
    # Add to history
    add_to_history(f"Command for: {task_text}", response)

@app.command()
def snippet(
    name: str = typer.Argument(None, help="Snippet name"),
    create: bool = typer.Option(False, "--create", "-c", help="Create a new snippet"),
    list_all: bool = typer.Option(False, "--list", "-l", help="List all snippets"),
    delete: bool = typer.Option(False, "--delete", "-d", help="Delete a snippet"),
):
    """Manage code snippets"""
    config = load_config()
    
    # List all snippets
    if list_all:
        snippets = config.get("snippets", {})
        if not snippets:
            console.print("No snippets found")
            return
        
        console.print("Available snippets:")
        for snippet_name, description in snippets.items():
            console.print(f"  - [bold]{snippet_name}[/bold]: {description}")
        return
    
    # Delete a snippet
    if delete and name:
        snippets = config.get("snippets", {})
        if name in snippets:
            del snippets[name]
            config["snippets"] = snippets
            save_config(config)
            
            # Also delete the file
            snippet_file = SNIPPETS_DIR / f"{name}.md"
            if snippet_file.exists():
                snippet_file.unlink()
            
            console.print(f"Snippet '{name}' deleted")
        else:
            console.print(f"Snippet '{name}' not found")
        return
    
    # Create a new snippet
    if create:
        if not name:
            name = typer.prompt("Snippet name")
        
        description = typer.prompt("Short description")
        content = edit_in_editor("# Enter your snippet here\n# Include a clear description and usage examples")
        
        # Save snippet
        snippets = config.get("snippets", {})
        snippets[name] = description
        config["snippets"] = snippets
        save_config(config)
        
        # Save snippet content
        snippet_file = SNIPPETS_DIR / f"{name}.md"
        with open(snippet_file, "w") as f:
            f.write(content)
        
        console.print(f"Snippet '{name}' created")
        return
    
    # Retrieve a snippet
    if name:
        snippets = config.get("snippets", {})
        if name in snippets:
            snippet_file = SNIPPETS_DIR / f"{name}.md"
            if snippet_file.exists():
                with open(snippet_file, "r") as f:
                    content = f.read()
                
                console.print(Panel.fit(
                    Markdown(content),
                    title=f"Snippet: {name}",
                    subtitle=snippets[name]
                ))
            else:
                console.print(f"Snippet file for '{name}' not found")
        else:
            console.print(f"Snippet '{name}' not found")
    else:
        console.print("Please provide a snippet name or use --list to see all snippets")

@app.command()
def history(
    count: int = typer.Option(5, "--count", "-c", help="Number of history entries to show"),
    search: str = typer.Option(None, "--search", "-s", help="Search term in history"),
):
    """View command history"""
    history_entries = load_history()
    
    if not history_entries:
        console.print("No history entries found")
        return
    
    # Filter by search term if provided
    if search:
        history_entries = [
            entry for entry in history_entries
            if search.lower() in entry.get("query", "").lower()
        ]
        
        if not history_entries:
            console.print(f"No history entries matching '{search}'")
            return
    
    # Show last entries (limited by count)
    to_show = history_entries[-count:]
    
    for i, entry in enumerate(to_show):
        index = len(history_entries) - count + i
        timestamp = entry.get("timestamp", "")
        query = entry.get("query", "")
        
        # Format timestamp
        if timestamp:
            try:
                dt = datetime.datetime.fromisoformat(timestamp)
                timestamp = dt.strftime("%Y-%m-%d %H:%M")
            except Exception:
                pass
        
        console.print(f"[bold blue]#{index}[/bold blue] [dim]{timestamp}[/dim]")
        console.print(f"[bold]Query:[/bold] {query}")
        console.print("──" * 30)

@app.command()
def config(
    list_config: bool = typer.Option(False, "--list", "-l", help="List current configuration"),
    api_key: str = typer.Option(None, "--api-key", help="Set API key"),
    model: str = typer.Option(None, "--model", help="Set AI model"),
    max_tokens: int = typer.Option(None, "--max-tokens", help="Set maximum tokens"),
    temperature: float = typer.Option(None, "--temperature", help="Set temperature"),
    context_files: int = typer.Option(None, "--context-files", help="Set number of context files"),
    context_lines: int = typer.Option(None, "--context-lines", help="Set number of context lines per file"),
):
    """Configure the assistant"""
    current_config = load_config()
    
    # List current configuration
    if list_config:
        console.print("[bold]Current Configuration:[/bold]")
        for key, value in current_config.items():
            if key == "api_key" and value:
                console.print(f"  - [bold]{key}:[/bold] {'*' * 10}")
            elif key == "snippets":
                console.print(f"  - [bold]{key}:[/bold] {len(value)} snippet(s)")
            else:
                console.print(f"  - [bold]{key}:[/bold] {value}")
        return
    
    # Update configuration
    changes = False
    
    if api_key is not None:
        current_config["api_key"] = api_key
        changes = True
    
    if model is not None:
        current_config["model"] = model
        changes = True
    
    if max_tokens is not None:
        current_config["max_tokens"] = max_tokens
        changes = True
    
    if temperature is not None:
        current_config["temperature"] = temperature
        changes = True
    
    if context_files is not None:
        current_config["context_files"] = context_files
        changes = True
    
    if context_lines is not None:
        current_config["context_lines"] = context_lines
        changes = True
    
    if changes:
        save_config(current_config)
        console.print("Configuration updated!")
    else:
        console.print("No changes made to configuration")

@app.command()
def doc(
    file: str = typer.Argument(None, help="File to document"),
):
    """Generate documentation for a file"""
    if not file:
        console.print("Please provide a file to document")
        return
    
    file_path = os.path.abspath(file)
    if not os.path.isfile(file_path):
        console.print(f"File not found: {file_path}")
        return
    
    # Read the file
    try:
        with open(file_path, "r") as f:
            code = f.read()
    except Exception as e:
        console.print(f"Error reading file: {str(e)}")
        return
    
    # Detect language from file extension
    ext = os.path.splitext(file_path)[1].lower()
    language = {
        ".py": "Python",
        ".js": "JavaScript",
        ".ts": "TypeScript",
        ".go": "Go",
        ".rs": "Rust",
        ".c": "C",
        ".cpp": "C++",
        ".java": "Java",
        ".rb": "Ruby",
        ".php": "PHP",
        ".sh": "Bash",
    }.get(ext, "Unknown")
    
    # Prepare query
    query = f"Generate comprehensive documentation for this {language} code. Include function-level documentation, usage examples, and a high-level overview:\n\n```{ext[1:]}\n{code}\n```"
    
    # Show that we're working
    with console.status(f"Generating documentation for {os.path.basename(file_path)}..."):
        response = query_ai(query)
    
    # Display the response
    console.print(Markdown(response))
    
    # Ask if user wants to save the documentation
    if typer.confirm("Save documentation to a file?"):
        doc_file = os.path.splitext(file_path)[0] + ".docs.md"
        with open(doc_file, "w") as f:
            f.write(response)
        console.print(f"Documentation saved to {doc_file}")
    
    # Add to history
    add_to_history(f"Document {file}", response)

# Helper functions
def edit_in_editor(initial_text: str) -> str:
    """Open text in editor and return edited content"""
    editor = os.environ.get("EDITOR", "vim")
    
    with tempfile.NamedTemporaryFile(suffix=".md", mode="w+", delete=False) as tmp:
        tmp_path = tmp.name
        tmp.write(initial_text)
    
    try:
        subprocess.run([editor, tmp_path], check=True)
        with open(tmp_path, "r") as f:
            edited_text = f.read()
        return edited_text
    finally:
        os.unlink(tmp_path)

if __name__ == "__main__":
    app()
```

Make it executable and install:
```bash
chmod +x ~/bin/dev-assist.py
sudo ln -s ~/bin/dev-assist.py /usr/local/bin/dev-assist
```

3. **Test the development assistant**:
```bash
# Configure the assistant
dev-assist config --api-key "your_anthropic_api_key"
dev-assist config --list

# Try some basic commands
dev-assist ask "How do I optimize a Python list comprehension?"
dev-assist command "Find all files modified in the last 7 days"

# Create a snippet
dev-assist snippet --create
# Enter details when prompted

# Try explaining code
dev-assist explain ~/ai-test-project/src/main.py
```

### Task 2: Create an AI-Enhanced Git Workflow

1. **Create a Git commit helper script**:

```bash
#!/bin/bash
# ai-commit.sh - AI-powered Git commit assistant

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "Error: Not in a git repository"
  exit 1
fi

# Check if there are staged changes
if git diff --cached --quiet; then
  echo "No staged changes found. Use 'git add' to stage changes before committing."
  exit 1
fi

# Function to generate commit message
generate_commit_message() {
  # Get the diff of staged changes
  DIFF=$(git diff --cached)
  
  # Call AI service to generate a commit message
  echo "🤖 Generating commit message..."
  
  # Check for API key
  if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "Error: ANTHROPIC_API_KEY environment variable not set"
    exit 1
  fi
  
  # Call Claude API
  RESPONSE=$(curl -s -X POST https://api.anthropic.com/v1/messages \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -H "content-type: application/json" \
    -d "{
      \"model\": \"claude-3-haiku-20240307\",
      \"max_tokens\": 150,
      \"messages\": [
        {\"role\": \"user\", \"content\": \"Please generate a concise, descriptive commit message for these changes. Follow conventional commits format (feat, fix, docs, style, refactor, test, chore). Keep it under 72 characters for the first line, followed by a blank line and more details if needed. Do not include quotes around the message.\n\nHere's the git diff:\n\n$DIFF\"}
      ]
    }")
  
  # Extract the message from the response
  MESSAGE=$(echo "$RESPONSE" | grep -o '"text":"[^"]*"' | sed 's/"text":"//;s/"//')
  
  if [ -z "$MESSAGE" ]; then
    echo "Error: Failed to generate commit message"
    exit 1
  fi
  
  echo "$MESSAGE"
}

# Function to suggest related issues
suggest_issues() {
  # Get repository URL
  REPO_URL=$(git remote get-url origin 2>/dev/null)
  if [ $? -ne 0 ]; then
    return
  fi
  
  # Check if it's a GitHub repository
  if [[ $REPO_URL == *"github.com"* ]]; then
    # Extract owner and repo
    REPO_INFO=$(echo $REPO_URL | sed -E 's|.*github.com[/:]([^/]+)/([^/.]+).*|\1 \2|')
    OWNER=$(echo $REPO_INFO | cut -d' ' -f1)
    REPO=$(echo $REPO_INFO | cut -d' ' -f2)
    
    # Get issues from GitHub API
    echo "🔍 Checking for related GitHub issues..."
    ISSUES=$(curl -s "https://api.github.com/repos/$OWNER/$REPO/issues?state=open&per_page=5")
    
    # Check if we got issues
    if [[ $ISSUES != *"title"* ]]; then
      return
    fi
    
    # Extract issue numbers and titles
    echo "📋 Open issues that might be related:"
    echo "$ISSUES" | grep -E '"number"|"title"' | sed -E 's/.*"number": ([0-9]+).*/  #\1:/' | sed -E 's/.*"title": "([^"]+)".*/    \1/'
    echo
  fi
}

# Generate the commit message
COMMIT_MSG=$(generate_commit_message)

# Display the suggested commit message
echo -e "\n📝 Suggested commit message:"
echo "--------------------------------"
echo -e "$COMMIT_MSG"
echo "--------------------------------"

# Suggest related issues
suggest_issues

# Ask user what to do
echo -e "\nOptions:"
echo "1) Use this message"
echo "2) Edit this message"
echo "3) Write a new message"
echo "4) Cancel commit"
read -p "Choose an option (1-4): " OPTION

case $OPTION in
  1)
    # Use the suggested message
    echo "$COMMIT_MSG" > .git/COMMIT_EDITMSG
    git commit -F .git/COMMIT_EDITMSG
    ;;
  2)
    # Edit the suggested message
    echo "$COMMIT_MSG" > .git/COMMIT_EDITMSG
    ${EDITOR:-vim} .git/COMMIT_EDITMSG
    git commit -F .git/COMMIT_EDITMSG
    ;;
  3)
    # Write a new message
    git commit
    ;;
  *)
    # Cancel
    echo "Commit canceled"
    exit 0
    ;;
esac

echo "✅ Commit completed"
```

Make it executable and install:
```bash
chmod +x ai-commit.sh
sudo cp ai-commit.sh /usr/local/bin/ai-commit
```

2. **Create a Git pre-push hook with AI code review**:

Create a file `~/.config/git-hooks/pre-push`:
```bash
#!/bin/bash
# pre-push hook with AI code review

# Configuration
MAX_FILES=5
MAX_LINES_PER_FILE=100

# Check if we should skip the review
if [ "$SKIP_AI_REVIEW" = "1" ]; then
  echo "Skipping AI code review (SKIP_AI_REVIEW=1)"
  exit 0
fi

# Check for API key
if [ -z "$ANTHROPIC_API_KEY" ]; then
  echo "Warning: ANTHROPIC_API_KEY not set, skipping AI code review"
  exit 0
fi

# Get the current branch
BRANCH=$(git symbolic-ref --short HEAD)

# Get the remote and URL
remote="$1"
url="$2"

# Get changes between the current branch and the remote branch
REMOTE_BRANCH=$(git for-each-ref --format='%(upstream:short)' "$(git symbolic-ref -q HEAD)")
if [ -z "$REMOTE_BRANCH" ]; then
  REMOTE_BRANCH="origin/$BRANCH"
fi

# Get list of changed files
CHANGED_FILES=$(git diff --name-only "$REMOTE_BRANCH" 2>/dev/null)
if [ $? -ne 0 ]; then
  # Remote branch might not exist, use origin/main as fallback
  CHANGED_FILES=$(git diff --name-only origin/main 2>/dev/null)
  if [ $? -ne 0 ]; then
    # If that fails too, use the local branch's first commit
    FIRST_COMMIT=$(git rev-list --max-parents=0 HEAD)
    CHANGED_FILES=$(git diff --name-only "$FIRST_COMMIT" HEAD)
  fi
fi

# Filter for just code files
CODE_FILES=$(echo "$CHANGED_FILES" | grep -E '\.(py|js|ts|jsx|tsx|go|rs|c|cpp|h|hpp|java|rb|php)
)

# Count files
FILE_COUNT=$(echo "$CODE_FILES" | wc -l)

if [ "$FILE_COUNT" -eq 0 ]; then
  echo "No code files changed, skipping AI review"
  exit 0
fi

echo "🔍 AI Code Review"
echo "================="
echo "Reviewing changes before push..."

# Limit to MAX_FILES files
if [ "$FILE_COUNT" -gt "$MAX_FILES" ]; then
  echo "Too many files changed ($FILE_COUNT). Reviewing only the first $MAX_FILES."
  CODE_FILES=$(echo "$CODE_FILES" | head -n "$MAX_FILES")
fi

# Collect the changes for review
REVIEW_CONTENT=""

for file in $CODE_FILES; do
  if [ -f "$file" ]; then
    # Get file extension to determine language
    EXT="${file##*.}"
    
    # Skip files that are too large
    LINE_COUNT=$(wc -l < "$file")
    if [ "$LINE_COUNT" -gt 1000 ]; then
      echo "Skipping $file: too large ($LINE_COUNT lines)"
      continue
    fi
    
    echo "Reviewing $file..."
    
    # Get diff or file content
    if git diff --quiet "$REMOTE_BRANCH" -- "$file" 2>/dev/null; then
      # File is new, get the whole content
      FILE_CONTENT=$(head -n "$MAX_LINES_PER_FILE" "$file")
      REVIEW_CONTENT+="File: $file (new file)\n\n\`\`\`$EXT\n$FILE_CONTENT\n\`\`\`\n\n"
    else
      # File was modified, get the diff
      DIFF=$(git diff "$REMOTE_BRANCH" -- "$file" | head -n "$MAX_LINES_PER_FILE")
      REVIEW_CONTENT+="File: $file (changes)\n\n\`\`\`diff\n$DIFF\n\`\`\`\n\n"
    fi
  fi
done

if [ -z "$REVIEW_CONTENT" ]; then
  echo "No content to review"
  exit 0
fi

# Prepare prompt for AI review
PROMPT="Please review these code changes before I push them to the repository. Focus on:
1. Potential bugs or logic errors
2. Security issues or vulnerabilities
3. Performance concerns
4. Best practices and code quality issues

For each file, provide a brief assessment. If there are no issues, simply state that the code looks good.
Be concise but thorough. If you identify any critical issues, clearly mark them as CRITICAL.

Here are the changes:

$REVIEW_CONTENT"

# Call AI service for review
echo "Sending code for AI review..."
RESPONSE=$(curl -s -X POST https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d "{
    \"model\": \"claude-3-haiku-20240307\",
    \"max_tokens\": 1000,
    \"messages\": [
      {\"role\": \"user\", \"content\": \"$PROMPT\"}
    ]
  }")

# Extract the message from the response
REVIEW=$(echo "$RESPONSE" | grep -o '"text":"[^"]*"' | sed 's/"text":"//;s/"$//')

if [ -z "$REVIEW" ]; then
  echo "Error: Failed to get AI review"
  exit 0
fi

# Display the review
echo -e "\n📋 AI Code Review Results:"
echo "============================"
echo -e "$REVIEW"
echo "============================"

# Check if there are any critical issues
if echo "$REVIEW" | grep -i "CRITICAL" > /dev/null; then
  echo -e "\n⚠️ CRITICAL ISSUES FOUND!"
  echo "The AI review identified critical issues with your code."
  echo "It's recommended to fix these issues before pushing."
  
  # Ask user if they want to proceed
  read -p "Do you want to proceed with push anyway? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Push aborted. Fix the issues and try again."
    exit 1
  fi
  
  echo "Proceeding with push despite critical issues..."
else
  echo -e "\n✅ No critical issues found."
fi

exit 0
```

Make it executable:
```bash
chmod +x ~/.config/git-hooks/pre-push
```

3. **Create a script to install the hooks**:

```bash
#!/bin/bash
# install-ai-git-hooks.sh - Install AI-powered git hooks

set -e

HOOK_DIR=$(git rev-parse --git-dir 2>/dev/null)/hooks
if [ $? -ne 0 ]; then
  echo "Error: Not in a git repository"
  exit 1
fi

HOOK_SOURCE=~/.config/git-hooks

# Check if hook source directory exists
if [ ! -d "$HOOK_SOURCE" ]; then
  echo "Error: Hook source directory not found: $HOOK_SOURCE"
  echo "Please run ai-commit at least once to create the directory and hooks"
  exit 1
fi

# Create backup of existing hooks
echo "Creating backup of existing hooks..."
mkdir -p "$HOOK_DIR.bak"
for hook in pre-commit prepare-commit-msg commit-msg post-commit pre-push; do
  if [ -f "$HOOK_DIR/$hook" ]; then
    cp "$HOOK_DIR/$hook" "$HOOK_DIR.bak/$hook"
  fi
done

# Install pre-push hook
if [ -f "$HOOK_SOURCE/pre-push" ]; then
  echo "Installing pre-push hook..."
  cp "$HOOK_SOURCE/pre-push" "$HOOK_DIR/pre-push"
  chmod +x "$HOOK_DIR/pre-push"
else
  echo "Warning: pre-push hook not found in $HOOK_SOURCE"
fi

echo "Git hooks installed successfully!"
echo "To skip AI review when pushing, use: SKIP_AI_REVIEW=1 git push"
```

Make it executable and install:
```bash
chmod +x install-ai-git-hooks.sh
sudo cp install-ai-git-hooks.sh /usr/local/bin/install-ai-git-hooks
```

4. **Test the AI Git tools**:
```bash
# Create a test repository
mkdir -p ~/ai-git-workflow
cd ~/ai-git-workflow
git init

# Install the git hooks
install-ai-git-hooks

# Create a sample file
echo "# AI Git Workflow Test" > README.md
echo "This is a test repository to demonstrate AI-powered Git workflow." >> README.md

# Use AI to commit
git add README.md
ai-commit

# Create a remote repository (simulated)
mkdir -p ~/ai-git-remote
cd ~/ai-git-remote
git init --bare

# Add the remote to our repository
cd ~/ai-git-workflow
git remote add origin ~/ai-git-remote

# Try to push (this should trigger the pre-push hook)
git push --set-upstream origin main
```

## Additional Resources

### AI Integration Cheatsheet

**Environment Variables**:
```bash
# Add to your ~/.zshrc or ~/.bashrc
export ANTHROPIC_API_KEY="your_key_here"
export OPENAI_API_KEY="your_key_here"
```

**Shell Functions**:
```bash
# Quick AI query
alias ask='function _ask() { llm "$*" | bat --style=plain; }; _ask'

# Explain a command
alias explain='function _explain() { echo "Explaining command: $*" && llm "Explain this shell command in detail: $*" | bat --style=plain; }; _explain'

# Generate git commit message
alias aicm='function _aicm() { git diff --staged | llm "Generate a concise git commit message for these changes. Use conventional commits format." | bat --style=plain; }; _aicm'
```

**Vim Commands**:
```
" Add to .vimrc or init.vim
" AI explain current file
command! AIExplain !cat % | llm "Explain this code:" | less
" AI suggest improvements
command! AIImprove !cat % | llm "Suggest improvements for this code:" | less
```

**Development Assistant Usage**:
```bash
# Ask a question with project context
dev-assist ask "How can I optimize this code?"

# Explain a file
dev-assist explain path/to/file.py

# Generate documentation
dev-assist doc path/to/file.py

# Find a command
dev-assist command "Find all large files in the current directory"

# Manage code snippets
dev-assist snippet --create
dev-assist snippet --list
dev-assist snippet snippet_name
```

## Self-Assessment Quiz Answers

1. What environment variable is typically used to store the OpenAI API key?
   - `OPENAI_API_KEY`

2. How would you securely store API credentials in a Linux environment?
   - Store them in environment variables in your shell configuration, use a credential manager like `pass`, or use a secure file with restricted permissions (chmod 600).

3. What is the purpose of a system prompt when working with AI assistants?
   - It provides context and instructions to guide the AI's behavior and responses, setting roles, constraints, and expected output format.

4. How can you integrate AI code completion into Neovim?
   - Use plugins like Copilot.lua with cmp, configure LSP for code intelligence, and create custom commands for AI operations.

5. What are the key considerations when designing a CLI tool that uses AI services?
   - User experience, error handling, API rate limits, credential management, and providing helpful context for better results.

6. How would you implement project-specific context awareness in an AI assistant?
   - Detect the project type, analyze key files like README and configuration files, gather relevant source code, and maintain persistent project context between requests.

7. What are the security concerns when using AI in a development workflow?
   - Exposing sensitive code or data to external APIs, storing API credentials securely, and properly vetting AI suggestions before implementation.

8. How can you balance AI assistance with maintaining and developing your coding skills?
   - Use AI as a learning tool, understand the code it generates, implement solutions yourself first before asking for help, and use AI for specific challenges rather than relying on it completely.

9. What strategies can you use to reduce API costs when using AI services extensively?
   - Cache common queries, use smaller/faster models for simpler tasks, implement rate limiting, batch similar requests, and optimize prompts for efficiency.

10. How would you approach the design of a custom AI tool for a specific development task?
    - Identify the specific pain point, optimize context gathering, design a focused user experience, incorporate feedback loops, and implement error handling and fallbacks.

## Next Steps

To continue developing your AI-enhanced Linux development workflow:

1. **Explore Local Model Deployment**: Run models like Llama 3 locally for privacy and reduced costs
2. **Build Team Collaboration Tools**: Create shared AI utilities for development teams
3. **Develop Custom Plugins**: Create editor plugins specifically tailored to your workflow
4. **Implement Monitoring**: Track API usage and costs to optimize your AI integration
5. **Explore Multi-Modal Capabilities**: Integrate image and audio AI capabilities

## Acknowledgements

This exercise guide was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Exercise structure and organization
- Code examples and script development
- Troubleshooting guidance and best practices

Claude was used as a development aid while all final implementation decisions and review were performed by Joshua Michael Hall.

## Disclaimer

This guide is provided "as is", without warranty of any kind. Always evaluate the AI-generated code and suggestions before implementing them in production environments. Consider the privacy implications of sending code or sensitive information to external AI services, and implement appropriate safeguards.

---

> "Master the basics. Then practice them every day without fail." - John C. Maxwell