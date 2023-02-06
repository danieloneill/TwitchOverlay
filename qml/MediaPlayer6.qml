import QtQuick
import QtMultimedia

MediaPlayer {
    id: notifySound
    source: mediaSource
    audioOutput: AudioOutput {}
}
