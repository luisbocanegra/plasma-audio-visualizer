import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid
import "./components"

KCM.SimpleKCM {
    id: root
    // general
    property alias cfg_barCount: barCountSpinbox.value
    property alias cfg_framerate: framerateSpinbox.value
    property alias cfg_autoSensitivity: autoSensitivity.value
    property alias cfg_scaling: scalingCombobox.currentValue
    property alias cfg_sensitivityEnabled: sensitivityEnabled.checked
    property alias cfg_sensitivity: sensitivitySpinbox.value
    property alias cfg_lowerCutoffFreq: lowerCutoffFreqSpinbox.value
    property alias cfg_higherCutoffFreq: higherCutoffFreqSpinbox.value
    property alias cfg_cavaSleepTimer: cavaSleepTimerSpinbox.value
    // smoothing
    property alias cfg_noiseReduction: noiseReductionSpinbox.value
    property alias cfg_monstercat: monstercatCheckbox.checked
    property alias cfg_waves: wavesCheckbox.checked
    // input
    property string cfg_inputMethod
    property alias cfg_inputSource: inputSourceField.text
    property alias cfg_sampleRate: sampleRateSpinbox.value
    property alias cfg_sampleBits: sampleBitsSpinbox.value
    property alias cfg_inputChannels: inputChannelsSpinbox.value
    property alias cfg_autoconnect: autoconnectSpinbox.value
    property alias cfg_active: activeCheckbox.checked
    property alias cfg_remix: remixCheckbox.checked
    property alias cfg_virtual: virtualCheckbox.checked
    // output
    property string cfg_outputChannels
    property string cfg_monoOption
    property alias cfg_reverse: reverseCheckbox.checked
    property alias cfg_waveform: waveform.checked
    // eq
    property alias cfg_eqEnabled: eqEnabled.checked
    property var cfg_eq

    property alias cfg_pauseOnFullScreenWindow: pauseOnFullScreenWindow.checked
    property alias cfg_pauseOnMaximizedWindow: pauseOnMaximizedWindow.checked

    PactlList {
        id: pactl
    }

    ColumnLayout {
        Kirigami.FormLayout {
            id: parentLayout
            Layout.fillWidth: true

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("General")
            }

            Button {
                id: stopCavaButton
                text: Plasmoid.configuration._stopCava ? i18n("Start CAVA") : i18n("Stop CAVA")
                onClicked: {
                    Plasmoid.configuration._stopCava = !Plasmoid.configuration._stopCava;
                    Plasmoid.configuration.writeConfig();
                }
            }

            SpinBox {
                id: framerateSpinbox
                Kirigami.FormData.label: i18n("Framerate:")
                from: 1
                to: 144
            }

            RowLayout {
                id: barsRow
                Kirigami.FormData.buddyFor: barCountSpinbox
                Kirigami.FormData.label: i18n("Number of bars:")
                SpinBox {
                    id: barCountSpinbox
                    enabled: false //TODO enable when we have a visualization style that can use it
                    from: 1
                    to: 512
                    Layout.alignment: Qt.AlignTop
                }
                Label {
                    visible: !barCountSpinbox.enabled
                    text: i18n("Automatically calculated for the current visualizer style.")
                    font: Kirigami.Theme.smallFont
                    Layout.maximumWidth: 200
                    wrapMode: Label.Wrap
                    enabled: false
                    Layout.alignment: Qt.AlignTop
                }
            }
            RowLayout {
                Kirigami.FormData.label: i18n("Automatic sensitivity:")
                SpinBox {
                    id: autoSensitivity
                    from: 0
                    to: 10
                    stepSize: 1
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("will attempt to decrease sensitivity if the bars peak and increase slowly as ong as the bars don't peak. 0 = off, 1 = normal, 2..n = more aggressive<br>Increase to make sensitivity increase even faster.")
                }
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Scaling:")
                ComboBox {
                    id: scalingCombobox
                    textRole: "label"
                    valueRole: "value"
                    model: {
                        [
                            {
                                label: i18n("Linear"),
                                value: "linear"
                            },
                            {
                                label: i18n("Logarithmic (decibel)"),
                                value: "decibel"
                            }
                        ];
                    }
                    onActivated: root.cfg_scaling = currentValue
                    Component.onCompleted: currentIndex = indexOfValue(root.cfg_scaling)
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Linear scaling provides a clear visualisation of music when using fewer bars (less than 100). While Logarithmic scaling more correctly resembles how sound is perceived.")
                }
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Sensitivity:")
                CheckBox {
                    id: sensitivityEnabled
                }
                SpinBox {
                    id: sensitivitySpinbox
                    from: 1
                    to: 999
                    enabled: sensitivityEnabled.checked
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Manual sensitivity in %.\nIf autosens is enabled, this will only be the initial value")
                }
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Frequency range (Hz):")

                Label {
                    text: i18n("Min")
                }
                SpinBox {
                    id: lowerCutoffFreqSpinbox
                    from: 20
                    to: 22000
                    stepSize: 100
                }

                Label {
                    text: i18n("Max")
                }

                SpinBox {
                    id: higherCutoffFreqSpinbox
                    from: 1
                    to: 22000
                    stepSize: 100
                }

                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Lower and higher cutoff frequencies for lowest and highest bars, the bandwidth of the visualizer.\nNote: Cava will automatically increase the higher cutoff if a too low band is specified.")
                }
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Sleep timer (seconds):")
                SpinBox {
                    id: cavaSleepTimerSpinbox
                    from: 1
                    to: 60
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Seconds with no input before cava goes to sleep mode.\nCava will not perform FFT and only check for input once per second.")
                }
            }

            CheckBox {
                id: pauseOnFullScreenWindow
                Kirigami.FormData.label: i18n("Pause on:")
                text: i18n("Full screen window")
            }
            CheckBox {
                id: pauseOnMaximizedWindow
                text: i18n("Maximized window")
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Input")
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Method:")
                Layout.preferredWidth: 300
                ComboBox {
                    id: inputMethodCombobox
                    textRole: "label"
                    valueRole: "value"
                    Layout.fillWidth: true
                    model: [
                        {
                            label: i18n("Default"),
                            value: ""
                        },
                        {
                            label: "OSS",
                            value: "oss"
                        },
                        {
                            label: "PipeWire",
                            value: "pipewire"
                        },
                        {
                            label: "Sndio",
                            value: "sndio"
                        },
                        {
                            label: "JACK",
                            value: "jack"
                        },
                        {
                            label: "PulseAudio",
                            value: "pulse"
                        },
                        {
                            label: "ALSA",
                            value: "alsa"
                        },
                        {
                            label: "PortAudio",
                            value: "portaudio"
                        },
                        {
                            label: "FIFO",
                            value: "fifo"
                        },
                        {
                            label: "shmem",
                            value: "shmem"
                        },
                    ]
                    onActivated: {
                        root.cfg_inputMethod = currentValue;
                        if (!["pipewire", "pulse"].includes(root.cfg_inputMethod)) {
                            sourcesCard.visible = false;
                            root.cfg_inputSource = "";
                        }
                    }
                    Component.onCompleted: currentIndex = indexOfValue(root.cfg_inputMethod)
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Audio capturing method.\nDefaults to 'oss', 'pipewire', 'sndio', 'jack', 'pulse', 'alsa', 'portaudio' or 'fifo', in that order, dependent on what support cava was built with.\n")
                }
            }
            RowLayout {
                Kirigami.FormData.label: i18n("Source:")
                Layout.preferredWidth: 300
                TextField {
                    id: inputSourceField
                    Layout.fillWidth: true
                    placeholderText: "auto"
                }
                Button {
                    visible: ["pipewire", "pulse"].includes(root.cfg_inputMethod)
                    icon.name: sourcesCard.visible ? "arrow-up" : "arrow-down"
                    onClicked: {
                        sourcesCard.visible = !sourcesCard.visible;
                    }
                    checkable: true
                    checked: sourcesCard.visible
                }
                ToolButton {
                    onCheckedChanged: inputSourceHelpCard.visible = !inputSourceHelpCard.visible
                    checkable: true
                    icon.name: "help"
                }
            }
            Kirigami.AbstractCard {
                id: sourcesCard
                implicitHeight: 200
                visible: false
                Layout.fillWidth: true
                contentItem: ScrollView {
                    clip: true
                    ListView {
                        model: pactl.names
                        delegate: ItemDelegate {
                            id: delegate
                            required property string modelData
                            // required property Item root
                            width: ListView.view.width
                            text: modelData
                            contentItem: Label {
                                text: delegate.text
                                wrapMode: Label.WrapAnywhere
                                Layout.fillWidth: true
                                font: Kirigami.Theme.smallFont
                            }
                            ToolTip.visible: false
                            onClicked: root.cfg_inputSource = modelData
                        }
                    }
                }
            }
        }
        Kirigami.AbstractCard {
            id: inputSourceHelpCard
            spacing: 0
            visible: false
            Layout.fillWidth: true
            contentItem: ColumnLayout {
                spacing: Kirigami.Units.largeSpacing
                Kirigami.SelectableLabel {
                    text: i18n("For pulseaudio and pipewire 'source' will be the source. Default: 'auto', which uses the monitor source of the default sink (all pulseaudio sinks(outputs) have 'monitor' sources(inputs) associated with them).")
                    Layout.fillWidth: true
                }
                Kirigami.SelectableLabel {
                    text: i18n("For pipewire 'source' will be the object name or object.serial of the device to capture from. Both input and output devices are supported.")
                    Layout.fillWidth: true
                }
                Kirigami.SelectableLabel {
                    text: i18n("For alsa 'source' will be the capture device.")
                    Layout.fillWidth: true
                }
                Kirigami.SelectableLabel {
                    text: i18n("For fifo 'source' will be the path to fifo-file.")
                    Layout.fillWidth: true
                }
                Kirigami.SelectableLabel {
                    text: i18n("For shmem 'source' will be /squeezelite-AA:BB:CC:DD:EE:FF where 'AA:BB:CC:DD:EE:FF' will be squeezelite's MAC address.")
                    Layout.fillWidth: true
                }
                Kirigami.SelectableLabel {
                    text: i18n("For sndio 'source' will be a raw recording audio descriptor or a monitoring sub-device, e.g. 'rsnd/2' or 'snd/1'. Default: 'default'.")
                    Layout.fillWidth: true
                }
                Kirigami.SelectableLabel {
                    text: i18n("For oss 'source' will be the path to a audio device, e.g. '/dev/dsp2'. Default: '/dev/dsp', i.e. the default audio device.")
                    Layout.fillWidth: true
                }
                Kirigami.SelectableLabel {
                    text: i18n("For jack 'source' will be the name of the JACK server to connect to, e.g. 'foobar'. Default: 'default'.")
                    Layout.fillWidth: true
                }
            }
        }

        Kirigami.FormLayout {
            twinFormLayouts: [parentLayout]

            RowLayout {
                Kirigami.FormData.label: i18n("Sample rate:")
                SpinBox {
                    id: sampleRateSpinbox
                    from: 1
                    to: 192000
                    stepSize: 100
                    enabled: ["", "fifo", "pipewire", "sndio", "oss"].includes(root.cfg_inputMethod)
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Only for fifo, pipewire, sndio, oss")
                }
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Sample bits:")
                SpinBox {
                    id: sampleBitsSpinbox
                    from: 8
                    to: 32
                    stepSize: 8
                    enabled: ["", "fifo", "pipewire", "sndio", "oss"].includes(root.cfg_inputMethod)
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Only for fifo, pipewire, sndio, oss")
                }
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Channels:")
                SpinBox {
                    id: inputChannelsSpinbox
                    from: 2
                    to: 4
                    enabled: ["", "pipewire", "sndio", "oss", "jack"].includes(root.cfg_inputMethod)
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Only for pipewire & cava>=0.10.6, sndio, oss, jack")
                }
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Auto connect:")
                SpinBox {
                    id: autoconnectSpinbox
                    from: 2
                    to: 4
                    enabled: ["", "jack"].includes(root.cfg_inputMethod)
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Only for jack")
                }
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Active:")
                CheckBox {
                    id: activeCheckbox
                    enabled: ["", "pipewire"].includes(root.cfg_inputMethod)
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Only for pipewire & cava>=0.10.6. Force the node to always process. Useful for monitoring sources when no other application is active.")
                }
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Remix:")
                CheckBox {
                    id: remixCheckbox
                    enabled: ["", "pipewire"].includes(root.cfg_inputMethod)
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Only for pipewire & cava>=0.10.6. Allow to remix audio channels to match cava's channel count. Useful for surround sound.")
                }
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Virtual:")
                CheckBox {
                    id: virtualCheckbox
                    enabled: ["", "pipewire"].includes(root.cfg_inputMethod)
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Only for pipewire & cava>=0.10.6. Set the node to virtual, to avoid recording notifications from the DE.")
                }
            }
        }

        Kirigami.FormLayout {
            twinFormLayouts: [parentLayout]

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Output")
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Visual channels:")
                ComboBox {
                    id: outputChannelsCombobox
                    model: ["mono", "stereo"]
                    onActivated: root.cfg_outputChannels = currentValue
                    Component.onCompleted: currentIndex = indexOfValue(root.cfg_outputChannels)
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("'mono' outputs left to right lowest to highest frequencies.\n'stereo' mirrors both channels with low frequencies in center.")
                }
            }

            ComboBox {
                id: monoOptionCombobox
                Kirigami.FormData.label: i18n("Mono channel:")
                model: ['left', 'right', 'average']
                onActivated: root.cfg_monoOption = currentValue
                Component.onCompleted: currentIndex = indexOfValue(root.cfg_monoOption)
                enabled: root.cfg_outputChannels === "mono"
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Reverse:")
                CheckBox {
                    id: reverseCheckbox
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Display frequencies the other way around")
                }
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Waveform:")
                CheckBox {
                    id: waveform
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Show waveform instead of frequency spectrum. Takes precedence over the simulate waveform option.")
                }
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Smoothing")
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Noise reduction:")
                SpinBox {
                    id: noiseReductionSpinbox
                    from: 0
                    to: 100
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("The raw visualization is very noisy, this factor adjusts the integral and gravity filters to keep the signal smooth.\n100 will be very slow and smooth, 0 will be fast but noisy.")
                }
            }
            RowLayout {
                Kirigami.FormData.label: i18n("Monstercat:")
                CheckBox {
                    id: monstercatCheckbox
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Enable the so-called \"Monstercat smoothing\" with or without \"waves\".")
                }
            }

            CheckBox {
                id: wavesCheckbox
                text: i18n("Waves")
                enabled: monstercatCheckbox.checked
            }
            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Equalizer")
            }
            RowLayout {
                Kirigami.FormData.label: i18n("Enabled:")
                CheckBox {
                    id: eqEnabled
                    enabled: root.cfg_scaling === "linear"
                }
                Kirigami.ContextualHelpButton {
                    toolTipText: i18n("Adjust frequencies by a multiplication factor, more bands equals more precision. Not supported with logarithmic scaling.")
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
        Eq {
            enabled: eqEnabled.checked && root.cfg_scaling === "linear"
            Layout.preferredWidth: parent.width - Kirigami.Units.gridUnit * 2
            Layout.alignment: Qt.AlignHCenter
            fromFreq: root.cfg_lowerCutoffFreq
            toFreq: root.cfg_higherCutoffFreq
            onValueChanged: (index, value) => {
                root.cfg_eq[index] = parseFloat(value.toString()).toFixed(1);
                const tmp = root.cfg_eq;
                root.cfg_eq = null;
                root.cfg_eq = tmp;
            }
            Component.onCompleted: values = root.cfg_eq.map(v => parseFloat(v).toFixed(1))
            onBandRemoved: {
                root.cfg_eq.pop();
                values = root.cfg_eq.map(v => parseFloat(v).toFixed(1));
            }
            onBandAdded: {
                root.cfg_eq.push("1.0");
                values = root.cfg_eq.map(v => parseFloat(v).toFixed(1));
            }
            onFlat: {
                root.cfg_eq = root.cfg_eq.map(v => "1.0");
                // HACK: setting values alone doesn't update the values in the controls
                bandAdded();
                bandRemoved();
            }
        }
    }
}
