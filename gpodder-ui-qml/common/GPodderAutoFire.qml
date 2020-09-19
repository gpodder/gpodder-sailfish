
/**
 *
 * gPodder QML UI Reference Implementation
 * Copyright (c) 2015, Thomas Perl <m@thp.io>
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

Timer {
    property int triggerCount: 0
    property int initialInterval: 1500
    property int autoFireInterval: 200

    signal fired()

    interval: triggerCount > 1 ? autoFireInterval : initialInterval

    repeat: true
    triggeredOnStart: true

    onRunningChanged: {
        if (!running) {
            triggerCount = 0
        }
    }

    onTriggered: {
        triggerCount += 1
        fired()
    }
}
