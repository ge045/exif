#!/bin/bash

if [ $# -eq 0 ]
  then
    INDIR=.
else
    INDIR=$1
fi

echo "Searching directory $INDIR"
set -x

# loop through possible extensions,
for ext in jpg jpeg ; do
    set +x
    echo ======================
    echo Process all $ext files
    echo ======================
    set -x

    # loop through files
    # use a loop that properly handles filepaths containing spaces
    find "${INDIR}" -depth 1 -type f -iname "*.${ext}" -print0 | while read -d $'\0' file
    do
        set +x
        echo renaming $file
        set -x

        # in case of spaces escape them
        FILE=$(printf %q "$file")

        # exiflist cannot handle this properly, thus indirect through eval
        cmd=$(echo exiflist -o l -f date-taken $FILE)
        eval $cmd

        # get the date and time from exif; omit in case no date was returned
        dateTaken="$(eval $cmd)"
        if [[ -z ${dateTaken// } ]]
        then
            set +x
            echo No EXIF entry for file $file
            set -x
            continue
        fi
        # replace forbidden characters
        dateTaken="$(echo $(echo "$dateTaken" | sed s/:/_/g | sed s/\ /_/g | sed s/\[.]/_/g | sed s/-/_/g ))"
        target="${INDIR}/${dateTaken}.${ext}"
        cnt=0
        while [ -f "$target" ]
        do
            let "cnt += 1"
            target="${INDIR}/${dateTaken}-${cnt}.${ext}"
        done
        mv "$file" "$target"
        # set date properties of file to dateTaken
        exiffile -t ${INDIR}/${dateTaken}.${ext}

        # that is the exiftool native rename function but it is
        # somehow less flexible then pure bash operations
        #exiffile -t -n {date-taken}{basename $file .$ext}.jpg $file
    done
done

# rename files in case date format uses ':'
#find $1 -depth 1 -name "*.jpg" -exec sh -c 'mv "$1" "$(echo "$1" | sed s/:/_/g)"' _ {} \;

