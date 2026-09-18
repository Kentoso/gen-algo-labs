#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#show terms.item: it => block(breakable: false)[
  #text(weight: "bold")[#it.term]
  #block(inset: (left: 1.5em, top: -0.4em))[#it.description]
]

#set table(
  inset: 6pt,
  stroke: none
)

#show figure.where(
  kind: table
): set figure.caption(position: top)

#show figure.where(
  kind: image
): set figure.caption(position: bottom)

#let content-to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).join("")
  } else if content.has("body") {
    content-to-string(content.body)
  } else if content == [ ] {
    " "
  }
}
#let conf(
  title: none,
  subtitle: none,
  authors: (),
  keywords: (),
  date: none,
  abstract-title: none,
  abstract: none,
  thanks: none,
  cols: 1,
  margin: (x: 20mm, y: 18mm),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: none,
  fontsize: 11pt,
  mathfont: none,
  codefont: none,
  linestretch: 1,
  sectionnumbering: none,
  linkcolor: none,
  citecolor: none,
  filecolor: none,
  pagenumbering: "1",
  doc,
) = {
  set document(
    title: title,
    keywords: keywords,
  )
  set document(
      author: authors.map(author => content-to-string(author.name)).join(", ", last: " & "),
  ) if authors != none and authors != ()
  set page(
    paper: paper,
    margin: margin,
    numbering: pagenumbering,
    columns: cols
  )

  set par(
    justify: true,
    leading: linestretch * 0.65em
  )
  set text(lang: lang,
           region: region,
           size: fontsize)

  set text(font: font) if font != none
  show math.equation: set text(font: mathfont) if mathfont != none
  show raw: set text(font: codefont) if codefont != none

  set heading(numbering: sectionnumbering)

  show link: set text(fill: rgb(content-to-string(linkcolor))) if linkcolor != none
  show ref: set text(fill: rgb(content-to-string(citecolor))) if citecolor != none
  show link: this => {
    if filecolor != none and type(this.dest) == label {
      text(this, fill: rgb(content-to-string(filecolor)))
    } else {
      text(this)
    }
  }

  if title != none {
    place(top, float: true, scope: "parent", clearance: 4mm, block(below: 1em, width: 100%)[
      #if title != none {
        align(center, block[
            #text(weight: "bold", size: 1.5em, hyphenate: false)[#title #if thanks != none {
                footnote(thanks, numbering: "*")
                counter(footnote).update(n => n - 1)
              }]
            #(
              if subtitle != none {
                parbreak()
                text(weight: "bold", size: 1.25em, hyphenate: false)[#subtitle]
              }
             )])
      }

      #if authors != none and authors != [] {
        let count = authors.len()
        let ncols = calc.min(count, 3)
        grid(
          columns: (1fr,) * ncols,
          row-gutter: 1.5em,
          ..authors.map(author => align(center)[
            #author.name \
            #author.affiliation \
            #author.email
          ])
        )
      }

      #if date != none {
        align(center)[#block(inset: 1em)[
            #date
          ]]
      }

      #if abstract != none {
        block(inset: 2em)[
          #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
        ]
      }
    ])
  }
  doc
}
#show: doc => conf(
  abstract-title: [Abstract],
  paper: "a4",
  font: ("Times New Roman",),
  fontsize: 14pt,
  pagenumbering: "1",
  cols: 1,
  lang: "uk",
  region: "UA",
  doc,
)


#show heading: it => block(
  width: 100%,
  above: 1.2em,
  below: 0.8em,
  align(center, text(weight: "bold", it)),
)

#let code-bg = rgb("#f6f8fa")
#let code-border = rgb("#d7dde4")
#let accent = rgb("#1f4e79")

#show raw: set text(font: "Courier New")
#show raw.where(block: true): set text(size: 7.5pt)
#show raw.where(block: false): it => if it.lang == "plainline" {
  set text(size: 7pt)
  it
} else if it.lang == "plainbig" {
  set text(size: 9.5pt)
  it
} else {
  set text(size: 10pt)
  box(
    fill: code-bg,
    radius: 2pt,
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    it,
  )
}

#let num-color = rgb("#0b6e5f")
#let key-color = rgb("#8250df")
#let plain-keywords = (
  "Generation", "Best", "Average", "Distance", "Stopped",
  "route", "distance", "generation", "generations", "found",
  "stagnation", "limit", "reached",
)
#let highlight-line(line, tag) = {
  show regex("\d+(\.\d+)?"): n => text(fill: num-color, n)
  show regex("[A-Za-z]+"): w => if w.text in plain-keywords {
    text(fill: key-color, weight: "bold", w)
  } else { w }
  raw(line, lang: tag)
}
#let highlight-plain(it, tag) = {
  set par(justify: false, leading: 0.5em)
  it.text.split("\n").map(line => highlight-line(line, tag)).join(linebreak())
}

#show raw.where(block: true): it => block(
  width: 100%,
  breakable: true,
  fill: code-bg,
  stroke: (left: 1.5pt + accent, rest: 0.4pt + code-border),
  radius: (right: 2pt),
  inset: (x: 8pt, y: 7pt),
  if it.lang == "text" {
    highlight-plain(it, "plainline")
  } else if it.lang == "example" {
    highlight-plain(it, "plainbig")
  } else { it },
)

#set table(
  inset: (x: 7pt, y: 5pt),
  stroke: none,
  fill: (_, row) => if row == 0 { rgb("#e8eef5") } else if calc.odd(row) { rgb("#f7f9fb") },
)
#show table.cell.where(y: 0): set text(weight: "bold", fill: accent)

= Лабораторна робота № 2
== Задача комівояжера: генетичний алгоритм

Виконав: *Самусь Демʼян Михайлович* \
Група: *ММШІ-2*

=== Мета та постановка задачі
Знайти найкоротший замкнений маршрут у повному неорієнтованому графі:
відвідати кожне з 10 міст рівно один раз і повернутися до початкового міста.
Використано синтетичну симетричну матрицю відстаней. Її ненульові елементи
є цілими числами від 10 до 99 в умовних одиницях; діагональ дорівнює нулю.
Матриця наведена у повному виводі програми та у вихідному коді.

Місто 0 зафіксовано як початок і кінець циклу. Хромосома містить лише
перестановку міст від 1 до 9. Наприклад, хромосома
```example
3 6 9 2 5 8 1 4 7
```
задає маршрут
```example
0 -> 3 -> 6 -> 9 -> 2 -> 5 -> 8 -> 1 -> 4 -> 7 -> 0
```
Оцінкою маршруту є сума ваг усіх ребер циклу, включно з переходами від міста 0
до першого міста та від останнього до 0. Для наведеного прикладу це
$28 + 21 + 13 + 25 + 14 + 27 + 17 + 23 + 16 + 19 = 203$ умовні одиниці, де
28 є відстанню від міста 0 до міста 3, а 19 є відстанню від міста 7 назад до
міста 0. Менше значення означає кращий маршрут.

=== Алгоритм і параметри
#table(
  columns: (1fr, 1fr),
  table.header([Параметр], [Значення]),
  [Популяція], [100 випадкових перестановок],
  [Турнірний відбір], [5% популяції: 5 учасників],
  [Схрещування], [Перевпорядкування сегмента, імовірність 1.0],
  [Мутація], [Обмін двох міст, імовірність 0.10 на нащадка],
  [Елітизм], [1 незмінний найкращий маршрут],
  [Зупинка], [50 поколінь без покращення або 500 поколінь],
  [Seed], [43],
  [Статистика], [Кожні 10 поколінь, початкове й кінцеве],
)

Початкова популяція складається з незалежних випадкових перестановок;
повторення дозволені. Для кожного батька незалежно обираються п'ять різних
позицій популяції, з яких перемагає маршрут із найменшою довжиною. Якщо у
турнір потрапили маршрути довжиною 268, 305, 241, 297 і 260, батьком стає
маршрут довжиною 241, а решта четверо відсіюються. Один маршрут може виграти
обидва турніри.

Для схрещування випадково обираються два різні індекси. Сегмент включає
обидві межі й містить щонайменше два міста. Для першого нащадка міста
сегмента першого батька розміщуються в порядку їх появи у другому батьку.
Решта позицій не змінюється. Другий нащадок утворюється симетрично. Нехай
батьки та вибраний сегмент такі:
```example
Батько 1:  1 2 | 3 4 5 | 6 7 8 9
Батько 2:  4 7 | 2 9 1 | 5 8 3 6
```
Сегмент першого батька містить міста 3, 4 і 5. У другому батьку вони
розташовані в порядку 4, 5, 3, тому саме цей порядок потрапляє в сегмент
першого нащадка. Сегмент другого батька містить міста 2, 9 і 1, а в першому
батьку вони йдуть у порядку 1, 2, 9. Нащадки виходять такі:
```example
Нащадок 1: 1 2 | 4 5 3 | 6 7 8 9
Нащадок 2: 4 7 | 1 2 9 | 5 8 3 6
```
Поза сегментом обидва нащадки повністю повторюють своїх батьків, а всередині
сегмента змінюється лише порядок тих самих міст. Тому кожне місто
залишається в маршруті рівно один раз. Такий оператор відповідає прикладу
з лекції. Якщо порядок уже збігається, схрещування може не змінити маршрут.

Мутація незалежно для кожного нащадка з імовірністю 0.10 обмінює два
випадкові різні міста. Вона може відбутися після схрещування. Наприклад,
обмін другої та сьомої позицій дає таку зміну:
```example
До мутації:    3 6 9 2 5 8 1 4 7    довжина 203
Після мутації: 3 1 9 2 5 8 6 4 7    довжина 456
```
Перестановка знову лишається коректною, бо міста не зникають і не
дублюються, а лише міняються місцями. Цей приклад показує й іншу властивість
мутації: окремий випадковий обмін частіше псує маршрут, ніж покращує, і
корисним він стає саме у поєднанні з відбором, який такі гірші варіанти
відкидає.

Місто 0 не бере участі в операторах. До нового покоління копіюється одна
найкраща особина, решта місць заповнюється нащадками; зайвий нащадок
відкидається. Завдяки такому копіюванню найкращий знайдений маршрут не може
загубитися через невдалі схрещування чи мутації у наступному поколінні.

Лічильник стагнації скидається лише за строго меншої довжини. Інший маршрут
тієї самої довжини не є покращенням. Зберігається перший знайдений найкращий
маршрут. Контрольні точки містять найкращу і середню довжину та п'ять
найкращих особин із повтореннями. Однакові маршрути серед перших п'яти
не означають, що вся популяція однакова.

=== Запуск і результати
З каталогу лабораторної виконати:
```sh
uv run main.py
```
Параметри змінюються константами у файлі `main.py`. Matplotlib встановлюється
через uv. Графік автоматично зберігається поруч із програмою у
`convergence.png`, замінюючи попередній файл, без відкриття вікна.

За seed 43 знайдено маршрут:
```example
0 -> 3 -> 6 -> 9 -> 2 -> 5 -> 8 -> 1 -> 4 -> 7 -> 0
```
Його довжина дорівнює *203*. Він уперше з'явився в поколінні *4*.
Алгоритм завершив роботу після *54* поколінь через 50 поколінь без покращення.

#figure(image("convergence.png", width: 100%),
  caption: [Найкраща та середня довжина маршруту в кожному поколінні.])

=== Незалежна точна перевірка
Після запуску окремо перевірено всі 9! = 362 880 перестановок міст 1–9
із зафіксованим початком 0. Зворотні маршрути теж враховано; це не впливає
на мінімум. Для кожного кандидата обчислено суму відстаней замкненого циклу.
Мінімальна довжина дорівнює *203*, і такої довжини досягають рівно дві
перестановки, які є одна одній зворотними. Тобто з точністю до напрямку
обходу оптимальний маршрут єдиний, і він збігається зі знайденим генетичним
алгоритмом. Отже, розрив між результатом алгоритму та точним мінімумом
нульовий.

Матрицю, метод, кількість перевірених перестановок та оптимальний маршрут
збережено у `verification.json`. Точний перебір виконано заздалегідь:
звичайний запуск програми його не виконує та не використовує результат
для пошуку або зупинки. Після зміни матриці точну перевірку потрібно повторити.
Для відтворення перевірки з каталогу `lab2` виконати:
```sh
uv run verify.py
```
Скрипт читає поточну матрицю з `main.py` та перезаписує `verification.json`.
Повний код скрипта наведено в додатку Б.

=== Висновок
У ході виконання роботи реалізовано пошук найкоротшого замкненого маршруту
задачі комівояжера генетичним алгоритмом на перестановочному кодуванні, де
хромосома задає порядок обходу дев'яти міст, а місто 0 зафіксовано як початок
і кінець циклу. Знайдено маршрут 0, 3, 6, 9, 2, 5, 8, 1, 4, 7, 0 довжиною 203
умовні одиниці.

Розібрано та запрограмовано всі стадії генетичного алгоритму: кодування
маршруту перестановкою, обчислення довжини циклу, турнірний відбір батьків,
схрещування перевпорядкуванням сегмента, мутацію обміном двох міст, елітизм
і критерій зупинки за стагнацією. Роботу алгоритму продемонстровано на
покроковому виведенні статистики та на графіку збіжності: найкраща довжина
падає з 377 до 203 уже за чотири покоління, а середня по популяції
підтягується до найкращої в міру збіжності.

Генетичний алгоритм є евристикою, тому зупинка за стагнацією не доводить
оптимальності знайденого маршруту, а результат залежить від початкової
популяції, випадкових операцій і обраних параметрів. Для цієї матриці
збіг із точним мінімумом підтверджено окремим повним перебором.

#pagebreak()
=== Повний вивід програми
#raw(read("run-output.txt"), lang: "text", block: true)

#pagebreak()
== Додаток А. Повний код основної програми
#raw(read("main.py"), lang: "python", block: true)

#pagebreak()
== Додаток Б. Скрипт точної перевірки
#raw(read("verify.py"), lang: "python", block: true)
