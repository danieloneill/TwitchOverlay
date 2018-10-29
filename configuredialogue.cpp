#include "configuredialogue.h"
#include "overlay.h"

#include <QQmlContext>

ConfigureDialogue::ConfigureDialogue(Overlay *o) : QQuickView()
{
    m_overlay = o;

    rootContext()->setContextProperty("Dialogue", this);
    rootContext()->setContextProperty("Overlay", m_overlay);
    setSource(QUrl(QStringLiteral("qrc:/qml/configure.qml")));
}
