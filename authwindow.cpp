#include "authwindow.h"

#include <QWebEnginePage>
#include <QQmlEngine>

AuthWindow::AuthWindow()
{
    m_view = new QWebEngineView();

    connect(m_view, &QWebEngineView::loadFinished, this, &AuthWindow::loadFinished);
    connect(m_view, &QWebEngineView::urlChanged, this, &AuthWindow::urlChanged);
}

void AuthWindow::loadFinished(bool ok)
{
    QWebEnginePage *p = m_view->page();
    if( !p )
        return;

    QVariantMap req;
    req["url"] = m_view->url();
    req["status"] = ok;

    emit loadingChanged(req);
}

void AuthWindow::runJavaScript(const QString &js, QJSValue cb)
{
    QWebEnginePage *p = m_view->page();
    if( !p )
        return;

    QQmlEngine *engine = qmlEngine(this);
    if( !engine )
        return;

    p->runJavaScript(js, [cb, engine](const QVariant &v) mutable {
        if( !cb.isCallable() )
            return;

        QJSValueList args;
        args << engine->toScriptValue(v);
        cb.call(args);
    });
}

//void loadingChanged(QVariant request);
