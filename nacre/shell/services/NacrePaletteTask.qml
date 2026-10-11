import QtQuick
import Quickshell.Io

QtObject {
    id: root
    property var command: []
    readonly property string tool: command[1] || ""
    property bool running: false
    property bool stdinEnabled: false
    property int starts: 0
    property bool issued: false
    property bool ready: false
    signal started
    signal exited(int code, int status)
    readonly property QtObject stdout: QtObject {
        signal read(string data)
    }
    onRunningChanged: if (running) {
        starts++;
        issued = false;
        if (ready)
            Qt.callLater(begin);
        else
            server.running = true;
    }
    function begin() {
        if (!running || issued)
            return;
        started();
        if (!stdinEnabled)
            send(command[3] || "");
    }
    function write(text) {
        if (running && !issued)
            send(JSON.parse(text));
    }
    function send(value) {
        issued = true;
        server.write(JSON.stringify({
            action: command[2],
            value: value
        }) + "\n");
    }
    readonly property Process server: Process {
        objectName: "paletteServer"
        command: ["python3", root.tool, "serve"]
        stdinEnabled: true
        running: true
        stdout: SplitParser {
            onRead: text => {
                try {
                    const data = JSON.parse(text);
                    if (data.ready) {
                        root.ready = true;
                        root.begin();
                    } else if (data.presentation) {
                        root.stdout.read(text);
                    } else if (data.done && root.running) {
                        if (!data.result || typeof data.result !== "object" || ![0, 1].includes(data.code))
                            throw new Error("Invalid publisher response");
                        root.stdout.read(JSON.stringify(data.result));
                        root.running = false;
                        root.exited(data.code || 0, 0);
                    }
                } catch (error) {
                    root.ready = false;
                    server.running = false;
                }
            }
        }
        onExited: (code, status) => {
            root.ready = false;
            if (root.running) {
                root.running = false;
                root.exited(code || 1, status);
            }
        }
    }
}
