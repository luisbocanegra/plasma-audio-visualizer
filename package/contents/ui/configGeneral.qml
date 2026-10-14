import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.core as PlasmaCore
import "code/enum.js" as Enum

KCM.SimpleKCM {
    id: root
    property alias cfg_desktopWidgetBg: desktopWidgetBackgroundRadio.value
    property int cfg_visibilityMode
    property int cfg_visualizerStyle
    property string cfg_barColors
    property string cfg_waveFillColors
    property alias cfg_debugMode: debugModeCheckbox.checked
    property alias cfg_idleTimer: idleTimerSpinbox.value
    property alias cfg_hideToolTip: hideToolTipCheckbox.checked
    property alias cfg_disableLeftClick: disableLeftClickCheckbox.checked

    Kirigami.FormLayout {
        id: parentLayout
        Layout.fillWidth: true

        RadioButton {
            Kirigami.FormData.label: i18n("Visibility:")
            text: i18n("Always")
            checked: cfg_visibilityMode === Enum.VisibilityMode.Always
            onCheckedChanged: if (checked) cfg_visibilityMode = Enum.VisibilityMode.Always
            ButtonGroup.group: visibilityModeGroup
        }
        RowLayout {
            RadioButton {
                id: idleRadio
                text: i18n("Show while audio plays and n seconds after.")
                checked: cfg_visibilityMode === Enum.VisibilityMode.WhileAudioPlays
                onCheckedChanged: if (checked) cfg_visibilityMode = Enum.VisibilityMode.WhileAudioPlays
                ButtonGroup.group: visibilityModeGroup
            }
            Label { text: i18n("n =") }
            SpinBox {
                id: idleTimerSpinbox
                enabled: idleRadio.checked
                from: 1
                to: 60
            }
        }
        RowLayout {
            RadioButton {
                text: i18n("While a media player is open")
                checked: cfg_visibilityMode === Enum.VisibilityMode.WhileMediaPlayerOpen
                onCheckedChanged: if (checked) cfg_visibilityMode = Enum.VisibilityMode.WhileMediaPlayerOpen
                ButtonGroup.group: visibilityModeGroup
            }
            Kirigami.ContextualHelpButton {
                toolTipText: i18n("Show the widget based on media player status (MPRIS) instead of audio activity (other sounds won't show it). Stays visible while playback is paused.")
            }
        }
        ButtonGroup { id: visibilityModeGroup }

        RadioButton {
            Kirigami.FormData.label: i18n("Desktop background:")
            text: i18n("Default")
            checked: desktopWidgetBackgroundRadio.value == PlasmaCore.Types.StandardBackground
            onCheckedChanged: () => {
                if (checked) {
                    desktopWidgetBackgroundRadio.value = PlasmaCore.Types.StandardBackground;
                }
            }
            ButtonGroup.group: desktopWidgetBackgroundRadio
        }
        RadioButton {
            text: i18n("Transparent")
            checked: desktopWidgetBackgroundRadio.value == PlasmaCore.Types.NoBackground
            onCheckedChanged: () => {
                if (checked) {
                    desktopWidgetBackgroundRadio.value = PlasmaCore.Types.NoBackground;
                }
            }
            ButtonGroup.group: desktopWidgetBackgroundRadio
        }
        RowLayout {
            RadioButton {
                text: i18n("Transparent with shadow")
                checked: desktopWidgetBackgroundRadio.value == PlasmaCore.Types.ShadowBackground
                onCheckedChanged: () => {
                    if (checked) {
                        desktopWidgetBackgroundRadio.value = PlasmaCore.Types.ShadowBackground;
                    }
                }
                ButtonGroup.group: desktopWidgetBackgroundRadio
            }
        }
        ButtonGroup {
            id: desktopWidgetBackgroundRadio
            property int value: PlasmaCore.Types.StandardBackground
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Disable tooltip:")
            CheckBox {
                id: hideToolTipCheckbox
            }
            Kirigami.ContextualHelpButton {
                toolTipText: i18n("Disable ToolTip that shows the widget name and description.")
            }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Disable left click:")
            CheckBox {
                id: disableLeftClickCheckbox
            }
            Kirigami.ContextualHelpButton {
                toolTipText: i18n("Applet popup will still be accessible from the right click menu.")
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Troubleshooting")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Debug mode:")
            CheckBox {
                id: debugModeCheckbox
            }
            Kirigami.ContextualHelpButton {
                toolTipText: i18n("Print additional messages to the system log. To make it easier to spot sizing issues, this will also force full height to the first visualizer bar and displays a grid over it.")
            }
        }
    }
}
