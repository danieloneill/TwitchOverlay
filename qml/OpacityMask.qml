import QtQuick 2.15

Item {
    id: opacityMaskWrapper
    property Item source
    property Item maskSource

    Loader {
        id: loader
        anchors.fill: parent
        source: qVersion.substring(0,2) === '6.' ? 'OpacityMask6.qml' : 'OpacityMask5.qml'

        onLoaded: {
            if( !item )
                return;

            item.source = opacityMaskWrapper.source;
            item.maskSource = opacityMaskWrapper.maskSource;
        }
    }

    onSourceChanged: {
        if( !loader.item )
            return;

        loader.item.source = opacityMaskWrapper.source;
    }

    onMaskSourceChanged: {
        if( !loader.item )
            return;

        loader.item.maskSource = opacityMaskWrapper.maskSource;
    }
}
