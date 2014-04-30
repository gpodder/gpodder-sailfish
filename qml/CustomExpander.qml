
/**
 *
 * gPodder QML UI Reference Implementation
 * Copyright (c) 2014, Thomas Perl <m@thp.io>
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
 * REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
 * LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
 * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 *
 */

import QtQuick 2.0
import Sailfish.Silica 1.0


BackgroundItem {
    id: expander

    property alias expanded: customExpanderContent.expanded
    property alias canExpand: customExpanderContent.canExpand

    property alias contractedHeight: customExpanderContent.contractedHeight
    property alias expandedHeight: customExpanderContent.expandedHeight

    default property alias contentChildren: customExpanderContent.children

    height: customExpanderContent.height

    onClicked: {
        if (expander.canExpand) {
            expander.expanded = !expander.expanded
        }
    }

    CustomExpanderContent {
        id: customExpanderContent
        width: parent.width
    }

    OpacityRampEffect {
        sourceItem: customExpanderContent
        direction: OpacityRamp.TopToBottom
        enabled: !expander.expanded
    }

    Label {
        id: chapterExpander

        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: Theme.paddingLarge
        }

        text: '•••'
        visible: !expander.expanded

        font.pixelSize: Theme.fontSizeLarge
        color: Theme.secondaryColor
    }
}
