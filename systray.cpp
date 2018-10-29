#include <QApplication>
#include <QDebug>

#include "systray.h"

Systray::Systray(QObject *parent) : QObject(parent)
{
    m_menu = new QMenu();
    QAction *a_toggle = m_menu->addAction(tr("&Show/Hide"));
    m_menu->addSeparator();
    QAction *a_reposition = m_menu->addAction(tr("&Reposition..."));
    QAction *a_configure = m_menu->addAction(tr("&Configuration..."));
    m_menu->addSeparator();
    QAction *a_exit = m_menu->addAction(tr("&E&xit"));

    QObject::connect( a_configure, SIGNAL(triggered()), this, SIGNAL(openConfig()) );
    QObject::connect( a_reposition, SIGNAL(triggered()), this, SIGNAL(openReposition()) );
    QObject::connect( a_toggle, SIGNAL(triggered()), this, SIGNAL(toggle()) );
    QObject::connect( a_exit, SIGNAL(triggered()), this, SLOT(exit()) );

    m_systray.setContextMenu(m_menu);

    QIcon icon(":/lewl.png");
    m_systray.setIcon(icon);
    m_systray.setVisible(true);
}

Systray::~Systray()
{
    m_menu->deleteLater();
}

void Systray::exit()
{
    qDebug() << "Exiting...";
    QApplication::exit(0);
}
