#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "esphandler.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    ESPHandler* esp = new ESPHandler();

    qmlRegisterSingletonInstance("ESP", 1, 0, "ESP", esp);

    engine.load(url);

    return app.exec();
}
