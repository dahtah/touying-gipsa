#import "@preview/touying-gipsa:0.1.0": *

#show: gipsa-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Title],
    author: [Author],
    institution: [GIPSA-Lab, UMR 5216 CNRS UGA],
    date: datetime.today().display("[year]-[month]-[day]"),
  ),
)

#title-slide()

= Example Section Title

== Example Slide

A slide with *important information*.

#focus-slide(theme: "blue")[
  A focus slide with theme "blue"
]
