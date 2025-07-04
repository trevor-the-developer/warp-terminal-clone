# 🚀 Wurp (Warp Terminal Clone)

A feature-rich AI-powered terminal built with .NET 9, featuring intelligent AI integration via FreelanceAI, command history, themes, and seamless shell compatibility. Generated from the [warp-terminal-clone-bootstrap](https://github.com/trevor-the-developer/warp-terminal-clone-bootstrap) project.

**Latest Updates (December 2025):**
- ✅ **Updated to .NET 9** for compatibility with FreelanceAI smart routing system
- ✅ **Enhanced AI Integration** with FreelanceAI's intelligent provider selection
- ✅ **Production-Ready Architecture** with comprehensive monitoring and cost optimisation
- ✅ **Modular Design** for easy extension and maintenance

## Quick Start

```bash
# Check dependencies (dotnet, jq, curl)
./scripts/wurp-terminal check

# Build and install everything
./scripts/wurp-terminal install

# Run the terminal
wurp-terminal

# Or run directly without installation
./scripts/wurp-terminal run
```

## Features

- 🤖 **Enhanced AI Integration** - Full FreelanceAI API integration with smart routing and real-time cost tracking
- 📊 **Real-time Metrics** - Provider selection and performance monitoring  
- 📜 **Command History** - Persistent history with search capability
- 🎨 **Multiple Themes** - Customisable themes with default, dark, and wurp options
- 🐚 **Cross-Shell Support** - Compatible with bash and zsh
- ⚙️ **JSON Configuration** - Centralised config management for easy setup
- 🔧 **Modular Architecture** - Clean separation of concerns with extendable modules
- 💰 **Cost Optimisation** - Budget tracking and intelligent provider selection
- 🔄 **Automatic Failover** - Seamless switching between AI providers (Groq → Ollama)
- 💻 **Cross-Platform** - Runs on Linux, macOS, Windows with .NET 9

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

This terminal is designed to work seamlessly with [FreelanceAI](../Freelance-AI/)'s production-ready intelligent routing system:

### Requirements
- **FreelanceAI API** running on `http://localhost:5000`
- **Groq API Key** (free tier available) - primary provider
- Optional: **Ollama** for local AI fallback

### Smart Features
- **Intelligent Provider Selection** - Priority-based routing (Groq → Ollama)
- **Cost Optimisation** - Real-time budget tracking and cost monitoring
- **Health Monitoring** - Automatic failover when providers are unavailable
- **Rate Limiting** - Respects provider limits and quotas
- **Response History** - Complete request/response tracking with analytics
- **Performance Metrics** - Response times and success rates per provider
- **Enterprise Logging** - Structured logging with multiple output formats

### Setup FreelanceAI
```bash
# Clone and start FreelanceAI (from parent directory)
cd ../Freelance-AI

# Configure API key in appsettings.Development.json
# Add your Groq API key to "Groq:ApiKey"

# Build and run
dotnet build
dotnet run --project src/FreelanceAI.WebApi

# Verify it's running
curl http://localhost:5000/health
curl http://localhost:5000/api/ai/status

# Test CLI integration
./scripts/freelance-ai status
```

## Installation & Management

### Build Commands
```bash
./scripts/wurp-terminal check      # Verify dependencies (dotnet, jq, curl)
./scripts/wurp-terminal build      # Build application (.NET 9)
./scripts/wurp-terminal publish    # Create optimised binary
./scripts/wurp-terminal install    # Full installation (build, publish, create symlinks)
./scripts/wurp-terminal status     # Show installation status and paths
```

### Advanced Usage
```bash
# Run directly without installation
./scripts/wurp-terminal run

# Check AI service connectivity and status
./scripts/wurp-terminal ai-status

# Development workflow
dotnet run                          # Direct .NET execution
dotnet build --watch               # Hot reload during development
dotnet test                         # Run tests (if available)

# Clean build artifacts
./scripts/wurp-terminal clean
```

## Project Structure

```
wurp-terminal/
├── Program.cs                          # Application entry point (C# 12, .NET 9)
├── WurpTerminal.csproj                # .NET 9 project configuration
├── Core/                               # Modular C# architecture
│   ├── WurpTerminalService.cs          # Main terminal service
│   ├── AIIntegration.cs               # FreelanceAI API integration
│   └── ThemeManager.cs                # Theme management system
├── wurp-config.json                   # Centralised JSON configuration
├── scripts/
│   ├── wurp-terminal                   # Main build and launcher script
│   └── lib/
│       └── wurp-terminal-functions.sh # Generated function library
├── .gitignore                          # Git ignore patterns
├── .editorconfig                       # Editor configuration
└── README.md                          # Project documentation
```

### Generated by Bootstrap

This project was generated using the [warp-terminal-clone-bootstrap](../warp-terminal-clone-bootstrap/) system, which provides:
- **Modular Architecture** - Clean separation of concerns
- **Automated Build System** - Complete build, publish, and installation workflow
- **Configuration Management** - JSON-based configuration with validation
- **Cross-Platform Support** - Works on Linux, macOS, Windows

## Configuration

The `wurp-config.json` file contains all project settings:

```json
{
  "project": {
    "name": "Wurp (Warp Terminal Clone)",
    "description": "AI-Powered Terminal built with .NET 9",
    "version": "1.0.0",
    "binary_name": "wurp-terminal"
  },
  "services": {
    "freelance_ai": {
      "base_url": "http://localhost:5000",
      "api_endpoints": {
        "generate": "/api/ai/generate",
        "status": "/api/ai/status",
        "spend": "/api/ai/spend",
        "health": "/api/ai/health",
        "history": "/api/ai/history",
        "swagger": "/swagger"
      },
      "features": [
        "Smart provider routing (Groq, Ollama)",
        "Cost optimisation and tracking",
        "Response history analytics",
        "Health monitoring",
        "Automatic failover",
        "Rate limiting",
        "Budget management"
      ]
    }
  },
  "dependencies": {
    "required": [
      ".NET 9 SDK", "jq", "curl"
    ]
  }
}
```

## Troubleshooting

### Common Issues
1. **AI commands not working**: Ensure FreelanceAI is running on port 5000
2. **Theme not changing**: Try using the full command: `theme <name>`
3. **Build fails**: Check that .NET 9 SDK is properly installed
4. **Dependencies missing**: Run `./scripts/wurp-terminal check` to verify requirements
5. **Permission denied**: Make sure scripts are executable: `chmod +x scripts/wurp-terminal`

### Debug Commands
```bash
# Check FreelanceAI connectivity and provider status
curl http://localhost:5000/health
curl http://localhost:5000/api/ai/status

# Check dependencies and configuration
./scripts/wurp-terminal check

# View detailed installation status
./scripts/wurp-terminal status

# Test AI service integration
./scripts/wurp-terminal ai-status

# Check build artifacts
ls -la bin/Release/net9.0/publish/
```

## Development

### Related Projects
- **[FreelanceAI](../Freelance-AI/)** - Smart AI routing service that powers this terminal
- **[warp-terminal-clone-bootstrap](../warp-terminal-clone-bootstrap/)** - Bootstrap system that generated this project

### Development Workflow
```bash
# Make changes to Core/*.cs files
nano Core/WurpTerminalService.cs

# Test changes
dotnet run

# Build and test
./scripts/wurp-terminal build
./scripts/wurp-terminal run

# Full installation for testing
./scripts/wurp-terminal install
```

### Architecture
This project uses a clean, modular architecture:
- **Program.cs** - Entry point with argument handling
- **Core/WurpTerminalService.cs** - Main terminal loop and command processing
- **Core/AIIntegration.cs** - FreelanceAI API client
- **Core/ThemeManager.cs** - Theme management and color schemes

---

**Built with ❤️ using .NET 9, C# 12, and FreelanceAI**

*Experience the future of terminal interaction with AI-powered assistance and intelligent routing.*
