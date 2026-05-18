import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
  id: root
  property var pluginApi: null

  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  property string editStorePath: cfg.storePath ?? defaults.storePath ?? ""
  property real editTypeDelay: cfg.typeDelay ?? defaults.typeDelay ?? 0.2
  property int editWtypeDelay: cfg.wtypeDelay ?? defaults.wtypeDelay ?? 12

  spacing: Style.marginL

  NTextInput {
    Layout.fillWidth: true
    label: pluginApi?.tr("settings.storePath.label") || "Password Store Path"
    description: pluginApi?.tr("settings.storePath.desc") || "Custom path to the password store (default: ~/.password-store)"
    text: root.editStorePath
    onTextChanged: root.editStorePath = text
  }

  NTextInput {
    Layout.fillWidth: true
    label: pluginApi?.tr("settings.typeDelay.label") || "Launcher Close Delay"
    description: pluginApi?.tr("settings.typeDelay.desc") || "Delay before typing starts (seconds, default: 0.2)"
    text: root.editTypeDelay.toString()
    validator: RegularExpressionValidator { regularExpression: /^[0-9]*\.?[0-9]+$/ }
    onTextChanged: {
      var val = parseFloat(text)
      if (!isNaN(val) && val >= 0) root.editTypeDelay = val
    }
  }

  NTextInput {
    Layout.fillWidth: true
    label: pluginApi?.tr("settings.wtypeDelay.label") || "Wtype Keystroke Delay"
    description: pluginApi?.tr("settings.wtypeDelay.desc") || "Delay between keystrokes in ms (default: 12)"
    text: root.editWtypeDelay.toString()
    validator: RegularExpressionValidator { regularExpression: /^[0-9]+$/ }
    onTextChanged: {
      var val = parseInt(text)
      if (!isNaN(val) && val >= 0) root.editWtypeDelay = val
    }
  }

  function saveSettings() {
    if (!pluginApi) return;
    pluginApi.pluginSettings.storePath = root.editStorePath;
    pluginApi.pluginSettings.typeDelay = root.editTypeDelay;
    pluginApi.pluginSettings.wtypeDelay = root.editWtypeDelay;
    pluginApi.saveSettings();
  }
}