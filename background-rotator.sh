#!/bin/sh

files=(/home/mn/Pictures/Wallpaper/*.*)
count_of_files=$( ls -l /home/mn/Pictures/Wallpaper | wc -l )

echo "There are $count_of_files files in the Wallpaper directory."

random_num=$[ $RANDOM % count_of_files + 0]

echo "Random number is $random_num"

echo "Setting ${files[random_num]} as the new Wallaper"

gsettings set org.gnome.desktop.background picture-uri file://${files[random_num]}
gsettings set org.gnome.desktop.background picture-uri-dark file://${files[random_num]}
