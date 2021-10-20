QT += quick widgets quickwidgets webenginequick
CONFIG += c++17

SOURCES += main.cpp \
        #networkaccessmanager.cpp \
        #networkaccessmanagerfactory.cpp \
	overlay.cpp \
	systray.cpp \
	configuredialogue.cpp

HEADERS += overlay.h \
        #networkaccessmanager.h \
        #networkaccessmanagerfactory.h \
	systray.h \
	configuredialogue.h

QMAKE_CXXFLAGS += -pg
QMAKE_LFLAGS += -pg

RESOURCES += qml.qrc

DISTFILES += qml/skeleton.qml \
	qml/AboutOAuth2.qml \
	qml/Chatter.qml \
	qml/Handle.qml \
	qml/Repositioner.qml \
	qml/StylePreview.qml \
	qml/TextSlider.qml \
	qml/ToonLabel.qml \
	qml/TwitchLogin.qml \
	qml/configure.qml \
	qml/dragtest.qml \
	qml/main.qml \
	qml/twitch.js
