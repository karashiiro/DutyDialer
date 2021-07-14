using Dalamud.CrystalTower.Commands;
using Dalamud.CrystalTower.DependencyInjection;
using Dalamud.CrystalTower.UI;
using Dalamud.Game.Text;
using Dalamud.Game.Text.SeStringHandling;
using Dalamud.Plugin;
using DutyDialer.UI;
using Lumina.Excel.GeneratedSheets;
using System;
using System.Net.Sockets;

namespace DutyDialer
{
    // ReSharper disable once UnusedMember.Global
    public class Plugin : IDalamudPlugin
    {
        private DalamudPluginInterface pluginInterface;

        private CommandManager commandManager;
        private PluginConfiguration config;
        private PluginServiceCollection services;
        private WindowManager windowManager;

        private bool wsFailedToBindPort;

        public string Name => "DutyDialer";

        public void Initialize(DalamudPluginInterface pi)
        {
            this.pluginInterface = pi;

            this.config = (PluginConfiguration)this.pluginInterface.GetPluginConfig() ?? new PluginConfiguration();
            this.config.Initialize(this.pluginInterface);

            this.services = new PluginServiceCollection();
            this.services.AddService(this.config);
            try
            {
                var server = new NotificationServer(this.config.WebsocketPort);
                this.services.AddService(server);
                server.Start();
            }
            catch (Exception e) when (e is SocketException or ArgumentOutOfRangeException)
            {
                PluginLog.LogError(e, "Failed to start WebSocket server.");
                this.wsFailedToBindPort = true;
            }

            this.commandManager = new CommandManager(this.pluginInterface, this.services);

            this.windowManager = new WindowManager(this.services);
            this.windowManager.AddWindow<ConfigurationWindow>(Debug.InitiallyVisible);

            this.pluginInterface.UiBuilder.OnBuildUi += this.windowManager.Draw;
            this.pluginInterface.UiBuilder.OnOpenConfigUi += OpenConfigUi;

            this.pluginInterface.Framework.Gui.Chat.OnChatMessage += CheckFailedToBindPort;

            this.pluginInterface.ClientState.CfPop += ClientStateOnCfPop;
        }

        private void ClientStateOnCfPop(object sender, ContentFinderCondition e)
        {
            var notificationServer = this.services.GetService<NotificationServer>();
            var popTime = DateTime.UtcNow;
            var bannerUri = GetImageUrl(e.Image);
            notificationServer.NotifyPop(popTime, e.Name, bannerUri);
        }

        private static string GetImageUrl(uint id)
        {
            return $"https://xivapi.com/i/{id / 1000 * 1000:000000}/{id}_hr1.png";
        }

        private bool notifiedFailedToBindPort;
        private void CheckFailedToBindPort(XivChatType type, uint id, ref SeString sender, ref SeString message, ref bool handled)
        {
            if (!this.pluginInterface.ClientState.IsLoggedIn || !this.wsFailedToBindPort || this.notifiedFailedToBindPort) return;
            var chat = this.pluginInterface.Framework.Gui.Chat;
            chat.Print($"DutyDialer failed to bind to port {config.WebsocketPort}. " +
                       "Please close the owner of that port and reload the Websocket server, " +
                       "or select a different port.");
            this.notifiedFailedToBindPort = true;
        }

        private void OpenConfigUi(object sender, EventArgs args)
        {
            this.windowManager.ShowWindow<ConfigurationWindow>();
        }

        #region IDisposable Support
        protected virtual void Dispose(bool disposing)
        {
            if (!disposing) return;

            this.pluginInterface.ClientState.CfPop -= ClientStateOnCfPop;

            this.pluginInterface.Framework.Gui.Chat.OnChatMessage -= CheckFailedToBindPort;

            this.commandManager.Dispose();

            this.pluginInterface.UiBuilder.OnOpenConfigUi -= OpenConfigUi;
            this.pluginInterface.UiBuilder.OnBuildUi -= this.windowManager.Draw;
            this.windowManager.Dispose();

            this.services.Dispose();

            this.pluginInterface.SavePluginConfig(this.config);
            this.pluginInterface.Dispose();
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }
        #endregion
    }
}
