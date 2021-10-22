import QtQuick
import QtQuick.Dialogs

Window {
    id: dialogueWindow
    width: 600
    height: 400

    flags: Qt.Dialog
    maximumHeight: height
    maximumWidth: width
    minimumHeight: height
    minimumWidth: width

    property alias fileMode: dialogue.fileMode
    property alias nameFilters: dialogue.nameFilters
    property alias selectedFile: dialogue.selectedFile

    signal accepted();
    signal rejected();

    onRejected: close();
    onAccepted: close();

    // NOTE: This is a workaround for a jank Dialog implementation in Qt 6.x
    // On Windows, an MFC dialog is produced below.
    // On Linux, it's placed inside the parent, but like a .. transient modal.
    function open() { if( Qt.platform.os == 'windows' ) { dialogue.open(); } else { show(); } }

    FileDialog {
        id: dialogue

        title: dialogueWindow.title

        visible: dialogueWindow.visible

        onAccepted: dialogueWindow.accepted();
        onRejected: dialogueWindow.rejected();
    }
}
