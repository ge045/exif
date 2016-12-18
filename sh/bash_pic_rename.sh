#!/bin/bash

# rename files in case date format uses spaces
find "$1" -depth 1 -name "*.*" -exec sh -c 'mv "$1" "$(echo "$1" | sed s/\ /_/g)"' _ {} \;

# run through possible extensions,
# 'jpg' must be first !!!
for e in jpg JPG jpeg JPEG ; do
    # run through filelist
    echo $e "  ==================="

    for file in $( ls $1/*.$e ); do
        echo renaming $file
        exiflist -o l -f date-taken $file
        # get the date and time from exif
        dateTaken="$(exiflist -o l -f date-taken $file)"
        if [[ -z ${dateTaken// } ]]
        then
            echo No EXIF entry for file $file
            continue
        fi
        # split at first SPACE --> thus removing the time
        # (use just for separate into date directories) 
        # dateTaken=(${dateTaken// / })
        # replace forbidden characters
        dateTaken="$(echo $(echo "$dateTaken" | sed s/:/_/g | sed s/\ /_/g | sed s/\[.]/_/g | sed s/-/_/g ))"
        target="${1}/${dateTaken}.${e}"
        cnt=0
        while [ -f "$target" ]
        do
            let "cnt += 1"
            target="${1}/${dateTaken}-${cnt}.${e}"
        done
        mv "$file" "$target"
        # set date properties of file to dateTaken
        exiffile -t $1/$dateTaken.$e

        # that is the exiftool native rename function but it is somehow less flexible then pure bash operations
        #exiffile -t -n {date-taken}{basename $file .$e}.jpg $file
    done
done

# rename files in case date format uses ':'
#find $1 -depth 1 -name "*.jpg" -exec sh -c 'mv "$1" "$(echo "$1" | sed s/:/_/g)"' _ {} \;

