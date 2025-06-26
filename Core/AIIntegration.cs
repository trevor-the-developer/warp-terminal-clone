using System;
using System.Net.Http;
using System.Threading.Tasks;

namespace WurpTerminal.Core;

public class AIIntegration
{
    public async Task HandleAICommands(string[] args)
    {
        if (args.Length == 0)
        {
            Console.WriteLine("AI command requires subcommand:");
            Console.WriteLine("  ai explain <command>     - Explain a command or concept");
            Console.WriteLine("  ai suggest <task>        - Get suggestions for a task");
            Console.WriteLine("  ai debug <error>         - Debug help for errors");
            Console.WriteLine("  ai code <task>          - Generate code");
            Console.WriteLine("  ai review <code>        - Review code");
            Console.WriteLine("  ai optimise <task>      - Optimisation suggestions");
            Console.WriteLine("  ai test <task>          - Testing guidance");
            return;
        }

        var subcommand = args[0].ToLower();
        var prompt = string.Join(" ", args[1..]);

        if (string.IsNullOrWhiteSpace(prompt))
        {
            Console.WriteLine($"❌ Please provide a prompt for 'ai {subcommand}'");
            return;
        }

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

            // Check FreelanceAI health first
            var healthResponse = await client.GetAsync("http://localhost:5000/health");
            if (!healthResponse.IsSuccessStatusCode)
                return null;

            // Create AI request based on subcommand
            var aiPrompt = FormatPromptForSubcommand(subcommand, prompt);
            var requestBody = new
            {
                prompt = aiPrompt,
                maxTokens = 500,
                temperature = 0.7m
            };

            var jsonContent = System.Text.Json.JsonSerializer.Serialize(requestBody);
            var content = new StringContent(jsonContent, System.Text.Encoding.UTF8, "application/json");

            var response = await client.PostAsync("http://localhost:5000/api/ai/generate", content);
            if (response.IsSuccessStatusCode)
            {
                var responseText = await response.Content.ReadAsStringAsync();
                var jsonResponse = System.Text.Json.JsonDocument.Parse(responseText);

                if (jsonResponse.RootElement.TryGetProperty("success", out var success) && success.GetBoolean())
                {
                    if (jsonResponse.RootElement.TryGetProperty("content", out var contentProp))
                    {
                        var aiContent = contentProp.GetString();
                        var provider = jsonResponse.RootElement.TryGetProperty("provider", out var providerProp)
                            ? providerProp.GetString() : "Unknown";
                        var cost = jsonResponse.RootElement.TryGetProperty("cost", out var costProp)
                            ? costProp.GetDecimal() : 0m;

                        Console.WriteLine($"📊 Provider: {provider} | Cost: ${cost:F4}");
                        return aiContent;
                    }
                }
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"🚨 FreelanceAI Error: {ex.Message}");
        }

        return null;
    }

    private string FormatPromptForSubcommand(string subcommand, string prompt)
    {
        return subcommand.ToLower() switch
        {
            "explain" => $"Please explain the following command or concept in simple terms for a developer: {prompt}",
            "suggest" => $"Suggest practical solutions or commands for this task: {prompt}",
            "debug" => $"Help debug this issue and provide troubleshooting steps: {prompt}",
            "code" => $"Generate clean, production-ready code for: {prompt}",
            "review" => $"Review this code and suggest improvements: {prompt}",
            "optimise" => $"Optimise this code or process: {prompt}",
            "test" => $"Provide testing strategies and examples for: {prompt}",
            _ => prompt
        };
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
            case "code":
                Console.WriteLine($"💻 Code generation for: {prompt}");
                Console.WriteLine("• Local fallback - basic code templates available");
                break;
            case "review":
                Console.WriteLine($"🔍 Code review for: {prompt}");
                Console.WriteLine("• Local fallback - basic syntax checking");
                break;
            case "optimise":
                Console.WriteLine($"⚡ Optimisation suggestions for: {prompt}");
                Console.WriteLine("• Local fallback - general performance tips");
                break;
            case "test":
                Console.WriteLine($"🧪 Testing guidance for: {prompt}");
                Console.WriteLine("• Local fallback - basic testing strategies");
                break;
        }
    }

    public async Task<bool> CheckFreelanceAIHealthAsync()
    {
        try
        {
            using var client = new HttpClient();
            client.Timeout = TimeSpan.FromSeconds(5);

            var response = await client.GetAsync("http://localhost:5000/health");
            return response.IsSuccessStatusCode;
        }
        catch
        {
            return false;
        }
    }

    public async Task ShowFreelanceAIStatusAsync()
    {
        try
        {
            using var client = new HttpClient();
            client.Timeout = TimeSpan.FromSeconds(10);

            // Check basic health
            var healthResponse = await client.GetAsync("http://localhost:5000/health");
            if (!healthResponse.IsSuccessStatusCode)
            {
                Console.WriteLine("❌ FreelanceAI is not available");
                return;
            }

            Console.WriteLine("✅ FreelanceAI is running");

            // Get provider status
            var statusResponse = await client.GetAsync("http://localhost:5000/api/ai/status");
            if (statusResponse.IsSuccessStatusCode)
            {
                var statusText = await statusResponse.Content.ReadAsStringAsync();
                var statusJson = System.Text.Json.JsonDocument.Parse(statusText);

                Console.WriteLine("📊 Provider Status:");
                foreach (var provider in statusJson.RootElement.EnumerateArray())
                {
                    var name = provider.GetProperty("name").GetString();
                    var isHealthy = provider.GetProperty("isHealthy").GetBoolean();
                    var requests = provider.GetProperty("requestsToday").GetInt32();
                    var cost = provider.GetProperty("costToday").GetDecimal();

                    var healthIcon = isHealthy ? "✅" : "❌";
                    Console.WriteLine($"  {healthIcon} {name}: {requests} requests, ${cost:F4} spent today");
                }
            }

            // Get today's spend
            var spendResponse = await client.GetAsync("http://localhost:5000/api/ai/spend");
            if (spendResponse.IsSuccessStatusCode)
            {
                var spendText = await spendResponse.Content.ReadAsStringAsync();
                if (decimal.TryParse(spendText, out var totalSpend))
                {
                    Console.WriteLine($"💰 Total spend today: ${totalSpend:F4}");
                }
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"🚨 Error checking FreelanceAI status: {ex.Message}");
        }
    }
}
