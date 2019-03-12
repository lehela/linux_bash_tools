#!/bin/bash
clear
echo
echo -----------------------------------------
echo Devices 
echo -----------------------------------------
sudo lsblk -o NAME,LABEL,SIZE,MOUNTPOINT,FSTYPE,MODEL,STATE,UUID
echo
echo -----------------------------------------
echo Usage 
echo -----------------------------------------
echo
df -h -t ext4 -t fuseblk --output=source,target,fstype,size,avail,pcent
echo
echo -----------------------------------------
echo Mounts  
echo -----------------------------------------
echo
findmnt -t ext4,fuseblk
echo

