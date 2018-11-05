import QtQuick 2.7

Item {
    id: preview
    implicitHeight: previewImage.implicitHeight
    implicitWidth: previewImage.implicitWidth
    clip: true

    property string bgimage: ''
    property real overlayopacity: 1.0
    property real overlayscale: 1.0
    property int fadetime: 600
    property bool showtimestamps: true
    property bool showavatars: true
    /* TODO:
      Background image
      Text opacity
      Scaling of chatter
      Sound notification on message
      Fadeout delay configuration
      Enable/disable timestamps
      */


    Image {
        id: previewImage
        // This image is at 66% scale, so also scale Chatter down.
        source: '../previewbg.png'
        fillMode: Image.PreserveAspectFit
    }

    Chatter {
        id: chatter

        x: 20
        y: 20
        height: parent.height * 0.8
        width: parent.width * 0.8

        bgimage: preview.bgimage
        opacity: preview.overlayopacity
        overlayscale: 0.66 * preview.overlayscale
        fadeoutdelay: preview.fadetime
        timestampsEnabled: preview.showtimestamps
        avatarsEnabled: preview.showavatars

        positioning: true
    }
}
