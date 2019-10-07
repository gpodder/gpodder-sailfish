import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

import 'common'

Dialog {
    id: importOPML
    allowedOrientations: Orientation.All

    property string selectedFile: "None"
    canAccept: selectedFile != "None"
    onAccepted: py.call('main.import_opml', [importOPML.selectedFile])

    Column {
        anchors.fill: parent

        DialogHeader {
            title: qsTr("Import OPML File")
            acceptText: qsTr("Import")
        }

        ValueButton {
            id: importFile
            label: qsTr("Import File")
            value: selectedFile
            onClicked: pageStack.push(filePickerPage)
        }
    }
    Component {
        id: filePickerPage
        FilePickerPage {
            onSelectedContentPropertiesChanged: {
                importOPML.selectedFile = selectedContentProperties.filePath
            }
        }
    }
}

