using Dalamud.CrystalTower.Commands.Attributes;
using Dalamud.CrystalTower.UI;
using DutyDialer.UI;
// ReSharper disable UnusedMember.Global

namespace DutyDialer.Modules
{
    public class ConfigurationModule
    {
        public WindowManager Windows { get; set; }

        [Command("/dutydialer")]
        [HelpMessage("Toggle DutyDialer's configuration window.")]
        public void ToggleConfig(string command, string args)
        {
            Windows.ToggleWindow<ConfigurationWindow>();
        }
    }
}