#import "@preview/touying:0.8.0": *
#import "@preview/fontawesome:0.6.0": fa-icon
#import "colors.typ": *
#import "icons.typ": *
#import "utils.typ": *

// Path (relative to this file) containing the Gipsa-lab logos and backgrounds.
// Original assets come from the official Gipsa-lab Beamer template.
#let _assets-dir = "../assets/gipsa"

// Height of the footline strip. The Beamer template uses ~5 mm on a 96 mm
// high page (~5%); we use a slightly taller strip for readability.
#let _footer-height = 8mm

/// Gipsa-lab footline: colored "bandeau" with author/title and page number
/// (white text), and the CNRS / INPG / UGA logos on its right.
#let _gipsa-footer(self) = {
  let dir = self.store.assets-dir

  let title = self.info.title
  if self.info.at("short-title", default: auto) != auto {
    title = self.info.short-title
  }

  let author = self.info.author
  if self.store.footer-hide.contains("author") {
    author = none
  }

  set text(size: 7.5pt)

  // inset the footline from the page edges, like the Beamer template
  pad(left: 10mm, right: 4mm, grid(
    columns: (1fr, auto, auto, auto),
    column-gutter: 1em,
    align: horizon,

    // bandeau with overlaid white text
    box(width: 100%, height: _footer-height, clip: true, {
      place(
        image(dir + "/bandeau_court_4x3.png", width: 100%, height: 100%, fit: "stretch"),
      )
      place(
        left + horizon,
        dx: 1.2em,
        text(fill: white, {
          if _is(author) { author }
          if _is(author) and _is(title) { self.store.footer-first-sep }
          if _is(title) { title }
        }),
      )
      place(
        right + horizon,
        dx: 1.2em,
        text(fill: white, utils.call-or-display(self, context {
          let current = int(utils.slide-counter.display())
          let last = int(utils.last-slide-counter.display())
          if current > last {
            (text(self.store.footer-appendix-label, style: "italic") + str(current))
          } else {
            str(current)
          }
        })),
      )
    }),
    image(dir + "/logoCNRS_alpha_2023.png", height: 5.2mm),
    image(dir + "/logoINPG_alpha.png", height: 4.8mm),
    image(dir + "/logoUGA_alpha.png", height: 6.2mm),
  ))
}

/// Optional navigation bar (mini-slides), shown when `show-header` is true.
#let gipsa-nav-bar(self) = {
  show: block.with(inset: (x: 5em))
  set text(size: 1.4em)
  place(
    grid(
      components.mini-slides(
        display-section: true,
        display-subsection: false,
      ),
    ),
    dy: -1.4em,
  )
}

/// Frame title: Gipsa-lab logo on the left, title in the dark Gipsa blue,
/// mimicking the `frametitle` template of the Beamer theme.
#let _gipsa-frame-title(self) = {
  grid(
    columns: (auto, 1fr),
    column-gutter: 0.8em,
    align: horizon,
    image(self.store.assets-dir + "/logoGipsalab_alpha_lr.png", height: 8mm),
    text(
      size: 1.35em,
      weight: "bold",
      fill: self.colors.dark,
      utils.display-current-heading(depth: self.slide-level),
    ),
  )
  v(0.6em)
}

/// Creates a normal slide with a title and body.
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let self = utils.merge-dicts(self, config-page(
    header: if self.store.show-header {
      gipsa-nav-bar(self)
    } else {
      none
    },
    footer: if self.store.show-footer {
      _gipsa-footer(self)
    } else {
      none
    },
    margin: (x: 3em, y: 2em, bottom: 2.2em),
  ))

  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: setting,
    composer: composer,
    ..bodies,
  )
})

/// Creates an outline slide with outlined headings.
#let outline-slide(
  title: utils.i18n-outline-title,
  title-size: 1.5em,
  title-margin: -0.5em,
  content-size: 1.2em,
  fill: dark,
  text-color: white,
  outset: 30pt,
  height: 80%,
  width: 100%,
  radius: 7%,
  ..args,
) = {
  let body = {
    text(
      title-size,
      weight: "bold",
      fill: text-color,
      title,
    )

    v(title-margin)

    // Retrieving focus slides titles, which have a specific heading level applied.
    let outline-content = outline(
      target: selector.or(..range(99, 100).map(l => heading.where(level: l))),
      ..args,
    )

    set text(fill: text-color)
    text(content-size, box(outline-content, width: width * 1.1))
  }

  body = place(
    block(
      body,
      fill: fill,
      outset: outset,
      height: height,
      width: width,
      radius: radius,
    ),
    dy: -0.5em,
  )

  slide(body)
}

/// Creates a title slide matching the official Gipsa-lab PowerPoint template
/// (`template.pptx`): full-page wavy background ("fond") leaving a white strip
/// at the bottom, main logo in the top left corner (inside the white corner of
/// the fond), centered white title block (title, subtitle, author,
/// institution), the date in the bottom left of the white strip, and the
/// CNRS / INPG / UGA logos in the bottom right of the white strip.
///
/// On 16:9 decks the backgrounds extracted from the PowerPoint template are
/// used; on 4:3 decks the original Beamer ones are used instead.
///
/// - `title` (content): Override for the title. Default: "".
/// - `subtitle` (content): Override for the subtitle. Default: "".
/// - `logo` (content): Main logo, top left corner. Default: Gipsa-lab logo.
/// - `fond` (content | str): Background image. Default: "court" fond if an
///   institution is given, "long" otherwise (16:9 or 4:3 depending on the deck
///   aspect ratio).
/// - `hide` (array[str]): Info elements to hide ("date", "institution", ...).
#let title-slide(
  title: "",
  subtitle: "",
  logo: "",
  fond: auto,
  hide: (),
  ..args,
) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let dir = self.store.assets-dir

  // Backgrounds from the PowerPoint template for 16:9 decks, original Beamer
  // backgrounds for 4:3 decks.
  let ratio = self.store.at("aspect-ratio", default: "16-9")
  let (court, long) = if ratio == "16-9" {
    (dir + "/fond_titre_16x9.png", dir + "/fond_titre_long_16x9.png")
  } else {
    (dir + "/fond_titre_court_4x3.png", dir + "/fond_titre_long_4x3.png")
  }

  let fond-path = if fond == auto {
    let institution = info.at("institution", default: none)
    if institution != none and _is(institution) {
      court
    } else {
      long
    }
  } else if type(fond) == str {
    dir + "/" + fond
  } else {
    fond
  }

  // On 4:3 decks the white corner of the fond is smaller, so the logo needs a
  // white box to not overlap the wavy pattern.
  let main-logo = if logo != "" {
    logo
  } else if ratio == "16-9" {
    image(dir + "/logoGipsalab_alpha_lr.png", height: 4.6em)
  } else {
    box(
      fill: white,
      inset: 1.2em,
      radius: 1.5pt,
      image(dir + "/logoGipsalab_alpha_lr.png", height: 4.6em),
    )
  }

  let date-cell = if "date" in info and "date" not in hide {
    grid.cell(
      align: left + horizon,
      text(size: 0.53em, fill: footer-grey, utils.display-info-date(self)),
    )
  } else {
    []
  }

  let body = {
    set block(inset: 0mm, outset: 0mm, spacing: 0em)
    set align(top + left)

    block(fill: none, width: 100%, height: 100%, {
      grid(
        columns: (1fr,),
        rows: (auto, 1fr, auto, auto),

        // main logo, top left, inside the white corner of the fond
        pad(left: 0.8em, top: 0.4em, main-logo),

        // spacer
        [],

        // centered title block (title, subtitle, author, institution), like
        // the centered placeholders of the PowerPoint template
        grid.cell(pad(bottom: 0.8em, align(center, block(width: 85%, {
          set align(center)
          set text(fill: white)
          set par(spacing: 0em, leading: 0em)
          text(size: 2.3em, weight: "bold", if (title != "") {
            title
          } else {
            info.title
          })
          if (none, "", auto).all(x => x != info.subtitle) {
            v(0.45em)
            text(size: 1.05em, info.subtitle)
          }
          if _is(info.author) {
            v(0.4em)
            text(size: 0.9em, info.author)
          }
          if "email" in info and _is(info.email) {
            v(0.25em)
            text(size: 0.8em, info.email)
          }
          if (
            "institution" in info
              and _is(info.institution)
              and "institution" not in hide
          ) {
            v(0.25em)
            text(size: 0.8em, info.institution)
          }
        })))),

        // white strip: date on the left, partner logos on the right
        pad(left: 0.5em, right: 0.2em, bottom: 0.15em, grid(
          columns: (1fr, auto, auto, auto),
          column-gutter: 1.5em,
          align: bottom,
          date-cell,
          image(dir + "/logoCNRS_alpha_2023.png", height: 1.84em),
          image(dir + "/logoINPG_alpha.png", height: 1.51em),
          image(dir + "/logoUGA_alpha.png", height: 1.31em),
        )),
      )
    })
  }

  // The background ("fond") is drawn behind the slide, leaving a white strip
  // at the bottom (9.07% of the page height) for the date and the partner
  // logos, like the PowerPoint template.
  let background = box(width: 100%, height: 100%, stack(
    dir: ttb,
    image(fond-path, width: 100%, height: 90.93%, fit: "stretch"),
    rect(fill: white, width: 100%, height: 9.07%),
  ))

  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(margin: 0em, background: background),
    config-common(subslide-preamble: none),
  )

  touying-slide(
    self: self,
    body,
  )
})

/// Creates a focus slide with a gradient background.
///
/// If no colors are provided, will use the theme.
///
/// Examples:
///
/// ```typst
/// #focus-slide(c1: blue, c2: cyan)[Title]
/// ```
///
/// ```typst
/// #focus-slide(theme: "red")[Title]
/// ```
///
/// - `c1` (color): The first color of the gradient. Default: none.
///
/// - `c2` (color): The second color of the gradient. Default: none.
///
/// - `text-color` (color): The color of the text. Default: none.
///
/// - `text-size` (length): The size of the text. Default: 2em.
///
/// - `theme` (str | int): The color theme name or ID to use. Themes are defined in src/colors.typ. Default: none.
///
/// - `icon` (function): The icon to show above the text.
///
/// - `icon-size` (length): The size of the icon. Default: 1.7em.
///
/// - `counter` (counter): The counter to use for titles. Will show a count-label before the title. Default: counter("focus-slide").
///
/// - `show-counter` (bool): Whether to show the counter. Default: true.
///
/// - `outlined` (bool): Whether to outline the heading and make it appear in an outline slide. Default: true.
///
/// - `body` (content): Content of the slide.
#let focus-slide(
  c1: none,
  c2: none,
  text-color: none,
  text-size: 2em,
  theme: none,
  icon: none,
  icon-size: 1.7em,
  counter: counter("focus-slide"),
  show-counter: true,
  outlined: true,
  body,
) = touying-slide-wrapper(self => {
  assert(
    (c1 != none and c2 != none) or theme != none,
    message: "Please provide a color theme or two colors for the focus slide.",
  )

  let new-text-color = text-color
  let new-c1 = c1
  let new-c2 = c2

  if (theme != none) {
    let theme-colors = none
    let theme-name = none

    if (type(theme) == int) {
      let theme-id-str = str(theme)
      assert(
        theme-id-str in self.store.colorthemes-ids,
        message: "The theme ID "
          + str(theme)
          + " is not defined. Available theme IDs are: "
          + self.store.colorthemes-ids.keys().join(", "),
      )
      theme-colors = self.store.colorthemes-ids.at(theme-id-str)
    } else {
      assert(
        theme in self.store.colorthemes,
        message: "The theme "
          + theme
          + " is not defined. Available themes are: "
          + self.store.colorthemes.keys().join(", "),
      )
      theme-colors = self.store.colorthemes.at(theme)
      theme-name = theme
    }

    assert(
      theme-colors.len() == 2 or theme-colors.len() == 3,
      message: "The theme "
        + (if theme-name != none { theme-name } else { str(theme) })
        + " is not a valid color theme. A valid color theme should have 2 or 3 colors.",
    )

    let theme-has-text-color = theme-colors.len() == 3

    if (text-color == none and not theme-has-text-color) {
      new-text-color = self.colors.white
    } else if (theme-has-text-color) {
      new-text-color = theme-colors.at(2)
    }

    new-c1 = theme-colors.at(0)
    new-c2 = theme-colors.at(1)
  }

  let body = {
    set text(
      fill: new-text-color,
      size: text-size,
      weight: "bold",
      tracking: 0.8pt,
    )

    if (show-counter) {
      counter.step()
    }

    context {
      let count-label = none
      if (show-counter) {
        count-label = counter.display("I") + ". "
      }
      _gradientize(
        self,
        block(
          width: 100%,
          height: 100%,
          grid(
            grid.cell(
              if (_is(icon)) {
                text(size: icon-size)[#icon]
              },
              align: center + bottom,
            ),
            grid.cell(
              heading(
                level: 99,
                outlined: outlined,
                bookmarked: outlined,
                box(
                  width: 90%,
                  if (count-label != none) {
                    text(weight: "bold", count-label)
                  }
                    + body,
                ),
              ),
              align: center + top,
            ),
            columns: 1fr,
            rows: (1.1fr, auto, 1fr),
            row-gutter: 0.43em,
            align: center + horizon,
          ),
        ),
        c1: new-c1,
        c2: new-c2,
      )
    }
  }

  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(margin: 0em),
    config-common(subslide-preamble: none),
  )

  touying-slide(self: self, body)
})

/// Creates a hero slide with a high width image, and optional title, subtitle, caption and text. The image can take all the space, or be on the left or right side.
///
/// - `title` (content): The title of the slide. Default: none.
///
/// - `heading-level` (int): The heading level of the title. Default: 1.
///
/// - `subtitle` (content): The subtitle of the slide. Default: none.
///
/// - `caption` (content): The caption of the image. Default: none.
///
/// - `columns` (int | relative | fraction | array): The columns of the grid. Default: (1fr, 2fr).
///
/// - `txt` (dict): The text to display next to the image, along with its style.
///
/// - `direction` (str): The direction of the image and text. Possible values: "ltr", "rtl", "utd", "dtu". Default: "ltr".
///
/// - `hide-footer` (bool): Whether to hide the footer. Default: true.
#let hero(
  title: none,
  heading-level: 1,
  subtitle: none,
  caption: none,
  bold-caption: false,
  numbering: none,
  columns: (1fr, 2fr),
  rows: 1fr,
  txt: (:),
  direction: "ltr",
  gap: auto,
  hide-footer: true,
  fill: none,
  inset: -25mm,
  footnote: false,
  ..args,
) = touying-slide-wrapper(self => {
  let fig = args.pos().at(0)

  if (txt != (:) and "text" not in txt) {
    panic("The txt argument value must contain a text key")
  }

  // merge with default values
  let merged-txt = utils.merge-dicts(
    (
      text: none,
      enhanced: true,
      fill: none,
      align: horizon + center,
    ),
    txt,
  )

  if (fig == none) {
    panic(
      "A hero slide requires an inline image such as image('path/to/image.jpg')",
    )
  }

  let create-figure() = {
    if (bold-caption) {
      caption = text(weight: "bold", caption)
    }

    figure(
      fig,
      caption: caption,
      numbering: numbering,
    )
  }

  let create-image-cell() = {
    _cell(create-figure())
  }

  let create-text-cell() = {
    let new-txt = merged-txt.text
    if type(merged-txt.enhanced) == bool and merged-txt.enhanced {
      new-txt = text(size: 2em, weight: 900, merged-txt.text)
    } else if (
      type(merged-txt.enhanced) == bool and not merged-txt.enhanced
    ) {
      new-txt = merged-txt.text
    } else if type(merged-txt.enhanced) == function {
      new-txt = (merged-txt.enhanced)(merged-txt.text)
    } else {
      panic("Value of enhanced key must be a boolean or a function")
    }

    _cell(
      new-txt,
      height: 100%,
      width: 100%,
      inset: 20mm,
      alignment: merged-txt.align,
      fill: merged-txt.fill,
    )
  }

  let create-grid(
    first-cell,
    second-cell,
    columns: columns,
    rows: rows,
    column-gutter: auto,
    row-gutter: auto,
  ) = {
    grid(
      columns: columns,
      rows: rows,
      column-gutter: column-gutter,
      row-gutter: row-gutter,
      first-cell, second-cell,
    )
  }

  let create-body() = {
    if (merged-txt.text == none) {
      align(center, create-figure())
    } else {
      if direction == "ltr" {
        create-grid(
          create-text-cell(),
          create-image-cell(),
          column-gutter: gap,
        )
      } else if direction == "rtl" {
        create-grid(
          create-image-cell(),
          create-text-cell(),
          column-gutter: gap,
          columns: (2fr, 1fr),
        )
      } else if direction == "utd" {
        create-grid(
          create-image-cell(),
          create-text-cell(),
          columns: 1fr,
          rows: (1fr, 1fr),
          row-gutter: gap,
        )
      } else if direction == "dtu" {
        create-grid(
          create-text-cell(),
          create-image-cell(),
          columns: 1fr,
          rows: (1fr, 1fr),
          row-gutter: if gap != auto {
            gap
          } else {
            -2em
          },
        )
      }
    }
  }

  let body = create-body()

  if (title != none) {
    body = _title-and-sub(
      body,
      v(heading-level * -0.6em) + title,
      subtitle: subtitle,
      heading-level: heading-level,
    )
  }

  if hide-footer or footnote {
    body = block(
      body,
      fill: fill,
      height: if (footnote) {
        80%
      } else {
        100%
      },
      width: 100%,
    )
  }

  if (title, subtitle, caption).all(x => x == none) {
    body = block(
      body,
      inset: inset,
    )
  }

  let self = utils.merge-dicts(self, config-common(subslide-preamble: none))

  touying-slide(self: self, body)
})

/// Creates a gallery slide with a title and images.
#let gallery(
  title: none,
  heading-level: 2,
  subtitle: none,
  images: (),
  columns: auto,
  captions: (),
  bold-caption: true,
  height: auto,
  width: auto,
  fit: "cover",
  gutter: 0.5em,
  gap: 0.65em,
  ..args,
) = touying-slide-wrapper(self => {
  let figs = args.pos()

  if (figs == none) {
    panic(
      "A gallery slide requires at least one inline image such as image('path/to/image.jpg')",
    )
  }

  let rows = (figs.len() / columns)
  let body = {
    set align(center + horizon)
    grid(
      ..figs
        .enumerate()
        .map(((i, fig)) => {
          let caption = if i < captions.len() {
            let cap = captions.at(i)
            if cap != "" {
              cap
            } else {
              none
            }
          } else {
            none
          }

          if (bold-caption) {
            caption = text(weight: "bold", caption)
          }

          figure(
            fig,
            caption: caption,
            gap: gap,
            numbering: none,
          )
        }),
      columns: columns,
      rows: 1fr * rows,
      gutter: gutter,
    )
  }

  body = _title-and-sub(
    body,
    title,
    subtitle: subtitle,
    heading-level: heading-level,
  )

  let self = utils.merge-dicts(self, config-common(subslide-preamble: none))

  touying-slide(self: self, body)
})

/// Registers the Gipsa-lab theme.
#let gipsa-theme(
  aspect-ratio: "16-9",
  header: [],
  footer: [],
  ..args,
  body,
) = {
  set text(size: 20pt)

  show: touying-slides.with(
    config-colors(
      white: white,
      black: black,
      grey: grey,
      dark: dark,
      red: red,
      yellow: yellow,
      blue: blue,
      green: green,
      primary: dark,
      secondary: blue,
    ),

    config-page(
      paper: "presentation-" + aspect-ratio,
      footer-descent: 0em,
      header-ascent: 1em,
    ),

    config-common(
      slide-fn: slide,
      title-slide: title-slide,
      focus-slide: focus-slide,
      gallery: gallery,
      hero: hero,
      subslide-preamble: self => _gipsa-frame-title(self),
    ),

    config-store(
      // colorthemes from colors.typ
      colorthemes: colorthemes,
      colorthemes-ids: colorthemes-ids,
      show-header: false,
      show-footer: true,
      // directory containing the Gipsa-lab logos and backgrounds
      assets-dir: _assets-dir,
      // footer first separator
      footer-first-sep: " | ",
      // footer second separator
      footer-second-sep: " | ",
      footer-appendix-label: "A-",
      // Carlito is metrically compatible with Calibri, the font used by the
      // official PowerPoint template
      font: ("Carlito", "Calibri", "Liberation Sans", "DejaVu Sans"),
      // deck aspect ratio, used to pick matching backgrounds
      aspect-ratio: aspect-ratio,
      // type of left/right quote to use for the custom "Quote" element
      quotes: (
        left: "« ",
        right: " »",
        outset: 0.5em,
        margin-top: 0em,
      ),
      // elements to hide from footer ("author")
      footer-hide: (),
      // link icons are disabled by default: the Unistra icon fonts are not
      // available at Gipsa-lab. Set link-icons to a dict of
      // (regex, content) pairs to re-enable them.
      link-icons: (:),
      link-icons-fa: true,
    ),

    config-methods(
      alert: utils.alert-with-primary-color,
      smaller: smaller,
      smallest: smallest,

      // init
      init: (self: none, body) => {
        // states
        let in-outline = state("in-outline", false)

        // sets
        set text(
          fill: black,
          font: self.store.font,
          size: 20pt,
        )
        set outline(target: heading.where(level: 1), title: none)
        set outline.entry(fill: none)
        set enum(numbering: n => text(fill: self.colors.red)[*#n.*])
        set list(marker: text(fill: self.colors.red, [•]))
        set highlight(extent: 1pt)

        // shows
        show strong: self.methods.alert.with(self: self)
        show footnote.entry: set text(size: 13pt)

        show heading.where(level: 1): set text(
          size: 1.5em,
          weight: "bold",
          fill: self.colors.dark,
        )
        show heading.where(level: 2): set block(below: 1.5em)

        // color and iconize links
        show link: it => context {
          // except for the outline slide
          if in-outline.get() {
            text(weight: "regular", it)
          } else {
            let styled-link = text(
              link-color,
              underline.with(
                offset: 3pt,
                extent: -1pt,
              )(it),
            )

            if self.store.link-icons.len() > 0 {
              let dest = if type(it.dest) == str {
                it.dest
              } else {
                str(it.dest)
              }
              let found = none
              for pair in self.store.link-icons.values() {
                let (pattern, icon) = pair
                if dest.matches(pattern).len() > 0 {
                  found = icon
                  break
                }
              }
              if found != none {
                [#styled-link #super(found)]
              } else {
                styled-link
              }
            } else {
              styled-link
            }
          }
        }
        // custom quote
        show quote: it => _custom-quote(
          it,
          self.store.quotes.at("left"),
          self.store.quotes.at("right"),
          self.store.quotes.at("outset"),
          self.store.quotes.at("margin-top"),
        )
        show outline.entry: it => (
          // support links for outline entries
          link(it.element.location(), it.body()) + linebreak()
        )
        show outline: it => context {
          // state used to not color links in outline
          in-outline.update(true)
          block(inset: (x: 1em), it)
          in-outline.update(false)
        }
        // bibliography
        show bibliography: set text(size: 14pt)
        show bibliography: set par(spacing: 0.5em, leading: 0.4em)
        show bibliography: it => {
          // fixes https://github.com/typst/hayagriva/issues/114
          show "https://doi.org/": ""
          it
        }

        body
      },
    ),

    ..args,
  )

  body
}
