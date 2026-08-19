# Основы Go и командной строки

Конспект по настройке Go, работе с Bash и базовым инструментам командной строки.

## Урок 0.1. Окружение Go

### Переменные окружения

| Переменная | Назначение |
| --- | --- |
| `GOROOT` | Путь к установленному Go: компилятору, инструментам и стандартной библиотеке. Обычно задаётся установщиком, поэтому менять его вручную не нужно. Пример: `/usr/local/go`. |
| `GOPATH` | Рабочее пространство Go. В проектах с модулями используется, в частности, для кеша модулей и устанавливаемых инструментов. Значение по умолчанию — `$HOME/go` (`%USERPROFILE%\go` в Windows). |
| `GOMODCACHE` | Каталог с кешем загруженных модулей. По умолчанию — `$GOPATH/pkg/mod`. Благодаря кешу зависимости не требуется скачивать повторно. |
| `GOBIN` | Каталог, куда `go install` помещает исполняемые файлы. Если переменная не задана, используется `$GOPATH/bin`. Этот каталог нужно добавить в `PATH`, чтобы запускать инструменты по имени. |

Проверить значения переменных можно командой:

```bash
go env GOROOT GOPATH GOMODCACHE GOBIN
```

### Чек-лист

- [x] Установить Go.
- [x] Установить `goimports`, `golangci-lint` и `delve`.
- [x] Прочитать [How to Write Go Code](https://go.dev/doc/code).
- [x] Создать и запустить первый проект.
- [x] Разобраться с назначением `GOBIN`.
- [x] Посмотреть видео JustForFunc — «Go Modules» (Francesc Campoy).

Проверка версии Go:

```console
> go version
go version go1.26.5 windows/amd64
```

> **Примечание:** версия в примере отражает локальное окружение на момент создания конспекта.

#### Зачем нужен `GOBIN`?

`GOBIN` определяет каталог, куда команда `go install` помещает установленные программы. Если добавить этот каталог в `PATH`, программы можно запускать из терминала по имени.

#### Где Go хранит загруженные модули?

Модули хранятся в каталоге `GOMODCACHE`. По умолчанию это `$GOPATH/pkg/mod`, например:

```text
C:\Users\Nezna\go\pkg\mod
```

Кеш может одновременно содержать разные версии одной библиотеки, поэтому проекты могут использовать нужные им версии без конфликтов.

## Урок 0.2. Инструменты командной строки

### Просмотр и сортировка

- `cat file` — вывести всё содержимое файла;
- `sort file` — отсортировать строки;
- `uniq file` — убрать соседние повторяющиеся строки;
- `head -n 5 file` — вывести первые пять строк;
- `tail -n 5 file` — вывести последние пять строк.

### Поиск текста (`grep`)

- `grep "text" file` — найти строки с указанным текстом;
- `grep -r "text" .` — выполнить рекурсивный поиск в текущем каталоге;
- `grep -i "text" file` — искать без учёта регистра.

### Замена текста (`sed`)

`sed -i 's/что/на_что/g' file` — заменить все вхождения «что» на «на_что» в файле.

> Синтаксис опции `-i` различается между GNU `sed` и BSD/macOS `sed`.

### Поиск файлов (`find`)

- `find . -name "*.zip" -mtime +30` — найти архивы, изменённые более 30 дней назад;
- `find . -size +100M` — найти файлы размером более 100 МиБ;
- `find . -name "*.go" -exec grep "TODO" {} \;` — найти `TODO` во всех Go-файлах.

### Обработка столбцов (`awk`)

`awk '{print $2}' file` выводит второй столбец каждой строки. По умолчанию `awk` разделяет поля по последовательностям пробельных символов.

### Пример конвейера

Этот конвейер собирает статистику по журналу SSH на удалённом сервере:

```bash
ssh myserver 'journalctl -u sshd -b-1 | grep "Disconnected from"' \
  | sed -E 's/.*Disconnected from .* user (.*) [^ ]+ port.*/\1/' \
  | sort | uniq -c \
  | sort -nk1,1 | tail -n10 \
  | awk '{print $2}' | paste -sd,
```

1. `ssh` запускает команду на удалённом сервере.
2. `journalctl` получает журнал службы `sshd` за предыдущую загрузку системы.
3. `grep` оставляет строки об отключении.
4. `sed` извлекает имя пользователя.
5. `sort | uniq -c` группирует имена и подсчитывает их количество.
6. `sort -nk1,1 | tail -n 10` выбирает десять наиболее частых имён.
7. `awk` убирает счётчики, а `paste -sd,` объединяет имена через запятую.

**Результат:** десять пользователей, которые чаще всего отключались от сервера, одной строкой.

### Задания

#### 1. Запуск Bash

Запустить командную оболочку Bash и проверить её версию командой `bash --version`.

#### 2. Подробный вывод `ls`

**Задание:** что делает флаг `-l` команды `ls`? Выполнить `ls -l /` и определить значение первых десяти символов каждой строки.

Флаг `-l` включает подробный формат вывода (*long listing format*).

- **1-й символ** — тип файла: `d` — каталог, `-` — обычный файл, `l` — символическая ссылка;
- **2–4-й символы** — права владельца (`user`): `r` — чтение, `w` — запись, `x` — исполнение;
- **5–7-й символы** — права группы (`group`);
- **8–10-й символы** — права остальных пользователей (`others`).

Отсутствующее право обозначается дефисом. Например, `-rw-r--r--` — обычный файл, который владелец может читать и изменять, а остальные — только читать.

#### 3. Шаблоны имён файлов

**Задание:** изучить glob-шаблон `*.zip` в команде:

```bash
find ~/Downloads -type f -name "*.zip" -mtime +30
```

**Glob** — шаблон, который оболочка использует для сопоставления с именами файлов. Это не регулярное выражение.

```text
Downloads/0000019f-af0e-26ef-0000-0000a52b559b (1).zip
Downloads/0000019f-af0e-26ef-0000-0000a52b559b.zip
Downloads/MERN-ToDo.zip
Downloads/TLI-tracker-translated-main.zip
Downloads/Urban-Drive-main (1).zip
Downloads/Urban-Drive-main.zip
Downloads/vp9h8E5tHh8zSfauK_1784073600000-logs.zip
```

- `*` — любое количество символов;
- `?` — ровно один символ;
- `[abc]` — один символ из указанного набора;
- `{a,b}` — выбор вариантов с помощью *brace expansion*. Технически это отдельный механизм Bash, а не glob.

> Если совпадений нет, Bash по умолчанию передаёт шаблон команде как обычную строку. Поведение можно изменить настройкой `nullglob`.


## Практические задания к лекции 1

### Эксперименты с glob-шаблонами

```bash
mkdir glob_test && cd glob_test
touch a.txt b.txt c.txt file1.txt file2.txt notes.log script.sh
```

**Звёздочка (`*`):**

```bash
ls *.txt
```

Выведет все файлы с расширением `.txt`: `a.txt`, `b.txt`, `c.txt`, `file1.txt` и `file2.txt`.

**Вопросительный знак (`?`):**

```bash
ls file?.txt
```

Выведет `file1.txt` и `file2.txt`. Файл `file12.txt` не подойдёт, поскольку `?` заменяет ровно один символ.

**Фигурные скобки (`{}`):**

```bash
ls {a,b,c}.txt
```

Выведет только `a.txt`, `b.txt` и `c.txt`. Bash разворачивает выражение в список имён.


### 4. Виды кавычек
What’s the difference between 'single quotes', "double quotes", and $'ANSI quotes'? Write a command that echoes a string containing a literal $, a !, and a newline character. See Quoting.

- `'...'` — сохраняет каждый символ буквально;
- `"..."` — допускает подстановку переменных, команд и некоторых специальных символов;
- `$'...'` — обрабатывает ANSI-C-последовательности, например `\n` и `\t`.

Пример строки, содержащей литералы `$`, `!` и перевод строки:

```bash
printf '%s\n%s\n' '$ !' 'новая строка'
```


### 5. Стандартные потоки
The shell has three standard streams: stdin (0), stdout (1), and stderr (2). Run ls /nonexistent /tmp and redirect stdout to one file and stderr to another. How would you redirect both to the same file? See Redirections.

В Bash каждый процесс имеет три стандартных потока:
0 (stdin) — ввод (клавиатура).
1 (stdout) — стандартный вывод (результат работы).
2 (stderr) — вывод ошибок.

Команда ls /nonexistent /tmp выдаст и ошибку (так как папки /nonexistent нет), и список файлов в /tmp.

- `> file` или `1> file` — перенаправить `stdout`;
- `2> file` — перенаправить `stderr`;
- `&> file` — направить оба потока в один файл (синтаксис Bash);
- `2> /dev/null` — отбросить сообщения об ошибках.

```bash
ls /nonexistent /tmp >output.txt 2>errors.txt
ls /nonexistent /tmp >all.txt 2>&1
```


### 6. Код возврата и условное выполнение
$? holds the exit status of the last command (0 = success). && runs the next command only if the previous succeeded; || runs it only if the previous failed. Write a one-liner that creates /tmp/mydir only if it doesn’t already exist. See Exit Status.

$? — код возврата последней команды (0 = ок, >0 = ошибка).
cmd1 && cmd2 — выполнить cmd2 только если cmd1 прошла успешно.
cmd1 || cmd2 — выполнить cmd2 только если cmd1 завершилась с ошибкой.
Создать каталог, только если он ещё не существует:

```bash
[ -d /tmp/mydir ] || mkdir /tmp/mydir
```

> Для этой конкретной задачи проще и надёжнее использовать идемпотентную команду `mkdir -p /tmp/mydir`.

### 7. Почему `cd` — встроенная команда
Why does cd have to be built into the shell itself rather than a standalone program? (Hint: think about what a child process can and cannot affect in its parent.)


Внешние команды запускаются в дочерних процессах.
Дочерний процесс не может менять окружение родителя (его папку, переменные и т.д.).
Built-ins (как cd, export, alias) выполняются внутри самой оболочки, чтобы иметь возможность менять её состояние.
Как проверить:
Команда type cd покажет: cd is a shell builtin.
Команда type ls покажет: ls is aliased to... или путь к файлу /bin/ls.

### 8. Проверка существования файла
Write a script that takes a filename as an argument ($1) and checks whether the file exists using test -f or [ -f ... ]. It should print different messages depending on whether the file exists. See Bash Conditional Expressions.
Создаём файл `check.sh`:

```bash
#!/bin/bash

if [ -f "$1" ]; then
    echo "Файл $1 существует."
else
    echo "Файл $1 не найден."
fi
```

- `$1` — первый аргумент (имя файла);
- `-f` — проверка, что путь указывает на обычный файл, а не на каталог.

```bash
chmod +x check.sh
./check.sh /etc/passwd
# Файл /etc/passwd существует.

./check.sh non
# Файл non не найден.
```


- `nano file` — открыть или создать файл в консольном редакторе;
- `chmod +x file` — добавить право на исполнение файла.


### 9. Право на исполнение
Save the script from the previous exercise to a file (e.g., check.sh). Try running it with ./check.sh somefile. What happens? Now run chmod +x check.sh and try again. Why is this step necessary? (Hint: look at ls -l check.sh before and after the chmod.)

Почему ./check.sh не работает сразу? По умолчанию созданный файл имеет права только на чтение и запись (rw-). Чтобы система могла его запустить как программу, нужен бит исполнения (x).
Команда: chmod +x check.sh
Разница в ls -l: Было -rw-r--r--, стало -rwxr-xr-x (появилась буква x).

### 10. Трассировка скрипта
What happens if you add -x to the set flags in a script? Try it with a simple script and observe the output. See The Set Builtin.

Если добавить set -x в начало скрипта, Bash будет выводить каждую команду перед её выполнением, подставляя значения переменных.
Зачем: Это главный способ поиска ошибок (трассировка).

### 11. Резервная копия с датой
Write a command that copies a file to a backup with today’s date in the filename (e.g., notes.txt → notes_2026-01-12.txt). (Hint: $(date +%Y-%m-%d)).

```bash
cp notes.txt "notes_$(date +%Y-%m-%d).txt"
```

date +%Y-%m-%d — выводит дату в формате ГГГГ-ММ-ДД.

### 12. Команда как аргумент скрипта
Modify the flaky test script from the lecture to accept the test command as an argument instead of hardcoding cargo test my_test. (Hint: $1 or $@). See Special Parameters.

Вместо жесткой команды используем $@ (передает все аргументы скрипта)
Пример логики: запускать команду, пока она не упадет

```bash
while "$@"; do
    echo "Тест прошел успешно"
done
echo "Тест провалился!"
```

Запуск: ./retry.sh python3 my_test.py


### 13. Самые частые расширения файлов
Use pipes to find the 5 most common file extensions in your home directory. (Hint: combine find, grep or sed or awk, sort, uniq -c, and head.)

```bash
find "$HOME" -type f \
  | sed -nE 's/.*\.([^.\/]+)$/\1/p' \
  | sort | uniq -c | sort -nr | head -n 5
```

sed — вырезает всё до последней точки, оставляя расширение.
sort | uniq -c — группирует и считает.
sort -nr — сортирует по числу (в обратном порядке).

### 14. Совместное использование `find` и `xargs`
xargs converts lines from stdin into command arguments. Use find and xargs together (not find -exec) to find all .sh files in a directory and count the lines in each with wc -l. Bonus: make it handle filenames with spaces. (Hint: -print0 and -0). See man xargs.

Чтобы обработать файлы с пробелами, используем null-terminator:

```bash
find . -type f -name "*.sh" -print0 | xargs -0 -r wc -l
```

-print0 — разделяет имена файлов символом \0 вместо пробела.
-0 — заставляет xargs понимать этот разделитель

### 15. Получение HTML с помощью `curl`
Use curl to fetch the HTML of the course website (https://missing.csail.mit.edu/) and pipe it to grep to count how many lectures are listed. (Hint: look for a pattern that appears once per lecture; use curl -s to silence the progress output.)

```bash
curl -s https://missing.csail.mit.edu/ | grep -cE 'class="lecture"|/20[0-9]{2}/'
```

> Шаблон зависит от текущей HTML-разметки сайта, поэтому перед подсчётом стоит изучить полученный документ.

-s — (silent) убирает прогресс-бар загрузки.
grep — ищет ссылки на лекции (они имеют специфический путь).


### 16. Обработка JSON с помощью `jq`
jq is a powerful tool for processing JSON data. Fetch the sample data at https://microsoftedge.github.io/Demos/json-dummy-data/64KB.json with curl and use jq to extract just the names of people whose version is greater than 6. (Hint: pipe to jq . first to see the structure; then try jq '.[] | select(...) | .name')

```bash
curl -s https://microsoftedge.github.io/Demos/json-dummy-data/64KB.json | \
jq '.[] | select(.version > 6) | .name'
```

.[] — пройти по всем элементам массива.
select(.version > 6) — оставить только тех, у кого версия выше 6.
.name — вывести только поле с именем.


### 17. Фильтрация столбцов с помощью `awk`
awk can filter lines based on column values and manipulate output. For example, awk '$3 ~ /pattern/ {$4=""; print}' prints only lines where the third column matches pattern, while omitting the fourth column. Write an awk command that prints only lines where the second column is greater than 100, and swaps the first and third columns. Test with: printf 'a 50 x\nb 150 y\nc 200 z\n'

```bash
printf 'a 50 x\nb 150 y\nc 200 z\n' | awk '$2 > 100 { print $3, $2, $1 }'
```

- `$2 > 100` — фильтр по второму столбцу;
- `{ print $3, $2, $1 }` — вывод третьего, второго и первого столбцов в указанном порядке.


### 18. Анализ истории команд
Dissect the SSH log pipeline from the lecture: what does each step do? Then build something similar to find your most-used shell commands from ~/.bash_history (or ~/.zsh_history).

```bash
history | awk '{print $2}' | sort | uniq -c | sort -nr | head -n 10
```

history — берет список команд.
`awk '{print $2}'` — берёт название команды, убирая порядковый номер.
sort | uniq -c — считает повторы.
sort -nr — ставит самые частые наверх

