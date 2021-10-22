#ifndef OVERLAY_H
#define OVERLAY_H

#include <QWidget>
#include <QQuickWidget>
#include <QSettings>

class Overlay : public QWidget
{
    Q_OBJECT

    QRect   m_screenRect;
    int     m_screen;

    bool    m_positioning;
    QRect   m_position;

    QQuickWidget    *m_view;
    QSettings       *m_settings;

    Q_PROPERTY(qreal overlayx READ overlayX WRITE setOverlayX NOTIFY overlayXChanged)
    Q_PROPERTY(qreal overlayy READ overlayY WRITE setOverlayY NOTIFY overlayYChanged)
    Q_PROPERTY(qreal overlayw READ overlayW WRITE setOverlayW NOTIFY overlayWChanged)
    Q_PROPERTY(qreal overlayh READ overlayH WRITE setOverlayH NOTIFY overlayHChanged)
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY(QString authkey READ authkey WRITE setAuthkey NOTIFY authkeyChanged)
    Q_PROPERTY(QString refreshtoken READ refreshtoken WRITE setRefreshtoken NOTIFY refreshtokenChanged)
    Q_PROPERTY(QString expires READ expires WRITE setExpires NOTIFY expiresChanged)
    Q_PROPERTY(QString channel READ channel WRITE setChannel NOTIFY channelChanged)
    Q_PROPERTY(QString clientid READ clientid WRITE setClientid NOTIFY clientidChanged)
    Q_PROPERTY(QString clientsecret READ clientsecret WRITE setClientsecret NOTIFY clientsecretChanged)

    // Added for 1.2 release:
    Q_PROPERTY(QString notifySound READ notifySound WRITE setNotifySound NOTIFY notifySoundChanged)
    Q_PROPERTY(QString bgImage READ bgImage WRITE setBgImage NOTIFY bgImageChanged)
    Q_PROPERTY(qreal opacity READ opacity WRITE setOpacity NOTIFY opacityChanged)
    Q_PROPERTY(qreal scale READ scale WRITE setScale NOTIFY scaleChanged)
    Q_PROPERTY(int fadeDelay READ fadeDelay WRITE setFadeDelay NOTIFY fadeDelayChanged)
    Q_PROPERTY(bool showTimestamps READ showTimestamps WRITE setShowTimestamps NOTIFY showTimestampsChanged)
    Q_PROPERTY(bool showAvatars READ showAvatars WRITE setShowAvatars NOTIFY showAvatarsChanged)

public:
    explicit Overlay(int screen=0);
    ~Overlay();

signals:
    void overlayXChanged();
    void overlayYChanged();
    void overlayWChanged();
    void overlayHChanged();

    void usernameChanged();
    void authkeyChanged();
    void refreshtokenChanged();
    void expiresChanged();
    void channelChanged();
    void clientidChanged();
    void clientsecretChanged();

    void notifySoundChanged();
    void bgImageChanged();
    void opacityChanged();
    void scaleChanged();
    void fadeDelayChanged();
    void showTimestampsChanged();
    void showAvatarsChanged();

    void reconnect();
    void disconnect();
    void repositioning();
    void linked();
    void _showMessage(const QString &message);

public slots:
    void fillScreen();

    void reposition();
    void donePositioning();

    void toggle();

    void reload();
    void showMessage(const QString &message);

    // property getters:
    qreal overlayX();
    qreal overlayY();
    qreal overlayW();
    qreal overlayH();

    QString username();
    QString authkey();
    QString refreshtoken();
    QString expires();
    QString channel();
    QString clientid();
    QString clientsecret();

    QString notifySound();
    QString bgImage();
    qreal opacity();
    qreal scale();
    int fadeDelay();
    bool showTimestamps();
    bool showAvatars();

    // property setters:
    void setOverlayX(qreal v);
    void setOverlayY(qreal v);
    void setOverlayW(qreal v);
    void setOverlayH(qreal v);

    void setUsername(const QString &v);
    void setAuthkey(const QString &v);
    void setRefreshtoken(const QString &v);
    void setExpires(const QString &v);
    void setChannel(const QString &v);
    void setClientid(const QString &v);
    void setClientsecret(const QString &v);

    void setNotifySound(const QString &v);
    void setBgImage(const QString &v);
    void setOpacity(qreal v);
    void setScale(qreal v);
    void setFadeDelay(int v);
    void setShowTimestamps(bool v);
    void setShowAvatars(bool v);

protected:
    virtual void paintEvent(QPaintEvent *ev);
    virtual void resizeEvent(QResizeEvent *ev);
};

#endif // OVERLAY_H
