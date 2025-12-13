# Запуск программы

`lua pascal/main.lua`

# Загрузка зависимостей для тестирования и покрытия

`luarocks install luacov`

`luarocks install busted`

# Запуск тестирования

`busted --coverage`

# Запуск покрытия

`luacov`