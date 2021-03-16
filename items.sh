#!/bin/bash

# -#-   -Name-      -Function-
# -3    Chest       Drops an item on interact
# -2    Crates      Breakable
# -1    Wall        Prevents passthrough
#  0    Nothing
#  1    Apple       Restores 1HP
#  2    Armour      Restores 1 shield
#  3    Old Rag     TODO Increases attack damage
#  4    Rock        TODO Deals damage proportional to HP
#  5    Potion      TODO Restores 1HP per turn for 4 turns
#  6    Poison      TODO Next attacked enemy will take 1HP for 4 turns
#  7    Posion      TODO Heals enemy by 4HP
#  8    Gold        TODO Looks nice


tileIcons() {
    case $1 in
        -1)
            tileIcon="▒▒"
            ;;
        -2)
            case $2 in
                0)
                    tileIcon="▚▚"
                    ;;
                1)
                    tileIcon="▞▞"
                    ;;
            esac
            ;;
        -3)
            tileIcon="┌╖"
            ;;
    esac
}

itemIcons() {
    case $1 in
        0)
            itemIcon=" "
            ;;
        1)
            itemIcon="•"
            ;;
        2)
            itemIcon="▾"
            ;;
        3)
            itemIcon="▰"
            ;;
        4)
            itemIcon="▪"
            ;;
        5)
            itemIcon="◬"
            ;;
        6|7)
            itemIcon="◭"
            ;;
        8)
            itemIcon="$"
            ;;
    esac
}

itemNames() {
    case $1 in
        0)
            itemName=" - None -"
            ;;
        1)
            itemName="Apple"
            ;;
        2)
            itemName="Armour"
            ;;
        3)
            itemName="Old Rag"
            ;;
        4)
            [ $invIndex -eq $equipped ] && itemName="[Rock]" || itemName="Rock"
            ;;
        5)
            itemName="Potion"
            ;;
        6)
            itemName="Poison"
            ;;
        7)
            itemName="Posion"
            ;;
        8)
            itemName="Gold"
            ;;
    esac
}

tileUse() {
    case $1 in
        -2)
            objectGrid[$gridIndex]=0
            setMessage "You smash the Crate"
            stepped=1
            ;;
        -3)
            objectGrid[$gridIndex]=$((RANDOM % 8 + 1))
            setMessage "You open the Chest"
            stepped=1
            ;;
    esac
}

itemFunctions() {
    case $1 in
        1)
            heal 1
            setMessage "You eat the Apple"
            inventory[$((action - 1))]=0
            stepped=1
            ;;
        2)
            armour 1
            setMessage "You put on the Armour"
            inventory[$((action - 1))]=0
            stepped=1
            ;;
        3)
            clean 1
            setMessage "You clean your weapon"
            inventory[$((action - 1))]=0
            stepped=1
            ;;
        4)
            setMessage "You equip the Rock"
            equipped=$((action - 1))
            messageLast=0
            ;;
        5)
            healOverTime=$((healOverTime + 4))
            setMessage "You drink the Potion"
            inventory[$((action - 1))]=0
            stepped=1
            ;;
        6)
            weaponPoison=$((weaponPoison + 4))
            setMessage "You apply the Poison to your weapon"
            inventory[$((action - 1))]=0
            stepped=1
            ;;
        7)
            weaponPoison=$((weaponPoison - 4))
            setMessage "You apply the Possion to your weapon"
            inventory[$((action - 1))]=0
            stepped=1
            ;;
        8)
            setMessage "You admire the Gold"
            stepped=1
            ;;
    esac
}

echo "Items OK"