import QtQuick 2.15
import Qt.labs.platform 1.1

SystemTrayIcon {
    id: systray

    visible: true
    icon.source: 'qrc:/lewl.png'
    tooltip: qsTr('TwitchOverlay')

    signal showHide();
    signal reposition();
    signal configure();

    menu: Menu {
        visible: false

        MenuItem {
            text: qsTr("&Show/Hide")
            onTriggered: systray.showHide();
        }
        MenuSeparator {}
        MenuItem {
            text: qsTr("&Reposition")
            onTriggered: systray.reposition();
        }
        MenuItem {
            text: qsTr("&Configure")
            onTriggered: systray.configure();
        }
        MenuSeparator {}
        MenuItem {
            text: qsTr("E&xit")
            onTriggered: Qt.quit()
        }
    }
}
