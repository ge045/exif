#!/bin/bash

set -x

INDIR=$1

# loop through possible extensions,
for ext in jpg jpeg ; do
    echo ======================
    echo Process all $ext files
    echo ======================

    # loop through files
    # use a loop that properly handles filepaths containing spaces
    find "${INDIR}" -depth 1 -type f -iname "*.${ext}" -print0 | while read -d $'\0' file
    do
        echo renaming $file

        # in case of spaces escape them
        FILE=$(printf %q "$file")

        # exiflist cannot handle this properly, thus indirect through eval
        cmd=$(echo exiflist -o l -f date-taken $FILE)
        eval $cmd

        # get the date and time from exif; omit in case no date was returned
        dateTaken="$(eval $cmd)"
        if [[ -z ${dateTaken// } ]]
        then
            echo No EXIF entry for file $file
            continue
        fi
        # split at first SPACE --> thus removing the time
        dateTaken=(${dateTaken// / })
        # replace forbidden characters
        dateTaken="$(echo $(echo "$dateTaken" | sed s/:/_/g | sed s/\ /_/ | sed s/\[.]/_/g | sed s/-/_/g ))"

        # move in place
        mkdir -p "${INDIR}"/$dateTaken
        fileName="$(basename "$file")"
        mv "$file" "${INDIR}/$dateTaken/$fileName"

        # set date properties of file to dateTaken
        exiffile -t "${INDIR}/$dateTaken/$fileName"

    done
done

