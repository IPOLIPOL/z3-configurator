#!/usr/bin/env bash

awk '
{
    # Склеиваем все строки в одну длинную строку через пробел
    full_text = full_text " " $0
}
END {
    # Этот блок сработает ТОЛЬКО когда вы нажмете Ctrl+D (ввод окончен)
    
    count = 0
    # Ищем регулярное выражение, учитывая, что между элементами могут быть пробелы и переносы
    while (match(full_text, /node\s+"[^"]+"\s+[0-9]+/)) {
        
        # Вырезаем найденную ноду
        str = substr(full_text, RSTART, RLENGTH)
        
        # Чистим синтаксис (убираем лишние пробелы, кавычки и слово node)
        gsub(/node\s+"/, "", str)
        gsub(/"\s+/, " × ", str)
        
        # Форматируем дерево
        if (count == 0) {
            print str
        } else {
            print "├── " str
        }
        count++
        
        # Сдвигаем указатель дальше
        full_text = substr(full_text, RSTART + RLENGTH)
    }
}'
