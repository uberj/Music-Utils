#!/bin/bash

check_for_lib () {
    echo "Searching /usr/lib for libmp3lam3 library"
    if [ "$(find /usr/lib -iname libmp3lame.so*)" == ""  ]
    then
        echo "Error: libmp3lame.so was not found"
        echo "You should install <libavcodec-extra-52> as well."
        exit
    elif [ "$(which youtube-dl)" == "" ]
    then
        echo "youtube-dl not found"
        echo "Find it here http://rg3.github.com/youtube-dl/"
        exit
    fi
}

check_for_lib
echo $1 $2
work_dir=$HOME/Music/
case "$1" in
    -d)
        pwd
        tmp_file="$(echo $2 | sed 's/.*=//g')"
        # Remove tmp if it exist, clear it if it does.
        # Eventually, you should just exit from this case. It
        # probably means there are concurent downloads of the
        # same file.
        if [ -d ".$tmp_file" ]
        then
            echo "removing dir"
            rm -rf ".$tmp_file"
            echo "making new dir"
            mkdir ".$tmp_file"
        else
            echo "making new dir"
            mkdir ".$tmp_file"
        fi
        cd ".$tmp_file"
        pwd
        youtube-dl -t $2
        for file in ./*
        do
            echo -n "File is: "
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
            #rm -rf $tmp_file
        done
        ;;
    esac
exit
