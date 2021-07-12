using Dalamud.CrystalTower.Commands;
using Dalamud.CrystalTower.DependencyInjection;
using Dalamud.CrystalTower.UI;
using Dalamud.Plugin;
using System;

namespace DutyDialer
{
    public class Plugin : IDalamudPlugin
    {
        private DalamudPluginInterface pluginInterface;

        private CommandManager commandManager;
        private Configuration config;
        private PluginServiceCollection services;
        private WindowManager windowManager;

        public string Name => "DutyDialer";

        public void Initialize(DalamudPluginInterface pi)
        {
            this.pluginInterface = pi;

            this.config = (Configuration)this.pluginInterface.GetPluginConfig() ?? new Configuration();
            this.config.Initialize(this.pluginInterface);

            this.services = new PluginServiceCollection();
            this.services.AddService(new NotificationServer(this.config.WebsocketPort));

            this.commandManager = new CommandManager(this.pluginInterface, this.services);
            this.windowManager = new WindowManager(this.services);

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
