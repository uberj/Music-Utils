#!/bin/bash

check_for_lib () {
    echo "Searching /usr/lib for libmp3lam3 library"
    if [ "$(find /usr/lib -iname libmp3lame.so*)" == ""  ]
    then
        echo "Error: libmp3lame.so was not found"
        echo "You should install <libavcodec-extra-52> as well."
        exit
    fi
    echo "Searching /usr/lib for youtube-dl"
    if [ "$(which youtube-dl)" == "" ]
    then
        echo "youtube-dl not found"
        echo "Find it here http://rg3.github.com/youtube-dl/"
        exit
    fi
}
usage () {
    echo "Usage: dl.sh <flag> <youtube url>"
    echo "flags:    -d  download single file"
    exit
}

if [ $# -ne 2 ]
then
    usage
fi
check_for_lib


work_dir=$HOME/Music/
case "$1" in
    -d)
        tmp_file="$(echo $2 | sed 's/.*=//g')"
        # Remove tmp if it exist, clear it if it does.
        if [ -d ".$tmp_file" ]
        then
            rm -rf ".$tmp_file"
            mkdir ".$tmp_file"
        else
            mkdir ".$tmp_file"
        fi
        cd ".$tmp_file"
        echo -n "Moving into "
        pwd
        youtube-dl -t $2
        for file in ./*
        do
            echo "${file}"
            case "$file" in
                *.flv)
                    echo "Flv"
                    new=`echo $file | sed 's/\.flv$/\.mp3/g' | sed 's/\ /_/g'`
                    ;;
                *.mp4)
                    echo "mp4"
                    new=`echo $file | sed 's/\.mp4$/\.mp3/g' | sed 's/\ /_/g'`
                    ;;
                *.webm)
                    echo "webm"
                    new=`echo $file | sed 's/\.webm$/\.mp3/g' | sed 's/\ /_/g'`
                    ;;
                *)
                    echo "unknown file type"
                    exit 2
            esac

            ffmpeg -i "$file" -acodec libmp3lame -ab 128k "$new"
            mv "$new" $HOME/Music/Singles
            mv "$file" ../.orig
            cd ../
            rm -rf $tmp_file
        done
        ;;
    esac
exit
