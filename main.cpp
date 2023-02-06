#include <QApplication>

#include "overlay.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QCoreApplication::addLibraryPath("lib");

    app.setQuitOnLastWindowClosed(false);

    app.setApplicationName("TwitchOverlay");
    app.setOrganizationName("TwitchOverlay");

    Overlay o(0);
    o.show();

    return app.exec();
}
