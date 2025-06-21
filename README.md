# 🚀 Warp Terminal Clone

A feature-rich terminal emulator built with .NET 8, featuring AI integration, command history, auto-completion, and themes.

## Quick Start

```bash
# Check dependencies
./scripts/warp-terminal check

# Install everything
./scripts/warp-terminal install

# Run the terminal
warp-terminal
```

## Features

- 🤖 AI Integration (FreelanceAI compatible)
- 📜 Command History
- ⚡ Auto-completion
- 🎨 Multiple themes (default, dark, warp)
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
theme warp
clear
history
help
```

## Project Structure

- `Program.cs` - Main terminal application
- `warp-config.json` - Centralized configuration
- `scripts/warp-terminal` - Installation script
- `scripts/lib/warp-terminal-functions.sh` - Function library

Built with ❤️ using .NET 8
