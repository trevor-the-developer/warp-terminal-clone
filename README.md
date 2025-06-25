# 🚀 Wurp (Warp Terminal Clone)

A feature-rich terminal emulator built with .NET 8, featuring AI integration, command history, auto-completion, and themes.

## Quick Start

```bash
# Check dependencies
./scripts/wurp-terminal check

# Install everything
./scripts/wurp-terminal install

# Run the terminal
wurp-terminal
```

## Features

- 🤖 **Enhanced AI Integration** - Full FreelanceAI API integration with smart routing and real-time cost tracking
- 📊 **Real-time Metrics** - Provider selection and performance monitoring
- 📜 **Command History** - Persistent history with search capability
- 🎨 **Multiple Themes** - Customisable themes with default, dark, and wurp options
- 🐚 **Cross-Shell Support** - Compatible with bash and zsh
- ⚙️ **JSON Configuration** - Centralised config management for easy setup
- 🔧 **Modular Architecture** - Clean separation of concerns with extendable modules

## AI Commands

The terminal includes comprehensive AI integration with FreelanceAI's smart routing system:

### Basic AI Commands
```bash
# Explain commands and concepts
ai explain "docker ps"        # Get detailed explanations
ai suggest "deploy app"       # Get practical suggestions
ai debug "permission denied"  # Troubleshooting help
```

### Advanced AI Commands
```bash
# Code generation with smart provider routing
ai code "REST API controller in C#"
ai code "React component for login form"

# Code review and optimisation
ai review "my-function.cs"           # Get code review feedback
ai optimise "slow database query"    # Performance optimisation tips

# Testing guidance
ai test "async methods in C#"        # Testing strategies and examples
```

### Real-time Monitoring
Each AI request shows:
- 📊 **Provider Used**: Which AI service handled the request (Groq, Ollama)
- 💰 **Cost Tracking**: Real-time cost per request
- ⚡ **Performance**: Response time and success metrics

## Built-in Commands

```bash
# Theme management
theme                    # Show current theme and options
theme wurp              # Switch to wurp theme (cyan prompt)
theme dark              # Switch to dark theme
theme default           # Switch to default theme

# Terminal operations
clear                   # Clear screen
history                 # Show command history
help                    # Show comprehensive help
exit / quit             # Exit gracefully

# System commands work normally
ls -la                  # File operations
git status              # Version control
npm install             # Package management
docker ps               # Container management
```

## FreelanceAI Integration

This terminal is designed to work seamlessly with FreelanceAI's intelligent routing system:

### Requirements
- **FreelanceAI API** running on `http://localhost:5000`
- Optional: **Ollama** for local AI fallback

### Smart Features
- **Automatic Provider Selection** - Routes to best available AI provider (Groq → Ollama)
- **Cost Optimisation** - Real-time budget tracking and cost monitoring
- **Health Monitoring** - Automatic failover when providers are unavailable
- **Rate Limiting** - Respects provider limits and quotas
- **Response History** - Tracks all AI interactions for analytics

### Setup FreelanceAI
```bash
# Clone and start FreelanceAI
git clone <freelance-ai-repo>
cd FreelanceAI
dotnet run --project src/FreelanceAI.WebApi

# Verify it's running
curl http://localhost:5000/health
```

## Installation & Management

### Build Commands
```bash
./scripts/wurp-terminal check      # Verify dependencies
./scripts/wurp-terminal build      # Build application
./scripts/wurp-terminal publish    # Create optimised binary
./scripts/wurp-terminal install    # Full installation
./scripts/wurp-terminal status     # Show installation status
```

### Advanced Usage
```bash
# Run directly without installation
./scripts/wurp-terminal run

# Check AI service status
./scripts/wurp-terminal ai-status

# Development workflow
dotnet run                          # Direct .NET execution
dotnet build --watch               # Hot reload during development
```

## Project Structure

```
wurp-terminal/
├── Program.cs                          # Application entry point
├── Core/                               # Modular architecture
│   ├── WurpTerminalService.cs          # Main terminal service
│   ├── AIIntegration.cs               # FreelanceAI integration
│   └── ThemeManager.cs                # Theme management
├── wurp-config.json                   # Centralised configuration
├── scripts/
│   ├── wurp-terminal                   # Main launcher script
│   └── lib/
│       └── wurp-terminal-functions.sh # Function library
├── WurpTerminal.csproj                # .NET project file
└── README.md                          # This file
```

## Configuration

The `wurp-config.json` file contains all settings:

```json
{
  "services": {
    "freelance_ai": {
      "base_url": "http://localhost:5000",
      "features": [
        "Smart provider routing (Groq, Ollama)",
        "Cost optimisation and tracking",
        "Response history analytics",
        "Health monitoring",
        "Automatic failover"
      ]
    }
  }
}
```

## Troubleshooting

### Common Issues
1. **AI commands not working**: Ensure FreelanceAI is running on port 5000
2. **Theme not changing**: Try using the full command: `theme <name>`
3. **Build fails**: Check that .NET 8 SDK is properly installed

### Debug Commands
```bash
# Check FreelanceAI connectivity
curl http://localhost:5000/health

# Check dependencies
./scripts/wurp-terminal check

# View detailed status
./scripts/wurp-terminal status
```

---

**Built with ❤️ using .NET 8 and FreelanceAI**

*Experience the future of terminal interaction with AI-powered assistance and intelligent routing.*
