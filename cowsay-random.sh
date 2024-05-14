#!/bin/sh

files=(/usr/share/cows/*.cow)
count_of_files=$( ls -l /usr/share/cows/*.cow | wc -l )

random_num=$[ $RANDOM % count_of_files + 0]

cowsay -f $(basename ${files[random_num]} .cow) $1 | lolcat
