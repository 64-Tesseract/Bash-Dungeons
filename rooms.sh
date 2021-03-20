#!/bin/bash

IFS="%"
roomGrid () {  # $1: Layout ID
    case $1 in
        -1)
            grid=( 0  0  0  0  0 -2 -3 -3
                   0  0  0  0  0 -2 -3 -3
                   0  0  0  0  0  0 -2 -2
                   0  0  0 -1 -1  0  0  0
                   0  0  0 -1 -1  0  0  0
                   1  2  3  4  5  6  7  8
                   1  2  3  4  5  6  7  8
                   0  0  0  0  0  0  0  0)
            ;;
        0)
            grid=( 0  0  0  0  0  0  0  0
                   0  0  0  0  0  0  0  0
                   0  0  0  0  0  0  0  0
                   0  0  0  0  0  0  0  0
                   0  0  0  0  0  0  0  0
                   0  0  0  0  0  0  0  0
                   0  0  0  0  0  0  0  0
                   0  0  0  0  0  0  0  0)
            ;;
        1)
            grid=(-1  0  0  0  0  0  0  0
                   0 -1  0  0  0  0  0  0
                   0  0 -1  0  0  0  0  0
                   0  0  0 -1  0  0  0  0
                   0  0  0  0 -1  0  0  0
                   0  0  0  0  0 -1  0  0
                   0  0  0  0  0  0 -1  0
                   0  0  0  0  0  0  0 -1)
            ;;
        2)
            grid=( 0  0  0  0  0  0  0 -1
                   0  0  0  0  0  0 -1  0
                   0  0  0  0  0 -1  0  0
                   0  0  0  0 -1  0  0  0
                   0  0  0 -1  0  0  0  0
                   0  0 -1  0  0  0  0  0
                   0 -1  0  0  0  0  0  0
                  -1  0  0  0  0  0  0  0)
            ;;
        3)
            grid=( 0  0  0  0  0  0  0  0
                   0  0 -1 -1 -1 -1 -1  0
                   0  0  0  0  0  0 -1  0
                   0  0 -1 -1 -1  0 -1  0
                   0  0 -1 -3 -1  0 -1  0
                   0  0 -1  0  0  0 -1  0
                   0  0 -1 -1 -1 -1 -1  0
                   0  0  0  0  0  0  0  0)
            ;;
        4)
            grid=( 0  0  0  0  0  0  0  0
                   0  0  0  0  0  0  0  0
                  -1 -1 -1 -2 -2 -1 -1 -1
                   0  0  0  0  0  0  0  0
                   0  0  0  0  0  0  0  0
                  -1 -1 -1 -2 -2 -1 -1 -1
                   0  0  0  0  0  0  0  0
                   0  0  0  0  0  0  0  0)
            ;;
        5)
            grid=( 0  0 -1  0  0 -1  0  0
                   0  0 -1  0  0 -1  0  0
                   0  0 -1  0  0 -1  0  0
                   0  0 -2  0  0 -2  0  0
                   0  0 -2  0  0 -2  0  0
                   0  0 -1  0  0 -1  0  0
                   0  0 -1  0  0 -1  0  0
                   0  0 -1  0  0 -1  0  0)
            ;;
    esac
}

genRoom () {
    roomCoords="R$((playerPos[2])),$((playerPos[3]))"
    if ! [[ ${!rooms[@]} =~ (.*)$roomCoords(.*) ]]; then
        if [ $roomCoords == "R0,0" ]; then
            roomGrid -1
        else
            roomGrid $((RANDOM % 6))
        fi
        for y in {0..7}; do
            for x in {0..7}; do
                setObject "$roomCoords,$x,$y" $((grid[$x + $y * 8]))
            done
        done
    fi
}

setObject () {  # $1: Coords, $2: New ID
    if [ $2 -ne 0 ]; then
        rooms[$1]=$2
    else
        unset rooms[$1]
    fi
}

getObject () {  # $1: Coords
    if ! [[ ${!rooms[@]} =~ (.*)$1(.*) ]]; then
        objectID=0
    else
        objectID=${rooms[$1]}
    fi
}

echo "Rooms OK"