# Skill Universe

Небольшой Unix CLI для установки и обновления скиллов из Git-репозиториев в Codex и Claude.

## Зачем

- Простой инструмент доставки, который можно прочитать и проверить целиком.
- Без телеметрии, рейтингов, внешних каталогов и фоновых сетевых обращений.
- Обычный Git для получения скиллов и обновления самого тула.
- Один checkout для установки и локальной разработки скиллов через симлинки.

## Установка

Зависимости: Unix shell, Git и `jq`. Целевые платформы PoC — macOS и Linux.

Выполнить команду:

```sh
curl -fsSL "https://raw.githubusercontent.com/seliverstov-maxim/skill-universe/main/install.sh" | sh
```

Установщик клонирует тул в `~/.skill-universe/tool/` и создаёт симлинк команды в `~/.local/bin/`. Содержимое установщика:

```sh
#!/bin/sh
set -eu

git clone "https://github.com/seliverstov-maxim/skill-universe.git" "$HOME/.skill-universe/tool"
chmod +x "$HOME/.skill-universe/tool/skill-universe"
mkdir -p "$HOME/.local/bin"
ln -s "$HOME/.skill-universe/tool/skill-universe" "$HOME/.local/bin/skill-universe"

printf 'Installed: %s/.local/bin/skill-universe\n' "$HOME"
printf 'Add to your shell profile: export PATH="$HOME/.local/bin:$PATH"\n'
```

Проверить доступность команды:

```sh
skill-universe --version
```

`init` сразу задаёт источник самообновления: `https://github.com/seliverstov-maxim/skill-universe.git`, ветка `main`. Настраивать его вручную для `upgrade` не нужно.

## Использование

Создать конфигурацию выбранных харнесов:

```sh
skill-universe init --harness=codex,claude
```

Установить все скиллы репозитория либо выбрать один, ветку и алиас:

```sh
skill-universe install <repo-url>
skill-universe install <repo-url> --branch=<branch> --skill=<skill-name> --alias=<alias>
```

Источник должен содержать `skills/<skill-name>/SKILL.md`. Без флагов используются default branch и все скиллы; алиасы совпадают с именами директорий.

Управлять установленными скиллами:

```sh
skill-universe list
skill-universe rename <alias> <new-alias>
skill-universe update <alias>
skill-universe update all
skill-universe remove <alias>
```

При общем checkout обновление одного скилла затрагивает все связанные с ним скиллы. Локальные изменения допустимы; если Git не допускает fast-forward, конфликт разрешает пользователь.

Обновить тул и посмотреть справку:

```sh
skill-universe upgrade
skill-universe --version
skill-universe --help
```

Манифест находится в `~/.skill-universe/manifest.json`, клоны — в `~/.skill-universe/repos/`. Директории харнесов и Git-источник для `upgrade` настраиваются в манифесте.

Подробные требования, поведение команд и формат манифеста — в [docs/requirements.md](docs/requirements.md).
