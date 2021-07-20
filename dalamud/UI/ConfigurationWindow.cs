using Dalamud.CrystalTower.UI;
using Dalamud.Plugin;
using ImGuiNET;
using System;
using System.Net.Sockets;
using System.Numerics;
using System.Text;
using System.Threading.Tasks;

namespace DutyDialer.UI
{
    public class ConfigurationWindow : ImmediateModeWindow, IDisposable
    {
        private static readonly Vector4 HintColor = new(1.0f, 1.0f, 1.0f, 0.6f);
        private static readonly Vector4 Red = new(1, 0, 0, 1);

        private UrlQrCode qrCode;
        private bool once;

        public NotificationServer Server { get; set; }
        public PluginConfiguration Configuration { get; set; }
        public DalamudPluginInterface PluginInterface { get; set; }

        private void CreateQrCode()
        {
            this.qrCode?.Dispose();
            this.qrCode = new UrlQrCode(Server.Address);
            //_ = Task.Run(() => this.qrCode.GenerateImage(PluginInterface));
            this.qrCode.GenerateImage(PluginInterface);
        }

        public override void Draw(ref bool visible)
        {
            // Don't run this before everything is initialized
            if (!this.once && Server?.Address != null)
            {
                CreateQrCode();
                this.once = true;
            }

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

                            CreateQrCode();
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

                ImGui.TextColored(HintColor, $"{(Server.Active ? "Started" : "Will start")} on {Server.Address}");

                ImGui.Spacing();

                if (ImGui.Button("Restart server##DutyDialerWSRestart"))
                {
                    Server.RestartWithPort(Configuration.WebsocketPort);
                }

                if (this.qrCode != null && this.qrCode.IsReady)
                {
                    ImGui.Spacing();
                    ImGui.Spacing();
                    ImGui.Image(this.qrCode.Result!.ImGuiHandle, new Vector2(200, 200));
                    ImGui.TextColored(HintColor, "Scan this QR code with the mobile app to connect to the game!");
                }
            }
            ImGui.End();
        }

        public void Dispose()
        {
            this.qrCode?.Dispose();
        }
    }
}