#ifndef OVERLAY_H
#define OVERLAY_H

#include <QWidget>
#include <QQuickWidget>

class Overlay : public QWidget
{
    Q_OBJECT

    QRect   m_screenRect;
    int     m_screen;

    bool    m_positioning;
    QRect   m_position;

    QQuickWidget    *m_view;

public:
    explicit Overlay(int screen=0);
    ~Overlay();

    Q_INVOKABLE bool multimediaSupported() { return m_multimediaSupported; }

    bool    m_multimediaSupported;

signals:
    void repositioning();

public slots:
    void fillScreen();

    void reposition();
    void donePositioning();

    void toggle();

protected:
    virtual void paintEvent(QPaintEvent *ev);
    virtual void resizeEvent(QResizeEvent *ev);

private:
    void testForMultimedia();
};

#endif // OVERLAY_H
