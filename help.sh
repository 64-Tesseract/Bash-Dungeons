#!/bin/bash

helpLine() {
    [ $helpMode -eq 0 ] && return
    case $1 in
        0)
            [ $debug -eq 0 ] && echo -ne " \e[1;21m     Bash Dungeons    \e[0m" || echo -ne " \e[1;21m      [Debug $helpMode]       \e[0m"
            ;;
        1)
            [ $helpMode -eq 1 ] && echo -ne "  Move with \e[1mWASD\e[0m"
            [ $helpMode -eq 2 ] && echo -ne " \e[6;7m▪ \e[0m \e[1mItems\e[0m on left side"
            [ $helpMode -eq 3 ] && echo -ne "  Made by \e[1m64_Tesseract\e[0m"
            ;;
        2)
            [ $helpMode -eq 1 ] && echo -ne "  Wait with \e[1mSpace\e[0m"
            [ $helpMode -eq 2 ] && echo -ne " \e[6m ◷\e[0m \e[1mEntities\e[0m on right"
            [ $helpMode -eq 3 ] && echo -ne "  \e[1m15/03/21\e[0m - \e[1m??/??/??\e[0m"
            ;;
        3)
            [ $helpMode -eq 1 ] && echo -ne "  View backpack with \e[1mI\e[0m"
            [ $helpMode -eq 2 ] && echo -ne " \e[6;7m▒▒\e[0m \e[1mImpassible\e[0m on both"
            [ $helpMode -eq 3 ] && echo -ne "  In \e[1mBash\e[0m"
            ;;
        4)
            [ $helpMode -eq 1 ] && echo -ne "  Use items with \e[1m1-9\e[0m"
            [ $helpMode -eq 2 ] && echo -ne " \e[6m ◉\e[0m This is \e[1myou\e[0m"
            [ $helpMode -eq 3 ] && echo -ne "   with great \e[1meffort\e[0m"
            ;;
        5)
            [ $helpMode -eq 1 ] && echo -ne "  Use equipped with \e[1mF\e[0m"
            [ $helpMode -eq 2 ] && echo -ne "  Keep \e[1mHP\e[0m ◕ from 0 ○"
            ;;
        6)
            [ $helpMode -eq 1 ] && echo -ne "  Use an \e[1mempty slot\e[0m"
            [ $helpMode -eq 2 ] && echo -ne "  Equip \e[1mArmour\e[0m ▼ to"
            ;;
        7)
            [ $helpMode -eq 1 ] && echo -ne "      to pick up item"
            [ $helpMode -eq 2 ] && echo -ne "      protect yourself"
            ;;
        8)
            [ $helpMode -eq 1 ] && echo -ne "  Interact by \e[1mwalking\e[0m"
            ;;
        9)
            [ $helpMode -eq 3 ] && echo -ne "    ...Hide with \e[1mO\e[0m" ||
                                   echo -ne "  Next page with \e[1mO\e[0m"
            ;;
    esac
}

echo "Help OK"