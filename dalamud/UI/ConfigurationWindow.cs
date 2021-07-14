using Dalamud.CrystalTower.UI;
using Dalamud.Plugin;
using ImGuiNET;
using System;
using System.Net.Sockets;
using System.Numerics;
using System.Text;

namespace DutyDialer.UI
{
    public class ConfigurationWindow : ImmediateModeWindow
    {
        private static readonly Vector4 Red = new(1, 0, 0, 1);

        public NotificationServer Server { get; set; }
        public PluginConfiguration Configuration { get; set; }

        public override void Draw(ref bool visible)
        {
            ImGui.Begin("DutyDialer Configuration", ImGuiWindowFlags.AlwaysAutoResize);
            {
                var port = Configuration.WebsocketPort;
                var portBytes = Encoding.UTF8.GetBytes(port.ToString());
                var inputBuffer = new byte[6]; // One extra byte for the null terminator
                Array.Copy(portBytes, inputBuffer, portBytes.Length > inputBuffer.Length ? inputBuffer.Length : portBytes.Length);

                if (ImGui.InputText("Port##DutyDialerWSPort", inputBuffer, (uint)inputBuffer.Length, ImGuiInputTextFlags.CharsDecimal))
                {
                    if (int.TryParse(Encoding.UTF8.GetString(inputBuffer), out var newPort))
                    {
                        try
                        {
                            Server.RestartWithPort(newPort);
                            Configuration.WebsocketPort = newPort;
                        }
                        catch (ArgumentOutOfRangeException)
                        {
                            ImGui.TextColored(Red, "Port out of range");
                        }
                        catch (SocketException)
                        {
                            ImGui.TextColored(Red, "Port already taken");
                        }
                    }
                    else
                    {
                        PluginLog.LogError("Failed to parse port!");
                    }
                }

                ImGui.TextColored(new Vector4(1.0f, 1.0f, 1.0f, 0.6f), $"{(Server.Active ? "Started" : "Will start")} on {Server.Address}");

                ImGui.Spacing();

                if (ImGui.Button("Restart server##DutyDialerWSRestart"))
                {
                    Server.RestartWithPort(Configuration.WebsocketPort);
                }
            }
            ImGui.End();
        }
    }
}