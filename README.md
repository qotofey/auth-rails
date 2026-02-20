# Auth Rails API

API сервис аутентификации и авторизации на Ruby on Rails.

## Требования

- Ruby 4.0.1
- RVM
- Docker (для запуска тестов)
- MySQL 8.0 (для development)

## Установка

### 1. Установка Ruby и gemset через RVM

```bash
# Установить Ruby 4.0.1 и создать gemset
rvm install ruby-4.0.1
rvm use ruby-4.0.1@auth-rails --create

# Или автоматически при входе в директорию проекта (если настроен .rvmrc)
cd auth-rails
```

Проект автоматически использует Ruby 4.0.1 и gemset `auth-rails` благодаря файлам:
- `.ruby-version` — содержит `ruby-4.0.1@auth-rails`
- `.rvmrc` — содержит `rvm use ruby-4.0.1@auth-rails`

### 2. Установка зависимостей

```bash
bundle install
```

### 3. Настройка переменных окружения

Создайте файл `.env` в корне проекта:

```bash
# Bcrypt cost factor (рекомендуемое значение 10-12)
BCRYPT_COST=12

# JWT refresh token expiration (days)
JWT_REFRESH_TOKEN_EXPIRATION=21
```

### 4. Настройка базы данных

#### Development (локальный MySQL)

Отредактируйте `config/credentials.yml.enc` или создайте `config/database.yml` с вашими параметрами:

```yaml
development:
  adapter: trilogy
  encoding: utf8mb4
  host: localhost
  port: 3306
  database: auth_dev
  username: your_username
  password: your_password
```

Или используйте credentials:

```bash
rails credentials:edit
```

Добавьте:

```yaml
dev:
  db_host: localhost
  db_name: auth_dev
  db_username: your_username
  db_password: your_password
```

#### Test (автоматически через Testcontainers)

Для тестов используется MySQL 8.0 Oracle в Docker контейнере. Убедитесь, что Docker запущен:

```bash
# Проверить статус Docker
docker ps

# Запустить Docker Desktop (macOS/Windows)
open -a Docker
```

### 5. Создание и миграция базы данных

```bash
# Development
rails db:create db:migrate

# Test (автоматически при запуске тестов)
rails db:test:prepare
```

## Запуск приложения

```bash
# Запуск сервера
bin/rails server

# Или с указанием порта
bin/rails server -p 3000
```

Сервер будет доступен по адресу: http://localhost:3000

## Запуск тестов

### Требования для тестов

- Docker должен быть запущен
- Образ `mysql:8.0-oracle` будет автоматически загружен при первом запуске

### Запуск всех тестов

```bash
bundle exec rspec
```

### Запуск тестов по типу

```bash
# Тесты форм
bundle exec rspec spec/forms/

# Тесты контроллеров (request spec)
bundle exec rspec spec/requests/

# Тесты валидаторов
bundle exec rspec spec/validators/
```

### Запуск конкретного файла

```bash
bundle exec rspec spec/forms/api/v1/registration_form_spec.rb
```

### Запуск конкретного теста

```bash
bundle exec rspec spec/forms/api/v1/registration_form_spec.rb:10
```

### Запуск с подробным выводом

```bash
bundle exec rspec --format documentation
```

### Запуск с рандомизацией

```bash
# С конкретным seed
bundle exec rspec --seed 12345

# Без рандомизации (последовательно)
bundle exec rspec --order defined
```

### Переопределение образа MySQL для тестов

```bash
# Использовать другой образ MySQL
MYSQL_IMAGE=mysql:8.0 bundle exec rspec

# Или MariaDB
MYSQL_IMAGE=mariadb:10.6 bundle exec rspec
```

## Структура API

### Endpoints

| Метод | Путь | Описание |
|-------|------|----------|
| POST | `/api/v1/user` | Регистрация пользователя |
| GET | `/api/v1/user` | Получение данных пользователя (требуется auth) |
| PUT/PATCH | `/api/v1/user` | Обновление данных пользователя (требуется auth) |
| POST | `/api/v1/session` | Аутентификация (логин) |
| PUT/PATCH | `/api/v1/session` | Обновление JWT токенов |
| DELETE | `/api/v1/session` | Выход из системы |

### Формат запросов

Все запросы должны быть в формате JSONAPI 1.1:

```json
{
  "data": {
    "type": "users",
    "attributes": {
      "username": "username417",
      "password": "Qwerty1234567!"
    }
  }
}
```

### Формат ответов

Успешный ответ:

```json
{
  "data": {
    "id": "1",
    "type": "users",
    "attributes": {
      "username": "username417",
      "name": null,
      "middleName": null,
      "lastName": null,
      "gender": null,
      "birthDate": null
    }
  }
}
```

Ответ с ошибкой:

```json
{
  "errors": [
    {
      "source": { "pointer": "/data/attributes/username" },
      "title": "Обязательный атрибут отсутствует",
      "detail": "Логин не может быть пустым",
      "status": "422"
    }
  ]
}
```

## Статусы HTTP кодов

| Код | Описание |
|-----|----------|
| 200 | Успешный запрос (GET, PUT, PATCH) |
| 201 | Успешное создание (POST) |
| 204 | Успешное удаление (DELETE) |
| 400 | Неверный формат запроса (некорректный JSON) |
| 401 | Пользователь не аутентифицирован |
| 403 | Доступ запрещён |
| 404 | Ресурс не найден |
| 405 | Метод не поддерживается |
| 410 | Ресурс удалён |
| 422 | Ошибка валидации |
| 500 | Ошибка сервера |

## Разработка

### Кодстайл

Проект использует Rubocop с конфигурацией `rubocop-rails-omakase`:

```bash
# Проверка кода
bundle exec rubocop

# Автоисправление
bundle exec rubocop -a
```

### Аудит зависимостей

```bash
bundle exec bundle-audit
```

### Проверка безопасности

```bash
bundle exec brakeman
```

## Развёртывание

Приложение развёртывается как Docker контейнер с помощью Kamal:

```bash
# Сборка образа
kamal build

# Развёртывание
kamal deploy
```

См. конфигурацию в `.kamal/`.

## Дополнительные команды

```bash
# Консоль Rails
rails console

# Консоль для тестовой среды
RAILS_ENV=test rails console

# Просмотр маршрутов
rails routes

# Проверка миграций
rails db:migrate:status

# Откат миграций
rails db:rollback

# Сброс базы данных
rails db:reset
```

## Лицензия

MIT License.
