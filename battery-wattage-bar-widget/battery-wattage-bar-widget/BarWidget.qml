import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Commons
import qs.Widgets
import qs.Services.UI
import qs.Services.System

Item {
    id: root

    property var pluginApi: null
    property var screen: null
    property string widgetId: ""
    property string section: ""
    property int sectionWidgetIndex: -1
    property int sectionWidgetsCount: 0

    readonly property string screenName: screen ? (screen.name ?? "") : ""
    readonly property real capsuleHeight: (typeof Style !== "undefined" && typeof Style.getCapsuleHeightForScreen === "function") ? Style.getCapsuleHeightForScreen(root.screenName) : 26
    readonly property real barFontSize: (typeof Style !== "undefined" && typeof Style.getBarFontSizeForScreen === "function") ? Style.getBarFontSizeForScreen(root.screenName) : 10
    readonly property string fixedFont: (typeof Settings !== "undefined" && Settings.data?.ui?.fontFixed) ? Settings.data.ui.fontFixed : "monospace"

    property int batPercent: 0
    property real wattNum: 0.0
    property string batStatus: "Unknown"
    property string timeRemaining: "..."

    readonly property real contentWidth: layout.implicitWidth + ((typeof Style !== "undefined") ? Style.marginM * 2 : 16)
    readonly property real contentHeight: capsuleHeight
    implicitWidth: contentWidth
    implicitHeight: (typeof Style !== "undefined") ? Style.barHeight : 32

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (typeof pluginApi !== "undefined" && pluginApi && typeof pluginApi.pluginSettings !== "undefined") {
                let devPath = pluginApi.pluginSettings.batteryDevice || "/sys/class/power_supply/BAT0";
                let batName = devPath.split("/").pop() || "BAT0";
                
                batLoader.device = batName;
                batLoader.reload();
            }
        }
    }

    FileView {
        id: batLoader
        property string device: "BAT0"
        
        path: "/sys/class/power_supply/" + device + "/uevent"
        printErrors: false

        onLoaded: {
            let content = text();
            if (!content) return;

            let lines = content.split("\n");
            let cap = 0;
            let rate = 0;
            let volt = 0;
            let remain = 0;
            let status = "Unknown";

            for (let i = 0; i < lines.length; i++) {
                let line = lines[i].trim();
                if (line.indexOf("POWER_SUPPLY_CAPACITY=") === 0) {
                    cap = parseInt(line.split("=")[1]) || 0;
                } else if (line.indexOf("POWER_SUPPLY_POWER_NOW=") === 0) {
                    rate = parseInt(line.split("=")[1]) || 0;
                } else if (line.indexOf("POWER_SUPPLY_CURRENT_NOW=") === 0) {
                    rate = parseInt(line.split("=")[1]) || rate;
                } else if (line.indexOf("POWER_SUPPLY_VOLTAGE_NOW=") === 0) {
                    volt = parseInt(line.split("=")[1]) || 0;
                } else if (line.indexOf("POWER_SUPPLY_ENERGY_NOW=") === 0) {
                    remain = parseInt(line.split("=")[1]) || remain;
                } else if (line.indexOf("POWER_SUPPLY_CHARGE_NOW=") === 0) {
                    remain = parseInt(line.split("=")[1]) || remain;
                } else if (line.indexOf("POWER_SUPPLY_STATUS=") === 0) {
                    status = line.split("=")[1] || "Unknown";
                }
            }

            root.batPercent = cap;
            root.batStatus = status.charAt(0).toUpperCase() + status.slice(1).toLowerCase();

            if (content.indexOf("POWER_SUPPLY_POWER_NOW=") !== -1) {
                root.wattNum = rate / 1000000.0;
            } else if (volt > 0) {
                root.wattNum = (rate * volt) / 1000000000000.0;
            } else {
                root.wattNum = 0.0;
            }

            if (root.wattNum > 0.1 && remain > 0) {
                let totalHours = 0;
                if (content.indexOf("POWER_SUPPLY_ENERGY_NOW=") !== -1) {
                    let energyNow = remain / 1000000.0;
                    if (root.batStatus === "Discharging") {
                        totalHours = energyNow / root.wattNum;
                    } else if (root.batStatus === "Charging") {
                        let energyFull = 50.0;
                        for (let j = 0; j < lines.length; j++) {
                            if (lines[j].indexOf("POWER_SUPPLY_ENERGY_FULL=") === 0) {
                                energyFull = parseInt(lines[j].split("=")[1]) / 1000000.0;
                                break;
                            }
                        }
                        totalHours = (energyFull - energyNow) / root.wattNum;
                    }
                } else if (volt > 0) {
                    let chargeNow = remain / 1000000.0;
                    let currentNow = rate / 1000000.0;
                    if (currentNow > 0) {
                        if (root.batStatus === "Discharging") {
                            totalHours = chargeNow / currentNow;
                        } else if (root.batStatus === "Charging") {
                            let chargeFull = 4.5;
                            for (let j = 0; j < lines.length; j++) {
                                if (lines[j].indexOf("POWER_SUPPLY_CHARGE_FULL=") === 0) {
                                    chargeFull = parseInt(lines[j].split("=")[1]) / 1000000.0;
                                    break;
                                }
                            }
                            totalHours = (chargeFull - chargeNow) / currentNow;
                        }
                    }
                }

                if (totalHours > 0 && totalHours < 24) {
                    let h = Math.floor(totalHours);
                    let m = Math.floor((totalHours - h) * 60);
                    root.timeRemaining = h + "h " + m + "m";
                } else {
                    root.timeRemaining = "0h 0m";
                }
            } else if (root.batStatus === "Full" || root.batStatus === "Not charging") {
                root.timeRemaining = "0h 0m";
            } else {
                root.timeRemaining = "...";
            }
        }
    }

    Rectangle {
        id: visualCapsule
        anchors.centerIn: parent
        width: root.contentWidth
        height: root.contentHeight
        radius: (typeof Style !== "undefined") ? Style.radiusL : 6
        color: mouseArea.containsMouse ? ((typeof Color !== "undefined") ? Color.mHover : "#33ffffff") : ((typeof Style !== "undefined") ? Style.capsuleColor : "#1affffff")
        border.color: (root.batStatus === "Charging" || root.batStatus === "Full") ? ((typeof Color !== "undefined") ? Color.mPrimary : "#00ff00") : ((typeof Style !== "undefined") ? Style.capsuleBorderColor : "#33ffffff")
        border.width: (typeof Style !== "undefined") ? Style.capsuleBorderWidth : 1

        RowLayout {
            id: layout
            anchors.centerIn: parent
            spacing: (typeof Style !== "undefined") ? Style.marginS : 4

            NIcon {
                icon: (root.batStatus === "Charging" || root.batStatus === "Full") ? "battery-charging" : "battery-4"
                color: (root.batStatus === "Charging") ? ((typeof Color !== "undefined") ? Color.mPrimary : "#00ff00") : (root.wattNum > 22.0 ? "#ff5555" : ((typeof Color !== "undefined") ? Color.mOnSurface : "#ffffff"))
            }

            NText {
                text: root.batPercent + "% " + (root.batStatus === "Charging" ? "+" : "-") + root.wattNum.toFixed(1) + "W"
                pointSize: barFontSize
                font.family: root.fixedFont
                font.weight: Font.Bold
                color: (root.batStatus === "Charging") ? ((typeof Color !== "undefined") ? Color.mPrimary : "#00ff00") : (root.wattNum > 22.0 ? "#ff5555" : ((typeof Color !== "undefined") ? Color.mOnSurface : "#ffffff"))
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: {
            if (typeof TooltipService !== "undefined" && typeof BarService !== "undefined") {
                let labelTime = root.batStatus === "Charging" ? "Time to full" : "Time to empty";
                let primaryColor = (typeof Color !== "undefined") ? Color.mPrimary : "#00ff00";
                
                let tooltipText = "<table style='width: 170px;'>" +
                                  "<tr><td align='left'>Battery level</td><td align='right'><b>" + root.batPercent + "%</b></td></tr>" +
                                  "<tr><td align='left'>Status</td><td align='right'><b>" + root.batStatus + "</b></td></tr>" +
                                  "<tr><td align='left'>" + labelTime + "</td><td align='right' style='color:" + primaryColor + ";'><b>" + root.timeRemaining + "</b></td></tr>" +
                                  "</table>";

                TooltipService.show(root, tooltipText, BarService.getTooltipDirection())
            }
        }
        onExited: {
            if (typeof TooltipService !== "undefined") {
                TooltipService.hide()
            }
        }
        onClicked: {
            if (pluginApi && typeof pluginApi.openPanel === "function") {
                pluginApi.openPanel(root.screen, root)
            }
        }
    }
}