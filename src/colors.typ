// Colors from the official Gipsa-lab Beamer template
// (latex_template/external-communication/gipsa-lab-styles/beamercolorthemeGipsalab.sty)

#let white = rgb("#ffffff")
#let black = rgb("#000000")

// Main structure color (GipsalabBlue / gipsalightgray)
#let dark = rgb("#16223A")

// Accent colors of the Gipsa-lab template
#let red = rgb("#BE1B20")
#let yellow = rgb("#ED7D20")
#let blue = rgb("#22AEE2")
#let green = rgb("#32A855")

// Footer text gray of the PowerPoint template
#let footer-grey = rgb("#9a9b9d")

// Old background colors of the original Gipsa-lab theme
#let bg-top = rgb(69, 20, 79)
#let bg-mid = rgb(48, 18, 69)
#let bg-bottom = rgb(28, 13, 38)

#let grey = (
  "A": rgb("#333332"),
  "B": rgb("#929292"),
  "C": rgb("#CACACA"),
  "D": rgb("#F6F6F6"),
  "E": rgb("#696260"),
)

#let link-color = blue.darken(35%)

// ----

// Color themes for focus slides, built from the Gipsa-lab accent colors.
#let colorthemes = (
  blue: (dark, blue),
  red: (red, yellow),
  green: (green, blue),
  night: (bg-top, bg-bottom),
  sunrise: (yellow, red),
  glacier: (blue, dark),
  forest: (green.darken(40%), green),
  ember: (red.darken(30%), red),
)

#let colorthemes-ids = (
  "1": colorthemes.blue,
  "2": colorthemes.red,
  "3": colorthemes.green,
  "4": colorthemes.night,
  "5": colorthemes.sunrise,
  "6": colorthemes.glacier,
  "7": colorthemes.forest,
  "8": colorthemes.ember,
)
