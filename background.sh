#!/usr/bin/bash
# vim: ts=8:sts=4:sw=4:et
#
# ----- background.sh
#
# fancy script to run a command in the background
#

# define an array
declare -a cmd_queue

# function to add 4 spaces, use like a pipe
indent() { 
    sed 's/^/    /'; 
}

# clear the command queue
cmd_clear () {
    unset cmd_queue
    declare -a cmd_queue
}

# add command to queue
cmd_addqueue () {
    #echo "adding $1"
    cmd_queue+=("${1}")
    #echo "# of elements = ${#cmd_queue[@]}"
}

# list commands
cmd_printqueue () {

    for value in "${cmd_queue[@]}"; do
        echo "$value"
    done
}

# the guts, this does the magic
runcommand () {
    # temp file to "watch" the output from the background process
    OutputFile=$(mktemp)
    
    # viewport is 6 lines high
    # pad with (viewport-1) blank lines
    echo -e \n\n\n\n\n > $OutputFile
    
    # exec commands in array
    # echo "runcommand"
    # cmd_printqueue
    
    # run through the queued command in the cmd_queue array
    for value in "${cmd_queue[@]}"; do
    
        # Execute command
        # Redirect stdout->append to $OutputFile, combine stderr with stdout, & run in background 
        ${value} >> $OutputFile 2>&1 &
        # save PID to detect end of task
        PID=$!
        
        # repeat (ticker loop)
        while true; do
            # We have viewport lines to use
            # Line 1: ticker & job command line
            tput bold
            echo -e "\r-   Running ${value}... "
            echo "----------------------------------------"
            
            # Line 2 to (viewport-1). column limited tail
            tput dim
            
            # print last 5 lines of output
            # cut line width to (screen.width-4)
            # add 4 spaces to start of line via local function indent
            # put tail before cut; was other way around
            # **note** indent adds 4 spaced; the may cause misalignment with tabbed outputs
            tail -n 5 | cut -c -$(($(tput cols)-4)) $OutputFile | indent
            
            # if background process isn't running, break
            # **only way out of the ticker loop**
            sudo kill -0 $PID > /dev/null 2>&1 || break
            
            # make ticker TICK, i.e. the ticker change rate is about 4 times per second
            sleep 0.25
            
            # go back UP (viewport+1) lines
            # why +1? 6th line printed with newline
            tput cuu1
            tput cuu1
            tput cuu1
            tput cuu1
            tput cuu1
            tput cuu1
            tput cuu1
            tput ed
            
            # Repeated 2x more times, only differentce is the echo first echo which has the ticker (animated "-")
            # left in the old comments
            
            # We have 6 lines to use
            # Line 1 - ticker
            tput bold
            echo -e "\r -  Running ${value}... "
            echo "----------------------------------------"
            # Line 2-5. column limited tail
            tput dim
            cut -c -$(($(tput cols)-4)) $OutputFile | indent | tail -n 5
            # if background process isn't running, break
            sudo kill -0 $PID > /dev/null 2>&1 || break
            # make ticker TICK
            sleep 0.25
            # go back UP 6 lines
            tput cuu1
            tput cuu1
            tput cuu1
            tput cuu1
            tput cuu1
            tput cuu1
            tput cuu1
            tput ed

            # We have 6 lines to use
            # Line 1 - ticker
            tput bold
            echo -e "\r  - Running ${value}... "
            echo "----------------------------------------"
            # Line 2-5. column limited tail
            tput dim
            cut -c -$(($(tput cols)-4)) $OutputFile | indent | tail -n 5
            # if background process isn't running, break
            sudo kill -0 $PID > /dev/null 2>&1 || break
            # make ticker TICK
            sleep 0.25
            # go back UP 6 lines
            tput cuu1
            tput cuu1
            tput cuu1
            tput cuu1
            tput cuu1
            tput cuu1
            tput cuu1
            tput ed
            
            
        done
        tput bold
        
        wait $PID
        echo "----------------------------------------"
        echo "Errorcode=$?"
        echo -e
        echo -e
    done
}



cmd_clear
cmd_addqueue "sudo apt update"
cmd_addqueue "sudo apt -y upgrade"
cmd_addqueue "sudo apt -y autoremove"
runcommand
