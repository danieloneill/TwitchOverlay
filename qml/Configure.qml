import QtQuick 2.15

Loader {
    source: qVersion.substring(0,2) === '6.' ? 'Configure6.qml' : 'Configure5.qml'
    function open() {
        if( !item )
            return;

        item.open();
    }
}
