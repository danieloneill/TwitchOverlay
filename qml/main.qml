import QtQuick 2.15

Item {
    SystemTray {
        id: systray

        onConfigure: configure.open();
        onReposition: Overlay.reposition();
        onShowHide: Overlay.toggle();
    }

    Configure {
        id: configure
    }
}
