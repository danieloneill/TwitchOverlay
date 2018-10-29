#include "overlay.h"

#include <QApplication>
#include <QDebug>
#include <QPainter>
#include <QPaintEvent>
#include <QScreen>
#include <QQmlEngine>
#include <QQmlContext>

/* Based on: https://github.com/trishume/transience
 * by Tristan Hume
 * https://github.com/trishume
 */

Overlay::Overlay(int screen) : QWidget(0, Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint ), m_screen(screen)
{
#ifndef Q_OS_WINDOWS
    setWindowFlag(Qt::X11BypassWindowManagerHint);
#endif
    setWindowFlag( Qt::ToolTip );

    //platformSpecificSetup(); // NOTE: For OSX (see https://github.com/trishume/transience/blob/master/osxhacks.mm)

    QScreen *srn = QApplication::screens().at(screen);
    m_screenRect = srn->geometry();
    fillScreen();

    m_settings = new QSettings("TwitchOverlay", "TwitchOverlay", this);

    m_view = new QQuickWidget(this);
    m_view->engine()->rootContext()->setContextProperty("Overlay", this);

    m_view->setResizeMode(QQuickWidget::SizeRootObjectToView);
    m_view->setSource(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    donePositioning();
}

Overlay::~Overlay()
{
    repaint();

    m_view->deleteLater();

    m_settings->deleteLater();
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

// property getters:
qreal Overlay::overlayX()
{
    return m_settings->value("x", 0).toReal();
}

qreal Overlay::overlayY()
{
    return m_settings->value("y", 0).toReal();
}

qreal Overlay::overlayW()
{
    return m_settings->value("width", 240).toReal();
}

qreal Overlay::overlayH()
{
    return m_settings->value("height", 648).toReal();
}

QString Overlay::username()
{
    return m_settings->value("username").toString();
}

QString Overlay::authkey()
{
    return m_settings->value("authkey").toString();
}

QString Overlay::clientid()
{
    return m_settings->value("clientid").toString();
}

QString Overlay::secret()
{
    return m_settings->value("secret").toString();
}

QString Overlay::channel()
{
    return m_settings->value("channel").toString();
}

// property setters:
void Overlay::setOverlayX(qreal v)
{
    if( v == overlayX() )
        return;

    m_settings->setValue("x", v);
    emit overlayXChanged();
}

void Overlay::setOverlayY(qreal v)
{
    if( v == overlayY() )
        return;

    m_settings->setValue("y", v);
    emit overlayYChanged();
}

void Overlay::setOverlayW(qreal v)
{
    if( v == overlayW() )
        return;

    m_settings->setValue("width", v);
    emit overlayWChanged();
}

void Overlay::setOverlayH(qreal v)
{
    if( v == overlayH() )
        return;

    m_settings->setValue("height", v);
    emit overlayHChanged();
}

void Overlay::setUsername(const QString &v)
{
    if( v == username() )
        return;

    m_settings->setValue("username", v);
    emit usernameChanged();
}

void Overlay::setAuthkey(const QString &v)
{
    if( v == authkey() )
        return;

    m_settings->setValue("authkey", v);
    emit authkeyChanged();
}

void Overlay::setClientid(const QString &v)
{
    if( v == clientid() )
        return;

    m_settings->setValue("clientid", v);
    emit clientidChanged();
}

void Overlay::setSecret(const QString &v)
{
    if( v == secret() )
        return;

    m_settings->setValue("secret", v);
    emit secretChanged();
}

void Overlay::setChannel(const QString &v)
{
    if( v == channel() )
        return;

    m_settings->setValue("channel", v);
    emit channelChanged();
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
