#!/usr/bin/bash 

# OUTPUT="main.ahk"

# mv ./${OUTPUT} ./${OUTPUT}.old

# printf "#Requires AutoHotkey v2.0-a \n#SingleInstance Force\n" > ${OUTPUT}

# for file in *.ahk; do
#     if [[ "$file" != "$OUTPUT" && "$file" != "${OUTPUT}.old" ]]; then
#         echo "Appending: ${file}"
#         { echo ""; echo "; -------------------------------- ${file} -------------------------------- "; } >> ${OUTPUT}
#         sed '1,2d' "$file" >> ${OUTPUT}  # trim off the first two line, and append
#     fi
# done

# read -p "Delete the backup for original ${OUTPUT}.old (Y/n): " confirm

# if [[ $confirm == [yY] ]]; then
#     rm ${OUTPUT}.old 2> /dev/null
#     exit 0
# fi

# exit 0

merge() {
    OUTPUT="main.ahk"

    mv ./${OUTPUT} ./${OUTPUT}.old 2> /dev/null

    printf "#Requires AutoHotkey v2.0 \n#SingleInstance Force\n" > ${OUTPUT}

    for file in *.ahk; do
        if [[ "$file" != "$OUTPUT" && "$file" != "${OUTPUT}.old" ]]; then
            echo "Appending: ${file}"
            printf "#Include %s\n" "${file}" >> ${OUTPUT}
        fi
    done

    read -p "Delete the backup for original ${OUTPUT}.old (Y/n): " confirm

    if [[ $confirm == [yY] ]]; then
        rm ${OUTPUT}.old 2> /dev/null
        exit 0
    fi
}

if [[ $# -eq 0 || $1 == "merge" ]]; then
    merge
elif [[ $1 == "startup" ]]; then
    powershell.exe ./create_shortcut.ps1 './main.ahk'
    echo "Added a shortcut to the startup folder"
fi

exit 0

