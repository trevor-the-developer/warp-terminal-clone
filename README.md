# 🚀 Wurp Terminal - Standalone Project

A modern, AI-powered terminal emulator built with .NET 8, featuring intelligent command assistance, themes, and comprehensive history management.

## Quick Start

### Using the Build Script (Recommended)
```bash
# Navigate to the standalone project directory
cd ~/workspace/wurp-terminal-standalone

# Build and test the project
./build.sh test

# Run the terminal
./build.sh run

# Create a release build
./build.sh publish
```

### Using .NET CLI Directly
```bash
# Navigate to the standalone project directory
cd ~/workspace/wurp-terminal-standalone

# Build the project
dotnet build

# Run the terminal (Debug mode)
dotnet run

# Or run the compiled binary directly
./bin/Debug/net8.0/wurp-terminal
```

## Features

- 🤖 **AI Integration** - Full FreelanceAI API support with smart routing and cost tracking
- 📜 **Command History** - Persistent command history with search capability
- 🎨 **Multiple Themes** - Built-in themes: default, dark, and wurp
- 🔧 **System Commands** - Execute any system command through the terminal
- 💡 **Smart Help System** - Context-aware help and command suggestions
- 🐚 **Cross-Shell Support** - Works with bash, zsh, and other shells

## Built-in Commands

### AI Commands
```bash
ai explain <command>        # Get detailed explanations
ai suggest <task>          # Get practical suggestions
ai debug <error>           # Troubleshooting help
ai code <task>             # Generate code snippets
ai review <code>           # Code review and improvements
ai optimise <task>         # Performance optimization tips
ai test <task>             # Testing strategies
```

### Terminal Commands
```bash
theme                      # Show current theme and available options
theme <name>               # Switch to a specific theme (default, dark, wurp)
clear                      # Clear the terminal screen
history                    # Show recent command history
help / commands            # Display comprehensive help
version                    # Show version information
status                     # Check FreelanceAI API status
exit / quit                # Exit the terminal gracefully
```

### System Commands
Any system command works normally:
```bash
ls -la                     # File operations
git status                 # Version control
npm install                # Package management
docker ps                  # Container management
```

## Project Structure

```
wurp-terminal-standalone/
├── Program.cs                     # Application entry point
├── WurpTerminal.csproj           # .NET project configuration
├── build.sh                      # Build and development script
├── README.md                     # This documentation
├── Core/                         # Core functionality modules
│   ├── WurpTerminalService.cs    # Main terminal service
│   ├── AIIntegration.cs          # FreelanceAI API integration
│   └── ThemeManager.cs           # Theme management system
├── bin/                          # Compiled binaries
├── obj/                          # Build artifacts
└── publish/                      # Published release binaries
```

## Requirements

### Essential
- **.NET SDK 8.0** or later
- **Linux/macOS/Windows** (cross-platform)

### Optional (for AI features)
- **FreelanceAI API** running on `http://localhost:5000`
- **Ollama** for local AI fallback

## Development

### Quick Development Workflow

#### Using Build Script
```bash
# Clone or navigate to the project
cd ~/workspace/wurp-terminal-standalone

# Show available build commands
./build.sh help

# Build and test
./build.sh test

# Run in development mode
./build.sh run

# Create release build
./build.sh release

# Create deployable binary
./build.sh publish

# Clean build artifacts
./build.sh clean
```

#### Using .NET CLI Directly
```bash
# Run in development mode with hot reload
dotnet run

# Build for release
dotnet build --configuration Release

# Publish as single-file executable
dotnet publish --configuration Release --self-contained false --output ./publish
```

### Testing AI Integration
```bash
# Check if FreelanceAI is running
curl http://localhost:5000/health

# Test AI commands within the terminal
ai explain "docker ps"
ai suggest "deploy web application"
```

## FreelanceAI Integration

This terminal integrates seamlessly with the FreelanceAI service for intelligent assistance:

### Features
- **Smart Provider Routing** - Automatically selects best AI provider (Groq, Ollama)
- **Cost Tracking** - Real-time cost monitoring per request
- **Health Monitoring** - Automatic failover when providers are unavailable
- **Local Fallback** - Works offline with basic help functionality

### Setup FreelanceAI (Optional)
```bash
# Start FreelanceAI service (if available)
git clone <freelance-ai-repo>
cd FreelanceAI
dotnet run --project src/FreelanceAI.WebApi

# Verify it's running
curl http://localhost:5000/health
```

## Customization

### Adding New Themes
Edit `Core/ThemeManager.cs` to add custom color schemes:
```csharp
["custom"] = new()
{
    ["prompt"] = "\x1b[95m→",
    ["red"] = "\x1b[91m",
    // ... add your colors
}
```

### Adding New Commands
Extend `Core/WurpTerminalService.cs` in the `ProcessSpecialCommandAsync` method:
```csharp
case "mycmd":
    MyCustomCommand(parts[1..]);
    return true;
```

## Troubleshooting

### Common Issues

1. **Build Fails**
   ```bash
   # Ensure .NET 8 SDK is installed
   dotnet --version
   
   # Clean and rebuild
   dotnet clean
   dotnet restore
   dotnet build
   ```

2. **AI Commands Not Working**
   - Check FreelanceAI service: `curl http://localhost:5000/health`
   - Terminal will fall back to local help if API is unavailable

3. **Theme Not Changing**
   - Use exact theme names: `theme default`, `theme dark`, `theme wurp`
   - Check available themes: `theme` (without arguments)

### Debug Commands
```bash
# Within the terminal
status                     # Check AI service connectivity
version                    # Verify terminal version
help                       # Show all available commands
```

## Contributing

This is a standalone project extracted from the Wurp Terminal bootstrap. Feel free to:

- Add new features
- Improve AI integration
- Create additional themes
- Enhance command functionality
- Add tests and documentation

## License

Built as part of the Warp Terminal Clone project using .NET 8 and FreelanceAI integration.

---

**Built with ❤️ using .NET 8 and FreelanceAI**

*Experience the future of terminal interaction with AI-powered assistance and intelligent command routing.*
