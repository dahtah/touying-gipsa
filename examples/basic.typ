#import "@preview/touying:0.8.0": *
#import "../src/lib.typ": *

#show: gipsa-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Main title of the talk],
    short-title: [Short title 1],
    subtitle: [Subtitle 1],
    author: [Author 1],
    institution: [GIPSA-Lab, UMR 5216 CNRS UGA Grenoble-inp],
    date: datetime.today().display("[year]-[month]-[day]"),
  ),
)

#title-slide()

= Example Section Title

== Example Slide

A slide with *important information*.

#pause

...and some more information revealed with `#pause`.

=== Highlight

This is #highlight(fill: blue.lighten(80%))[highlighted in blue]. This is #highlight(fill: yellow.lighten(80%))[highlighted in yellow]. This is #highlight(fill: green.lighten(80%))[highlighted in green]. This is #highlight(fill: red.lighten(80%))[highlighted in red].

== Itemize

- Item with depth 1
  - Item with depth 2
    - Item with depth 3
- Item with depth 1

== Enumerate

+ Item
+ Item
  + Sub-item
+ Item

== Blocks

#block[
  A normal block. #lorem(10)
]

#block(fill: red.lighten(90%), stroke: red)[
  An "alert" block, in gipsa red.
]

#block(fill: blue.lighten(90%), stroke: blue)[
  An "example" block, in gipsa blue.
]

#quote(attribution: [Someone], [
  A quote, with the custom French quotation marks.
])

#slide[
  First column. #lorem(10)
][
  Second column. #lorem(10)
]

#focus-slide(theme: "blue")[
  A focus slide with theme "blue"
]

#focus-slide(theme: "red")[
  A focus slide with theme "red"
]

= Second Section

== Outline

#outline-slide()

== Links

#link("https://www.gipsa-lab.grenoble-inp.fr")[Gipsa-lab website]

#show: appendix

== Rescue Slide 1

A rescue slide, after `#show: appendix`.

== Rescue Slide 2

Note the appendix label in the footer.
