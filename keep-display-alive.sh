#!/bin/bash
# This script periodically moves the mouse pointer by 1 pixel and back
# to simulate user activity and prevent screen blanking

# Wait for X to be fully started
sleep 10

while true; do
    # Get the current mouse position
    eval $(xdotool getmouselocation --shell)
    
    # Move mouse 1 pixel to the right
    xdotool mousemove $((X+1)) $Y
    
    # Wait a bit
    sleep 0.5
    
    # Move mouse back
    xdotool mousemove $X $Y
    
    # Wait 50 seconds before next activity simulation
    sleep 50
done
