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

void Overlay::reload()
{
    emit reconnect();
}

void Overlay::showMessage(const QString &message)
{
    emit _showMessage(message);
}

// property getters:
qreal Overlay::overlayX()
{
    return m_settings->value("x", 60).toReal();
}

qreal Overlay::overlayY()
{
    return m_settings->value("y", 60).toReal();
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

QString Overlay::refreshtoken()
{
    return m_settings->value("refreshtoken").toString();
}

QString Overlay::expires()
{
    return m_settings->value("expires").toString();
}

QString Overlay::channel()
{
    return m_settings->value("channel").toString();
}

QString Overlay::notifySound()
{
    return m_settings->value("notifySound", "").toString();
}

QString Overlay::bgImage()
{
    return m_settings->value("bgImage", "").toString();
}

qreal Overlay::opacity()
{
    return m_settings->value("opacity", 100).toReal();
}

qreal Overlay::scale()
{
    return m_settings->value("scale", 100).toReal();
}

int Overlay::fadeDelay()
{
    return m_settings->value("fadeDelay", 600).toLongLong();
}

bool Overlay::showTimestamps()
{
    return m_settings->value("showTimestamps", true).toBool();
}

bool Overlay::showAvatars()
{
    return m_settings->value("showAvatars", true).toBool();
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

void Overlay::setRefreshtoken(const QString &v)
{
    if( v == refreshtoken() )
        return;

    m_settings->setValue("refreshtoken", v);
    emit refreshtokenChanged();
}

void Overlay::setExpires(const QString &v)
{
    if( v == expires() )
        return;

    m_settings->setValue("expires", v);
    emit expiresChanged();
}

void Overlay::setChannel(const QString &v)
{
    if( v == channel() )
        return;

    m_settings->setValue("channel", v);
    emit channelChanged();
}

void Overlay::setNotifySound(const QString &v)
{
    if( v == notifySound() )
        return;

    m_settings->setValue("notifySound", v);
    emit notifySoundChanged();
}

void Overlay::setBgImage(const QString &v)
{
    if( v == bgImage() )
        return;

    m_settings->setValue("bgImage", v);
    emit bgImageChanged();
}

void Overlay::setOpacity(qreal v)
{
    if( v == opacity() )
        return;

    m_settings->setValue("opacity", v);
    emit opacityChanged();
}

void Overlay::setScale(qreal v)
{
    if( v == scale() )
        return;

    m_settings->setValue("scale", v);
    emit scaleChanged();
}

void Overlay::setFadeDelay(int v)
{
    if( v == fadeDelay() )
        return;

    m_settings->setValue("fadeDelay", v);
    emit fadeDelayChanged();
}

void Overlay::setShowTimestamps(bool v)
{
    if( v == showTimestamps() )
        return;

    m_settings->setValue("showTimestamps", v);
    emit showTimestampsChanged();
}

void Overlay::setShowAvatars(bool v)
{
    if( v == showAvatars() )
        return;

    m_settings->setValue("showAvatars", v);
    emit showAvatarsChanged();
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
