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

    function open() { show(); }

    FileDialog {
        id: dialogue

        title: dialogueWindow.title

        visible: dialogueWindow.visible

        onAccepted: dialogueWindow.accepted();
        onRejected: dialogueWindow.rejected();
    }
}
