import QtQuick 2.0
import Sailfish.Silica 1.0

 Dialog {
     Column {
         width: parent.width

         DialogHeader {
             title: "Connection blocked"
         }
         Label{
             text: "Make an exception for now?"
         }
     }

 }
