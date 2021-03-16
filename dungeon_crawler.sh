#!/bin/bash

IFS="%"
cd "${0%/*}"
source items.sh
source help.sh

debug=0
#       PlayerX/Y  RoomX/Y
player=(      1 1      0 0)
lives=3
shields=0
stepCounter=0
stepped=0
action=-1
equipped=-1
healOverTime=0
weaponPoison=0
invMode=1
discardMode=0
helpMode=1
inventory=(0 0 0 0 0 0 0 0 0)
message="You awaken in a room..."
messageLast=0
objectGrid=(0  0  0  0  0 -2 -3 -3
            0  0  0  0  0 -2 -3 -3
            0  0  0  0  0  0 -2 -2
            0  0  0 -1 -1  0  0  0
            0  0  0 -1 -1  0  0  0
            1  2  3  4  5  6  7  8
            1  2  3  4  5  6  7  8
            0  0  0  0  0  0  0  0)


printChar() {  # Draws grid element
    oddCell=$((($1 + $2) % 2))
    oddRoom=$(($((player[2] + player[3])) % 2))
    [ $oddRoom -lt 0 ] && oddRoom=$((oddRoom + 2))
    if [ $oddCell -eq $oddRoom ]; then echo -ne "\e[47;30m"; fi
    
    objectIndex=$(($1 + $2 * 8))
    objectID=$((objectGrid[objectIndex]))
    
    if [ $objectID -ge 0 ]; then
        itemIcons $objectID
        echo -n $itemIcon
        
        if [ $((player[0])) -eq $1 ] && [ $((player[1])) -eq $2 ]; then
            echo -n "◉"
        else
            echo -n " "
        fi
    else
        tileIcons $objectID $(($oddCell == $oddRoom ? 1 : 0))
        echo -n $tileIcon
    fi
    ## if [ $((($1 + $2) % 2)) -eq 0 ]; then echo -n "\e[0m"; fi
    echo -ne "\e[0m"
}

printHeart() {  # Prints a heart icon
    if [ $1 -le 0 ]; then
        echo -n "○"
    elif [ $1 -eq 1 ]; then
        echo -n "◔"
    elif [ $1 -eq 2 ]; then
        echo -n "◑"
    elif [ $1 -eq 3 ]; then
        echo -n "◕"
    else
        echo -n "●"
    fi
}

printShield() {  # Prints a shield icon
    if [ $1 -le 0 ]; then
        echo -n "▽"
    else
        echo -n "▼"
    fi
}

printLifeBar() {  # Prints armour, steps, & hearts
    echo -n "│"
    printShield $shields
    printShield $((shields - 1))
    printShield $((shields - 2))
    printShield $((shields - 3))
    
    spaceCount=$((6 - ${#stepCounter}))
    ## echo $spaceCount
    for (( space=0; space <= $((spaceCount / 2)); space++ )); do echo -n " "; done
    echo -n $stepCounter
    for (( space=0; space <= $(((spaceCount + 1) / 2)); space++ )); do echo -n " "; done
    
    printHeart $((lives - 12))
    printHeart $((lives - 8))
    printHeart $((lives - 4))
    printHeart $lives
    echo "│"
}

printInventory() {  # Prints items in inventory
    [ $invMode -eq 0 ] && return
    for invIndex in {0..8}; do
        if [ $((inventory[invIndex])) -eq 0 ] && [ $invMode -eq 1 ]; then continue; fi
        itemNames $((inventory[invIndex]))
        spaceCount=$((12 - ${#itemName}))
        echo -en "│$((invIndex + 1)): \e[1m"
        [ $discardMode -eq 1 ] && echo -en "\e[9m" 
        echo -en $itemName
        for (( space=0; space <= $spaceCount; space++ )); do echo -n " "; done
        echo -e "\e[0m│"
    done
    echo "│                ╵"
}

heal() {  # Add value to `$lives`
    newLives=$((lives + $1))
    lives=$((newLives > 16 ? 16 : newLives))
}

armour() {  # Add value to `$shields`
    newShields=$((shields + $1))
    shields=$((newShields > 4 ? 4 : newShields))
}

setMessage() {  # Set message
    message=$1
    messageLast=-1
}

tryMove() {
    tryX=$((player[0] + $1))
    tryY=$((player[1] + $2))
    gridIndex=$((tryX + tryY * 8))
    objectID=$((objectGrid[gridIndex]))
    
    if [[ $tryX =~ [3,4] ]] && [ $tryY -eq -1 ]; then
        player[1]=7
        player[3]=$((player[3] - 1))
        stepped=1
    elif [[ $tryX =~ [3,4] ]] && [ $tryY -eq 8 ]; then
        player[1]=0
        player[3]=$((player[3] + 1))
        stepped=1
    elif [[ $tryY =~ [3,4] ]] && [ $tryX -eq -1 ]; then
        player[0]=7
        player[2]=$((player[2] - 1))
        stepped=1
    elif [[ $tryY =~ [3,4] ]] && [ $tryX -eq 8 ]; then
        player[0]=0
        player[2]=$((player[2] + 1))
        stepped=1
    elif [ $objectID -le -2 ]; then
        tileUse $objectID
    elif [ $tryX -eq -1 ] || [ $tryY -eq -1 ] || [ $tryX -eq 8 ] || [ $tryY -eq 8 ] || [ $objectID -eq -1 ]; then
        setMessage "You bump into a wall"
        messageLast=0
    else
        player[0]=$tryX
        player[1]=$tryY
        stepped=1
    fi
}

doActions() {  # Read actions & perform them
    stty echo
    read -sN 1 action
    case $action in
        "w") # Move Up
            tryMove 0 -1
            ;;
        "a")  # Move Left
            tryMove -1 0
            ;;
        "s")  # Move Down
            tryMove 0 1
            ;;
        "d")  # Move Right
            tryMove 1 0
            ;;
        " ")  # Wait
            stepped=1
            ;;
        0)  # Set inv mode to discard
            discardMode=$((($discardMode + 1) % 2))
            ;;
        [1-9])  # Discard or Use Item, or Pick up
            itemID=$((inventory[action - 1]))
            if [ $discardMode -eq 0 ]; then
                if [ $itemID -ne 0 ]; then
                    itemFunctions $itemID
                else
                    gridIndex=$((player[0] + player[1] * 8))
                    itemID=$((objectGrid[gridIndex]))
                    if [ $itemID -ne 0 ]; then
                        itemNames $itemID
                        inventory[$((action - 1))]=$itemID
                        objectGrid[$gridIndex]=0
                        setMessage "You picked up $itemName"
                        stepped=1
                    fi
                fi
            else
                itemNames $itemID
                setMessage "You discard the $itemName"
                messageLast=0
                inventory[$((action - 1))]=0
                [ $equipped -eq $((action - 1)) ] && equipped=-1
            fi
            ;;
        "i")  # Change Inventory View
            invMode=$((($invMode + 1) % 3))
            ;;
        "o")  # Change Help View
            helpMode=$((($helpMode + 1) % 4))
            ;;
        "h")  # Debug Heal
            [ $debug -eq 1 ] && heal 1
            ;;
        "j")  # Debug Armour
            [ $debug -eq 1 ] && armour 1
            ;;
    esac
    stty -echo
}


until [ $lives -eq 0 ]; do
    clear
    ## tput cup 0 0
    
    # -- GUI Rendering --
    # Top line ╔╡x╞═══┄┄┄┄═══╡y ╞╗
    spaceCountLeft=$((3 - ${#player[2]}))
    spaceCountRight=$((3 - ${#player[3]}))
    echo -n "╔╡$((player[2]))╞"
    for (( space=0; space <= $spaceCountLeft; space++ )); do echo -n "═"; done
    echo -n "┄┄┄┄"
    for (( space=0; space <= $spaceCountRight; space++ )); do echo -n "═"; done
    echo -n "╡$((player[3]))╞╗"
    helpLine 0
    echo
    
    # Side walls
    for y in {0..7}; do
        if [ $y -eq 3 ] || [ $y -eq 4 ]; then echo -n "┊"; else echo -n "║"; fi
        for x in {0..7}; do
            printChar $x $y
        done
        if [ $y -eq 3 ] || [ $y -eq 4 ]; then echo -n "┊"; else echo -n "║"; fi
        helpLine $((y + 1))
        echo
    done
    
    # Bottom wall
    echo -n "╚══════┄┄┄┄══════╝"
    helpLine 9
    echo
    
    # HUD elements
    printLifeBar
    printInventory
    echo -en "╰\e[3m"
    if [ $messageLast -ne 0 ]; then
        echo -en "\e[2m"
    fi
    echo -en "$message\e[0m"
    
    doActions
    
    # -- If move occured --
    if [ $stepped -eq 1 ]; then
        # TODO: Monster AIs
        if [ $healOverTime -gt 0 ]; then
            healOverTime=$((healOverTime - 1))
            heal 1
        elif [ $healOverTime -lt 0 ]; then
            healOverTime=$((healOverTime + 1))
            heal -1
            damagedBy+="\nwith Poison"
        fi
        stepCounter=$((stepCounter + 1))
        messageLast=$((messageLast + 1))
        stepped=0
        discardMode=0
    fi
done