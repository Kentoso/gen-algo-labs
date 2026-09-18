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
#show raw.where(block: true): set text(size: 8.5pt)
#show raw.where(block: false): it => if it.lang == "plainline" {
  set text(size: 7pt)
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
  "Generation", "Best", "Average", "Fitness", "Stopped",
  "chromosome", "fitness", "generation", "found", "stagnation", "limit",
)
#let highlight-line(line) = {
  show regex("\d+(\.\d+)?"): n => text(fill: num-color, n)
  show regex("[A-Za-z]+"): w => if w.text in plain-keywords {
    text(fill: key-color, weight: "bold", w)
  } else { w }
  raw(line, lang: "plainline")
}
#let highlight-plain(it) = {
  set par(justify: false, leading: 0.5em)
  it.text.split("\n").map(highlight-line).join(linebreak())
}

#show raw.where(block: true): it => block(
  width: 100%,
  breakable: true,
  fill: code-bg,
  stroke: (left: 1.5pt + accent, rest: 0.4pt + code-border),
  radius: (right: 2pt),
  inset: (x: 8pt, y: 7pt),
  if it.lang == "text" { highlight-plain(it) } else { it },
)

#set table(
  inset: (x: 7pt, y: 5pt),
  stroke: none,
  fill: (_, row) => if row == 0 { rgb("#e8eef5") } else if calc.odd(row) { rgb("#f7f9fb") },
)
#show table.cell.where(y: 0): set text(weight: "bold", fill: accent)

= Лабораторна робота № 1
<лабораторна-робота-1>
== Максимізація функції генетичним алгоритмом
<максимізація-функції-генетичним-алгоритмом>

Виконав: *Самусь Демʼян Михайлович* \
Група: *ММШІ-2*

=== Мета та постановка задачі
<мета-та-постановка-задачі>
Реалізувати генетичний алгоритм для пошуку найбільшого значення функції:

```text
f(w, x, y, z) = w³ + x² − y² − z² + 2yz − 3wx + wz − xy + 2.
```

Кожна зі змінних є цілим числом від 0 до 15, тобто на неї вистачає рівно
чотирьох бітів. Через це хромосома має довжину 16 бітів і складається з
чотирьох послідовних блоків, які відповідають `w`, `x`, `y` та `z`. У
програмі її збережено як звичайний список нулів і одиниць, причому
старший біт кожного блоку стоїть зліва. Наприклад, запис
`1101 | 0110 | 0111 | 1100` читається як `w = 13`, `x = 6`, `y = 7`,
`z = 12`.

=== Алгоритм та обрані параметри
<алгоритм-та-обрані-параметри>
Стартова популяція складається зі 100 випадкових хромосом. За fitness
взято безпосередньо значення заданої функції, тому чим воно більше, тим
кращим вважається розв'язок. Від'ємні значення тут нічим не заважають і
нормалізувати їх не довелося: турнірний відбір лише порівнює особини між
собою і не будує ймовірностей, пропорційних до fitness.

#figure(
  align(center)[#table(
    columns: (auto, 1fr),
    align: (left, left),
    table.header([Параметр], [Значення],),
    table.hline(stroke: 0.6pt + accent),
    [Розмір популяції], [100],
    [Максимальна кількість поколінь], [500],
    [Частка учасників турніру], [5% популяції, округлення вгору],
    [Crossover], [Рівномірний, імовірність 1.0],
    [Mutation], [Імовірність 0.05 на кожного нащадка; інверсія одного
    біта],
    [Елітизм], [1 найкраща особина],
    [Межа стагнації], [5 поколінь без строгого покращення],
    [Seed], [43],
    [Період виведення статистики], [Кожне покоління],
  )]
  , kind: table
  )

Щоб вибрати кожного з двох батьків, програма випадково бере 5 різних
позицій популяції, і перемагає та особина, у якої fitness найбільший.
Турніри між собою незалежні, тому одна й та сама особина може стати
обома батьками. Однакові хромосоми в популяції теж
дозволені. Чим більший турнір, тим сильніша перевага кращих особин, а
разом з нею і ризик швидше втратити різноманіття.

Рівномірний crossover працює так: для кожної позиції незалежно, з
імовірністю 0.5, біти двох батьків міняються місцями між двома
нащадками. Імовірність crossover дорівнює 1.0, тобто оператор
застосовується до кожної пари без винятку. Далі кожен нащадок з
імовірністю 0.05 мутує, і тоді інвертується рівно один випадковий біт.
Ця ймовірність стосується всієї особини, а не кожного біта окремо.

Кожне наступне покоління починається з незміненої копії найкращої
особини, а решту місць займають нащадки. Якщо вільним лишається тільки
одне місце, береться перший нащадок пари, тому розмір популяції
залишається сталим. Елітна особина не проходить ні через crossover, ні
через mutation, тому найкращий fitness ніколи не падає, а середній може
коливатися.

Після кожного покоління програма дивиться, чи покращився найкращий
fitness. Лічильник стагнації обнуляється лише за строгого покращення, а
однакове значення його не скидає. Робота завершується або після 5
поколінь без покращення, або після 500 поколінь. Початкову популяцію
позначено як покоління 0.

=== Запуск і результат
<запуск-і-результат>
У каталозі `lab1` виконати:

```sh
uv run main.py
```

Усі параметри винесено в іменовані константи на початку `main.py`, тож
змінювати їх зручно в одному місці. Жодних залежностей поза стандартною
бібліотекою немає. Наведені нижче результати перевірено запуском
`python3 main.py`.

На кожній контрольній точці програма друкує найкращий і середній
fitness, а також п'ять найкращих особин поточного покоління разом з
їхнім fitness, хромосомами та декодованими змінними. Особини
впорядковані за спаданням fitness. Однакові хромосоми навмисно не
прибрано з виведення, бо саме вони показують, як популяція сходиться.
Якщо особин менше п'яти, виводяться всі наявні. За поточних налаштувань
статистика друкується щопокоління, і завдяки цьому добре видно ранні
покращення. Для описаних параметрів отримано таке:

```text
Generation    0 | Best:  3475 | Average:    738.00
  #1 | Fitness:  3475 | 1111 | 0001 | 0111 | 1011 | w = 15, x = 1, y = 7, z = 11
  #2 | Fitness:  3229 | 1111 | 0111 | 1000 | 1110 | w = 15, x = 7, y = 8, z = 14
  #3 | Fitness:  3005 | 1111 | 1011 | 1110 | 1011 | w = 15, x = 11, y = 14, z = 11
  #4 | Fitness:  2953 | 1111 | 1111 | 0011 | 0101 | w = 15, x = 15, y = 3, z = 5
  #5 | Fitness:  2845 | 1110 | 0001 | 0111 | 1110 | w = 14, x = 1, y = 7, z = 14
Generation    1 | Best:  3475 | Average:   2037.77
  #1 | Fitness:  3475 | 1111 | 0001 | 0111 | 1011 | w = 15, x = 1, y = 7, z = 11
  #2 | Fitness:  3415 | 1111 | 0001 | 0010 | 1011 | w = 15, x = 1, y = 2, z = 11
  #3 | Fitness:  3311 | 1111 | 0101 | 1000 | 1110 | w = 15, x = 5, y = 8, z = 14
  #4 | Fitness:  3291 | 1111 | 0010 | 0000 | 0000 | w = 15, x = 2, y = 0, z = 0
  #5 | Fitness:  3261 | 1111 | 0101 | 0011 | 1001 | w = 15, x = 5, y = 3, z = 9
Generation    2 | Best:  3526 | Average:   2984.69
  #1 | Fitness:  3526 | 1111 | 0000 | 0111 | 1011 | w = 15, x = 0, y = 7, z = 11
  #2 | Fitness:  3475 | 1111 | 0001 | 0111 | 1011 | w = 15, x = 1, y = 7, z = 11
  #3 | Fitness:  3471 | 1111 | 0010 | 1010 | 1111 | w = 15, x = 2, y = 10, z = 15
  #4 | Fitness:  3458 | 1111 | 0000 | 0011 | 0110 | w = 15, x = 0, y = 3, z = 6
  #5 | Fitness:  3433 | 1111 | 0000 | 0000 | 1000 | w = 15, x = 0, y = 0, z = 8
Generation    3 | Best:  3602 | Average:   3247.82
  #1 | Fitness:  3602 | 1111 | 0000 | 1111 | 1111 | w = 15, x = 0, y = 15, z = 15
  #2 | Fitness:  3538 | 1111 | 0000 | 0111 | 1111 | w = 15, x = 0, y = 7, z = 15
  #3 | Fitness:  3526 | 1111 | 0000 | 0111 | 1011 | w = 15, x = 0, y = 7, z = 11
  #4 | Fitness:  3526 | 1111 | 0000 | 0111 | 1011 | w = 15, x = 0, y = 7, z = 11
  #5 | Fitness:  3513 | 1111 | 0001 | 1001 | 1111 | w = 15, x = 1, y = 9, z = 15
Generation    4 | Best:  3602 | Average:   3380.85
  #1 | Fitness:  3602 | 1111 | 0000 | 1111 | 1111 | w = 15, x = 0, y = 15, z = 15
  #2 | Fitness:  3586 | 1111 | 0000 | 1111 | 1110 | w = 15, x = 0, y = 15, z = 14
  #3 | Fitness:  3586 | 1111 | 0000 | 1011 | 1111 | w = 15, x = 0, y = 11, z = 15
  #4 | Fitness:  3571 | 1111 | 0000 | 1010 | 1110 | w = 15, x = 0, y = 10, z = 14
  #5 | Fitness:  3571 | 1111 | 0000 | 1010 | 1110 | w = 15, x = 0, y = 10, z = 14
Generation    5 | Best:  3602 | Average:   3491.71
  #1 | Fitness:  3602 | 1111 | 0000 | 1111 | 1111 | w = 15, x = 0, y = 15, z = 15
  #2 | Fitness:  3602 | 1111 | 0000 | 1111 | 1111 | w = 15, x = 0, y = 15, z = 15
  #3 | Fitness:  3602 | 1111 | 0000 | 1111 | 1111 | w = 15, x = 0, y = 15, z = 15
  #4 | Fitness:  3602 | 1111 | 0000 | 1111 | 1111 | w = 15, x = 0, y = 15, z = 15
  #5 | Fitness:  3602 | 1111 | 0000 | 1111 | 1111 | w = 15, x = 0, y = 15, z = 15
Generation    6 | Best:  3602 | Average:   3564.03
  #1 | Fitness:  3602 | 1111 | 0000 | 1111 | 1111 | w = 15, x = 0, y = 15, z = 15
  #2 | Fitness:  3602 | 1111 | 0000 | 1111 | 1111 | w = 15, x = 0, y = 15, z = 15
  #3 | Fitness:  3602 | 1111 | 0000 | 1111 | 1111 | w = 15, x = 0, y = 15, z = 15
  #4 | Fitness:  3602 | 1111 | 0000 | 1111 | 1111 | w = 15, x = 0, y = 15, z = 15
  #5 | Fitness:  3602 | 1111 | 0000 | 1111 | 1111 | w = 15, x = 0, y = 15, z = 15
Generation    7 | Best:  3602 | Average:   3562.67
  #1 | Fitness:  3602 | 1111 | 0000 | 1111 | 1111 | w = 15, x = 0, y = 15, z = 15
  #2 | Fitness:  3602 | 1111 | 0000 | 1111 | 1111 | w = 15, x = 0, y = 15, z = 15
  #3 | Fitness:  3602 | 1111 | 0000 | 1111 | 1111 | w = 15, x = 0, y = 15, z = 15
  #4 | Fitness:  3602 | 1111 | 0000 | 1111 | 1111 | w = 15, x = 0, y = 15, z = 15
  #5 | Fitness:  3602 | 1111 | 0000 | 1111 | 1111 | w = 15, x = 0, y = 15, z = 15
Generation    8 | Best:  3602 | Average:   3579.86
  #1 | Fitness:  3602 | 1111 | 0000 | 1111 | 1111 | w = 15, x = 0, y = 15, z = 15
  #2 | Fitness:  3602 | 1111 | 0000 | 1111 | 1111 | w = 15, x = 0, y = 15, z = 15
  #3 | Fitness:  3602 | 1111 | 0000 | 1111 | 1111 | w = 15, x = 0, y = 15, z = 15
  #4 | Fitness:  3602 | 1111 | 0000 | 1111 | 1111 | w = 15, x = 0, y = 15, z = 15
  #5 | Fitness:  3602 | 1111 | 0000 | 1111 | 1111 | w = 15, x = 0, y = 15, z = 15

Stopped after 8 generations: stagnation limit reached.
Best chromosome: 1111 | 0000 | 1111 | 1111
w = 15, x = 0, y = 15, z = 15
Best fitness: 3602
First found at generation: 3
```

Якщо підставити знайдені значення в функцію вручну, дістанемо
$3375 - 225 - 225 + 450 + 225 + 2 = 3602$, тобто результат збігається.
Завдяки фіксованому seed той самий запуск можна повторити в тому ж
середовищі і отримати ідентичний вивід.

=== Висновок
<висновок>
У ході виконання роботи реалізовано пошук максимуму функції
`f(w, x, y, z)` генетичним алгоритмом на двійковому кодуванні, де кожна
змінна займає чотири біти хромосоми. Знайдено найбільше значення 3602
при `w = 15`, `x = 0`, `y = 15`, `z = 15`, і його перевірено прямою
підстановкою в функцію.

Розібрано та запрограмовано всі стадії генетичного алгоритму:
кодування й декодування розв'язку, обчислення fitness, турнірний відбір
батьків, рівномірний crossover, мутацію інверсією біта, елітизм і
критерій зупинки за стагнацією. Роботу алгоритму продемонстровано на
покроковому виведенні статистики: видно, як найкращий fitness зростає
з 3475 до 3526 і далі до 3602, а середній підтягується до найкращого в
міру збіжності популяції.

Генетичний алгоритм є евристикою, тому зупинка за стагнацією не
доводить, що знайдено саме глобальний максимум, а
результат залежить від початкової популяції, випадкових операцій і
обраних параметрів.

== Додаток: повний код `main.py`
<додаток-повний-код-main.py>
#raw(read("main.py"), lang: "python", block: true)
