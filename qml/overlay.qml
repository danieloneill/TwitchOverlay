import QtQuick 2.15

import Qt.labs.settings 1.1

import 'twitch.js' as Twitch
import 'owncast.js' as Owncast

Rectangle {
    id: overlayRect
    visible: true
    color: 'transparent'

    property variant twitchApi: Twitch.getApi();
    property variant owncastApi: Owncast.getApi();

    Component.onCompleted: {
        twitchApi.hookChat(chatter.appendMessage);
        twitchApi.hookChat(chatter.saveLog);
        twitchApi.hookAvatar(chatter.updateAvatar);

        twitchApi.create(chatter);

        owncastApi.hookChat(chatter.appendMessage);
        owncastApi.hookChat(chatter.saveLog);
        owncastApi.create(chatter);

        // This will (re)connect for us:
        overlayRect.resetSettings();
        twitchApi.refresh();

        chatter.restoreLog();
    }

    Settings {
        id: settings
        property real overlayx
        property real overlayy
        property real overlayw
        property real overlayh

        property bool twitchEnabled
        property string username
        property string authkey
        property string refreshtoken
        property int expires
        property string channel
        property string clientid
        property string clientsecret

        property bool owncastEnabled
        property string owncastHost
        property string owncastToken

        property string notifySound
        property string bgImage
        property real opacity
        property real scale
        property int fadeDelay
        property bool showTimestamps
        property bool showAvatars

        property string messages
    }

    SystemTray {
        id: systray

        onConfigure: configure.show();
        onReposition: Overlay.reposition();
        onShowHide: Overlay.toggle();
    }

    Configure {
        id: configure
    }

    Chatter {
        id: chatter

        height: overlayRect.height * 0.6
        width: 240

        onPositioningChanged: {
            if( positioning )
                opacity = 1;
        }
    }

    function resetSettings()
    {
        chatter.x = settings.overlayx || 10;
        chatter.y = settings.overlayy || 10;
        chatter.width = settings.overlayw || 200;
        chatter.height = settings.overlayh || 200;

        chatter.bgimage = settings.bgImage || '';
        chatter.opacity = settings.opacity * 0.01 || 1;
        chatter.overlayscale = settings.scale * 0.01 || 1;
        chatter.fadeoutdelay = settings.fadeDelay || 2000;
        chatter.timestampsEnabled = settings.showTimestamps || true;
        chatter.avatarsEnabled = settings.showAvatars || true;

        twitchApi.open();
        owncastApi.open();
    }

    Repositioner {
        id: repositioner
        anchors.fill: parent
        visible: false
        onSaved: {
            visible = false;
            chatter.positioning = false;
            Overlay.donePositioning();
            console.log("Done repositioning.");
            chatter.opacity = settings.opacity * 0.01;
        }
        onRepositioned: function(x, y, w, h) {
            settings.overlayx = x;
            settings.overlayy = y;
            settings.overlayw = w;
            settings.overlayh = h;

            chatter.x = settings.overlayx;
            chatter.y = settings.overlayy;
            chatter.width = settings.overlayw;
            chatter.height = settings.overlayh;
        }
    }

    Connections {
        target: Overlay
        function onRepositioning() {
            console.log("Starting to reposition...");
            repositioner.setRect(chatter.x, chatter.y, chatter.width, chatter.height);
            repositioner.visible = true;
            chatter.positioning = true;
        }
    }

    function reconnect() {
        resetSettings();
        twitchApi.open();
        owncastApi.open();
    }

    function linked() {
        // Reset the 'refresh' timer:
        twitchApi.updateRefresh(chatter);
        twitchApi.getUsername();
    }
}
