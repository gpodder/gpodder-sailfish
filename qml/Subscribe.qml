
/**
 *
 * gPodder QML UI Reference Implementation
 * Copyright (c) 2013, Thomas Perl <m@thp.io>
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

SlidePage {
    id: subscribe

    SlidePageHeader { title: 'Add subscription' }

    Column {
        anchors.centerIn: parent
        spacing: 30 * pgst.scalef

        PTextField {
            id: input
            width: subscribe.width *.8
            placeholderText: 'Feed URL'
        }

        ButtonArea {
            id: button
            width: input.width
            height: input.height

            PLabel {
                anchors.centerIn: parent
                text: 'Subscribe'
            }

            onClicked: {
                loading.visible = true;
                button.visible = false;
                input.visible = false;
                py.call('main.subscribe', [input.text], function () {
                    subscribe.closePage();
                });
            }
        }

        PBusyIndicator {
            id: loading
            visible: false
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
