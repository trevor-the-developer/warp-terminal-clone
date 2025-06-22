using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace WurpTerminal.Core;

public class WurpTerminalService
{
    private readonly List<string> _history = new();
    private readonly string _historyFile = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), ".wurp_terminal_history");
    private readonly AIIntegration _ai = new();
    private readonly ThemeManager _themes = new();

    public WurpTerminalService()
    {
        LoadHistory();
        Console.CancelKeyPress += OnCancelKeyPress;
    }

    public async Task HandleCommands(string[] args)
    {
        var command = args[0].ToLower();

        switch (command)
        {
            case "ai":
                await _ai.HandleAICommands(args[1..]);
                break;
            case "theme":
                _themes.HandleThemeCommand(args[1..]);
                break;
            case "help":
                ShowHelp();
                break;
            case "version":
                Console.WriteLine("Wurp (Warp Terminal Clone) v1.0 - .NET 8");
                break;
            default:
                Console.WriteLine($"Unknown command: {command}");
                Console.WriteLine("Run 'wurp-terminal help' for available commands.");
                break;
        }
    }

    public async Task RunInteractiveMode()
    {
        Console.WriteLine("🎯 Interactive mode - Type commands or 'exit' to quit");
        Console.WriteLine("Features: History, AI commands, themes\n");

        while (true)
        {
            Console.Write($"{_themes.GetPrompt()}> ");

            var input = Console.ReadLine();

            if (string.IsNullOrWhiteSpace(input))
                continue;

            if (input.ToLower() == "exit" || input.ToLower() == "quit")
            {
                Console.WriteLine("👋 Goodbye!");
                break;
            }

            // Add to history
            _history.Add(input);
            SaveHistory();

            // Process command
            await ProcessCommand(input);
            Console.WriteLine();
        }
    }

    private async Task ProcessCommand(string input)
    {
        var parts = input.Split(' ', StringSplitOptions.RemoveEmptyEntries);

        if (await ProcessSpecialCommandAsync(parts))
            return;

        // Execute system command
        await ExecuteSystemCommand(input);
    }

    private async Task<bool> ProcessSpecialCommandAsync(string[] parts)
    {
        if (parts.Length == 0) return false;

        switch (parts[0].ToLower())
        {
            case "ai":
                await _ai.HandleAICommands(parts[1..]);
                return true;
            case "theme":
                _themes.HandleThemeCommand(parts[1..]);
                return true;
            case "clear":
                Console.Clear();
                return true;
            case "history":
                ShowHistory();
                return true;
            default:
                return false;
        }
    }

    private async Task ExecuteSystemCommand(string command)
    {
        try
        {
            var process = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = "/bin/bash",
                    Arguments = $"-c \"{command}\"",
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true
                }
            };

            process.Start();

            var output = await process.StandardOutput.ReadToEndAsync();
            var error = await process.StandardError.ReadToEndAsync();

            await process.WaitForExitAsync();

            if (!string.IsNullOrEmpty(output))
                Console.Write(output);
            if (!string.IsNullOrEmpty(error))
                Console.Write(_themes.ColorText(error, "red"));
        }
        catch (Exception ex)
        {
            Console.WriteLine(_themes.ColorText($"Error executing command: {ex.Message}", "red"));
        }
    }

    private void LoadHistory()
    {
        try
        {
            if (File.Exists(_historyFile))
            {
                var lines = File.ReadAllLines(_historyFile);
                _history.AddRange(lines);
            }
        }
        catch { /* Ignore errors */ }
    }

    private void SaveHistory()
    {
        try
        {
            File.WriteAllLines(_historyFile, _history.TakeLast(1000));
        }
        catch { /* Ignore errors */ }
    }

    private void ShowHistory()
    {
        for (int i = Math.Max(0, _history.Count - 20); i < _history.Count; i++)
        {
            Console.WriteLine($"{i + 1,3}: {_history[i]}");
        }
    }

    private void OnCancelKeyPress(object? sender, ConsoleCancelEventArgs e)
    {
        e.Cancel = true;
        Console.WriteLine("\n👋 Use 'exit' to quit gracefully");
    }

    private void ShowHelp()
    {
        Console.WriteLine("🚀 Wurp (Warp Terminal Clone) - Help");
        Console.WriteLine("═══════════════════════════════════");
        Console.WriteLine();
        Console.WriteLine("Built-in Commands:");
        Console.WriteLine("  ai explain <command>     - Explain a command");
        Console.WriteLine("  ai suggest <task>        - Get command suggestions");
        Console.WriteLine("  ai debug <error>         - Debug help");
        Console.WriteLine("  theme [name]             - Change/show theme");
        Console.WriteLine("  clear                    - Clear screen");
        Console.WriteLine("  history                  - Show command history");
        Console.WriteLine("  help                     - Show this help");
        Console.WriteLine("  exit/quit                - Exit terminal");
        Console.WriteLine();
        Console.WriteLine("Features:");
        Console.WriteLine("  • Command history");
        Console.WriteLine("  • AI-powered assistance");
        Console.WriteLine("  • Multiple themes");
        Console.WriteLine("  • System command execution");
    }
}
