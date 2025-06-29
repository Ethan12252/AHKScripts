#!/usr/bin/bash 

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

generate_config() {
    cat > config.ini <<EOF
[global]
device="msi_laptop"

[LaunchTerminal]
WslProfileName="Ubuntu 20.04 (WSL)"

[PotPlayerFastFoward]
FastSpeed=3.0
ResetSpeed=1.0
EOF
    echo "config.ini template generated."
}

if [[ $1 == "-h" || $1 == "--help" ]]; then
    echo "Usage: $0 [merge|startup|genconfig|compiler]"
    echo "  merge     : Merge all .ahk files into main.ahk (default)"
    echo "  startup   : Add main.ahk to startup via shortcut"
    echo "  genconfig : Generate config.ini template"
    echo "  compiler  : Launch Ahk2exe"
elif [[ $# -eq 0 || $1 == "merge" ]]; then
    merge
elif [[ $1 == "startup" ]]; then
    powershell.exe ./create_shortcut.ps1 './main.ahk'
    echo "Added a shortcut to the startup folder"
elif [[ $1 == "genconfig" ]]; then
    generate_config
elif [[ $1 == "compiler" ]]; then
    /c/Users/ethbr/AppData/Local/Programs/AutoHotkey/Compiler/Ahk2Exe.exe
else
    echo "Parameter error"
fi

exit 0

