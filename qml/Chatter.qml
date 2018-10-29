import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.0

import Qt.labs.settings 1.0

Item {
    id: chatter

    property variant api
    property int sfontsize: 24
    property alias model: chatModel
    property bool positioning: false

    signal chat(variant message)
    function sendMessage(message, cb) { return api.sendMessage(message, cb); }

    function applySettings(obj)
    {
        sfontsize = obj['chatFontSize'];
    }

    function appendMessage(msg)
    {
        msg['timestamp'] = new Date();
        chatModel.insert(0, msg);
        while( chatModel.count > 20 )
            chatModel.remove(chatModel.count-1, 1);
    }

    function updateAvatar(username, url)
    {
        var cmlen = chatModel.count;
        for( var x=0; x < cmlen; x++ )
        {
            var ent = chatModel.get(x);
            if( ent['username'] == username )
            {
                //ent['avatarUrl'] = url;
                chatModel.setProperty(x, 'avatarUrl', url);
                console.log("Avatar URL updated to: "+url);
            }
        }
    }

    ListView {
        id: chatView
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4
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
            Column {
                x: 4
                y: 4
                width: parent.width
                spacing: 3
                clip: true
                Row {
                    width: parent.width
                    spacing: 6
                    Image {
                        id: avatar
                        height: 40
                        width: 40
                        sourceSize.width: width
                        sourceSize.height: height
                        fillMode: Image.PreserveAspectCrop
                        source: avatarUrl
                    }
                    Column {
                        width: parent.width - avatar.width - 6
                        spacing: -3
                        ToonLabel {
                            width: parent.width
                            text: styledusername
                            color: 'white'
                            font.pointSize: 12
                        }
                        ToonLabel {
                            width: parent.width
                            text: timestamp
                            color: 'white'
                            font.pointSize: 8
                            shadow.radius: 5
                            //shadow.color: '#999900aa'
                        }
                    }
                }
                ToonLabel {
                    text: message
                    width: parent.width
                    color: 'white'
                    font.pointSize: 10
                    shadow.radius: 5
                }
            }
        }
    }

    ListModel { id: chatModel }
    ListModel {
        id: demoModel
        ListElement {
            avatarUrl: 'qrc:/lewl.png'
            styledusername: '<b>Prince</b>'
            timestamp: '1999-12-31T23:59:59.999'
            message: 'This is some test text to simulate chat text that will be visible on your overlay.'
        }
        ListElement {
            avatarUrl: 'qrc:/lewl.png'
            styledusername: '<b>Prince</b>'
            timestamp: '1999-12-31T23:59:59.999'
            message: 'This is some test text to simulate chat text that will be visible on your overlay.'
        }
        ListElement {
            avatarUrl: 'qrc:/lewl.png'
            styledusername: '<b>Prince</b>'
            timestamp: '1999-12-31T23:59:59.999'
            message: 'This is some test text to simulate chat text that will be visible on your overlay.'
        }
        ListElement {
            avatarUrl: 'qrc:/lewl.png'
            styledusername: '<b>Prince</b>'
            timestamp: '1999-12-31T23:59:59.999'
            message: 'This is some test text to simulate chat text that will be visible on your overlay.'
        }
        ListElement {
            avatarUrl: 'qrc:/lewl.png'
            styledusername: '<b>Prince</b>'
            timestamp: '1999-12-31T23:59:59.999'
            message: 'This is some test text to simulate chat text that will be visible on your overlay.'
        }
        ListElement {
            avatarUrl: 'qrc:/lewl.png'
            styledusername: '<b>Prince</b>'
            timestamp: '1999-12-31T23:59:59.999'
            message: 'This is some test text to simulate chat text that will be visible on your overlay.'
        }
        ListElement {
            avatarUrl: 'qrc:/lewl.png'
            styledusername: '<b>Prince</b>'
            timestamp: '1999-12-31T23:59:59.999'
            message: 'This is some test text to simulate chat text that will be visible on your overlay.'
        }
        ListElement {
            avatarUrl: 'qrc:/lewl.png'
            styledusername: '<b>Prince</b>'
            timestamp: '1999-12-31T23:59:59.999'
            message: 'This is some test text to simulate chat text that will be visible on your overlay.'
        }
        ListElement {
            avatarUrl: 'qrc:/lewl.png'
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
            while( chatModel.count > 0 )
            {
                var idx = chatModel.count-1;
                var msg = chatModel.get(idx);
                if( msg['timestamp'].getTime() + 600000 < now.getTime() // 10 minutes
                 || chatModel.count > 20 )
                    chatModel.remove(idx, 1);
                else
                    return;
            }
        }
    }
}
