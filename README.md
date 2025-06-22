# 🚀 Wurp (Warp Terminal Clone)

A feature-rich terminal emulator built with .NET 8, featuring AI integration, command history, auto-completion, and themes.

## Requirements:

- [Freelance AI](https://github.com/trevor-the-developer/Freelance-AI)

To access the AI and API features ensure the Freelance AI project is running first.

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

- 🤖 AI Integration (FreelanceAI compatible)
- 📜 Command History
- ⚡ Auto-completion
- 🎨 Multiple themes (default, dark, wurp)
- 🐚 Multi-shell support (bash/zsh)
- ⚙️ JSON configuration
- 🔧 Modular architecture

## Usage

```bash
# AI commands
ai explain "docker ps"
ai suggest "deploy app"
ai debug "permission denied"

# Built-in commands
theme wurp
clear
history
help
```

## Project Structure

- `Program.cs` - Main entry point
- `Core/` - Core application classes
  - `WurpTerminalService.cs` - Main terminal service
  - `AIIntegration.cs` - AI integration logic
  - `ThemeManager.cs` - Theme management
- `wurp-config.json` - Centralized configuration
- `scripts/wurp-terminal` - Installation script
- `scripts/lib/wurp-terminal-functions.sh` - Function library

Built with ❤️ using .NET 8
