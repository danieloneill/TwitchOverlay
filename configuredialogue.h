#ifndef CONFIGUREDIALOGUE_H
#define CONFIGUREDIALOGUE_H

#include <QObject>
#include <QQuickView>

class Overlay;
class ConfigureDialogue : public QQuickView
{
    Q_OBJECT

    Overlay     *m_overlay;

public:
    explicit ConfigureDialogue(Overlay *o);

signals:
    void shown();

public slots:
};

#endif // CONFIGUREDIALOGUE_H
