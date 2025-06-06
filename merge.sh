#!/usr/bin/bash

OUTPUT="main.ahk"

mv ${OUTPUT} ${OUTPUT}.old

for file in *.ahk; do
    echo "Appending: ${file}"
    echo "; -------------------------------- ${file} -------------------------------- " >> main.ahk
    sed '1,2d' "$file" >> ${OUTPUT}  # trim off the first two line, and append
done

read -p "Delete the backup for original ${OUTPUT}.old (y/N): " ${confirm:-'N'} && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit

rm ${OUTPUT}.old