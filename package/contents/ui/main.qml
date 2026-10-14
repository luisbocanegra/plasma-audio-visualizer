import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import "code/enum.js" as Enum
import "code/utils.js" as Utils

PlasmoidItem {
    id: main
    Plasmoid.backgroundHints: editMode ? PlasmaCore.Types.StandardBackground : plasmoid.configuration.desktopWidgetBg
    Plasmoid.constraintHints: Plasmoid.configuration.fillPanel ? Plasmoid.CanFillArea : Plasmoid.NoHint

    property bool editMode: Plasmoid.containment.corona?.editMode ?? false
    property bool onDesktop: Plasmoid.location === PlasmaCore.Types.Floating
    property bool horizontal: Plasmoid.formFactor !== PlasmaCore.Types.Vertical
    property int orientation: Plasmoid.configuration.orientation
    property bool stopCava: Plasmoid.configuration._stopCava
    property bool disableLeftClick: Plasmoid.configuration.disableLeftClick
    property real minimumDimension: Math.min(main.width, main.height)

    property int barGap: {
        if (Plasmoid.configuration.visualizerStyle === Enum.VisualizerStyles.Wave) {
            return Math.max(1, Plasmoid.configuration.barGap);
        }
        return Plasmoid.configuration.barGap;
    }

    property int barCount: {
        let bars = 1;
        let width;
        if (Plasmoid.configuration.circleMode) {
            width = minimumDimension;
        } else {
            width = [Enum.Orientation.Left, Enum.Orientation.Right].includes(Plasmoid.configuration.orientation) ? main.height : main.width;
        }
        if (Plasmoid.configuration.visualizerStyle === Enum.VisualizerStyles.Wave) {
            bars = Math.floor((width + barGap) / barGap);
        } else {
            bars = Math.floor((width + barGap) / (Plasmoid.configuration.barWidth + barGap));
        }
        if (Plasmoid.configuration.outputChannels === "stereo") {
            bars = Utils.makeEven(bars);
        }
        if (Plasmoid.configuration.visualizerStyle === Enum.VisualizerStyles.Wave) {
            bars = Math.max(2, bars);
        }
        return bars;
    }

    property int asciiMaxRange: [Enum.Orientation.Left, Enum.Orientation.Right].includes(Plasmoid.configuration.orientation) ? main.width : main.height
    property var logger: Logger.create(Plasmoid.configuration.debugMode ? LoggingCategory.Debug : LoggingCategory.Info)
    property bool hideWhenIdle: Plasmoid.configuration.hideWhenIdle

    property bool pauseFullScreen: Plasmoid.configuration.pauseOnFullScreenWindow
    property bool pauseMaximized: Plasmoid.configuration.pauseOnMaximizedWindow
    property bool pauseByWindow: (pauseMaximized && tasksModel.maximizedExists) || (pauseFullScreen && tasksModel.fullScreenExists)

    Plasmoid.status: PlasmaCore.Types.ActiveStatus

    function updateStatus() {
        logger.debug("Plasmoid.status:", Plasmoid.status);
        // HACK: without this delay there is a visible margin on the right side when expanding == true
        Utils.delay(10, () => {
            if (Plasmoid.status === PlasmaCore.Types.RequiresAttentionStatus) {
                return;
            }
            Plasmoid.status = (hideWhenIdle && cava.idle || !cava.running) && !Plasmoid.expanded && !editMode && !cava.hasError ? PlasmaCore.Types.HiddenStatus : PlasmaCore.Types.ActiveStatus;
            logger.debug("Plasmoid.status:", Plasmoid.status);
        }, main);
    }
    onExpandedChanged: expanded => {
        logger.debug("expanded:", expanded);
        Utils.delay(1000, updateStatus, main);
    }

    onBarCountChanged: {
        if (editMode && stopCava) {
            return;
        }
        Qt.callLater(() => {
            resizeDebounce.restart();
        });
    }

    onAsciiMaxRangeChanged: {
        if (editMode && stopCava) {
            return;
        }
        Qt.callLater(() => {
            resizeDebounce.restart();
        });
    }

    Timer {
        id: resizeDebounce
        interval: 50
        onTriggered: {
            cava.barCount = main.barCount;
            cava.asciiMaxRange = main.asciiMaxRange;
            logger.debug("barCount:", barCount, "asciiMaxRange:", asciiMaxRange);
        }
    }

    onEditModeChanged: {
        logger.debug("editMode:", editMode);
        updateStatus();
    }

    Cava {
        id: cava
        framerate: Plasmoid.configuration.framerate
        noiseReduction: Plasmoid.configuration.noiseReduction
        monstercat: Plasmoid.configuration.monstercat
        waves: Plasmoid.configuration.waves
        autoSensitivity: Plasmoid.configuration.autoSensitivity
        sensitivityEnabled: Plasmoid.configuration.sensitivityEnabled
        sensitivity: Plasmoid.configuration.sensitivity
        scaling: Plasmoid.configuration.scaling
        lowerCutoffFreq: Plasmoid.configuration.lowerCutoffFreq
        higherCutoffFreq: Plasmoid.configuration.higherCutoffFreq
        inputMethod: Plasmoid.configuration.inputMethod
        inputSource: Plasmoid.configuration.inputSource
        sampleRate: Plasmoid.configuration.sampleRate
        sampleBits: Plasmoid.configuration.sampleBits
        inputChannels: Plasmoid.configuration.inputChannels
        autoconnect: Plasmoid.configuration.autoconnect
        active: Plasmoid.configuration.active
        remix: Plasmoid.configuration.remix
        virtual: Plasmoid.configuration.virtual
        outputChannels: Plasmoid.configuration.outputChannels
        monoOption: Plasmoid.configuration.monoOption
        reverse: Plasmoid.configuration.reverse
        waveform: Plasmoid.configuration.waveform
        eqEnabled: Plasmoid.configuration.eqEnabled
        eq: Plasmoid.configuration.eq
        idleCheck: main.hideWhenIdle
        idleTimer: Plasmoid.configuration.idleTimer
        cavaSleepTimer: Plasmoid.configuration.cavaSleepTimer
        onIdleChanged: {
            main.logger.info("cava.idle:", idle);
            main.updateStatus();
        }
        onHasErrorChanged: {
            main.logger.error("cava.hasError:", hasError, error);
            main.updateStatus();
        }
        onRunningChanged: {
            main.logger.info("cava.running:", running);
            main.updateStatus();
        }
    }

    preferredRepresentation: compactRepresentation
    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {}

    onStopCavaChanged: {
        logger.debug("stopCava:", stopCava);
        if (stopCava) {
            cava.stop();
        } else {
            cava.start();
        }
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: cava.running ? i18n("Stop CAVA") : i18n("Start CAVA")
            icon.name: "waveform-symbolic"
            onTriggered: {
                Plasmoid.configuration._stopCava = !Plasmoid.configuration._stopCava;
                Plasmoid.configuration.writeConfig();
            }
        },
        PlasmaCore.Action {
            text: i18n("Show support information")
            icon.name: "info-symbolic"
            onTriggered: {
                main.expanded = !main.expanded;
            }
            visible: main.disableLeftClick
        }
    ]
    // hide default tooltip
    toolTipMainText: ""
    toolTipSubText: ""
    Connections {
        target: Qt.application
        function onAboutToQuit() {
            cava.stop();
        }
    }

    TasksModel {
        id: tasksModel
        screenGeometry: Plasmoid.containment.screenGeometry
    }

    onPauseByWindowChanged: {
        if (Plasmoid.configuration._stopCava) {
            return;
        }
        if (pauseByWindow) {
            cava.stop();
        } else {
            cava.start();
        }
    }
}
