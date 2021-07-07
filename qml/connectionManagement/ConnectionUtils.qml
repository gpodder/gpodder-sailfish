import QtQuick 2.0
import Nemo.DBus 2.0

QtObject {

    property DBusInterface connmanWifi: DBusInterface {
          bus: DBus.SystemBus
          service: "net.connman"
          path: "/net/connman/technology/wifi"
          iface: "net.connman.Technology"

          property bool wifiConnected

          signalsEnabled: true
          function propertyChanged(name, value) {
              if (name === "Connected") {
                  wifiConnected = value
              }
          }

          function getProperties() {
              typedCall('GetProperties', undefined, function(result) {
                  wifiConnected = result['Connected']})
          }
          Component.onCompleted: getProperties();

          onWifiConnectedChanged: {
              console.debug("wifistate is now",wifiConnected)
          }
      }

    function checkConnection(ignoreConnection){
        var cellularAllowed = configCellularDownloadsEnabled.value === true || ignoreConnection === true;
        console.debug("Connection check: cellular allowed:",cellularAllowed," wifi connected: ", connmanWifi.wifiConnected)
        return cellularAllowed || connmanWifi.wifiConnected;
    }


    /**
      * @return signal binding for executing callback anyway
      **/
    function downloadBlockedDialog(callback){        
        console.info("creating connection blocked dialog, because not on wifi!");
        pageStack.push("ConnectionBlockedDialog.qml").accepted.connect(callback)
    }

    function executeIfConnectionAllowed(callback){
        if(checkConnection())
            callback()
        else
            downloadBlockedDialog(callback)
    }

}
