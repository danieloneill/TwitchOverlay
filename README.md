# TwitchOverlay
A Twitch chat overlay for streamers to follow their stream chat while gaming.

![Imgur](https://i.imgur.com/04O4MVD.png)

## Build Requirements

#### This section (and the Instructions section following) are only necessary for those wishing to build TwitchOverlay from source code. If you just want to use it, skip to Configuring.

This application is developed using [Qt](http://www.qt.io/) in C++, QML, and Javascript. The buildsystem is QBS.

You'll need [qml-sockets](https://github.com/jemc/qml-sockets). This allows us to connect to the IRC service on Twitch.

The most convenient way to build both qml-sockets and TwitchOverlay is in Qt Creator itself, which is free to download, as is the open source edition of Qt.

## Build instructions

Once you have qml-sockets built and installed (paying mind to selecting the correct type of build between Debug and Release depending on which type of TwitchOverlay build you intend to make), open TwitchOverlay.qbs in Qt Creator and click Build.

## Configuring

Running the application may present a console for log messages depending on your build type and platform, but the actual program should tuck away politely in your system tray as a ![Imgur](https://i.imgur.com/pk1cmv2.png) icon.

For Windows this system tray is in the bottom right of the taskbar, typically. It may be put into a clutter drawer, requiring you to click an arrow to unhide them.

For Xorg platforms that depends on your desktop. Ubuntu, for example, will place it in the top right, near the status indicators:

![Imgur](https://i.imgur.com/evbY4MC.png)

Right clicking the ![Imgur](https://i.imgur.com/pk1cmv2.png) icon should present you with a menu:

![TwitchOverlay Menu](https://i.imgur.com/CaS6GuJ.png)

From here you can position the chat frame as you please by clicking Reposition and dragging the corners until your heart is content with the cozy burrow in which the frame is nestled.

Clicking the chat window while in Reposition mode will save the position.

The Configuration menu option will open a configuration window to specify a few required parameters:

![Configuration Window](https://i.imgur.com/szQXFp1.png)

Click "Link Twitch" and follow the prompts.

Channel is the Twitch chat you wish to monitor.

## Usage

Any games you play which use a true Fullscreen mode will display over this overlay. Overwatch, for example, offers a "Borderless Windowed" mode which will play nice with this overlay.

