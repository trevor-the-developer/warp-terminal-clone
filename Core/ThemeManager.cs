namespace WurpTerminal.Core;

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
        ["wurp"] = new()
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