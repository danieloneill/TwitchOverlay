#include <QApplication>
#include <QtWebEngineQuick/qtwebenginequickglobal.h>

#include "overlay.h"
#include "systray.h"
#include "configuredialogue.h"

int main(int argc, char *argv[])
{
    QtWebEngineQuick::initialize();

    QApplication app(argc, argv);
    QCoreApplication::addLibraryPath("lib");

    app.setQuitOnLastWindowClosed(false);

    app.setApplicationName("TwitchOverlay");
    app.setOrganizationName("TwitchOverlay");

    Overlay o(0);
    o.show();

    Systray s;
    QObject::connect( &s, SIGNAL(toggle()), &o, SLOT(toggle()) );
    QObject::connect( &s, SIGNAL(openReposition()), &o, SLOT(reposition()) );

    QObject::connect( &o, SIGNAL(_showMessage(QString)), &s, SLOT(showMessage(QString)) );

    ConfigureDialogue cd(&o);
    QObject::connect( &s, SIGNAL(openConfig()), &cd, SLOT(show()) );

    return app.exec();
}
