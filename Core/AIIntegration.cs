namespace WurpTerminal.Core;

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
            using var client = new HttpClient();
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