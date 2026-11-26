import QtQuick
import org.kde.plasma.plasmoid
import "../"

Item {
    id: root

    property string command: ""
    property bool autoStartCava: true
    readonly property string stdout: process.stdout ?? ""
    readonly property string stderr: process.stderr ?? ""
    readonly property bool forceFallback: false
    readonly property bool running: process.running ?? false
    property bool usingFallback: false
    property var process: null
    property bool loadingFailed: false
    property list<string> loadingErrors

    function restart() {
        if (process !== null) {
            process.restart();
        }
    }

    function start() {
        if (process !== null) {
            process.start();
        }
    }

    function stop() {
        if (process !== null) {
            process.stop();
        }
    }

    onCommandChanged: {
        if (process !== null) {
            process.command = root.command;
        }
    }

    property var logger: Logger.create(Plasmoid.configuration.debugMode ? LoggingCategory.Debug : LoggingCategory.Info)

    Component.onCompleted: {
        let component = null;
        const sources = ["ProcessMonitorFallback.qml"];
        if (!root.forceFallback) {
            sources.unshift("ProcessMonitorPrimary.qml");
        }
        for (let source of sources) {
            logger.debug("Trying to load", source);
            component = Qt.createComponent(source);
            if (component.status === Component.Ready) {
                process = component.createObject(root, {
                    autoStartCava: Qt.binding(() => root.autoStartCava)
                });
                process.command = root.command;
                break;
            } else {
                logger.warn(component.errorString());
                root.loadingErrors.push(component.errorString());
            }
        }

        if (process === null) {
            root.loadingFailed = true;
        }
        root.usingFallback = component.url.toString().includes("ProcessMonitorFallback.qml");
    }
}
