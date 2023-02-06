import QtQuick 2.15

import Qt.labs.settings 1.1

import 'twitch.js' as Twitch

Rectangle {
    id: overlayRect
    visible: true
    color: 'transparent'

    property variant api: Twitch.getApi();

    Component.onCompleted: {
        chatter.api.hookChat(chatter.appendMessage);
        chatter.api.hookAvatar(chatter.updateAvatar);

        chatter.api.create(chatter);

        // This will (re)connect for us:
        overlayRect.resetSettings();
        overlayRect.api.refresh();
    }

    Settings {
        id: settings
        property real overlayx
        property real overlayy
        property real overlayw
        property real overlayh

        property string username
        property string authkey
        property string refreshtoken
        property int expires
        property string channel
        property string clientid
        property string clientsecret

        property string notifySound
        property string bgImage
        property real opacity
        property real scale
        property int fadeDelay
        property bool showTimestamps
        property bool showAvatars
    }

    SystemTray {
        id: systray

        onConfigure: configure.open();
        onReposition: Overlay.reposition();
        onShowHide: Overlay.toggle();
    }

    Configure {
        id: configure
    }

    Chatter {
        id: chatter
        api: overlayRect.api

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

        if( settings.username.length > 0 )
            chatter.api.open();
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
        chatter.api.open();
    }

    function linked() {
        // Reset the 'refresh' timer:
        overlayRect.api.updateRefresh(chatter);
        overlayRect.api.getUsername();
    }
}
