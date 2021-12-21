#ifndef ESPHANDLER_H
#define ESPHANDLER_H

#include <QObject>
#include <QTimer>

class ESPHandler : public QObject
{
    Q_OBJECT
public:
    explicit ESPHandler(QObject *parent = nullptr);

    Q_PROPERTY(QString currentTemp READ getCurrentTemp NOTIFY currentTempChanged);
    Q_PROPERTY(QString targetTemp READ getTargetTemp NOTIFY targetTempChanged);
    Q_PROPERTY(QString currentHumidity READ getCurrentHumidity NOTIFY currentHumidityChanged);
    Q_PROPERTY(QString currentState READ getCurrentState NOTIFY currentStateChanged);
    Q_PROPERTY(QString manualState READ getManualState NOTIFY manualStateChanged);

    Q_INVOKABLE void setManualState(QString state);
    Q_INVOKABLE void setTargetTemp(QString value);

    QString getCurrentTemp();
    QString getTargetTemp();
    QString getCurrentHumidity();
    QString getCurrentState();
    QString getManualState();

signals:
    void manualStateChanged();
    void currentStateChanged();
    void currentHumidityChanged();
    void targetTempChanged();
    void currentTempChanged();

private:
    void requestStatus();

    QString m_manualState;
    QString m_currentState;
    QString m_currentHumidity;
    QString m_targetTemp;
    QString m_currentTemp{};
    QTimer requestTick;
};

#endif // ESPHANDLER_H
