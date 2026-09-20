import QtQuick
import "./components"

Item {
    id: root
    property int framerate
    property int barCount
    property int noiseReduction
    property int monstercat // boolean
    property int waves // boolean
    property int autoSensitivity
    property bool sensitivityEnabled
    property int sensitivity
    property int lowerCutoffFreq
    property int higherCutoffFreq
    property string inputMethod
    property string inputSource
    property int sampleRate
    property int sampleBits
    property int inputChannels
    property int autoconnect
    property int active // boolean
    property int remix // boolean
    property int virtual // boolean
    property string outputChannels
    property string monoOption
    property int reverse // boolean
    property int waveform // boolean
    property bool eqEnabled
    property list<real> eq
    property list<int> values
    property bool idle
    property bool idleCheck
    property int idleTimer
    property int cavaSleepTimer
    property int asciiMaxRange: 100
    readonly property bool hasError: error !== "" || loadingFailed
    readonly property string error: process.stderr
    readonly property list<string> loadingErrors: process.loadingErrors
    readonly property bool loadingFailed: process.loadingFailed
    readonly property bool usingFallback: process.usingFallback
    readonly property bool running: process.running
    readonly property string cavaCommand: process.command
    readonly property string cavaConfig: {
        let config = `[general]
framerate=${root.framerate}
bars=${root.barCount}
autosens=${root.autoSensitivity}
lower_cutoff_freq=${root.lowerCutoffFreq}
higher_cutoff_freq=${root.higherCutoffFreq}
sleep_timer=${root.cavaSleepTimer}
`;

        if (root.sensitivityEnabled) {
            config += `sensitivity=${root.sensitivity}\n`;
        }
        config += "[input]\n";
        if (root.inputMethod !== "") {
            config += `method=${root.inputMethod}\n`;
        }
        if (root.inputSource !== "") {
            config += `source=${root.inputSource}\n`;
        }

        config += `sample_rate=${root.sampleRate}
sample_bits=${root.sampleBits}
channels=${root.inputChannels}
autoconnect=${root.autoconnect}
active=${root.active}
remix=${root.remix}
virtual=${root.virtual}
[output]
channels=${root.outputChannels}
mono_option=${root.monoOption}
reverse=${root.reverse}
method=raw
raw_target=/dev/stdout
data_format=ascii
ascii_max_range=${asciiMaxRange}
waveform=${root.waveform}
[smoothing]
noise_reduction=${root.noiseReduction}
monstercat=${root.monstercat}
waves=${root.waves}
`;
        if (root.eqEnabled) {
            config += "[eq]\n";
            for (let i = 0; i < eq.length; i++) {
                config += `${i + 1}=${eq[i]}`;
                if (i < eq.length - 1) {
                    config += '\n';
                }
            }
        }
        return config;
    }
    function restart() {
        process.restart();
    }
    function start() {
        process.start();
    }
    function stop() {
        process.stop();
    }
    onCavaConfigChanged: {
        if (barCount > 0 && cavaConfig != "") {
            process.command = `bash -c 'exec cava -p /dev/stdin <<-EOF
${cavaConfig}
EOF'
`;
        }
    }
    ProcessMonitor {
        id: process
        onStdoutChanged: {
            let output = process.stdout.trim();
            if (output.endsWith(';')) {
                output = output.slice(0, -1);
            }
            root.values = output.split(";").map(v => parseInt(v, 10));
            if (!root.idleCheck) {
                return;
            }
            if (root.values.find(v => v > 0)) {
                if (idleTimer.running) {
                    idleTimer.stop();
                }
                root.idle = false;
            } else {
                idleTimer.restart();
            }
        }
    }

    Timer {
        id: idleTimer
        interval: root.idleTimer * 1000
        onTriggered: root.idle = true
    }
}
