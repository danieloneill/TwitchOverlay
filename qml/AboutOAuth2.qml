import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    title: qsTr('About Twitch + OAuth2')

    width: 400
    height: 360

    Text {
        id: topLabel
        anchors {
            left: parent.left
            top: parent.top
            margins: 10
        }

        font.pointSize: 24
        text: qsTr('How To Register')
    }

    Text {
        anchors {
            left: parent.left
            top: topLabel.bottom
            right: parent.right
            bottom: parent.bottom
            margins: 10
        }

        textFormat: Text.RichText
        wrapMode: Text.WordWrap
        text: qsTr('Twitch uses OAuth2 to authenticate users logging in through an app, but this requires the app to have a public endpoint on the web somewhere.<p>Since I don\'t have/want to host publically, this app "pretends" to be its own endpoint.<p>You\'ll need to register it at <a href="https://dev.twitch.tv/console/apps/create">https://dev.twitch.tv/console/apps/create</a> and add <b>https://twitchoverlay.invalid</b> to the </i>OAuth Redirect URLs</i>.<p>Once done, you need the <i>client id</i> and <i>client secret</i> and place them in their spots on the Configuration screen.<p>Click <b>Save</b> and re-open the configuration, and now you can link your Twitch account.')
        onLinkActivated: function(url)
        {
            Qt.openUrlExternally(url);
        }
    }
}
