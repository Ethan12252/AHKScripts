#!/usr/bin/bash -i

OUTPUT="main.ahk"

mv ./${OUTPUT} ./${OUTPUT}.old

printf "#Requires AutoHotkey v2.0-a \n#SingleInstance Force\n" > ${OUTPUT}

for file in *.ahk; do
    if [[ "$file" != "$OUTPUT" && "$file" != "${OUTPUT}.old" ]]; then
        echo "Appending: ${file}"
        { echo ""; echo "; -------------------------------- ${file} -------------------------------- "; } >> ${OUTPUT}
        sed '1,2d' "$file" >> ${OUTPUT}  # trim off the first two line, and append
    fi
done

read -p "Delete the backup for original ${OUTPUT}.old (Y/n): " confirm

if [[ $confirm == [yY] ]]; then
    rm ${OUTPUT}.old 2> /dev/null
    exit 0
fi

exit 0

