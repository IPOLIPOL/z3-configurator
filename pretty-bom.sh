#!/usr/bin/env bash

awk '
{
    # Если вручную с новой строки ввели EOF — прекращаем чтение
    if ($1 == "EOF") {
        exit
    }
    full_text = full_text " " $0
}
END {
    count = 0
    
    # [[:space:]] гарантированно работает на macOS и Windows, заменяя собой \s
    while (match(full_text, /node[[:space:]]+"[^"]+"[[:space:]]+[0-9]+/)) {
        str = substr(full_text, RSTART, RLENGTH)
        
        # Очищаем синтаксис стандартными методами
        gsub(/node[[:space:]]+"/, "", str)
        gsub(/"[[:space:]]+/, " × ", str)
        
        lines[count] = str
        count++
        
        full_text = substr(full_text, RSTART + RLENGTH)
    }
    
    # Защита от пустого ввода
    if (count == 0) {
        print "Ошибка: Данные Z3 не распознаны (проверьте формат)."
        exit 1
    }
    
    # Корректный вывод красивого дерева с уголком в конце
    for (i = 0; i < count; i++) {
        if (i == 0) {
            print lines[i]
        } else if (i == count - 1) {
            print "└── " lines[i]
        } else {
            print "├── " lines[i]
        }
    }
}'
