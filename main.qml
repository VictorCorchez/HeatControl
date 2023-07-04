import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import ESP

ApplicationWindow
{
    id: window
    width: Screen.width
    height: Screen.height
    color: "gray"
    visible: true
    title: qsTr("Stack")

    Rectangle
    {
        id: tempControlTitle
        width: parent.width
        height: 40
        color: "gray"

        Rectangle
        {
            height: 20
            border.width: 2
            width: tempControlText.width + 10
            anchors.bottom: parent.bottom
            color: "gray"

            Text
            {
                id: tempControlText
                text: "Temperature control"
                anchors.centerIn: parent
            }
        }
    }

    Rectangle
    {
        id: tempControlBox
        width: parent.width
        height: 250
        color: "gray"
        border.width: 2
        anchors.top: tempControlTitle.bottom

        ColumnLayout
        {
            anchors.fill: parent
            spacing: 0

            Text
            {
                id: currentState
                Layout.fillWidth: true
                Layout.margins: 10
                Layout.topMargin: 5
                Layout.bottomMargin: 5
                text: "Current state: " + ESP.currentState
                font.bold: true

                Connections
                {
                    target: ESP
                    function onCurrentStateChanged()
                    {
                        currentState.text = "Current state: " + ESP.currentState;
                    }
                }
            }

            Text
            {
                id: currentHumidity
                Layout.fillWidth: true
                Layout.margins: 10
                Layout.topMargin: 5
                Layout.bottomMargin: 5
                text: "Current humidity: " + ESP.currentHumidity
                font.bold: true
            }

            Text
            {
                id: currentTemp
                Layout.fillWidth: true
                Layout.margins: 10
                Layout.topMargin: 5
                Layout.bottomMargin: 5
                text: "Current temperature: " + ESP.currentTemp + " \u00B0C"
                font.bold: true
            }

            RowLayout
            {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                Layout.margins: 10
                Layout.topMargin: 5
                Layout.bottomMargin: 5

                Text
                {
                    id: txtLabel
                    text: "Target temperature:"
                    Layout.preferredWidth: txtLabel.contentWidth
                    Layout.alignment: Qt.AlignVCenter
                    font.bold: true
                }

                Rectangle
                {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 30
                    border.width: 2
                    border.color: "black"
                    color: "lightgray"

                    TextInput
                    {
                        id: txtInput
                        anchors.fill: parent
                        font.capitalization: Font.AllUppercase
                        text: ESP.targetTemp
                        inputMethodHints: Qt.ImhDigitsOnly
                        horizontalAlignment: TextInput.AlignHCenter
                        verticalAlignment: TextInput.AlignVCenter
                        color: "black"

                        validator: DoubleValidator {
                            notation: DoubleValidator.StandardNotation
                            decimals: 1
                            bottom: 0.0
                            top: 30.0
                        }

                        onFocusChanged:
                        {
                            if (txtInput.focus)
                            {
                                sliderLayout.visible = true;
                            }
                        }
                        onTextChanged:
                        {
                            tempSlider.value = text;
                        }
                    }
                }

                Text
                {
                    text: "\u00B0C"
                    font.bold: true
                }

                Button
                {
                    text: "SET"

                    onClicked:
                    {
                        if (txtInput.text !== "0.0")
                        {
                            manualSwitchMA.enabled = false;
                            manualSwitch.color = "darkGray";
                            sliderLayout.visible = false;
                        }
                        ESP.setTargetTemp(txtInput.text);
                    }
                }

                Button
                {
                    text: "RESET"

                    onClicked:
                    {
                        txtInput.text = "0.0";
                        manualSwitch.color = "red";
                        manualSwitchMA.enabled = true;
                        ESP.setTargetTemp("0.0");
                        sliderLayout.visible = false;
                    }
                }
            }

            Rectangle
            {
                id: sliderLayout
                height: 30
                width: 200
                visible: false
                border.width: 2
                border.color: "black"
                color: "lightgray"
                Layout.alignment: Qt.AlignRight
                Layout.rightMargin: 30

                Slider
                {
                    id: tempSlider
                    visible: parent.visible
                    anchors.fill: parent
                    stepSize: 1.0
                    from: 18.0
                    to: 30.0
                    snapMode: Slider.SnapAlways

                    background: Rectangle {
                        x: tempSlider.leftPadding
                        y: tempSlider.topPadding + tempSlider.availableHeight / 2 - height / 2
                        implicitWidth: 200
                        implicitHeight: 5
                        width: tempSlider.availableWidth
                        height: implicitHeight
                        radius: 2
                        color: "#bdbebf"

                        Rectangle {
                            width: tempSlider.visualPosition * parent.width
                            height: parent.height
                            color: "#21be2b"
                            radius: 2
                        }
                    }

                    handle: Rectangle {
                        x: tempSlider.leftPadding + tempSlider.visualPosition * (tempSlider.availableWidth - width)
                        y: tempSlider.topPadding + tempSlider.availableHeight / 2 - height / 2
                        implicitWidth: 20
                        implicitHeight: 20
                        radius: 10
                        color: tempSlider.pressed ? "#f0f0f0" : "#f6f6f6"
                        border.color: "#bdbebf"
                    }

                    onMoved:
                    {
                        txtInput.text = value;
                    }
                }
            }
        }        
    }

    Rectangle
    {
        id: manualControlBox
        anchors.top: tempControlBox.bottom
        width: parent.width
        height: 40
        color: "gray"

        Rectangle
        {
            height: 20
            border.width: 2
            width: manualControlText.width + 10
            anchors.bottom: parent.bottom
            color: "gray"

            Text
            {
                id: manualControlText
                text: "Manual control"
                anchors.centerIn: parent
            }
        }
    }

    Rectangle
    {
        width: parent.width
        height: 250
        color: "gray"
        border.width: 2
        anchors.top: manualControlBox.bottom

        Rectangle
        {
            id: manualSwitch
            anchors.centerIn: parent
            height: 100
            width: 100
            radius: 50
            color: (txtInput.text === "0.0") ? "red" : "darkGray"

            Text
            {
                id: manualSwitchText
                anchors.centerIn: parent
                font.bold: true
                font.pointSize: 25
                text: "OFF"
            }

            MouseArea
            {
                id: manualSwitchMA
                anchors.fill: parent
                enabled: txtInput.text === "0.0"
                onPressed:
                {
                    ESP.setManualState(manualSwitchText.text === "OFF" ? "on" : "off");
                }
            }

            Connections
            {
                target: ESP
                function onManualStateChanged()
                {
                    manualSwitchText.text = ESP.manualState;
                    manualSwitch.color = (manualSwitchText.text === "ON" ? "green" : "red");
                }
            }
        }
    }
}
