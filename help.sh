#!/bin/bash

helpLine() {
    [ $helpMode -eq 0 ] && return
    case $1 in
        0)
            [ $debug -eq 0 ] && echo -ne " \e[1;4m     Bash Dungeons    \e[0m" || echo -ne " \e[1;4m     [Debug Mode]     \e[0m"
            ;;
        1)
            [ $helpMode -eq 1 ] && echo -ne "  Move with \e[1mWASD\e[0m ◉" || echo -ne "  Made by \e[1m64_Tesseract\e[0m"
            ;;
        2)
            [ $helpMode -eq 1 ] && echo -ne "  Wait with \e[1mSpace\e[0m" || echo -ne "  \e[1m15/03/21\e[0m - \e[1m??/??/??\e[0m"
            ;;
        3)
            [ $helpMode -eq 1 ] && echo -ne "  View backpack with \e[1mI\e[0m" || echo -ne "  In \e[1mBash\e[0m"
            ;;
        4)
            [ $helpMode -eq 1 ] && echo -ne "  Use items with \e[1m1-9\e[0m" || echo -ne "   with great \e[1meffort\e[0m"
            ;;
        5)
            [ $helpMode -eq 1 ] && echo -ne "  Use equipped with \e[1mF\e[0m"
            ;;
        6)
            [ $helpMode -eq 1 ] && echo -ne "  Use an \e[1mempty slot\e[0m"
            ;;
        7)
            [ $helpMode -eq 1 ] && echo -ne "   to pick up item"
            ;;
        8)
            [ $helpMode -eq 1 ] && echo -ne "  Interact by \e[1mwalking\e[0m"
            ;;
        9)
            [ $helpMode -eq 2 ] && echo -ne "       ...Hide with \e[1mO\e[0m"
            ;;
    esac
}

echo "Help OK"