using Dalamud.CrystalTower.Commands;
using Dalamud.CrystalTower.DependencyInjection;
using Dalamud.CrystalTower.UI;
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

        private Exception wsConstructException;

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
                // Save the exception to notify the user when they log in
                this.wsConstructException = e;
            }

            this.commandManager = new CommandManager(this.pluginInterface, this.services);

            this.windowManager = new WindowManager(this.services);
            this.windowManager.AddWindow<ConfigurationWindow>(initiallyVisible: false);

            this.pluginInterface.UiBuilder.OnBuildUi += this.windowManager.Draw;
        }

        #region IDisposable Support
        protected virtual void Dispose(bool disposing)
        {
            if (!disposing) return;

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
