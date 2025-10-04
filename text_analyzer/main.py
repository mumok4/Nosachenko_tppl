freq_dict = {}

with open(input("Введите путь до файла: "), 'r') as f:
    lines = f.readlines()
    lines_count = len(lines)
    letters_count = 0
    blank_count = 0
    for line in lines:
        if line.isspace():
            blank_count+=1
        letters_count+=len(line)
        for letter in line:
            if letter in freq_dict:
                freq_dict[letter] += 1
            else:
                freq_dict[letter] = 1


print(f"Количество строк: {lines_count}")
print(f"Количество букв: {letters_count}")
print(f"Количество пустых строк: {blank_count}")
print(f"Частотный словарь: {freq_dict}")