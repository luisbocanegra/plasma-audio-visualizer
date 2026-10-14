import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import "./components"
import "code/enum.js" as Enum
import "code/globals.js" as Globals
import "code/utils.js" as Utils

Item {
    id: root

    Layout.preferredWidth: Plasmoid.configuration.expanding || main.onDesktop ? -1 : content.implicitWidth
    Layout.preferredHeight: Plasmoid.configuration.expanding || main.onDesktop ? -1 : content.implicitHeight
    Layout.minimumWidth: Plasmoid.configuration.expanding ? (main.horizontal ? Plasmoid.configuration.minimumLength : -1) : Layout.preferredWidth
    Layout.minimumHeight: Plasmoid.configuration.expanding ? (!main.horizontal ? Plasmoid.configuration.minimumLength : -1) : Layout.preferredHeight
    Layout.fillHeight: main.horizontal || Plasmoid.configuration.expanding || main.onDesktop
    Layout.fillWidth: !main.horizontal || Plasmoid.configuration.expanding || main.onDesktop

    property int framerate: Plasmoid.configuration.framerate
    property int barGap: Plasmoid.configuration.barGap
    property int barWidth: Plasmoid.configuration.barWidth
    property int blockHeight: Plasmoid.configuration.blockHeight
    property int blockSpacing: Plasmoid.configuration.blockSpacing
    property int noiseReduction: Plasmoid.configuration.noiseReduction
    property int monstercat: Plasmoid.configuration.monstercat
    property int waves: Plasmoid.configuration.waves
    property bool centeredBars: Plasmoid.configuration.centeredBars
    property int waveMode: Plasmoid.configuration.waveMode
    property bool roundedBars: Plasmoid.configuration.roundedBars
    property int visualizerStyle: Plasmoid.configuration.visualizerStyle
    property bool circleMode: Plasmoid.configuration.circleMode
    property real circleModeSize: Plasmoid.configuration.circleModeSize
    property bool fillWave: Plasmoid.configuration.fillWave
    property int orientation: Plasmoid.configuration.orientation
    property bool disableLeftClick: Plasmoid.configuration.disableLeftClick
    property bool stereo: Plasmoid.configuration.outputChannels === "stereo"
    property bool waveSimulateWaveform: Plasmoid.configuration.waveSimulateWaveform
    property bool circleModeFill: Plasmoid.configuration.circleModeFill
    property bool pinnedDownSides: Plasmoid.configuration.pinnedDownSides
    property bool waveform: Plasmoid.configuration.waveform
    clip: !Plasmoid.configuration.debugMode

    property var logger: Logger.create(Plasmoid.configuration.debugMode ? LoggingCategory.Debug : LoggingCategory.Info)

    property var barColorsCfg: {
        let barColors;
        try {
            barColors = JSON.parse(Plasmoid.configuration.barColors);
        } catch (e) {
            logger.error(e, e.stack);
            globalSettings = Globals.baseBarColors;
        }
        const config = Utils.mergeConfigs(Globals.baseBarColors, barColors);
        const configStr = JSON.stringify(config);
        if (Plasmoid.configuration.barColors !== configStr) {
            Plasmoid.configuration.barColors = configStr;
            Plasmoid.configuration.writeConfig();
        }
        return config;
    }

    property var waveFillColorsCfg: {
        let waveFillColors;
        try {
            waveFillColors = JSON.parse(Plasmoid.configuration.waveFillColors);
        } catch (e) {
            logger.error(e, e.stack);
            globalSettings = Globals.baseWaveFillColors;
        }
        const config = Utils.mergeConfigs(Globals.baseWaveFillColors, waveFillColors);
        const configStr = JSON.stringify(config);
        if (Plasmoid.configuration.waveFillColors !== configStr) {
            Plasmoid.configuration.waveFillColors = configStr;
            Plasmoid.configuration.writeConfig();
        }
        return config;
    }

    property var inactiveBlockColorsCfg: {
        let inactiveBlockColors;
        try {
            inactiveBlockColors = JSON.parse(Plasmoid.configuration.inactiveBlockColors);
        } catch (e) {
            logger.error(e, e.stack);
            globalSettings = Globals.baseInactiveBlockColors;
        }
        const config = Utils.mergeConfigs(Globals.baseInactiveBlockColors, inactiveBlockColors);
        const configStr = JSON.stringify(config);
        if (Plasmoid.configuration.inactiveBlockColors !== configStr) {
            Plasmoid.configuration.inactiveBlockColors = configStr;
            Plasmoid.configuration.writeConfig();
        }
        return config;
    }
    property bool drawInactiveBlocks: Plasmoid.configuration.drawInactiveBlocks

    RowLayout {
        id: content
        height: [Enum.Orientation.Left, Enum.Orientation.Right].includes(root.orientation) ? parent.width : parent.height
        width: [Enum.Orientation.Left, Enum.Orientation.Right].includes(root.orientation) ? parent.height : parent.width
        anchors.centerIn: parent
        spacing: 0
        Visualizer {
            id: visualizer
            visualizerStyle: root.visualizerStyle
            circleMode: root.circleMode
            circleModeSize: root.circleModeSize
            circleModeFill: root.circleModeFill
            barWidth: root.barWidth
            blockHeight: root.blockHeight
            blockSpacing: root.blockSpacing
            barGap: root.barGap
            centeredBars: root.centeredBars
            waveMode: root.waveMode
            roundedBars: root.roundedBars
            fillWave: root.fillWave
            barColorsCfg: root.barColorsCfg
            waveFillColorsCfg: root.waveFillColorsCfg
            inactiveBlockColorsCfg: root.inactiveBlockColorsCfg
            drawInactiveBlocks: root.drawInactiveBlocks
            waveSimulateWaveform: root.waveSimulateWaveform
            waveform: root.waveform
            values: {
                let values = [...cava.values];
                if (circleMode && root.stereo) {
                    return Utils.swapChannels(values);
                }
                if (root.visualizerStyle === Enum.VisualizerStyles.Wave && root.pinnedDownSides && !root.circleMode && !root.waveform) {
                    values[0] = 0;
                    values[values.length - 1] = 0;
                }
                return values;
            }
            debugMode: Plasmoid.configuration.debugMode
            visible: !cava.hasError && (!cava.idle || main.visibilityMode !== Enum.VisibilityMode.WhileAudioPlays)
            fixVertical: !main.horizontal
            Layout.preferredWidth: {
                if (circleMode) {
                    return main.minimumDimension;
                }
                return (main.horizontal && !Plasmoid.configuration.expanding) ? Plasmoid.configuration.length : -1;
            }
            Layout.preferredHeight: {
                if (circleMode) {
                    return main.minimumDimension;
                }
                return !(main.horizontal && !Plasmoid.configuration.expanding) ? Plasmoid.configuration.length : -1;
            }
            Layout.fillHeight: main.horizontal || Plasmoid.configuration.expanding || [Enum.Orientation.Left, Enum.Orientation.Right].includes(root.orientation) || main.onDesktop
            Layout.fillWidth: !main.horizontal || Plasmoid.configuration.expanding || [Enum.Orientation.Left, Enum.Orientation.Right].includes(root.orientation) || main.onDesktop
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

            property var orientationBottom: Rotation {
                origin.x: Math.floor(visualizer.width / 2)
                origin.y: Math.floor(visualizer.height / 2)
                axis {
                    x: 1
                    y: 0
                    z: 0
                }
                angle: 0
            }
            property var orientationTop: Rotation {
                origin.x: Math.floor(visualizer.width / 2)
                origin.y: Math.floor(visualizer.height / 2)
                axis {
                    x: 1
                    y: 0
                    z: 0
                }
                angle: 180
            }
            property var orientationLeft: Rotation {
                origin.x: Math.floor(visualizer.width / 2)
                origin.y: Math.floor(visualizer.height / 2)
                angle: 90
            }
            property var orientationRight: Rotation {
                origin.x: Math.floor(visualizer.width / 2)
                origin.y: Math.floor(visualizer.height / 2)
                angle: -90
            }
            transform: {
                let t = [];
                if (main.orientation === Enum.Orientation.Top) {
                    t.push(orientationTop);
                }
                if (main.orientation === Enum.Orientation.Left) {
                    t.push(orientationLeft);
                }
                if (main.orientation === Enum.Orientation.Right) {
                    t.push(orientationRight);
                    t.push(orientationTop);
                }
                return t;
            }
        }
        Kirigami.Icon {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.preferredWidth: Kirigami.Units.iconSizes.roundedIconSize(Math.min(main.height, main.width))
            Layout.fillHeight: Layout.preferredWidth
            source: Qt.resolvedUrl("./icons/error.svg").toString().replace("file://", "")
            active: mouseArea.containsMouse
            isMask: true
            color: Kirigami.Theme.negativeTextColor
            visible: cava.hasError
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: enabled
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            main.expanded = !main.expanded;
        }
        enabled: !root.disableLeftClick || cava.hasError || main.expanded
    }

    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        mainItem: Tooltip {}
        active: !Plasmoid.configuration.hideToolTip
    }
}
