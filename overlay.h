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
    Q_PROPERTY(QString clientid READ clientid WRITE setClientid NOTIFY clientidChanged)
    Q_PROPERTY(QString secret READ secret WRITE setSecret NOTIFY secretChanged)
    Q_PROPERTY(QString channel READ channel WRITE setChannel NOTIFY channelChanged)

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
    void clientidChanged();
    void secretChanged();
    void channelChanged();

    void reconnect();
    void disconnect();
    void repositioning();

public slots:
    void fillScreen();

    void reposition();
    void donePositioning();

    void toggle();

    // property getters:
    qreal overlayX();
    qreal overlayY();
    qreal overlayW();
    qreal overlayH();

    QString username();
    QString authkey();
    QString clientid();
    QString secret();
    QString channel();

    // property setters:
    void setOverlayX(qreal v);
    void setOverlayY(qreal v);
    void setOverlayW(qreal v);
    void setOverlayH(qreal v);

    void setUsername(const QString &v);
    void setAuthkey(const QString &v);
    void setClientid(const QString &v);
    void setSecret(const QString &v);
    void setChannel(const QString &v);

protected:
    virtual void paintEvent(QPaintEvent *ev);
    virtual void resizeEvent(QResizeEvent *ev);
};

#endif // OVERLAY_H
