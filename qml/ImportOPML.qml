import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

import 'common'

Dialog {
    id: importOPML
    allowedOrientations: Orientation.All

    property string selectedFile: "None"
    property string opmlAction: "Import"

    canAccept: {
        (opmlAction == 'Import' && selectedFile != "None") || (opmlAction == 'Export' && exportFile.text != '')
    }
    onAccepted: {
        opmlAction == 'Import' ? py.call('main.import_opml', [importOPML.selectedFile]) : py.call('main.export_opml', [exportFile.text])
    }

    Column {
        anchors.fill: parent

        DialogHeader {
            title: opmlAction == "Import" ? qsTr("Import OPML File") : qsTr('Export OPML File')
            acceptText: opmlAction == "Import" ? qsTr("Import") : qsTr('Export')
        }

        ComboBox {
            label: "OPML"

            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Import")
                    onClicked: opmlAction = "Import"
                }
                MenuItem {
                    text: qsTr("Export")
                    onClicked: opmlAction = "Export"
                }
            }
        }


        ValueButton {
            id: importFile
            label: qsTr("Import File")
            value: selectedFile
            onClicked: pageStack.push(filePickerPage)
            visible: opmlAction == "Import" ? true : false
        }

        TextField {
            id: exportFile
            label: 'Filename'
            placeholderText: qsTr('Enter filname')
            visible: opmlAction == 'Export' ? true : false

            anchors {
                left: parent.left
                right: parent.right
            }
            EnterKey.iconSource: "image://theme/icon-m-enter-close"
            EnterKey.onClicked: focus = false
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

