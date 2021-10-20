#ifndef SYSTRAY_H
#define SYSTRAY_H

#include <QObject>
#include <QWidget>
#include <QIcon>
#include <QAction>
#include <QMenu>
#include <QSystemTrayIcon>

class Systray : public QObject
{
    Q_OBJECT

    QSystemTrayIcon m_systray;
    QMenu           *m_menu;

public:
    explicit Systray(QObject *parent = nullptr);
    ~Systray();

signals:
    void openConfig();
    void openReposition();
    void toggle();

public slots:
    void showMessage(const QString &message);
    void exit();
};

#endif // SYSTRAY_H
