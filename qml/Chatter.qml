import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: chatter

    property int sfontsize: 24
    property alias model: chatModel
    property bool positioning: false

    property string bgimage: ''
    property bool timestampsEnabled: true
    property bool avatarsEnabled: true
    property int fadeoutdelay: 600
    property real overlayscale: 1.0

    signal chat(variant message)

    onWidthChanged: scrollDown();
    onHeightChanged: scrollDown();

    function applySettings(obj)
    {
        sfontsize = obj['chatFontSize'];
    }

    function scrollDown()
    {
        chatView.positionViewAtBeginning();
    }

    function appendMessage(msg)
    {
        msg['timestamp'] = new Date();
        chatModel.insert(0, msg);
        while( chatModel.count > 20 )
            chatModel.remove(chatModel.count-1, 1);

        notifySound.play();
    }

    function updateAvatar(username, url)
    {
        const cmlen = chatModel.count;
        for( let x=0; x < cmlen; x++ )
        {
            const ent = chatModel.get(x);
            if( ent['username'] === username )
                chatModel.setProperty(x, 'avatarUrl', url);
        }
    }

    function saveLog()
    {
        let messages = [];
        const cmlen = chatModel.count;
        for( let x=0; x < cmlen; x++ )
        {
            let ent = chatModel.get(x);
            // TODO Update 'timestamp' before store to relative time.
            messages.unshift(ent);
        }
        settings.messages = JSON.stringify(messages);
    }

    function restoreLog()
    {
        try {
            const mlog = JSON.parse(settings.messages);
            if( !(mlog instanceof Array) )
                return;

            mlog.forEach( m => appendMessage(m) );
        } catch(err) {
            console.log("Chatter: Couldn't restore old messages. Oh well.");
        }
    }

    MediaPlayer {
        id: notifySound
        source: settings.notifySound
    }

    Item {
        width: parent.width
        height: parent.height
        clip: true
        Image {
            id: bgImage
            // This image is at 66% scale, so also scale Chatter down.
            visible: chatter.bgimage.length > 0
            source: chatter.bgimage
            fillMode: Image.PreserveAspectCrop
            scale: overlayscale
            transformOrigin: Item.TopLeft
            x: 0
            y: 0
        }
    }

    ListView {
        id: chatView
        anchors.fill: parent
        anchors.margins: 4 * overlayscale
        spacing: 4 * overlayscale
        verticalLayoutDirection: ListView.BottomToTop

        clip: true

        addDisplaced: Transition {
            SmoothedAnimation { properties: "x,y"; duration: 250 }
        }
        removeDisplaced: Transition {
            SmoothedAnimation { properties: "x,y"; duration: 250 }
        }
        add: Transition {
            ParallelAnimation {
                SmoothedAnimation { properties: "y"; duration: 250; from: height }
                PropertyAction { properties: "opacity"; value: 1 }
            }
        }
        remove: Transition {
            PropertyAnimation { properties: "opacity"; duration: 250; to: 0; from: 1 }
        }

        model: chatter.positioning ? demoModel : chatModel
        delegate: Item {
            width: chatView.width
            height: childrenRect.height + 8
            clip: true
            /*
            color: 'transparent'
            border.width: 1
            border.color: '#88000000'
            radius: 8
*/

            Item {
                id: avatar
                anchors {
                    top: parent.top
                    left: parent.left
                }

                visible: chatter.avatarsEnabled && avatarUrl && avatarUrl.length > 0
                height: 40 * overlayscale
                width: 40 * overlayscale
                Image {
                    id: sourceImage
                    visible: false
                    height: parent.height
                    width: parent.width
                    sourceSize.width: width
                    sourceSize.height: height
                    fillMode: Image.PreserveAspectCrop
                    source: avatarUrl
                }
                Rectangle {
                    id: mask
                    visible: false
                    height: parent.height
                    width: parent.height
                    color: 'black'
                    radius: 10
                }
                OpacityMask {
                    maskSource: mask
                    source: sourceImage
                    height: parent.height
                    width: parent.height
                }
            }

            Image {
                id: facilityImage
                anchors {
                    top: parent.top
                    left: avatar.visible ? avatar.right : parent.left
                    leftMargin: 5 * overlayscale
                    //topMargin: 5 * overlayscale
                }

                height: 16 * overlayscale
                width: 16 * overlayscale
                sourceSize.height: height
                sourceSize.width: width
                source: facility === 'twitch' ? 'qrc:/twitch.png' : 'qrc:/owncast.png'
            }

            ToonLabel {
                anchors {
                    top: parent.top
                    left: facilityImage.right
                    leftMargin: 5 * overlayscale
                    //topMargin: 5 * overlayscale
                }

                text: timestamp
                color: 'white'
                font.pointSize: 7 * overlayscale
                //shadow.radius: 5
                //shadow.color: '#999900aa'
                visible: chatter.timestampsEnabled
            }

            ToonLabel {
                id: authorLabel
                anchors {
                    top: facilityImage.bottom
                    left: avatar.visible ? avatar.right : parent.left
                    leftMargin: 5 * overlayscale
                    //topMargin: 5 * overlayscale
                }

                text: type === 'chat' ? styledusername : message
                color: 'white'
                font.pointSize: 10 * overlayscale
            }

            ToonLabel {
                id: messageLabel
                anchors {
                    top: authorLabel.bottom
                    topMargin: 3 * overlayscale
                    left: parent.left
                    leftMargin: 5 * overlayscale
                    right: parent.right
                    rightMargin: 5 * overlayscale
                }

                visible: type === 'chat'
                text: message
                color: 'white'
                font.pointSize: 10 * overlayscale
                //shadow.radius: 5
            }
        }

        onModelChanged: scrollDown();
    }
/*
    Timer {
        property int idx: 1
        interval: 2000
        onTriggered: {
            var msg = { 'username':'TestUser', 'avatarUrl':'qrc:/lewl.png', 'styledusername':'<b>Prince</b>', 'message':'This is message #'+idx+' in the testing phase.' };
            idx++;
            appendMessage(msg);
        }
        running: true
        repeat: true
    }
*/
    ListModel { id: chatModel }
    ListModel {
        id: demoModel
        ListElement {
            type: 'chat'
            facility: 'twitch'
            avatarUrl: '../lewl.png'
            styledusername: '<b>Prince</b>'
            timestamp: '1999-12-31T23:59:59.999'
            message: 'This is some test text to simulate chat text that will be visible on your overlay.'
        }
        ListElement {
            type: 'chat'
            facility: 'twitch'
            avatarUrl: '../lewl.png'
            styledusername: '<b>Prince</b>'
            timestamp: '1999-12-31T23:59:59.999'
            message: 'This is some test text to simulate chat text that will be visible on your overlay.'
        }
        ListElement {
            type: 'chat'
            facility: 'twitch'
            avatarUrl: '../lewl.png'
            styledusername: '<b>Prince</b>'
            timestamp: '1999-12-31T23:59:59.999'
            message: 'This is some test text to simulate chat text that will be visible on your overlay.'
        }
        ListElement {
            type: 'chat'
            facility: 'twitch'
            avatarUrl: '../lewl.png'
            styledusername: '<b>Prince</b>'
            timestamp: '1999-12-31T23:59:59.999'
            message: 'This is some test text to simulate chat text that will be visible on your overlay.'
        }
        ListElement {
            type: 'chat'
            facility: 'twitch'
            avatarUrl: '../lewl.png'
            styledusername: '<b>Prince</b>'
            timestamp: '1999-12-31T23:59:59.999'
            message: 'This is some test text to simulate chat text that will be visible on your overlay.'
        }
        ListElement {
            type: 'chat'
            facility: 'twitch'
            avatarUrl: '../lewl.png'
            styledusername: '<b>Prince</b>'
            timestamp: '1999-12-31T23:59:59.999'
            message: 'This is some test text to simulate chat text that will be visible on your overlay.'
        }
        ListElement {
            type: 'chat'
            facility: 'twitch'
            avatarUrl: '../lewl.png'
            styledusername: '<b>Prince</b>'
            timestamp: '1999-12-31T23:59:59.999'
            message: 'This is some test text to simulate chat text that will be visible on your overlay.'
        }
        ListElement {
            type: 'chat'
            facility: 'twitch'
            avatarUrl: '../lewl.png'
            styledusername: '<b>Prince</b>'
            timestamp: '1999-12-31T23:59:59.999'
            message: 'This is some test text to simulate chat text that will be visible on your overlay.'
        }
        ListElement {
            type: 'chat'
            facility: 'twitch'
            avatarUrl: '../lewl.png'
            styledusername: '<b>Prince</b>'
            timestamp: '1999-12-31T23:59:59.999'
            message: 'This is some test text to simulate chat text that will be visible on your overlay.'
        }
    }

    // Only for layering over content, to auto-expire the chat:
    Timer {
        id: chatRemover
        repeat: true
        interval: 5000
        running: true
        onTriggered: {
            var now = new Date();
            for( var j=0; j < chatModel.count; j++ )
            {
                var idx = chatModel.count-1;
                var msg = chatModel.get(idx);
                if( msg['timestamp'].getTime() + (chatter.fadeoutdelay * 1000) < now.getTime()
                 || chatModel.count > 20 )
                    chatModel.remove(idx, 1);
            }
        }
    }
}
