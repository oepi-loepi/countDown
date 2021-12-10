//////  yaLabel     : Yet Anoter NumericKeyboard by JackV
//////  Based on    : NumericKeyboard.qml
//////  Needs       : KeyButton.qml
/*
Retrieved NumericKeyboard.qml by :

opkg install qtbase-tools-rcc-ext_5.11.2+git0+49efea26a5-r0_cortexa9hf-vfp-neon-mx6sx.ipk
opkg install qtbase-tools-tsc-rcc_5.11.2+git0+49efea26a5-r0_cortexa9hf-vfp-neon-mx6sx.ipk
cd /qmf/qml
rcc_ext --reverse resources.rcc
gives a lot including the folder /qmf/qml/qresource/res/resources.rcc/qb/components with NumericKeyboard.qml

other info can be founde from : rcc_ext --reverse resources-static-ebl.rcc

JackV changes :
added 
    property alias numberPin: p.enteredPin
        Reason :
            Now when you set pinMode true so the entered pin is set in numberPin
    property int kbMode : 1
        Reason :
            Now you can select 1 of 4 keyboard states at end of this qml
    added state "num_integer_backspace_clear" 
        Reason :
            to have a clean all and a backspace
    rounded buttons for pinMode == false
        Reason :
            I like rounded buttons
*/
import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0;
Item {
    id: root
    implicitWidth: keysGrid.width
    implicitHeight: childrenRect.height
    property int buttonWidth: Math.round(50 * horizontalScaling)
    property int buttonHeight: buttonWidth
    property int buttonSpace: Math.round(20 * horizontalScaling)
    property bool pinMode: false
    property int maxTextLength: pinMode ? 4 : -1
    property alias numberText: enteredNumber.text
    property int numberLength: pinMode ? p.enteredPin.length : enteredNumber.text.length
    property alias leftText: leftText.text
    property alias rightText: rightText.text
    property int maxDecimals: 4

    property alias numberPin: p.enteredPin
    property int kbMode : 1

    signal pinEntered(string pin)
    signal digitEntered(string digit)
    QtObject {
        id: p
        property bool disableInput: false
        property string enteredPin
        onEnteredPinChanged: checkMaxLength(enteredPin)
        function backspace() {
            if (pinMode)
                p.enteredPin = p.enteredPin.slice(0, -1);
            else
                enteredNumber.removeLastCharOfText();
        }
        function addDecimalSeparator(decimalSymbol) {
            if (pinMode)
                return;
            if (enteredNumber.text.length > 0 && enteredNumber.text.indexOf(decimalSymbol) == -1) {
                enteredNumber.addTextPartToText(decimalSymbol);
            }
        }
        function checkMaxLength(text) {
            var decimalIdx = text.indexOf(i18n.decimalSeparator());
            if ((decimalIdx >= 0 && (text.length - decimalIdx - 1) >= root.maxDecimals) || text.length === root.maxTextLength) {
                p.disableInput = true;
                pinEntered(p.enteredPin);
            } else {
                p.disableInput = false;
            }
        }
    }
    function clear() {
        if (pinMode)
            p.enteredPin = "";
        else
            enteredNumber.clearText();
    }
    function wrongPin() {
        if (!pinMode)
            return;
        clear();
        if (isNxt)
            wrongPinAnim.restart();
    }
    KeyboardGroup {
        id: keyboard
        enableLongPress: false
        onKeyPressed: {
            digitEntered(key);
            if (pinMode)
                p.enteredPin += key;
            else
                enteredNumber.addTextPartToText(key);
        }
    }
    StyledRectangle {
        id: editField
        width: keysGrid.width
        height: Math.round(40 * verticalScaling)
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        color: colors.keyboardOuterBorder
        radius: designElements.radius
        visible: !pinMode
        StyledCursorLabel {
            id: enteredNumber
            anchors.margins: Math.round(6 * horizontalScaling)
            anchors.fill: parent
            color: colors.keyboardInnerBg
            borderColor: colors.keyboardInnerBorder
            borderWidth: 2
            borderStyle: Qt.SolidLine
            fontFamily: qfont.regular.name
            fontPixelSize: qfont.bodyText
            fontColor: colors.keyboardInputColor
            radius: 0
            leftMargin: designElements.hMargin6
            rightMargin: designElements.hMargin6
            alignment: "AlignmentLeft"
            cursorHeight: root.buttonWidth / 2.5
            cursorActivated: visible
            maxTextWidth: width - leftMargin - rightMargin - 2
            maxTextLength: root.maxTextLength
            onTextChanged: p.checkMaxLength(text)
        }
    }
    Row {
        id: pinDigits
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        spacing: Math.round(2 * horizontalScaling)
        visible: pinMode
        property int digitWidth: (keysGrid.width - ((maxTextLength - 1) * pinDigits.spacing)) / maxTextLength
        SequentialAnimation on anchors.horizontalCenterOffset {
            id: wrongPinAnim
            running: false
            loops: 3 // doesn't seem to work
            SmoothedAnimation{ to: 10; duration: 100 }
            SmoothedAnimation{ to: -10; duration: 100 }
            SmoothedAnimation{ to: 0; duration: 100 }
        }
        Repeater {
            id: digitsRepeater
            model: maxTextLength
            StyledRectangle {
                width: pinDigits.digitWidth
                height: width
                color: colors.keyboardPinDigitsBg
                radius: designElements.radius
                topLeftRadiusRatio: index === 0 ? 1 : 0
                bottomLeftRadiusRatio: topLeftRadiusRatio
                topRightRadiusRatio: index === digitsRepeater.count - 1 ? 1 : 0
                bottomRightRadiusRatio: topRightRadiusRatio
                Text {
                    anchors.centerIn: parent
                    font {
                        family: qfont.semiBold.name
                        pixelSize: qfont.primaryImportantBodyText
                    }
                    color: colors.keyboardInputColor
                    text: "*"
                    visible: index < p.enteredPin.length
                }
            }
        }
    }
    Text {
        id: leftText
        anchors {
            right: editField.left
            rightMargin: Math.round(14 * horizontalScaling)
            verticalCenter: editField.verticalCenter
        }
        color: colors._fantasia
        font {
            pixelSize: qfont.navigationTitle
            family: qfont.semiBold.name
        }
    }
    Text {
        id: rightText
        anchors {
            left: editField.right
            leftMargin: Math.round(14 * horizontalScaling)
            verticalCenter: editField.verticalCenter
        }
        color: colors._fantasia
        font {
            pixelSize: qfont.navigationTitle
            family: qfont.semiBold.name
        }
    }
    Grid {
        id: keysGrid
        columns: 3
        rows: 4
        spacing: root.buttonSpace
        anchors {
            top: pinMode ? pinDigits.bottom : editField.bottom
            topMargin: root.buttonSpace
            horizontalCenter: parent.horizontalCenter
        }
        Repeater {
            model: 9
            KeyButton {
                width: root.buttonWidth
                height: root.buttonHeight
                radius: width / 2
                controlGroup: keyboard
                fontFamily: qfont.semiBold.name
                fontPixelSize: qfont.navigationTitle
                enabled: !p.disableInput && root.enabled
            }
        }
        KeyButton {
            id: leftBtn
            width: root.buttonWidth
            height: root.buttonHeight
            radius: width / 2
            fontFamily: qfont.semiBold.name
            fontPixelSize: qfont.navigationTitle
        }
        KeyButton {
            id: zeroBtn
            width: root.buttonWidth
            height: root.buttonHeight
            radius: width / 2
            controlGroup: keyboard
            fontFamily: qfont.semiBold.name
            fontPixelSize: qfont.navigationTitle
            enabled: !p.disableInput && root.enabled
        }
        KeyButton {
            id: rightBtn
            width: root.buttonWidth
            height: root.buttonHeight
            radius: width / 2
            fontFamily: qfont.semiBold.name
            fontPixelSize: qfont.navigationTitle
        }
    }
    state: pinMode ? "num_integer_clear_backspace" : (kbMode == 2) ? "num_integer" : (kbMode == 3) ? "num_integer_backspace" : (kbMode == 4) ? "num_integer_clear_backspace" : (kbMode == 5) ? "num_integer_backspace_clear" : "num_normal"
    states: [
// kbMode == 1
        State {
            name: "num_normal"
            PropertyChanges { target: keyboard; keys: qsTr("0123456789") }
            PropertyChanges { target: rightBtn; text: qsTr("C"); onClicked: clear() }
            PropertyChanges { target: leftBtn; text: i18n.decimalSeparator(); onClicked: p.addDecimalSeparator(text); enabled: !p.disableInput && root.enabled }
        },
// kbMode == 2
        State {
            name: "num_integer"
            PropertyChanges { target: keyboard; keys: qsTr("0123456789") }
            PropertyChanges { target: rightBtn; text: qsTr("C"); onClicked: clear(); enabled: root.enabled }
//            PropertyChanges { target: leftBtn; text: i18n.decimalSeparator(); enabled: false }
// JackV I do not want a decimal seperator symbol for integers
            PropertyChanges { target: leftBtn; text: "" ; enabled: true }
        },
// kbMode == 3
        State {
            name: "num_integer_backspace"
            PropertyChanges { target: keyboard; keys: qsTr("0123456789") } 
            PropertyChanges { target: rightBtn; text: ""; iconSource: "drawables/backspace_numkeyb.svg"; onClicked: p.backspace(); enabled: root.enabled }
            PropertyChanges { target: leftBtn; text: i18n.decimalSeparator(); enabled: false }
        },
// kbMode == 4
        State {
            name: "num_integer_clear_backspace"
            PropertyChanges { target: keyboard; keys: qsTr("0123456789") }
            PropertyChanges { target: rightBtn; text: ""; iconSource: "drawables/backspace_numkeyb.svg"; onClicked: p.backspace(); enabled: root.enabled }
            PropertyChanges { target: leftBtn; text: qsTr("C"); onClicked: clear(); enabled: root.enabled }
        },
// kbMode == 5
        State {
            name: "num_integer_backspace_clear"
            PropertyChanges { target: keyboard; keys: qsTr("0123456789") } 
            PropertyChanges { target: rightBtn; text: qsTr("C"); onClicked: clear(); enabled: root.enabled }
            PropertyChanges { target: leftBtn; text: "<"; iconSource: "drawables/backspace_numkeyb.svg"; onClicked: numberText = numberText.slice(0,-1); enabled: root.enabled }
        }
    ]
}
