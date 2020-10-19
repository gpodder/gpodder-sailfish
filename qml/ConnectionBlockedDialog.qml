import QtQuick 2.0
import Sailfish.Silica 1.0

 Dialog {
     property var callback

     Column {
         width: parent.width

         DialogHeader {
             title: "Connection blocked"
         }
         Label{
             text: "Make an exception for now?"
         }
     }

     onAccepted: {
         callback();
     }

 }
