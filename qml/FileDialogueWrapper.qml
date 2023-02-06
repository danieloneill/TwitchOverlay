import QtQuick 2.15
import Qt.labs.platform 1.1

Item {
    id: dialogueWindow
    width: 600
    height: 400

    property alias fileMode: dialogue.fileMode
    property alias nameFilters: dialogue.nameFilters
    property alias selectedFile: dialogue.file
    property alias title: dialogue.title

    signal accepted();
    signal rejected();

    onRejected: close();
    onAccepted: close();

    // NOTE: This is a workaround for a jank Dialog implementation in Qt 6.x
    // On Windows, an MFC dialog is produced below.
    // On Linux, it's placed inside the parent, but like a .. transient modal.
    //function open() { if( Qt.platform.os == 'windows' ) { dialogue.open(); } else { show(); } }
    function open() { dialogue.open(); }
    function close() { dialogue.close(); }

    FileDialog {
        id: dialogue

        title: dialogueWindow.title

        onAccepted: dialogueWindow.accepted();
        onRejected: dialogueWindow.rejected();
    }
}
