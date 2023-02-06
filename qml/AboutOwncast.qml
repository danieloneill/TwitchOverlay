import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    title: qsTr('Setting Up Owncast')

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
        text: qsTr('Owncast')
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
        text: qsTr(`<p>Owncast is very simple to get set up!</p><p>Visit your Owncast Admin page and navigate to <b>Integrations</b> - <b>Access Tokens</b> and create a token with the name of your choice.</p><p>Put the address to your Owncast stream in the <i>Owncast Host</i> field, and your newly generated token in the <i>Access Token</i> field.</p>`)
        onLinkActivated: function(url)
        {
            Qt.openUrlExternally(url);
        }
    }
}
