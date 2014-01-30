
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

function updateModelFrom(model, data) {
    for (var i=0; i<data.length; i++) {
        if (model.count < i) {
            model.append(data[i]);
        } else {
            model.set(i, data[i]);
        }
    }

    while (model.count > data.length) {
        model.remove(model.count-1);
    }
}

function updateModelWith(model, key, value, update) {
    for (var row=0; row<model.count; row++) {
        var current = model.get(row);
        if (current[key] == value) {
            for (var key in update) {
                model.setProperty(row, key, update[key]);
            }
        }
    }
}
