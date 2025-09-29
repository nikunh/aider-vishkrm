# Aider - AI Pair Programming Assistant

AI-powered coding assistant with comprehensive configuration for multiple AI models and development scenarios.

## 🤖 **What is Aider?**

Aider is an AI pair programming tool that lets you edit code in your local git repository using AI. It can:
- Add new features to existing code
- Fix bugs and refactor code  
- Write tests and documentation
- Explain and review code changes
- Work with multiple AI models (GPT-4, Claude, local models)

## ✨ **Features Included**

### **Pre-configured AI Models**
- **GPT-4/GPT-3.5**: OpenAI models with API key support
- **Claude**: Anthropic models via API
- **Local LLMs**: Integration with Ollama for offline development
- **Custom Models**: Easy configuration for additional models

### **Development Scenarios**
Pre-configured scenarios in `configs/aider_scenarios.json`:
- **Code Review**: Review and suggest improvements
- **Bug Fixing**: Identify and fix issues
- **Feature Development**: Add new functionality
- **Documentation**: Generate and update docs
- **Testing**: Write unit and integration tests

### **Advanced Configuration**
- **Project-specific settings**: Per-project aider configuration
- **Environment detection**: Auto-selects best available model
- **Git integration**: Automatic commit messages and branch management
- **Custom commands**: Pre-defined command shortcuts

## 🚀 **Getting Started**

### **Basic Usage**
```bash
# Start aider in current directory
aider

# Work on specific files
aider app.py tests/test_app.py

# Use specific model
aider --model gpt-4

# Load a scenario
aider --config configs/aider_scenarios.json
```

### **First Time Setup**
```bash
# Configure API keys (if using cloud models)
export OPENAI_API_KEY="your-openai-key"
export ANTHROPIC_API_KEY="your-claude-key"

# Or use local models (if Ollama is available)
aider --model ollama/codellama
```

## 🔧 **Configuration**

### **Environment Variables**
Set these in your shell or `.env` file:

```bash
# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key
OPENAI_BASE_URL=https://api.openai.com/v1  # Optional

# Anthropic Claude
ANTHROPIC_API_KEY=your_anthropic_api_key

# Local LLM (Ollama)
OLLAMA_HOST=http://localhost:11434  # Default
```

### **Configuration Files**

**Main Config** (`configs/aider.conf.yml`):
```yaml
model: gpt-4
edit-format: diff
git: true
auto-commits: true
show-diffs: true
```

**Model Settings** (`configs/aider.model.settings.yml`):
- Per-model temperature and parameter settings
- Fallback model configuration
- Local model endpoints

**Scenarios** (`configs/aider_scenarios.json`):
- Pre-configured development workflows
- Custom prompts and settings
- Project-specific templates

### **Custom Commands**
Available in `configs/aider_commands.json`:

```bash
# Code review workflow
aider-review file.py

# Bug fixing mode
aider-debug file.py

# Documentation generation
aider-docs project/

# Test generation
aider-test src/module.py
```

## 🎯 **Usage Examples**

### **Feature Development**
```bash
# Start aider and describe what you want
aider app.py
# Then: "Add user authentication with JWT tokens"
```

### **Bug Fixing**
```bash
# Point aider to problematic code
aider --model gpt-4 problematic_file.py
# Then: "Fix the memory leak in the process_data function"
```

### **Code Review**
```bash
# Review recent changes
aider --review HEAD~1..HEAD

# Review specific files
aider --review src/new_feature.py
```

### **Documentation**
```bash
# Generate documentation for modules
aider --docs src/
# Then: "Add comprehensive docstrings to all functions"
```

## 🧠 **Available Models**

### **Cloud Models** (API Key Required)
- **gpt-4**: Most capable, best for complex tasks
- **gpt-3.5-turbo**: Fast and cost-effective
- **claude-3**: Anthropic's model, excellent for analysis
- **claude-instant**: Faster Claude variant

### **Local Models** (via Ollama)
- **codellama**: Code-focused Llama variant
- **llama2**: General purpose local model
- **mistral**: Fast local alternative
- **custom**: Any model available in local Ollama

### **Model Selection Strategy**
```bash
# Auto-select best available model
aider --auto

# Fallback chain (cloud -> local)
aider --model gpt-4 --fallback codellama

# Cost-conscious development
aider --model gpt-3.5-turbo
```

## 🛠️ **Advanced Features**

### **Git Integration**
```bash
# Automatic commits with AI-generated messages
aider --auto-commits

# Create feature branch
aider --branch feature/user-auth

# Review mode (no changes, only suggestions)
aider --review-only
```

### **Project Templates**
```bash
# Load project-specific configuration
aider --config .aider.conf.yml

# Use predefined scenario
aider --scenario bug-fix

# Combine multiple configs
aider --config global.yml --config project.yml
```

### **Collaboration Mode**
```bash
# Share session with team
aider --share

# Export session for review
aider --export session.json

# Replay session
aider --replay session.json
```

## 📁 **File Structure**

```
.devcontainer/features/aider/
├── configs/
│   ├── aider.conf.yml           # Main configuration
│   ├── aider.model.settings.yml # Model-specific settings  
│   ├── aider_commands.json      # Custom commands
│   ├── aider_config.json        # Base configuration
│   ├── aider_scenarios.json     # Development scenarios
│   ├── babaji_aider.py          # Custom aider extensions
│   ├── env                      # Environment setup
│   ├── environments.sh          # Environment detection
│   └── requirements.txt         # Python dependencies
├── devcontainer-feature.json   # Feature metadata
├── install.sh                  # Installation script
└── README.md                   # This file
```

## 🆘 **Troubleshooting**

### **Model Not Available**
```bash
# Check available models
aider --models

# Test model connection
aider --model gpt-4 --test

# Use fallback model
aider --model gpt-3.5-turbo
```

### **API Key Issues**
```bash
# Verify API key is set
echo $OPENAI_API_KEY

# Test API connection
curl -H "Authorization: Bearer $OPENAI_API_KEY" \
  https://api.openai.com/v1/models
```

### **Local Model Problems**
```bash
# Check Ollama status
ollama list

# Start Ollama service
ollama serve

# Pull required model
ollama pull codellama
```

### **Git Integration Issues**
```bash
# Verify git repository
git status

# Check aider git settings
aider --show-git-config

# Reset git configuration
git config --unset-all aider.*
```

## 💡 **Tips & Best Practices**

### **Effective Prompting**
- Be specific about what you want changed
- Provide context about the codebase
- Ask for explanations of complex changes
- Request tests for new functionality

### **Model Selection**
- Use GPT-4 for complex logic and architecture
- Use GPT-3.5-turbo for simple changes and refactoring
- Use local models for privacy-sensitive code
- Use Claude for code analysis and documentation

### **Workflow Integration**
- Start with small, focused changes
- Review AI suggestions before accepting
- Use meaningful commit messages
- Test changes thoroughly

### **Performance Optimization**
- Use `--fast` for quick iterations  
- Cache model responses with `--cache`
- Use `--no-stream` for batch processing
- Limit context with `--context-tokens`

## 🔗 **Related Documentation**

- **[AI-Assisted Development](../../../docs/04-development/ai-assisted-development.md)** - Using AI in development workflows
- **[Development Workflows](../../../docs/04-development/)** - Complete development guide
- **[Feature Catalog](../../../docs/08-reference/feature-catalog.md)** - All available features

## 🌐 **External Resources**

- **[Aider Official Documentation](https://aider.chat/docs/)**
- **[AI Code Assistant Comparison](https://github.com/paul-gauthier/aider)**
- **[OpenAI API Documentation](https://platform.openai.com/docs/)**
- **[Anthropic Claude API](https://docs.anthropic.com/)**

---

*Part of the Shellinator Reloaded DevContainer feature collection*