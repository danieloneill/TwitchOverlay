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

            Button { id: fieldLink; text: 'Link Twitch'; Layout.fillWidth: true; Layout.columnSpan: 2; onClicked: { twitchLogin.spawn(); } }

            Label { text: qsTr('Channel:'); }
            TextField { id: fieldChannel; text: Overlay.channel; Layout.fillWidth: true }
        }

        TwitchLogin {
            id: twitchLogin
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
                    Overlay.channel = fieldChannel.text;
                    Overlay.reconnect();

                    Dialogue.hide();
                }
            }
        }
    }
}
