freq_dict = {}

with open(input("Введите путь до файла: "), 'r') as f:
    lines = f.readlines()
    lines_count, letters_count, blank_count = len(lines), 0, 0
    for line in lines:
        if line.isspace():
            blank_count+=1
            continue

        letters_count+=len(line)
        for letter in line:
            match letter in freq_dict:
                case True: freq_dict[letter] += 1
                case False: freq_dict[letter] = 1

options = list(map(int,input("Введите опции вывода:\n 1) Количество строк\n 2) количество букв\n 3) Количество пустых строк\n 4) Частотный словарь\n").split()))

for option in options:
    match option:
        case 1:print(f"Количество строк: {lines_count}")
        case 2:print(f"Количество букв: {letters_count}")
        case 3:print(f"Количество пустых строк: {blank_count}")
        case 4:print(f"Частотный словарь: {freq_dict}")
