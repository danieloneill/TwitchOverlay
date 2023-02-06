import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

Window {
    id: configDialogue
    height: mainContainer.implicitHeight + 20
    width: mainContainer.implicitWidth + 20
    title: qsTr('Configuration')
    flags: Qt.Dialog

    Rectangle {
        anchors.fill: parent
        color: Material.backgroundColor
    }

    ColumnLayout {
        id: mainContainer
        anchors.fill: parent
        anchors.margins: 10

        spacing: 5

        ComboBox {
            id: comboService
            Layout.fillWidth: true
            model: [ { 'code':'twitch', 'name':'Twitch' }, { 'code':'owncast', 'name':'Owncast' } ]
            textRole: 'name'
            valueRole: 'code'
        }

        GridLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            columns: 3
            rowSpacing: 5
            columnSpacing: 5
            visible: comboService.currentValue === 'twitch'

            Button { id: fieldLink; text: 'Link Twitch'; Layout.fillWidth: true; Layout.columnSpan: 3; onClicked: { twitchLogin.spawn(); } }

            Label { color: Material.foreground; text: qsTr('Channel:'); }
            TextField { id: fieldChannel; text: settings.channel || ''; Layout.fillWidth: true; Layout.columnSpan: 2 }

            Label { color: Material.foreground; text: qsTr('Client ID:'); }
            TextField { id: fieldClientID; text: settings.clientid || ''; Layout.fillWidth: true }
            Text { Layout.preferredWidth: implicitHeight; color: 'blue'; text: '(?)'; MouseArea { anchors.fill: parent; onClicked: aboutOAuth2.show(); } }

            Label { color: Material.foreground; text: qsTr('Client Secret:'); }
            TextField { id: fieldClientSecret; text: settings.clientsecret || ''; Layout.fillWidth: true }
            Text { Layout.preferredWidth: implicitHeight; color: 'blue'; text: '(?)'; MouseArea { anchors.fill: parent; onClicked: aboutOAuth2.show(); } }
        }

        GridLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            columns: 3
            rowSpacing: 5
            columnSpacing: 5
            visible: comboService.currentValue === 'owncast'

            Label { color: Material.foreground; text: qsTr('Owncast Host:'); }
            TextField { id: fieldOwncastHost; text: settings.owncastHost || ''; Layout.fillWidth: true; Layout.columnSpan: 2 }

            Label { color: Material.foreground; text: qsTr('Access Token:'); }
            TextField { id: fieldOwncastToken; text: settings.owncastToken || ''; Layout.fillWidth: true }
            Text { Layout.preferredWidth: implicitHeight; color: 'blue'; text: '(?)'; MouseArea { anchors.fill: parent; onClicked: aboutOwncast.show(); } }
        }

        GridLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            columns: 3
            rowSpacing: 5
            columnSpacing: 5

            Label { color: Material.foreground; text: qsTr('Backdrop:'); }
            TextField { id: bgimage; text: settings.bgImage || ''; Layout.fillWidth: true }
            Button { text: qsTr('Select...'); onClicked: { bgDialogue.open(); } }

            Label { color: Material.foreground; text: qsTr('Notification Sound:'); }
            TextField { id: notification; text: settings.notifySound || ''; Layout.fillWidth: true }
            Button { text: qsTr('Select...'); onClicked: { notifyDialogue.open(); notifyDialogue.visible=true; } }

            Label { color: Material.foreground; text: qsTr('Opacity:') }
            TextSlider {
                id: opacitySlider
                Layout.columnSpan: 2
                Layout.fillWidth: true
                from: 0
                value: settings.opacity || 100
                to: 100
                text: parseInt(value) + '%'
            }

            Label { color: 'white'; text: qsTr('Scale:') }
            TextSlider {
                id: scaleSlider
                Layout.columnSpan: 2
                Layout.fillWidth: true
                from: 1
                value: settings.scale || 100
                to: 400
                text: parseInt(value) + '%'
            }

            Label { color: 'white'; text: qsTr('Fade delay:') }
            TextSlider {
                id: fadeSlider
                Layout.columnSpan: 2
                Layout.fillWidth: true
                from: 1
                value: settings.fadeDelay || 3600
                to: 3600
                text: parseInt(value) + 's'
                textScale: 0.8
            }

            RowLayout {
                Layout.columnSpan: 3
                Layout.fillWidth: true

                CheckBox {
                    id: cbTimestamps
                    checked: settings.showTimestamps || true
                }
                Label {
                    text: qsTr('Show timestamps')
                    color: Material.foreground
                    MouseArea {
                        anchors.fill: parent
                        onClicked: cbTimestamps.checked = !cbTimestamps.checked;
                    }
                }

                Item {
                    Layout.fillWidth: true
                    height: 5
                }

                CheckBox {
                    id: cbAvatars
                    checked: settings.showAvatars || true
                }
                Label {
                    text: qsTr('Show avatars')
                    color: Material.foreground
                    MouseArea {
                        anchors.fill: parent
                        onClicked: cbAvatars.checked = !cbAvatars.checked;
                    }
                }
            }
        }

        StylePreview {
            id: preview

            bgimage: bgimage.text
            overlayopacity: opacitySlider.value * 0.01
            overlayscale: scaleSlider.value * 0.01
            fadetime: fadeSlider.value
            showtimestamps: cbTimestamps.checked
            showavatars: cbAvatars.checked
        }

        DialogButtonBox {
            standardButtons: DialogButtonBox.Save | DialogButtonBox.Cancel
            onRejected: {
                configDialogue.close();
                fieldChannel.text = settings.channel || '';
                fieldClientID.text = settings.clientid || '';
                fieldClientSecret.text = settings.clientsecret || '';
                bgimage.text = settings.bgImage || '';
                notification.text = settings.notifySound || '';
                scaleSlider.value = settings.scale || 100;
                opacitySlider.value = settings.opacity || 100;
                fadeSlider.value = settings.fadeDelay || 3600;
                cbTimestamps.checked = settings.showTimestamps || true;
                cbAvatars.checked = settings.showAvatars || true;

                fieldOwncastHost.text = settings.owncastHost || '';
                fieldOwncastToken.text = settings.owncastToken || '';
            }
            onAccepted: {
                //Overlay.disconnect();
                settings.channel = fieldChannel.text;
                settings.clientid = fieldClientID.text;
                settings.clientsecret = fieldClientSecret.text;
                settings.bgImage = bgimage.text;
                settings.notifySound = notification.text;
                settings.scale = scaleSlider.value;
                settings.opacity = opacitySlider.value;
                settings.fadeDelay = fadeSlider.value;
                settings.showTimestamps = cbTimestamps.checked;
                settings.showAvatars = cbAvatars.checked;

                settings.owncastHost = fieldOwncastHost.text;
                settings.owncastToken = fieldOwncastToken.text;

                if( ( settings.channel.length > 0
                   && settings.clientid.length > 0
                   && settings.clientsecret.length > 0 )
                 || ( settings.owncastHost.length > 0
                   && settings.owncastToken.length > 0 )
                )
                    overlayRect.reconnect();

                configDialogue.close();
            }
        }
    }

    Login {
        id: twitchLogin
    }

    FileDialogueWrapper {
        id: bgDialogue
        title: qsTr("Please choose an image file")
        //fileMode: FileDialog.OpenFile
        nameFilters: [ qsTr("Image files (*.jpg *.png)"), qsTr("All files (*)") ]
        onAccepted: {
            bgimage.text = bgDialogue.selectedFile;
            bgDialogue.close();
        }
        onRejected: {
            bgDialogue.close();
        }
    }

    FileDialogueWrapper {
        id: notifyDialogue
        title: qsTr("Please choose an audio file")
        //fileMode: FileDialog.OpenFile
        nameFilters: [ qsTr("Audio files (*.wav *.mp3)"), qsTr("All files (*)") ]
        onAccepted: {
            notification.text = notifyDialogue.selectedFile;
            notifyDialogue.close();
        }
        onRejected: {
            notifyDialogue.close();
        }
    }

    AboutOAuth2 {
        id: aboutOAuth2
        visible: false
    }

    AboutOwncast {
        id: aboutOwncast
        visible: false
    }
}
