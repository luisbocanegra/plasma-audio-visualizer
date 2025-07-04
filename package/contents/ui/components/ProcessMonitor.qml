import QtQuick

Item {
    id: root

    property string command: ""
    property string stdout: ""
    property string stderr: ""
    property bool useFallback: false
    property bool usingFallback: loader.source.toString() === "ProcessMonitorFallback.qml"
    property bool running: false

    function restart() {
        if (loader.status === Loader.Ready) {
            loader.item.restart();
        }
    }

    function stop() {
        if (loader.status === Loader.Ready) {
            loader.item.stop();
        }
    }

    onCommandChanged: {
        if (loader.status === Loader.Ready) {
            loader.item.command = root.command;
        }
    }

    Loader {
        id: loader

        source: root.useFallback ? "ProcessMonitorFallback.qml" : "ProcessMonitorPrimary.qml"
        onStatusChanged: {
            if (status === Loader.Error) {
                loader.source = "ProcessMonitorFallback.qml";
            }
        }
        onLoaded: {
            loader.item.command = root.command;
            loader.item.stdoutChanged.connect(() => {
                root.stdout = loader.item.stdout;
            });
            loader.item.stderrChanged.connect(() => {
                root.stderr = loader.item.stderr;
            });
            loader.item.runningChanged.connect(() => {
                root.running = loader.item.running;
            });
        }
    }
}
