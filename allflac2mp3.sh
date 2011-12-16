#!/bin/bash

function flac2mp3(){

    find *.flac -print0 | while read -d $'\0' a
    do
    OUTF=`echo "$a" | sed s/\.flac$/.mp3/g`

    ARTIST=`metaflac "$a" --show-tag=ARTIST | sed s/.*=//g`
    TITLE=`metaflac "$a" --show-tag=TITLE | sed s/.*=//g`
    ALBUM=`metaflac "$a" --show-tag=ALBUM | sed s/.*=//g`
    GENRE=`metaflac "$a" --show-tag=GENRE | sed s/.*=//g`
    TRACKNUMBER=`metaflac "$a" --show-tag=TRACKNUMBER | sed s/.*=//g`
    DATE=`metaflac "$a" --show-tag=DATE | sed s/.*=//g`

    flac -c -d "$a" | lame -m j -q 0 --vbr-new -V 0 -s 44.1 - "$OUTF"
    id3 -t "$TITLE" -T "${TRACKNUMBER:-0}" -a "$ARTIST" -A "$ALBUM" -y "$DATE" -g "${GENRE:-12}" "$OUTF"

    done

}

function do_dir(){
    find *.flac > /dev/null
    if [ $? -eq 0 ]
    then
        echo "****Found flac in `pwd`"
        flac2mp3
        if [ ! -d ".flac_files" ]
        then
            mkdir .flac_files
        fi
        mv *.flac .flac_files/
    fi

    for file in ./*
    do
        if [ -f "$file" ]
        then
            echo "****Regulare file ".$file
            continue
        fi

        if [ -d "$file" ]
        then
            cd $file
            echo "****In dir $file"
            ls
            do_dir # Recurse
            cd ../
        else
            echo "****File not dir: ".$file
        fi
    done
}

do_dir

