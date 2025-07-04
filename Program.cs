using System;
using System.Threading.Tasks;
using WurpTerminal.Core;

namespace WurpTerminal;

class Program
{
    static async Task Main(string[] args)
    {
        try
        {
            var terminal = new WurpTerminalService();

            Console.WriteLine("🚀 Wurp (Warp Terminal Clone) v1.0.0");
            Console.WriteLine("AI-Powered Terminal built with .NET 9");
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
