#!/bin/bash

IFS="%"
cd "${0%/*}"
source items.sh
source help.sh
source rooms.sh

read -sn 1 -t 5

debug=0
playerPos=(1 1  0 0)    # Position & room ID
health=3                # Starting life
shields=0               # Starting armour
stepCounter=0           # Number of moves made
stepped=0               # Whether to advence the step count
action=""               # Last action performed
healOverTime=0          # Potion/Poison effect, HP over time
weaponPoison=0          # Poison applied to monsters attacked
invMode=1               # Inventory view mode
helpMode=1              # Help view mode
discardMode=0           # Whether to discard a inventory items when selected
inventory=(0 0 0 0 0 0 0 0 0)
message="You awaken in a room..."
messageLast=0
declare -A rooms        # roomX, roomY, gridX, gridY: item
declare -A enemies      # posX, posY, var: type, health, shields, poison, stun
genRoom


printChar() {  # Draws grid element
    oddCell=$((($1 + $2) % 2))
    oddRoom=$(($((playerPos[2] + playerPos[3])) % 2))
    [ $oddRoom -lt 0 ] && oddRoom=$((oddRoom + 2))
    if [ $oddCell -eq $oddRoom ]; then echo -ne "\e[47;30m"; fi
    
    objectIndex="R$((playerPos[2])),$((playerPos[3])),$1,$2"
    getObject $objectIndex
    
    if [ $objectID -ge 0 ]; then
        echo -n ${itemIcons[$objectID]}
        
        if [ $((playerPos[0])) -eq $1 ] && [ $((playerPos[1])) -eq $2 ]; then
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
    
    printHeart $((health - 12))
    printHeart $((health - 8))
    printHeart $((health - 4))
    printHeart $health
    echo "│"
}

printInventory() {  # Prints items in inventory
    [ $invMode -eq 0 ] && return
    for invIndex in {0..8}; do
        if [ $((inventory[invIndex])) -eq 0 ] && [ $invMode -eq 1 ]; then continue; fi
        itemID=${inventory[invIndex]}
        itemName=${itemNames[$itemID]}
        spaceCount=$((12 - ${#itemName}))
        echo -en "│$((invIndex + 1)): \e[1m"
        [ $discardMode -eq 1 ] && echo -en "\e[9m"
        echo -en $itemName
        for (( space=0; space <= $spaceCount; space++ )); do echo -n " "; done
        echo -e "\e[0m│"
    done
    echo "│                ╵"
}

heal() {  # Add value to `$health`
    newHealth=$((health + $1))
    health=$((newHealth > 16 ? 16 : newHealth))
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
    tryX=$((playerPos[0] + $1))
    tryY=$((playerPos[1] + $2))
    objectIndex="R$((playerPos[2])),$((playerPos[3])),$tryX,$tryY"
    getObject $objectIndex
    
    if [[ $tryX =~ [3,4] ]] && [ $tryY -eq -1 ]; then
        playerPos[1]=7
        playerPos[3]=$((playerPos[3] - 1))
        stepped=1
        genRoom
    elif [[ $tryX =~ [3,4] ]] && [ $tryY -eq 8 ]; then
        playerPos[1]=0
        playerPos[3]=$((playerPos[3] + 1))
        stepped=1
        genRoom
    elif [[ $tryY =~ [3,4] ]] && [ $tryX -eq -1 ]; then
        playerPos[0]=7
        playerPos[2]=$((playerPos[2] - 1))
        stepped=1
        genRoom
    elif [[ $tryY =~ [3,4] ]] && [ $tryX -eq 8 ]; then
        playerPos[0]=0
        playerPos[2]=$((playerPos[2] + 1))
        stepped=1
        genRoom
    elif [ $tryX -eq -1 ] || [ $tryY -eq -1 ] || [ $tryX -eq 8 ] || [ $tryY -eq 8 ] || [ $objectID -eq -1 ]; then
        setMessage "You bump into a wall"
        messageLast=0
    elif [ $objectID -le -2 ]; then
        tileUse $objectID
    else
        playerPos[0]=$tryX
        playerPos[1]=$tryY
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
                    objectIndex="R$((playerPos[2])),$((playerPos[3])),$((playerPos[0])),$((playerPos[1]))"
                    getObject $objectIndex
                    if [ $objectID -ne 0 ]; then
                        inventory[$((action - 1))]=$objectID
                        setObject $objectIndex 0
                        setMessage "You pick up the ${itemNames[$objectID]}"
                        stepped=1
                    fi
                fi
            elif [ $itemID -ne 0 ]; then
                setMessage "You discard the ${itemNames[$itemID]}"
                messageLast=0
                inventory[$((action - 1))]=0
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


until [ $health -eq 0 ]; do
    clear
    ## echo ${!rooms[@]}
    ## tput cup 0 0
    
    # -- GUI Rendering --
    # Top line ╔╡x╞═══┄┄┄┄═══╡y ╞╗
    spaceCountLeft=$((3 - ${#playerPos[2]}))
    spaceCountRight=$((3 - ${#playerPos[3]}))
    echo -n "╔╡$((playerPos[2]))╞"
    for (( space=0; space <= $spaceCountLeft; space++ )); do echo -n "═"; done
    echo -n "┄┄┄┄"
    for (( space=0; space <= $spaceCountRight; space++ )); do echo -n "═"; done
    echo -n "╡$((playerPos[3]))╞╗"
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