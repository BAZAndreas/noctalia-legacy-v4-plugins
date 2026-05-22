import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
    id: root

    property var pluginApi: null
    property var screen: null
    
    readonly property var mainWidget: pluginApi?.mainInstance || null

    property real contentPreferredWidth: (panelContent.implicitWidth + Style.marginM * 6) * Style.uiScaleRatio
    property real contentPreferredHeight: (mainLayout.implicitHeight + Style.marginM * 4) * Style.uiScaleRatio
    
    readonly property var geometryPlaceholder: mainLayout
    readonly property bool allowAttach: true

    anchors.fill: parent

    Component.onCompleted: {
        if (root.mainWidget?.updatePowerProfile) {
            root.mainWidget.updatePowerProfile();
        }
    }

    ColumnLayout {
        id: mainLayout
        anchors.centerIn: parent
        spacing: Style.marginM

        // --- CAPSULE 1: BATTERY INFO ---
        Rectangle {
            id: batteryCapsule
            Layout.preferredWidth: root.contentPreferredWidth - (Style.marginM * 2)
            Layout.preferredHeight: 64 * Style.uiScaleRatio
            
            color: Color.mSurfaceVariant
            radius: Style.capsuleRadius ?? Style.radiusM
            border.color: Style.capsuleBorderColor
            border.width: Style.capsuleBorderWidth

            RowLayout {
                id: panelContent
                anchors.centerIn: parent
                anchors.margins: Style.marginL
                spacing: Style.marginL

                ColumnLayout {
                    spacing: Style.marginS
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: false

                    NIcon {
                        icon: (root.mainWidget?.batStatus === "Charging" || root.mainWidget?.batStatus === "Full") ? "battery-charging" : "battery-4"
                        pointSize: Style.fontSizeXL
                        color: Color.mPrimary
                        Layout.alignment: Qt.AlignHCenter
                    }

                    NText {
                        text: root.mainWidget ? root.mainWidget.batPercent + "%" : "0%"
                        font.weight: Font.Bold
                        pointSize: Style.fontSizeM
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    width: 1
                    color: Color.mOutline
                    opacity: 0.15
                }

                ColumnLayout {
                    spacing: Style.marginS
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    NText {
                        text: root.mainWidget ? root.mainWidget.batStatus : "Unknown"
                        font.weight: Font.Bold
                        pointSize: Style.fontSizeS
                        color: Color.mOnSurface
                    }

                    NText {
                        text: {
                            if (!root.mainWidget) return "...";
                            if (root.mainWidget.batStatus === "Charging") return "Time to full: " + root.mainWidget.timeRemaining;
                            else if (root.mainWidget.batStatus === "Discharging") return "Remaining: " + root.mainWidget.timeRemaining;
                            else return root.mainWidget.wattNum.toFixed(1) + " W";
                        }
                        pointSize: Style.fontSizeXS
                        color: Color.mOnSurfaceVariant
                    }
                }
            }
        }

        // --- CAPSULE 2: POWER PROFILE ---
        Rectangle {
            id: profileCapsule
            Layout.preferredWidth: batteryCapsule.Layout.preferredWidth
            Layout.preferredHeight: 52 * Style.uiScaleRatio
            
            color: Color.mSurfaceVariant
            radius: Style.capsuleRadius ?? Style.radiusM
            border.color: Style.capsuleBorderColor
            border.width: Style.capsuleBorderWidth

            RowLayout {
                anchors.centerIn: parent
                spacing: Style.marginL * 1.5

                ProfileButton {
                    icon: "leaf"
                    profile: "power-saver"
                    active: root.mainWidget?.currentProfile === "power-saver"
                    onClicked: root.mainWidget?.setPowerProfile("power-saver")
                }

                ProfileButton {
                    icon: "scale"
                    profile: "balanced"
                    active: root.mainWidget?.currentProfile === "balanced"
                    onClicked: root.mainWidget?.setPowerProfile("balanced")
                }

                ProfileButton {
                    icon: "gauge"
                    profile: "performance"
                    active: root.mainWidget?.currentProfile === "performance"
                    onClicked: root.mainWidget?.setPowerProfile("performance")
                }
            }
        }

        // --- CAPSULE 3: BATTERY THRESHOLD ---
        Rectangle {
            id: thresholdCapsule
            Layout.preferredWidth: batteryCapsule.Layout.preferredWidth
            Layout.preferredHeight: 52 * Style.uiScaleRatio
            
            color: Color.mSurfaceVariant
            radius: Style.capsuleRadius ?? Style.radiusM
            border.color: Style.capsuleBorderColor
            border.width: Style.capsuleBorderWidth

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Style.marginL
                anchors.rightMargin: Style.marginL
                spacing: Style.marginM

                NIcon {
                    icon: "shield-heart"
                    pointSize: Style.fontSizeM
                    color: Color.mOnSurfaceVariant
                    Layout.alignment: Qt.AlignVCenter
                }

                Item {
                    id: customSlider
                    Layout.fillWidth: true
                    height: 32 * Style.uiScaleRatio
                    Layout.alignment: Qt.AlignVCenter

                    readonly property real minVal: 50
                    readonly property real maxVal: 100
                    property real currentVal: root.mainWidget ? root.mainWidget.batteryThreshold : 80

                    Rectangle {
                        id: track
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        height: 4 * Style.uiScaleRatio
                        radius: Style.radiusS / 2
                        color: Color.mSurface

                        Rectangle {
                            anchors.left: parent.left
                            height: parent.height
                            radius: Style.radiusS / 2
                            color: Color.mPrimary
                            width: {
                                if (track.width <= 0) return 0;
                                let pct = (customSlider.currentVal - customSlider.minVal) / (customSlider.maxVal - customSlider.minVal);
                                return pct * track.width;
                            }
                        }
                    }

                    Rectangle {
                        id: handle
                        width: 14 * Style.uiScaleRatio
                        height: 14 * Style.uiScaleRatio
                        radius: width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        x: {
                            if (track.width <= 0) return 0;
                            let pct = (customSlider.currentVal - customSlider.minVal) / (customSlider.maxVal - customSlider.minVal);
                            return (pct * track.width) - (width / 2);
                        }
                        color: sliderMouseArea.pressed ? Color.mPrimary : Color.mOnPrimary
                        border.color: Color.mPrimary
                        border.width: Style.capsuleBorderWidth * 2
                    }

                    MouseArea {
                        id: sliderMouseArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        
                        function handlePositionUpdate(mouseX) {
                            if (track.width <= 0) return;
                            let clampedX = Math.max(0, Math.min(mouseX, track.width));
                            let pct = clampedX / track.width;
                            let rawValue = customSlider.minVal + (pct * (customSlider.maxVal - customSlider.minVal));
                            let steppedValue = Math.round(rawValue / 5) * 5;
                            let finalValue = Math.max(customSlider.minVal, Math.min(steppedValue, customSlider.maxVal));
                            
                            if (root.mainWidget && root.mainWidget.batteryThreshold !== finalValue) {
                                root.mainWidget.setBatteryThreshold(finalValue);
                            }
                        }

                        onPressed: (mouse) => handlePositionUpdate(mouse.x)
                        onPositionChanged: (mouse) => handlePositionUpdate(mouse.x)
                    }
                }

                NText {
                    text: customSlider.currentVal + "%"
                    font.weight: Font.Bold
                    pointSize: Style.fontSizeS
                    color: Color.mOnSurface
                    Layout.preferredWidth: 40 * Style.uiScaleRatio
                    horizontalAlignment: Text.AlignRight
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }
    }

    component ProfileButton: MouseArea {
        property string icon: ""
        property string profile: ""
        property bool active: false
        
        implicitWidth: 36 * Style.uiScaleRatio
        implicitHeight: 36 * Style.uiScaleRatio
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        Rectangle {
            anchors.fill: parent
            radius: Style.radiusS ?? 4
            
            color: parent.active ? Color.mPrimary : Color.mSurface
            opacity: parent.active ? 1.0 : (parent.containsMouse ? 0.8 : 0.0)
        }

        NIcon {
            anchors.centerIn: parent
            icon: parent.icon
            pointSize: Style.fontSizeS
            color: parent.active 
                ? Color.mOnPrimary 
                : (parent.containsMouse ? Color.mPrimary : Color.mOnSurfaceVariant)
        }
    }
}