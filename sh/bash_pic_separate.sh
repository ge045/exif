#!/bin/bash

set -x

# rename files in case date format uses spaces
INDIR=$@
find "${INDIR}" -depth 1 -name "*.*" -exec sh -c 'mv "$1" "$(echo "$1" | sed s/\ /_/g)"' _ {} \;

# run through possible extensions,
# 'jpg' must be first !!!
for e in jpg JPG jpeg JPEG ; do
    # run through filelist
    echo $e "  ==================="

    for file in $( ls ${INDIR}/*.$e ); do
        echo renaming $file
        exiflist -o l -f date-taken $file
        # get the date and time from exif 
        dateTaken="$(exiflist -o l -f date-taken $file)"
        # split at first SPACE --> thus removing the time
        dateTaken=(${dateTaken// / })
        # replace forbidden characters
        dateTaken="$(echo $(echo "$dateTaken" | sed s/:/_/g | sed s/\ /_/ | sed s/\[.]/_/g | sed s/-/_/g ))"
        if [ ! -d "$INDIR/$dateTaken" ]; then
            mkdir $INDIR/$dateTaken
        fi
        fileName="$(basename $file)"
        mv $file $INDIR/$dateTaken/$fileName
        # set date properties of file to dateTaken
        exiffile -t $INDIR/$dateTaken/$fileName
    done
done

