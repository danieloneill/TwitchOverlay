QT += quick widgets quickwidgets webenginewidgets multimedia
QT -= printsupport

CONFIG += c++17

SOURCES += main.cpp \
	authwindow.cpp \
	overlay.cpp

HEADERS += overlay.h \
	authwindow.h

RESOURCES += qml.qrc

DISTFILES += qml/skeleton.qml \
	qml/AboutOAuth2.qml \
	qml/Chatter.qml \
        qml/Configure.qml \
        qml/Configure5.qml \
        qml/Configure6.qml \
        qml/DropShadow.qml \
        qml/DropShadow5.qml \
        qml/DropShadow6.qml \
	qml/FileDialogueWrapper.qml \
	qml/Handle.qml \
	qml/Login.qml \
        qml/MediaPlayer.qml \
        qml/MediaPlayer5.qml \
        qml/MediaPlayer6.qml \
        qml/MediaPlayerStub.qml \
        qml/OpacityMask.qml \
        qml/OpacityMask5.qml \
        qml/OpacityMask6.qml \
	qml/Repositioner.qml \
	qml/StylePreview.qml \
	qml/TextSlider.qml \
	qml/ToonLabel.qml \
	qml/TwitchLogin.qml \
        qml/overlay.qml \
	qml/twitch.js
