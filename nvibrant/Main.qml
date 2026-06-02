import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
  id: root
  property var pluginApi: null

  readonly property var cfg: pluginApi?.pluginSettings ?? ({})
  readonly property var defaults: pluginApi?.manifest?.metadata?.defaultSettings ?? ({})

  readonly property bool vibrantEnabled: cfg.enabled ?? defaults.enabled ?? false
  readonly property int vibranceValue: cfg.vibranceValue ?? defaults.vibranceValue ?? 512
  // stored 1-based (1 = port 0), converted on use
  readonly property int displayIndex: (cfg.displayIndex ?? defaults.displayIndex ?? 1) - 1

  function buildCmd(value) {
    var args = ["/usr/sbin/nvibrant"]
    for (var i = 0; i < root.displayIndex; i++)
      args.push("0")
    args.push(value.toString())
    return args
  }

  function applyVibrance(value) {
    var cmd = buildCmd(value)
    Logger.i("NVibrant", "Running: " + cmd.join(" "))
    Quickshell.exec(cmd)
  }

  // Reactively apply vibrance when any relevant property changes
  onVibrantEnabledChanged: applyVibrance(vibrantEnabled ? vibranceValue : 0)
  onVibranceValueChanged: if (vibrantEnabled) applyVibrance(vibranceValue)
  onDisplayIndexChanged: applyVibrance(vibrantEnabled ? vibranceValue : 0)

  function toggle() {
    if (pluginApi) {
      pluginApi.pluginSettings.enabled = !vibrantEnabled
      pluginApi.saveSettings()
    }
  }

  IpcHandler {
    target: "plugin:nvibrant"
    function toggle() { root.toggle() }
  }
}
