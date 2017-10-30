#!/bin/bash
# Create symlinks into Git submodules, so the project can
# be started with qmlscene directly from a source checkout

# array of symlinks in form "$TARGET","$LINK_NAME"
SYMLINKS=("gpodder-core/src/gpodder","gpodder" "podcastparser/podcastparser.py","podcastparser.py" "gpodder-ui-qml/main.py","main.py" "../gpodder-ui-qml/common","qml/common" "minidb/minidb.py","minidb.py")

help() {
	echo "Manage symlinks into Git submodules, so the project can
be started with qmlscene directly from a source checkout

Usage:
$0 [--unlink | --help]

default behaviour: create symlinks into Git submodules
--unlink: remove symlinks again
--help: display this help"
}

create_symlinks() {
#	ln -sf gpodder-core/src/gpodder .
#	ln -sf podcastparser/podcastparser.py .
#	ln -sf gpodder-ui-qml/main.py .
#	ln -sf ../gpodder-ui-qml/common qml
#	ln -sf minidb/minidb.py .

	# emulate iteration over tuples by splitting at ','
	OLDIFS=$IFS
	for i in ${SYMLINKS[*]}; do
		IFS=',' read -r TARGET LINK_NAME <<< "${i}"
		ln -sf "$TARGET" "$LINK_NAME"
	done
	IFS=$OLDIFS
}

delete_symlinks() {

	# check first whether all targets are symlinks before deleting them
	# emulate iteration over tuples by splitting at ','
	OLDIFS=$IFS
	for i in ${SYMLINKS[*]}; do
		IFS=',' read -r TARGET LINK_NAME <<< "${i}"
		if [ ! -L "$LINK_NAME" ]; then
			echo "Error: $LINK_NAME is no symlink or doesn't exist. Aborting." >&2
			exit -2
		fi
	done

	# now actually delete them
	for i in ${SYMLINKS[*]}; do
		IFS=',' read -r TARGET LINK_NAME <<< "${i}"
		rm "$LINK_NAME"
	done
	IFS=$OLDIFS
}

case "$1" in
	"--help"|"-h")
		help
		exit 1;;
	"--unlink")
		delete_symlinks;;
	'')
		create_symlinks;;
	*)
		echo "invalid argument"
		exit -1
esac

exit 0
