import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    height: mainContainer.implicitHeight + 20
    width: mainContainer.implicitWidth + 20

    ColumnLayout {
        id: mainContainer
        anchors.centerIn: parent

        spacing: 5
        GridLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            columns: 2
            rowSpacing: 5
            columnSpacing: 5

            Label { text: qsTr('Username:'); }
            TextField { id: fieldUsername; text: Overlay.username; Layout.fillWidth: true }

            Label { text: qsTr('Authkey:'); }
            TextField { id: fieldAuthkey; text: Overlay.authkey; Layout.fillWidth: true }
/*
            Label { text: qsTr('Client ID:'); }
            TextField { id: fieldClientid; text: Overlay.clientid; Layout.fillWidth: true }

            Label { text: qsTr('Client Secret:'); }
            TextField { id: fieldSecret; text: Overlay.secret; Layout.fillWidth: true }
*/
            Label { text: qsTr('Channel:'); }
            TextField { id: fieldChannel; text: Overlay.channel; Layout.fillWidth: true }
        }

        Row {
            Layout.fillWidth: true
            spacing: 5
            layoutDirection: Qt.RightToLeft

            Button
            {
                text: qsTr('&Cancel')
                onClicked: {
                    Dialogue.hide();
                }
            }

            Button
            {
                text: qsTr('&Okay')
                onClicked: {
                    Overlay.disconnect();
                    Overlay.username = fieldUsername.text;
                    Overlay.authkey = fieldAuthkey.text;
                    /*
                    Overlay.clientid = fieldClientid.text;
                    Overlay.secret = fieldSecret.text;
                    */
                    Overlay.channel = fieldChannel.text;
                    Overlay.reconnect();

                    Dialogue.hide();
                }
            }
        }
    }
}
