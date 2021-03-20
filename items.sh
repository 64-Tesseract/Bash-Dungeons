#!/bin/bash

# -#-   -Name-      -Function-
# -4    Mimic       Turns into an enemy when interacted with
# -3    Chest       Drops an item on interact
# -2    Rocks       Breakable
# -1    Wall        Prevents passthrough
#  0    Nothing
#  1    Apple       Restores 1HP
#  2    Armour      Restores 1 shield
#  3    Old Rag     TODO Increases attack damage
#  4    Rock        TODO Throw at a random enemy, dealing damage proportional to HP
#  5    Potion      Restores 1HP per turn for 4 turns
#  6    Poison      TODO Next attacked enemy will take 1HP for 4 turns
#  7    Posion      TODO Heals enemy by 4HP
#  8    Gold        Looks nice

IFS="%"
itemCount=9

tileIcons() {  # $1: Tile ID, $2: Odd/Even
    case $1 in
        -1)
            tileIcon="▒▒"
            ;;
        -2)
            case $2 in
                0)
                    tileIcon="▀▄" # "▚▚"
                    ;;
                1)
                    tileIcon="▄▀" # "▞▞"
                    ;;
            esac
            ;;
        -3|-4)
            tileIcon="┌╖"
            ;;
    esac
}

declare -A itemIcons
itemIcons=([0]=" " [1]="•" [2]="▾" [3]="▰" [4]="▪" [5]="◬" [6]="◭" [7]="◭" [8]="$")

declare -A itemNames
itemNames=([0]=" - None -" [1]="Apple" [2]="Armour" [3]="Old Rag" [4]="Rock" [5]="Potion" [6]="Poison" [7]="Posion" [8]="Gold")

tileUse() {  # $1: Tile ID
    case $1 in
        -2)
            setObject $objectIndex $((RANDOM % 4 / 3 * 4))  # 1 in 4 chance of dropping a rock
            setMessage "You smash through the Rocks"
            stepped=1
            ;;
        -3)
            setObject $objectIndex $((RANDOM % (itemCount - 1) + 1))
            setMessage "You open the Chest"
            stepped=1
            ;;
    esac
}

itemFunctions() {  # $1: Item ID
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
            setMessage "You lob the rock at the $enemy"
            # TODO
            stepped=1
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