#ifndef AUTHWINDOW_H
#define AUTHWINDOW_H

#include <QQuickItem>
#include <QWebEngineView>

class AuthWindow : public QQuickItem
{
    Q_OBJECT

    QWebEngineView  *m_view;

    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)

public:
    AuthWindow();

    void setUrl(const QUrl &url) { m_view->load(url); }
    QUrl url() { return m_view->url(); }

    Q_INVOKABLE void show() { m_view->show(); }
    Q_INVOKABLE void hide() { m_view->hide(); }
    Q_INVOKABLE void setTitle(const QString &title) { m_view->setWindowTitle(title); }
    Q_INVOKABLE void resize(int w, int h) { m_view->resize(w, h); }
    Q_INVOKABLE void runJavaScript(const QString &js, QJSValue cb);

private slots:
    void loadFinished(bool ok);

signals:
    void urlChanged(const QUrl &newUrl);
    void loadingChanged(QVariant request);
};

#endif // AUTHWINDOW_H
