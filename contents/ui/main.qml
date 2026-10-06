pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PC3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    property var power: ({battery: {present: false}, plaid: false, profiles: [], activeProfile: ""})
    property bool busy: false
    property string error: ""
    property string helper: Qt.resolvedUrl("../code/komapowercontrol").toString().replace(/^file:\/\//, "")
    function command(args) { return "python3 '" + helper.replace(/'/g, "'\\''") + "' " + args; }
    function refresh() { if (!busy && reader.connectedSources.length === 0) reader.connectSource(command("status")); }
    function act(args) { if (busy) return; busy = true; error = ""; writer.connectSource(command(args)); }
    function receive(data) {
        try {
            let value = JSON.parse(data.stdout);
            if (value.error) error = value.error;
            if (value.battery) power = value;
        } catch (e) { error = "Unable to read power information."; }
    }
    P5Support.DataSource {
        id: reader
        engine: "executable"
        onNewData: function(source, data) { disconnectSource(source); if (!root.busy) root.receive(data); }
    }
    P5Support.DataSource {
        id: writer
        engine: "executable"
        onNewData: function(source, data) { disconnectSource(source); root.receive(data); root.busy = false; root.refresh(); }
    }
    Timer { interval: root.expanded ? 2000 : 15000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.refresh() }
    Plasmoid.icon: "system-shutdown"
    toolTipMainText: "kOMA Power Control"
    toolTipSubText: power.plaid ? "PLAID Power is on — keeping the machine and screens awake" : (power.battery.present ? Math.round(power.battery.percent) + "% · " + power.battery.status : "AC power")
    compactRepresentation: PC3.ToolButton {
        icon.name: "system-shutdown"
        onClicked: root.expanded = !root.expanded
        Layout.minimumWidth: Kirigami.Units.iconSizes.smallMedium
        Layout.minimumHeight: Kirigami.Units.iconSizes.smallMedium
    }
    fullRepresentation: PlasmaExtras.Representation {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 23
        Layout.preferredWidth: Kirigami.Units.gridUnit * 25
        Layout.minimumHeight: body.implicitHeight + Kirigami.Units.largeSpacing * 2
        Layout.preferredHeight: Layout.minimumHeight
        ColumnLayout {
            id: body
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: Kirigami.Units.largeSpacing }
            spacing: Kirigami.Units.largeSpacing
            RowLayout {
                Kirigami.Icon { source: "battery"; implicitWidth: 40; implicitHeight: 40 }
                ColumnLayout {
                    PlasmaExtras.Heading { text: root.power.battery.present ? "Battery" : "Power"; level: 2 }
                    PC3.Label { text: root.power.battery.present ? root.power.battery.status : "AC power · No battery detected"; opacity: 0.7 }
                }
                Item { Layout.fillWidth: true }
                PlasmaExtras.Heading { visible: root.power.battery.present; text: Math.round(root.power.battery.percent || 0) + "%"; level: 1 }
            }
            PC3.ProgressBar { visible: root.power.battery.present; Layout.fillWidth: true; from: 0; to: 100; value: root.power.battery.percent || 0 }
            GridLayout {
                visible: root.power.battery.present
                columns: 2
                Layout.fillWidth: true
                PC3.Label { text: "Battery size"; opacity: 0.7 }
                PC3.Label { text: root.power.battery.capacity > 0 ? root.power.battery.capacity.toFixed(1) + " Wh" : "—"; Layout.alignment: Qt.AlignRight }
                PC3.Label { text: "Charge cycles"; opacity: 0.7 }
                PC3.Label { text: root.power.battery.cycles >= 0 ? root.power.battery.cycles : "—"; Layout.alignment: Qt.AlignRight }
                PC3.Label { text: root.power.battery.status === "Charging" ? "Time to full" : "Time remaining"; opacity: 0.7 }
                PC3.Label { text: root.power.battery.seconds > 0 ? Math.floor(root.power.battery.seconds / 3600) + "h " + Math.floor(root.power.battery.seconds / 60) % 60 + "m" : "—"; Layout.alignment: Qt.AlignRight }
                PC3.Label { text: "Charge / discharge rate"; opacity: 0.7 }
                PC3.Label { text: root.power.battery.rate > 0 ? root.power.battery.rate.toFixed(1) + " W" : "—"; Layout.alignment: Qt.AlignRight }
            }
            Kirigami.Separator { Layout.fillWidth: true }
            PC3.Button {
                Layout.fillWidth: true
                text: root.power.plaid ? "Turn PLAID Power Off" : "PLAID Power"
                icon.name: "system-shutdown"
                checkable: true
                checked: root.power.plaid
                enabled: !root.busy
                onClicked: root.act("plaid " + (root.power.plaid ? "off" : "on"))
            }
            PC3.Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                opacity: 0.7
                text: root.power.plaid ? "Keeping the machine and screens awake. Turn off to restore your normal settings." : "Keep the machine and screens awake until you turn PLAID Power off."
            }
            PlasmaExtras.Heading { text: "Power profile"; level: 3 }
            RowLayout {
                Layout.fillWidth: true
                Repeater {
                    model: [{key: "power-saver", label: "Power-saver", icon: "battery-profile-powersave"}, {key: "balanced", label: "Balanced", icon: "battery-profile-balanced"}, {key: "performance", label: "Performance", icon: "battery-profile-performance"}]
                    PC3.Button {
                        required property var modelData
                        Layout.fillWidth: true
                        text: modelData.label
                        icon.name: modelData.icon
                        checkable: true
                        checked: root.power.activeProfile === modelData.key
                        enabled: !root.busy && root.power.profiles.indexOf(modelData.key) >= 0
                        onClicked: root.act("profile " + modelData.key)
                    }
                }
            }
            PC3.Label { visible: root.power.profiles.length === 0; Layout.fillWidth: true; wrapMode: Text.WordWrap; opacity: 0.7; text: "Power profiles aren’t available on this machine." }
            Kirigami.InlineMessage { Layout.fillWidth: true; visible: root.error.length > 0; text: root.error; type: Kirigami.MessageType.Error }
        }
    }
}
