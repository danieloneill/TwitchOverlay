import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3 as Dialogue

Dialogue.Dialog {
    id: configDialogue
    height: mainContainer.implicitHeight + 20
    width: mainContainer.implicitWidth + 20

    standardButtons: Dialogue.StandardButton.Save | Dialogue.StandardButton.Cancel

    ColumnLayout {
        id: mainContainer
        anchors.centerIn: parent

        spacing: 5
        GridLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            columns: 3
            rowSpacing: 5
            columnSpacing: 5

            Button { id: fieldLink; text: 'Link Twitch'; Layout.fillWidth: true; Layout.columnSpan: 3; onClicked: { twitchLogin.spawn(); } }

            Label { text: qsTr('Channel:'); }
            TextField { id: fieldChannel; text: settings.channel || ''; Layout.fillWidth: true; Layout.columnSpan: 2 }

            Label { text: qsTr('Client ID:'); }
            TextField { id: fieldClientID; text: settings.clientid || ''; Layout.fillWidth: true }
            Text { Layout.preferredWidth: implicitHeight; color: 'blue'; text: '(?)'; MouseArea { anchors.fill: parent; onClicked: aboutOAuth2.show(); } }

            Label { text: qsTr('Client Secret:'); }
            TextField { id: fieldClientSecret; text: settings.clientsecret || ''; Layout.fillWidth: true }
            Text { Layout.preferredWidth: implicitHeight; color: 'blue'; text: '(?)'; MouseArea { anchors.fill: parent; onClicked: aboutOAuth2.show(); } }

            Label { text: qsTr('Backdrop:'); }
            TextField { id: bgimage; text: settings.bgImage || ''; Layout.fillWidth: true }
            Button { text: qsTr('Select...'); onClicked: { bgDialogue.open(); } }

            Label { text: qsTr('Notification Sound:'); }
            TextField { id: notification; text: settings.notifySound || ''; Layout.fillWidth: true }
            Button { text: qsTr('Select...'); onClicked: { notifyDialogue.open(); notifyDialogue.visible=true; } }

            Label { text: qsTr('Opacity:') }
            TextSlider {
                id: opacitySlider
                Layout.columnSpan: 2
                Layout.fillWidth: true
                from: 0
                value: settings.opacity || 100
                to: 100
                text: parseInt(value) + '%'
            }

            Label { text: qsTr('Scale:') }
            TextSlider {
                id: scaleSlider
                Layout.columnSpan: 2
                Layout.fillWidth: true
                from: 1
                value: settings.scale || 100
                to: 400
                text: parseInt(value) + '%'
            }

            Label { text: qsTr('Fade delay:') }
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

            CheckBox {
                id: cbTimestamps
                text: qsTr('Show timestamps')
                Layout.columnSpan: 2
                Layout.fillWidth: true
                checked: settings.showTimestamps || true
            }
            CheckBox {
                id: cbAvatars
                text: qsTr('Show avatars')
                Layout.fillWidth: true
                checked: settings.showAvatars || true
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
    }

    onRejected: configDialogue.close();
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

        if( settings.channel.length > 0 && settings.clientid.length > 0 && settings.clientsecret.length > 0 )
            overlayRect.reconnect();

        configDialogue.close();
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
}
