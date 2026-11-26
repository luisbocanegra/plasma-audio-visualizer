import QtQuick
import com.github.luisbocanegra.audiovisualizer.process
import org.kde.plasma.plasmoid
import "../"

Item {
    id: root
    property string command: ""
    property bool autoStartCava: true
    readonly property string stdout: process.stdout
    readonly property string stderr: process.stderr
    readonly property bool running: process.running
    property var logger: Logger.create(Plasmoid.configuration.debugMode ? LoggingCategory.Debug : LoggingCategory.Info)

    function restart() {
        logger.debug("ProcessMonitorPrimary.restart()");
        process.restart();
    }
    // the plugin keeps a single process so no special handling is needed here
    // this function is here just to match the signature of the fallback
    function start() {
        logger.debug("ProcessMonitorPrimary.start()");
        // the command may not have been passed to the plugin yet (autoStartCava off),
        // setting a new one makes the plugin restart the process by itself
        if (!applyCommand()) {
            restart();
        }
    }
    // returns true if the plugin command changed (which restarts the process)
    function applyCommand() {
        if (command == "")
            return false;
        const newCommand = ["sh", "-c", `${command}`];
        if (JSON.stringify(process.command) === JSON.stringify(newCommand))
            return false;
        process.command = newCommand;
        return true;
    }
    function stop() {
        logger.debug("ProcessMonitorPrimary.stop()");
        process.stop();
    }
    Process {
        id: process
    }

    onCommandChanged: {
        if (command == "")
            return;
        logger.debug("ProcessMonitorPrimary.onCommandChanged:", command);
        // the plugin restarts the process when its command changes
        if (!autoStartCava && !running)
            return;
        applyCommand();
    }
}
