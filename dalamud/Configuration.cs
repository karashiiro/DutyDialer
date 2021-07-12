using Dalamud.Configuration;
using Dalamud.Plugin;
using Newtonsoft.Json;

namespace DutyDialer
{
    public class Configuration : IPluginConfiguration
    {
        public int Version { get; set; }

        public int WebsocketPort { get; set; }

        [JsonIgnore] private DalamudPluginInterface pluginInterface;

        public void Initialize(DalamudPluginInterface pi)
        {
            this.pluginInterface = pi;
        }

        public void Save()
        {
            this.pluginInterface.SavePluginConfig(this);
        }
    }
}
