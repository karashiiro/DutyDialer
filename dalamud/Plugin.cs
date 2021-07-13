using Dalamud.CrystalTower.Commands;
using Dalamud.CrystalTower.DependencyInjection;
using Dalamud.CrystalTower.UI;
using Dalamud.Game.Text;
using Dalamud.Game.Text.SeStringHandling;
using Dalamud.Plugin;
using DutyDialer.UI;
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
                this.services.AddService(new NotificationServer(this.config.WebsocketPort));
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

            this.pluginInterface.Framework.Gui.Chat.OnChatMessage += CheckFailedToBindPort;
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

        #region IDisposable Support
        protected virtual void Dispose(bool disposing)
        {
            if (!disposing) return;

            this.pluginInterface.Framework.Gui.Chat.OnChatMessage -= CheckFailedToBindPort;

            this.commandManager.Dispose();

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
