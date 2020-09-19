
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

var layout = {
    header: {
        height: 100, /* page header height */
    },
    item: {
        height: 80, /* podcast/episode item height */
    },
    coverart: 80, /* cover art size */
    padding: 10, /* padding of items left/right */
};

var colors = {
    download: '#7ac224', /* download green */
    select: '#7f5785', /* gpodder dark purple */
    fresh: '#815c86', /* gpodder purple */
    playback: '#729fcf', /* playback blue */
    destructive: '#cf424f', /* destructive actions */

    toolbar: '#d0d0d0',
    toolbarText: '#333333',
    toolbarDisabled: '#666666',

    inverted: {
        toolbar: '#815c86',
        toolbarText: '#ffffff',
        toolbarDisabled: '#aaffffff',
    },

    page: '#dddddd',
    dialog: '#dddddd',
    dialogBackground: '#aa000000',
    text: '#333333', /* text color */
    dialogText: '#333333',
    highlight: '#433b67',
    dialogHighlight: '#433b67',
    secondaryHighlight: '#605885',
    area: '#cccccc',
    dialogArea: '#d0d0d0',
    toolbarArea: '#bbbbbb',
    placeholder: '#666666',

    //page: '#000000',
    //text: '#ffffff', /* text color */
    //highlight: Qt.lighter('#433b67', 1.2),
    //secondaryHighlight: Qt.lighter('#605885', 1.2),
    //area: '#333333',
    //placeholder: '#aaaaaa',

    background: '#948db3',
    secondaryBackground: '#d0cce1',
};

var font = 'Source Sans Pro';

var state = {
    normal: 0,
    downloaded: 1,
    deleted: 2,
};

