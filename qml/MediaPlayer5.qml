import QtQuick 2.15
import QtMultimedia 5.15

MediaPlayer {
    id: notifySound
    //required property url mediaSource
    source: mediaSource
    autoLoad: true
    audioRole: MediaPlayer.NotificationRole
}
