
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

function formatDuration(duration) {
    if (duration !== 0 && !duration) {
        return ''
    }

    var h = parseInt(duration / 3600) % 24
    var m = parseInt(duration / 60) % 60
    var s = parseInt(duration % 60)

    var hh = h > 0 ? (h < 10 ? '0' + h : h) + ':' : ''
    var ms = (m < 10 ? '0' + m : m) + ':' + (s < 10 ? '0' + s : s)

    return hh + ms
}

function formatPosition(position,duration) {
  return formatDuration(position) + " / " + formatDuration(duration)
}

// Call a Python function and disable item until the function returns
function disableUntilReturn(item, py, func, args) {
    item.enabled = false;
    py.call(func, args, function() {
        item.enabled = true;
    });
}

function format(s, d) {
    return s.replace(/{([^}]*)}/g, function (m, k) {
        return (k in d) ? d[k] : m;
    });
}

function atMostOnce(callback) {
    var called = false;
    return function () {
        if (!called) {
            called = true;
            callback();
        }
    };
}
