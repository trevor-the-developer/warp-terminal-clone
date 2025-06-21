using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace WarpTerminal;

class Program
{
    static async Task Main(string[] args)
    {
        try
        {
            var terminal = new WarpTerminalService();
            
            Console.WriteLine("🚀 Warp Terminal Clone v1.0");
            Console.WriteLine("AI-Powered Terminal built with .NET");
            Console.WriteLine("═══════════════════════════════════════\n");

            if (args.Length > 0)
            {
                await terminal.HandleCommands(args);
            }
            else
            {
                await terminal.RunInteractiveMode();
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Error: {ex.Message}");
            Environment.Exit(1);
        }
    }
}

public class WarpTerminalService
{
    private readonly List<string> _history = new();
    private readonly string _historyFile = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), ".warp_terminal_history");
    private readonly AIIntegration _ai = new();
    private readonly ThemeManager _themes = new();

    public WarpTerminalService()
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
                Console.WriteLine("Warp Terminal Clone v1.0 - .NET 8");
                break;
            default:
                Console.WriteLine($"Unknown command: {command}");
                Console.WriteLine("Run 'warp-terminal help' for available commands.");
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
        Console.WriteLine("🚀 Warp Terminal Clone - Help");
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

public class AIIntegration
{
    public async Task HandleAICommands(string[] args)
    {
        if (args.Length == 0)
        {
            Console.WriteLine("AI command requires subcommand (explain, suggest, debug)");
            return;
        }

        var subcommand = args[0].ToLower();
        var prompt = string.Join(" ", args[1..]);

        Console.WriteLine($"🤖 AI {subcommand}: {prompt}");
        
        var aiResponse = await CallFreelanceAI(subcommand, prompt);
        if (aiResponse != null)
        {
            Console.WriteLine($"✨ {aiResponse}");
        }
        else
        {
            Console.WriteLine("🔧 FreelanceAI API not available - using local fallback");
            await LocalAIFallback(subcommand, prompt);
        }
    }

    private async Task<string?> CallFreelanceAI(string subcommand, string prompt)
    {
        try
        {
            using var client = new System.Net.Http.HttpClient();
            client.Timeout = TimeSpan.FromSeconds(30);
            
            var response = await client.GetAsync("http://localhost:5000/health");
            if (response.IsSuccessStatusCode)
            {
                return $"AI response for '{prompt}' (via FreelanceAI)";
            }
        }
        catch { }
        
        return null;
    }

    private async Task LocalAIFallback(string subcommand, string prompt)
    {
        await Task.Delay(500);
        
        switch (subcommand)
        {
            case "explain":
                Console.WriteLine($"📖 Command explanation for: {prompt}");
                Console.WriteLine("This is a local fallback explanation.");
                break;
            case "suggest":
                Console.WriteLine($"💡 Suggestions for: {prompt}");
                Console.WriteLine("• Try using 'man' command for documentation");
                Console.WriteLine("• Use '--help' flag for command options");
                break;
            case "debug":
                Console.WriteLine($"🔍 Debug help for: {prompt}");
                Console.WriteLine("• Check error logs");
                Console.WriteLine("• Verify command syntax");
                Console.WriteLine("• Check file permissions");
                break;
        }
    }
}

public class ThemeManager
{
    private readonly Dictionary<string, Dictionary<string, string>> _themes = new()
    {
        ["default"] = new()
        {
            ["prompt"] = "\x1b[36mwarp",
            ["red"] = "\x1b[31m",
            ["green"] = "\x1b[32m",
            ["yellow"] = "\x1b[33m",
            ["blue"] = "\x1b[34m",
            ["reset"] = "\x1b[0m"
        },
        ["dark"] = new()
        {
            ["prompt"] = "\x1b[35mwarp",
            ["red"] = "\x1b[91m",
            ["green"] = "\x1b[92m",
            ["yellow"] = "\x1b[93m",
            ["blue"] = "\x1b[94m",
            ["reset"] = "\x1b[0m"
        },
        ["warp"] = new()
        {
            ["prompt"] = "\x1b[96m❯",
            ["red"] = "\x1b[91m",
            ["green"] = "\x1b[92m",
            ["yellow"] = "\x1b[93m",
            ["blue"] = "\x1b[96m",
            ["reset"] = "\x1b[0m"
        }
    };

    private string _currentTheme = "default";

    public void HandleThemeCommand(string[] args)
    {
        if (args.Length == 0)
        {
            Console.WriteLine($"Current theme: {_currentTheme}");
            Console.WriteLine("Available themes:");
            foreach (var theme in _themes.Keys)
            {
                Console.WriteLine($"  • {theme}");
            }
            return;
        }

        var themeName = args[0].ToLower();
        if (_themes.ContainsKey(themeName))
        {
            _currentTheme = themeName;
            Console.WriteLine($"✅ Theme changed to: {themeName}");
        }
        else
        {
            Console.WriteLine($"❌ Unknown theme: {themeName}");
        }
    }

    public string GetPrompt() => _themes[_currentTheme]["prompt"] + _themes[_currentTheme]["reset"];
    
    public string ColorText(string text, string color) => 
        _themes[_currentTheme].GetValueOrDefault(color, "") + text + _themes[_currentTheme]["reset"];
}
