import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.Commons
import qs.Widgets

Rectangle {
    id: popupRoot
    implicitWidth: 240
    implicitHeight: 160
    color: (typeof Color !== "undefined") ? Color.mSurface : "#1e1e2e"
    radius: (typeof Style !== "undefined") ? Style.radiusL : 6
    border.color: (typeof Style !== "undefined") ? Style.capsuleBorderColor : "#33ffffff"
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: (typeof Style !== "undefined") ? Style.marginM : 8
        spacing: (typeof Style !== "undefined") ? Style.marginM : 8

        NText {
            text: "Battery Details"
            font.weight: Font.Bold
            pointSize: (typeof Style !== "undefined") ? Style.fontSizeM : 12
            Layout.alignment: Qt.AlignHCenter
        }

        ProgressBar {
            Layout.fillWidth: true
            value: (typeof root !== "undefined") ? root.batPercent / 100 : 0
            background: Rectangle { 
                implicitHeight: 6
                color: (typeof Color !== "undefined") ? Color.alpha(Color.mOnSurface, 0.1) : "#11ffffff"
                radius: 3 
            }
            contentItem: Item {
                Rectangle {
                    width: parent.width * ((typeof root !== "undefined") ? (root.batPercent / 100) : 0)
                    height: parent.height
                    radius: 3
                    color: (typeof Color !== "undefined") ? Color.mPrimary : "#00ff00"
                }
            }
        }

        GridLayout {
            columns: 2
            Layout.fillWidth: true
            rowSpacing: 4
            
            NText { text: "Power:"; color: (typeof Color !== "undefined") ? Color.mOnSurfaceVariant : "#a6adc8" }
            NText { text: ((typeof root !== "undefined") ? root.wattNum.toFixed(2) : "0.00") + " W"; Layout.alignment: Qt.AlignRight }
            
            NText { text: "Status:"; color: (typeof Color !== "undefined") ? Color.mOnSurfaceVariant : "#a6adc8" }
            NText { text: (typeof root !== "undefined") ? root.batStatus : "Unknown"; Layout.alignment: Qt.AlignRight }
            
            NText { text: "Time:"; color: (typeof Color !== "undefined") ? Color.mOnSurfaceVariant : "#a6adc8" }
            NText { text: (typeof root !== "undefined") ? root.timeRemaining : "..."; Layout.alignment: Qt.AlignRight }
        }
    }
}