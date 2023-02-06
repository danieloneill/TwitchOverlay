import QtQuick 2.15

Item {
    property alias source: loader.mediaSource
    function play() {
        if( !loader.item )
            return;

        loader.item.play();
    }

    Loader {
        id: loader
        property url mediaSource
        source: Overlay.multimediaSupported() ? ( qVersion.substring(0,2) === '6.' ? 'MediaPlayer6.qml' : 'MediaPlayer5.qml' ) : 'MediaPlayerStub.qml'
    }
}
