#include "esphandler.h"

#include <QNetworkAccessManager>
#include <QNetworkReply>

ESPHandler::ESPHandler(QObject *parent) : QObject(parent)
{
    requestStatus();
    connect(&requestTick, &QTimer::timeout, this, &ESPHandler::requestStatus);
    requestTick.setInterval(5000);
    requestTick.start();
}

void ESPHandler::setManualState(QString state)
{
    QNetworkAccessManager* manager = new QNetworkAccessManager();

    connect(manager, &QNetworkAccessManager::finished, this, [=](QNetworkReply *reply)
    {
        if (reply->error())
        {
            qDebug() << reply->errorString();
        }
        else
        {
            QString answer = reply->readAll();
            qDebug() << answer;
            if (answer == "RELAY turned ON")
            {
                m_manualState = "on";
                emit manualStateChanged();
            }
            else if (answer == "RELAY turned OFF")
            {
                m_manualState = "off";
                emit manualStateChanged();
            }
        }
        manager->deleteLater();
    });

    QNetworkRequest request;
    request.setUrl(QUrl("http://192.168.100.62/" + state));
    manager->get(request);
}

void ESPHandler::setTargetTemp(QString value)
{
    QNetworkAccessManager* manager = new QNetworkAccessManager();

    connect(manager, &QNetworkAccessManager::finished, this, [=](QNetworkReply *reply)
    {
        if (reply->error())
        {
            qDebug() << reply->errorString();
        }
        else
        {
            QString answer = reply->readAll();
            qDebug() << answer;
            if (answer != "OK!")
            {
                m_targetTemp = "0";
                emit targetTempChanged();
            }
        }
        manager->deleteLater();
    });

    m_targetTemp = value;
    QNetworkRequest request;
    request.setUrl(QUrl("http://192.168.100.61/target?tt=" + value));
    manager->get(request);
}

QString ESPHandler::getCurrentTemp()
{
    return m_currentTemp;
}

QString ESPHandler::getTargetTemp()
{
    return m_targetTemp;
}

QString ESPHandler::getCurrentHumidity()
{
    return m_currentHumidity;
}

QString ESPHandler::getCurrentState()
{
    return m_currentState;
}

QString ESPHandler::getManualState()
{
    return m_manualState.toUpper();
}

void ESPHandler::requestStatus()
{
    QNetworkAccessManager* manager = new QNetworkAccessManager();

    connect(manager, &QNetworkAccessManager::finished, this, [=](QNetworkReply *reply)
    {
        if (reply->error())
        {
            qDebug() << reply->errorString();
        }
        else
        {
            QString answer = reply->readAll();
            qDebug() << answer;
            QStringList stats = answer.split(",");
            QString s = stats[0].replace("s=", "");
            QString tt = stats[1].replace("tt=", "");
            QString ct = stats[2].replace("ct=", "");
            QString h = stats[3].replace("h=", "");
            if (m_currentState != s)
            {
                m_currentState = stats[0];
                emit currentStateChanged();
            }
            if (m_targetTemp != tt)
            {
                m_targetTemp = tt;
                emit targetTempChanged();
            }
            if (m_currentTemp != ct)
            {
                m_currentTemp = ct;
                emit currentTempChanged();
            }
            if (m_currentHumidity != h)
            {
                m_currentHumidity = h;
                emit currentHumidityChanged();
            }
        }
        manager->deleteLater();
    });

    QNetworkRequest request;
    request.setUrl(QUrl("http://192.168.100.61/status"));
    manager->get(request);
}
