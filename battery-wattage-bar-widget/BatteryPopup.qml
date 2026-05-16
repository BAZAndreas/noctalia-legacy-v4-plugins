import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
    id: root

    property var pluginApi: null
    property var screen: null
    
    readonly property var mainWidget: pluginApi?.mainInstance || null

    // Aumentato il moltiplicatore (da *4 a *6) per dare più spazio complessivo alla finestra
    property real contentPreferredWidth: (panelContent.implicitWidth + Style.marginM * 6) * Style.uiScaleRatio
    property real contentPreferredHeight: (panelContent.implicitHeight + Style.marginM * 6) * Style.uiScaleRatio
    
    readonly property var geometryPlaceholder: visualCapsule
    readonly property bool allowAttach: true

    anchors.fill: parent

    Rectangle {
        id: visualCapsule
        
        anchors.centerIn: parent
        width: parent.width - (Style.marginM * 2)
        height: parent.height - (Style.marginM * 2)
        
        color: (typeof Color !== "undefined") ? Color.mSurface : "#1e1e2e"
        radius: (typeof Style !== "undefined") ? Style.radiusL : 6
        border.color: (typeof Style !== "undefined") ? Style.capsuleBorderColor : "#33ffffff"
        border.width: 1

        RowLayout {
            id: panelContent
            anchors.centerIn: parent
            
            // Aggiunti i margini espliciti qui dentro per spingere i controlli verso il centro
            anchors.margins: (typeof Style !== "undefined") ? Style.marginL : 16
            
            // Aumentato lo spazio orizzontale tra il blocco di sinistra e quello di destra
            spacing: 16

            // Lato Sinistro: Icona Grande e Percentuale
            ColumnLayout {
                spacing: 4 // Leggermente aumentato lo spazio verticale tra icona e %
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: false

                NIcon {
                    icon: (root.mainWidget && (root.mainWidget.batStatus === "Charging" || root.mainWidget.batStatus === "Full")) ? "battery-charging" : "battery-4"
                    pointSize: 20
                    color: (typeof Color !== "undefined") ? Color.mPrimary : "#3355ff"
                    Layout.alignment: Qt.AlignHCenter
                }

                NText {
                    text: root.mainWidget ? root.mainWidget.batPercent + "%" : "0%"
                    font.weight: Font.Bold
                    pointSize: (typeof Style !== "undefined") ? Style.fontSizeM : 11
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // Divisore verticale
            Rectangle {
                Layout.fillHeight: true
                width: 1
                color: (typeof Color !== "undefined") ? Color.mOutline : "#33ffffff"
                opacity: 0.15
            }

            // Lato Destro: Stato principale e info temporale/watt dinamica
            ColumnLayout {
                spacing: 4 // Leggermente aumentato lo spazio verticale tra lo stato e i dettagli
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter

                NText {
                    text: root.mainWidget ? root.mainWidget.batStatus : "Unknown"
                    font.weight: Font.Bold
                    pointSize: (typeof Style !== "undefined") ? Style.fontSizeS : 10
                    color: (typeof Color !== "undefined") ? Color.mOnSurface : "#ffffff"
                }

                NText {
                    text: {
                        if (!root.mainWidget) return "...";
                        if (root.mainWidget.batStatus === "Charging") {
                            return "Time to full: " + root.mainWidget.timeRemaining;
                        } else if (root.mainWidget.batStatus === "Discharging") {
                            return "Remaining: " + root.mainWidget.timeRemaining;
                        } else {
                            return root.mainWidget.wattNum.toFixed(1) + " W";
                        }
                    }
                    pointSize: (typeof Style !== "undefined") ? Style.fontSizeXS : 9
                    color: (typeof Color !== "undefined") ? Color.mOnSurfaceVariant : "#a6adc8"
                }
            }
        }
    }
}