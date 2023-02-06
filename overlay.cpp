#include "authwindow.h"
#include "overlay.h"

#include <QApplication>
#include <QDebug>
#include <QMediaPlayer>
#include <QPainter>
#include <QPaintEvent>
#include <QScreen>
#include <QQmlEngine>
#include <QQmlContext>

/* Based on: https://github.com/trishume/transience
 * by Tristan Hume
 * https://github.com/trishume
 */

Overlay::Overlay(int screen)
    : QWidget(0, Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint ),
      m_screen{screen},
      m_multimediaSupported{true}
{
#ifndef Q_OS_WINDOWS
    setWindowFlag(Qt::X11BypassWindowManagerHint);
#endif
    setWindowFlag( Qt::ToolTip );

#ifdef TEST_MULTIMEDIA
    testForMultimedia();
#endif

    //platformSpecificSetup(); // NOTE: For OSX (see https://github.com/trishume/transience/blob/master/osxhacks.mm)

    QScreen *srn = QApplication::screens().at(screen);
    m_screenRect = srn->geometry();
    fillScreen();

    m_view = new QQuickWidget(this);
    m_view->engine()->rootContext()->setContextProperty("Overlay", this);
    m_view->engine()->rootContext()->setContextProperty("qVersion", QString::fromLocal8Bit(qVersion()));
    connect( m_view->engine(), &QQmlEngine::quit, this, [this](){
        m_view->deleteLater();
        qApp->quit();
    } );

    qmlRegisterType<AuthWindow>("com.oneill.AuthWindow", 1, 0, "AuthWindow");

    m_view->setResizeMode(QQuickWidget::SizeRootObjectToView);
    m_view->setSource(QUrl(QStringLiteral("qrc:/qml/overlay.qml")));

    m_view->show();

    donePositioning();
}

Overlay::~Overlay()
{
    repaint();

    m_view->deleteLater();
}

void Overlay::fillScreen() {
    move(m_screenRect.x(), m_screenRect.y());
    resize(m_screenRect.width(), m_screenRect.height());
}

void Overlay::reposition()
{
    if( m_positioning )
    {
        donePositioning();
        return;
    }

    qDebug() << "Preparing Overlay to reposition!";
    //m_position = QRect( overlayX(), overlayY(), overlayW(), overlayH() );
    m_positioning = true;

    setStyleSheet("background:white;");

    // Undo our "no focus" policy:
    //m_view->setFocusPolicy(Qt::StrongFocus);
    m_view->setAttribute( Qt::WA_TransparentForMouseEvents, false );
    //m_view->setAttribute( Qt::WA_TranslucentBackground, false );
    //m_view->setClearColor(Qt::white);
    m_view->setWindowFlag( Qt::WindowTransparentForInput, false );
    //m_view->setWindowFlag( Qt::WindowDoesNotAcceptFocus, false );
    //m_view->setStyleSheet("background:white;");

    //setWindowFlag( Qt::WindowDoesNotAcceptFocus, false );
    setWindowFlag( Qt::WindowTransparentForInput, false );

    //setAttribute(Qt::WA_TranslucentBackground, false);
    setAttribute(Qt::WA_ShowWithoutActivating, false);

    show();
    //activateWindow();
    //SetForegroundWindow((HWND)this->winId());
    //m_view->activateWindow();
    //m_view->setFocus();

    emit repositioning();
}

void Overlay::donePositioning()
{
    m_positioning = false;
    qDebug() << "Done positioning, resetting window flags!";

    setStyleSheet("background:transparent;");

    // Redo our "no focus" policy:
    m_view->setFocusPolicy(Qt::NoFocus);
    m_view->setAttribute( Qt::WA_TransparentForMouseEvents, true );
    m_view->setAttribute( Qt::WA_TranslucentBackground, true );
    m_view->setClearColor(Qt::transparent);
    m_view->setWindowFlag( Qt::WindowTransparentForInput, true );
    m_view->setWindowFlag( Qt::WindowDoesNotAcceptFocus, true );
    m_view->setStyleSheet("background:transparent;");

    setWindowFlag( Qt::WindowDoesNotAcceptFocus, true );
    setWindowFlag( Qt::WindowTransparentForInput, true );

    setAttribute(Qt::WA_TranslucentBackground, true);
    setAttribute(Qt::WA_ShowWithoutActivating, true);

    show();
}

void Overlay::toggle()
{
    qDebug() << "Toggling visibility to " << !isVisible();
    setVisible( !isVisible() );
}

void Overlay::paintEvent(QPaintEvent *ev) {
    if( !m_positioning )
        return;

    QPainter painter(this);

    // Filling with transparent doesn't clear the screen with normal overlay logic :P
    painter.setCompositionMode (QPainter::CompositionMode_Source);
    painter.fillRect(ev->rect(), Qt::transparent);
    painter.setCompositionMode (QPainter::CompositionMode_SourceOver);

    painter.fillRect(ev->rect(), QColor(0,255,0,50));
}

void Overlay::resizeEvent(QResizeEvent *ev)
{
    m_view->resize( ev->size() );
}

#include <signal.h>
#include <setjmp.h>
Overlay *__o;

jmp_buf env;

void on_sigabrt(int signum)
{
  signal(signum, SIG_DFL);
  __o->m_multimediaSupported = false;
  longjmp(env, 1);
}

void try_and_catch_abort()
{
    __o->m_multimediaSupported = true;
    if(setjmp(env) == 0) {
      signal(SIGABRT, &on_sigabrt);
      QMediaPlayer p;
      signal(SIGABRT, SIG_DFL);
    } else
        __o->m_multimediaSupported = false;
}

void Overlay::testForMultimedia()
{
    printf("Testing for Multimedia...\n");
    __o = this;

    try_and_catch_abort();

    printf("Multimedia: %s\n", m_multimediaSupported ? "true" : "false");
}
