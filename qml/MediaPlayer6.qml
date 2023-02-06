import QtQuick
import QtMultimedia

MediaPlayer {
    id: notifySound
    required property url mediaSource
    source: mediaSource
    audioOutput: AudioOutput {}
}
