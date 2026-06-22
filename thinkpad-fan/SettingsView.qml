import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root
    spacing: Style.marginL

    property var pluginApi: null

    // ===== EDIT STATE =====
    property bool editColorizeByStatus:
        pluginApi?.pluginSettings?.colorizeByStatus ??
        pluginApi?.manifest?.metadata?.defaultSettings?.colorizeByStatus ??
        true

    property bool editAllowPopupOpening:
        pluginApi?.pluginSettings?.allowPopupOpening ??
        pluginApi?.manifest?.metadata?.defaultSettings?.allowPopupOpening ??
        true

    property string editColorLevel0:
        pluginApi?.pluginSettings?.colorLevel0 ??
        pluginApi?.manifest?.metadata?.defaultSettings?.colorLevel0 ??
        Color.mError

    property string editColorActive:
        pluginApi?.pluginSettings?.colorActive ??
        pluginApi?.manifest?.metadata?.defaultSettings?.colorActive ??
        Color.mPrimary

    // ===== SAVE =====
    function saveSettings() {
        if (!pluginApi) return
        pluginApi.pluginSettings.colorizeByStatus = root.editColorizeByStatus
        pluginApi.pluginSettings.allowPopupOpening = root.editAllowPopupOpening
        pluginApi.pluginSettings.colorActive = root.editColorActive
        pluginApi.pluginSettings.colorLevel0 = root.editColorLevel0
        pluginApi.saveSettings()
    }

    // ===== UI =====

    // Color swatch sizing
    readonly property int swatchSize: 28
    readonly property int swatchBorderSelected: 3
    readonly property int swatchBorderDefault: 1

    // All palette colors
    readonly property var noctaliaPalette: [
        Color.mPrimary, Color.mSecondary, Color.mTertiary, Color.mError,
        Color.mSurface, Color.mSurfaceVariant, Color.mOutline
    ]

    // Option 1: Dynamic coloring based on fan status
    NToggle {
        Layout.fillWidth: true
        label: pluginApi?.tr("settings.dynamic-coloring")
        description: pluginApi?.tr("settings.dynamic-coloring-desc")
        checked: root.editColorizeByStatus
        onToggled: checked => {
            root.editColorizeByStatus = checked
            root.saveSettings()
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginM
        enabled: root.editColorizeByStatus
        opacity: enabled ? 1.0 : 0.5

        // Level 0 color
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.marginS

            NText {
                text: pluginApi?.tr("settings.color-level0")
                font.weight: Font.Bold
            }
            NText {
                text: pluginApi?.tr("settings.color-level0-desc")
                font.pointSize: Style.fontSizeS
                color: Color.mOnSurfaceVariant
            }

            RowLayout {
                spacing: Style.marginS

                Repeater {
                    id: level0Color
                    model: root.noctaliaPalette

                    Rectangle {
                        width: root.swatchSize
                        height: root.swatchSize
                        radius: root.swatchSize / 2
                        color: modelData
                        border.color: (root.editColorLevel0 && Qt.colorEqual(root.editColorLevel0, modelData)) ? Color.mOnSurface : Color.mOutline
                        border.width: (root.editColorLevel0 && Qt.colorEqual(root.editColorLevel0, modelData)) ? root.swatchBorderSelected : root.swatchBorderDefault

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.editColorLevel0 = modelData
                                root.saveSettings()
                            }
                        }
                    }
                }
            }
        }

        // Space separator
        Item { Layout.preferredHeight: Style.marginS }

        // Active (forced speed) color
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.marginS

            NText {
                text: pluginApi?.tr("settings.color-active")
                font.weight: Font.Bold
            }
            NText {
                text: pluginApi?.tr("settings.color-active-desc")
                font.pointSize: Style.fontSizeS
                color: Color.mOnSurfaceVariant
            }

            RowLayout {
                spacing: Style.marginS

                Repeater {
                    id: activeColor
                    model: root.noctaliaPalette

                    Rectangle {
                        width: root.swatchSize
                        height: root.swatchSize
                        radius: root.swatchSize / 2
                        color: modelData
                        border.color: (root.editColorActive && Qt.colorEqual(root.editColorActive, modelData)) ? Color.mOnSurface : Color.mOutline
                        border.width: (root.editColorActive && Qt.colorEqual(root.editColorActive, modelData)) ? root.swatchBorderSelected : root.swatchBorderDefault

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.editColorActive = modelData
                                root.saveSettings()
                            }
                        }
                    }
                }
            }
        }
    }

    // Option 2: Left Click Interaction Toggle
    NToggle {
        Layout.fillWidth: true
        label: pluginApi?.tr("settings.allow-popup")
        description: pluginApi?.tr("settings.allow-popup-desc")
        checked: root.editAllowPopupOpening
        onToggled: checked => {
            root.editAllowPopupOpening = checked
            root.saveSettings()
        }
    }

    Item { Layout.fillHeight: true }
}