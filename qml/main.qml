import QtQuick 2.7

import 'twitch.js' as Twitch

Rectangle {
    id: main
    visible: true
    color: 'transparent'
    Component.onCompleted: {
        chatter.api.hookChat(chatter.appendMessage);
        chatter.api.hookAvatar(chatter.updateAvatar);

        chatter.api.create(chatter);

        // This will (re)connect for us:
        main.resetSettings();
        Twitch.api.refresh();
    }

    Chatter {
        id: chatter
        api: Twitch.api

        height: main.height * 0.6
        width: 240

        onPositioningChanged: {
            if( positioning )
                opacity = 1;
        }
    }

    function resetSettings()
    {
        chatter.x = Overlay.overlayx;
        chatter.y = Overlay.overlayy;
        chatter.width = Overlay.overlayw;
        chatter.height = Overlay.overlayh;

        chatter.bgimage = Overlay.bgImage;
        chatter.opacity = Overlay.opacity * 0.01;
        chatter.overlayscale = Overlay.scale * 0.01;
        chatter.fadeoutdelay = Overlay.fadeDelay;
        chatter.timestampsEnabled = Overlay.showTimestamps;
        chatter.avatarsEnabled = Overlay.showAvatars;

        if( Overlay.username.length > 0 )
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
            chatter.opacity = Overlay.opacity * 0.01;
        }
        onRepositioned: {
            Overlay.overlayx = overlayX;
            Overlay.overlayy = overlayY;
            Overlay.overlayw = overlayW;
            Overlay.overlayh = overlayH;

            chatter.x = Overlay.overlayx;
            chatter.y = Overlay.overlayy;
            chatter.width = Overlay.overlayw;
            chatter.height = Overlay.overlayh;
        }
    }

    Connections {
        target: Overlay
        function onReconnect() {
            resetSettings();
            chatter.api.open();
        }
        function onDisconnect() {
            chatter.api.close();
        }
        function onRepositioning() {
            console.log("Starting to reposition...");
            repositioner.setRect(chatter.x, chatter.y, chatter.width, chatter.height);
            repositioner.visible = true;
            chatter.positioning = true;
        }
        function onLinked() {
            // Reset the 'refresh' timer:
            Twitch.api.updateRefresh(chatter);

            Twitch.api.getUsername();
        }
    }
}
