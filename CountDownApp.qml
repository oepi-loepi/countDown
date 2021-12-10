import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0;
import FileIO 1.0

App {
    id : app
    
    property url                tileUrl             : "CountDownTile.qml"
    property CountDownTile      countDownTile
	
    property url                countDownScreenUrl  : "CountDownScreen.qml"
    property CountDownScreen    countDownScreen
    
    property string             countDownDateTime
    property variant            countDownDateTimeInt

    property bool               momentReached

    property string             momentName
     
    property string settingsFile    : "file:///mnt/data/tsc/countDownDateTime.json"

    
// -------------------------------------- Location of user settings file

    FileIO {
        id                          : userSettingsFile
        source                      : settingsFile
     }

// -------------------------- Structure user settings from settings file

    property variant userSettingsJSON : {}

// ---------------------------------------------------------------------

    function init() {

        const args = {
            thumbCategory       : "general",
            thumbLabel          : "Count Down",
            thumbIcon           : "qrc:/tsc/down.png",
            thumbIconVAlignment : "center",
            thumbWeight         : 30
        }

        registry.registerWidget("tile",   tileUrl,            this, "countDownTile", args);
        registry.registerWidget("screen", countDownScreenUrl, this, "countDownScreen");

    }
    
// ------------------------------------- Actions right after APP startup

    Component.onCompleted: {

// read user settings

        try {
            userSettingsJSON = JSON.parse(userSettingsFile.read());
            log(JSON.stringify(userSettingsJSON))

            momentName         = userSettingsJSON['momentName'];
            countDownDateTime  = userSettingsJSON['countDownDateTime'];
            momentReached      = userSettingsJSON['momentReached'];
        } catch(e) {
            log('Startup : '+e)
            var now = new Date()
            countDownDateTime = now.getFullYear() + '-' +
                    ('00'+(now.getMonth() + 1)   ).slice(-2) + '-' +
                    ('00'+ now.getDate()         ).slice(-2) + ' ' +
                    ('00'+ now.getHours()        ).slice(-2) + ":" +
                    ('00'+ now.getMinutes()      ).slice(-2) + ":" +
                    ('00'+ now.getSeconds()      ).slice(-2)
            momentReached = false
            momentName ="Count Down"
            saveSettings()
        }
        countDownDateTimeInt = Date.parse(countDownDateTime+".000")
    }

// ---------------------------------------------------------------------

    function log(tolog) {

        var now      = new Date();
        var dateTime = now.getFullYear() + '-' +
                ('00'+(now.getMonth() + 1)   ).slice(-2) + '-' +
                ('00'+ now.getDate()         ).slice(-2) + ' ' +
                ('00'+ now.getHours()        ).slice(-2) + ":" +
                ('00'+ now.getMinutes()      ).slice(-2) + ":" +
                ('00'+ now.getSeconds()      ).slice(-2) + "." +
                ('000'+now.getMilliseconds() ).slice(-3);
        console.log(dateTime+' countDown : ' + tolog.toString())

    }
// ---------------------------------------------------------------------

    function saveSettings(){

        var tmpUserSettingsJSON = {
            "momentName"        : momentName,
            "countDownDateTime" : countDownDateTime,
            "momentReached"     : momentReached
        }

        var settings = new XMLHttpRequest();
        settings.open("PUT", settingsFile);
        settings.send(JSON.stringify(tmpUserSettingsJSON));
    }

// ---------------------------------------------------------------------

}
