
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

import 'util.js' as Util

Connections {
    target: py
    property var model

    onDownloadProgress: {
        Util.updateModelWith(model, 'id', episode_id,
            {'progress': progress});
    }
    onPlaybackProgress: {
        Util.updateModelWith(model, 'id', episode_id,
            {'playbackProgress': progress});
    }
    onUpdatedEpisode: {
        for (var i=0; i<model.count; i++) {
            if (model.get(i).id === episode.id) {
                model.set(i, episode);
                break;
            }
        }
    }
    onEpisodeListChanged: {
        if (model.podcast_id === podcast_id) {
            model.reload();
        }
    }

    onConfigChanged: {
        if (key === 'ui.qml.episode_list.filter_eql') {
            model.setQueryFromConfigUpdate(value);
        }
    }

    onReadyChanged: {
        model.reload();
    }
}
