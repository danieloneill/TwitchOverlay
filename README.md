# TwitchOverlay
A Twitch chat overlay for streamers to follow their stream chat while gaming.

![Imgur](https://i.imgur.com/04O4MVD.png)

## Build Requirements

#### This section (and the Instructions section following) are only necessary for those wishing to build TwitchOverlay from source code. If you just want to use it, skip to Configuring.

This application is developed using [Qt](http://www.qt.io/) in C++, QML, and Javascript. The buildsystem is QBS.

The most convenient way to build TwitchOverlay is in [Qt Creator](https://www.qt.io/qt-features-libraries-apis-tools-and-ide/#ide) itself, which is free to download, as is the open source edition of Qt.

## Build instructions

Assuming you have your Qt Creator build environment properly configured, open TwitchOverlay.qbs in Qt Creator and click Build.

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

![Configuration Window](https://i.imgur.com/M876OVA.png)

 - **Link Twitch** will link TwitchOverlay to your account. Simply click the button and follow the prompts.
 - **Channel** is the Twitch chat you wish to monitor. This is typically simply the Twitch username of the streamer. *(Note: the capitalization matters. Even if their username appears in chat with different capitalization, this must be set to the actual username. This can be found in the browser Address Bar when on their channel.)*
 - **Backdrop** is the path to an image file to use as the chat backdrop. If blank, the widget will be entirely translucent besides the text itself.
 - **Notification Sound** is the path to an audio clip to play to signify chat activity. If blank, no sound will be played.
 - **Opacity** will modify the overlay opacity.
 - **Scale** scales the chat up or down between 1% and 400%
 - **Fade delay** allows you to specify how long messages appear, in seconds, before they fade out.
 - **Show timestamps** shows or hides timestamps in the chat message headers.
 - **Show avatars** shows or hides avatars in chat message headers.

It may be worth noting that the Preview in the configuration section is displayed at 66% scale. Pay this in mind with respect to the **Scale** slider setting.

## Usage

Any games you play which use a true Fullscreen mode will display over this overlay. Overwatch, for example, offers a "Borderless Windowed" mode which will play nice with this overlay.

