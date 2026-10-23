# touying-gipsa

> [!WARNING]
> This theme is **NOT** an official Gipsa-lab product. The logos and background images are the property of Gipsa-lab / CNRS / UGA / Grenoble INP.

**touying-gipsa** is a [Touying](https://github.com/touying-typ/touying) theme for creating presentation slides in [Typst](https://github.com/typst/typst), adapting the visual identity of the official Gipsa-lab Beamer and PowerPoint templates (UMR 5216, CNRS / UGA / Grenoble INP) to Typst.

It is a fork of [touying-unistra-pristine](https://github.com/spidersouris/touying-unistra-pristine) by Enzo Doyen, rebranded and restyled for Gipsa-lab. It is a rough first draft: layout details (frame titles, title page, footline) are approximated and do not aim for pixel fidelity with the Beamer template.

# Features

- **Title slide** matching the official Gipsa-lab PowerPoint template: "fond" background with a white strip at the bottom, main logo in the top left corner, centered white title block (title, subtitle, author, institution), date in the bottom left of the strip, and the CNRS / INPG / UGA logos in the bottom right. 16:9 decks use the 16:9 backgrounds extracted from the PowerPoint template; 4:3 decks use the original Beamer ones.
- **Footline** with the "bandeau" image, author and short title (white), slide number, and the CNRS / INPG / UGA logos.
- **Frame titles** with the Gipsa-lab logo and the title in the Gipsa dark blue.
- **Gipsa-lab palette**: dark blue `#16223A`, red `#BE1B20`, yellow `#ED7D20`, blue `#22AEE2`, green `#32A855`, with red list/enum markers.
- **Focus slides** with gradient themes built from the Gipsa colors.
- **Hero slides** and **gallery slides** (inherited from touying-unistra-pristine).
- **Better citations** (inherited from touying-unistra-pristine, see `src/citations.typ`).
- Appendix numbering (`A-` prefix in the footer after `#show: appendix`).

# Requirements

- Typst >= 0.15.0
- Touying 0.8.0

## Fonts

The theme uses the font stack `Carlito`, `Calibri`, `Liberation Sans`, `DejaVu Sans` (in that order — see the `font` setting in [Configuration](#configuration)). It matches the Calibri of the official PowerPoint template.

Calibri is a proprietary Microsoft font and is not installed by default on most Linux systems. That is not a problem: Typst falls back to the next font in the stack and the deck still compiles — you only get a `warning: unknown font family: calibri` message.

For a layout identical to the PowerPoint template, install **Carlito**, the free metric-compatible replacement for Calibri (same glyph widths, so text wraps at the same places):

```sh
sudo apt install fonts-crosextra-carlito          # Debian / Ubuntu
sudo dnf install google-crosextra-carlito-fonts  # Fedora
sudo pacman -S ttf-carlito                       # Arch
sudo zypper install google-carlito-fonts         # openSUSE
brew install --cask font-carlito                 # macOS (Homebrew)
```

On Windows, Calibri has been preinstalled since Windows Vista. On macOS, it ships with Microsoft Office; otherwise use Carlito as above. If you own a copy of the real Calibri (e.g. from a Windows or Office installation), you can also install `calibri.ttf` manually into `~/.local/share/fonts/` (Linux) or via Font Book (macOS) and run `fc-cache -f`.

Check that it is visible with `fc-list | grep -i carlito`. Note that the `calibri` warning can still appear even with Carlito installed: Typst warns about any family in the stack it cannot find, whether or not an earlier font already covers the text. Since Carlito is first in the stack and metrically identical to Calibri, the warning is harmless. To silence it, either install a font actually named Calibri, or drop `"Calibri"` from the stack via the `font` setting.

# Usage

```typst
#import "@preview/touying-gipsa:0.1.0": *

#show: gipsa-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [A not so long title],
    short-title: [Short title],
    subtitle: [Subtitle],
    author: [Author],
    institution: [GIPSA-Lab, UMR 5216 CNRS UGA],
    date: datetime.today().display("[year]-[month]-[day]"),
  ),
)

#title-slide()

= Example Section Title

== Example Slide

A slide with *important information*.

#pause

...and more.

#focus-slide(theme: "blue")[A focus slide]
```

When working inside this repository (e.g. on the bundled example), import the theme directly instead: `#import "src/lib.typ": *`.

A full example is available in [examples/basic.typ](examples/basic.typ); compile it from the repository root with:

```sh
typst compile --root . examples/basic.typ
```

## Testing the package locally

Until the package is published on Typst Universe, you can test it as a local package. Typst looks for local packages in its data directory under `packages/local/<name>/<version>/` (`~/.local/share/typst` on Linux, `~/Library/Application Support/typst` on macOS, `%APPDATA%\typst` on Windows). Symlink this repository there:

```sh
mkdir -p ~/.local/share/typst/packages/local/touying-gipsa
ln -s /path/to/touying-gipsa ~/.local/share/typst/packages/local/touying-gipsa/0.1.0
```

Because it is a symlink, edits in the repository are picked up immediately, with no reinstall step. You can then import the theme with the `@local` namespace from any project on your machine:

```typst
#import "@local/touying-gipsa:0.1.0": *
```

The version number (`0.1.0`) must match the `version` field in `typst.toml`; when you bump it, create a new symlink directory for the new version. To remove the local install: `rm ~/.local/share/typst/packages/local/touying-gipsa/0.1.0`.

## Starting a new deck with `typst init`

The repository ships a `typst init` template (see [template/template.typ](template/template.typ)). After publication, scaffold a new deck with:

```sh
typst init @preview/touying-gipsa:0.1.0 my-talk
cd my-talk
typst compile template.typ
```

To try the template before publication, scaffold from the local package instead, and swap the import on the first line of `template.typ` from `@preview` to `@local`:

```sh
typst init @local/touying-gipsa:0.1.0 my-talk
cd my-talk
sed -i 's|@preview/touying-gipsa|@local/touying-gipsa|' template.typ
typst compile template.typ
```

Either way, you get a `template.typ` preconfigured with the Gipsa theme (title slide, author, institution, date), ready to compile.

# Configuration

The theme is configured with the usual Touying `config-*` functions, plus a few settings in `config-store`:

| Name | Description | Type | Default |
| :--: | :--: | :--: | :-- |
| show-header | Whether to show the mini-slides navigation bar. | bool | `false` |
| show-footer | Whether to show the footline. | bool | `true` |
| assets-dir | Directory (relative to `src/`) containing the logos and backgrounds. | str | `"../assets/gipsa"` |
| footer-first-sep | Separator between author and title in the footer. | str | `" \| "` |
| footer-appendix-label | Prefix of slide numbers in the appendix. | str | `"A-"` |
| font | Fonts to use. | array[str] | `("Carlito", "Calibri", "Liberation Sans", "DejaVu Sans")` |
| footer-hide | Footer elements to hide (`"author"`). | array[str] | `()` |
| quotes | Quote marks for the custom `#quote()` element. | dict | French quotes |
| link-icons | Regex/icon pairs appended to matching links. | dict | `(:)` |

## Known limitations (first draft)

- The title slide is tuned for 16:9 decks (like the PowerPoint template). On 4:3 decks the original 4:3 Beamer backgrounds are used, and the main logo keeps a white box behind it.
- Section slides do not use the "fond" background of the PowerPoint template (only the main title slide does).
- The footline "bandeau" height/position differs slightly from the PowerPoint template's content-slide footer.
- Blocks are not restyled (Beamer block/alertblock/exampleblock colors are not reproduced).
- Nested list markers do not alternate red/yellow/blue by depth yet (all red).
- Link icons are disabled by default (the Unistra icon fonts are not available at Gipsa-lab).
- The speaker-notes panel (`notes-fn`) is not themed.

# Credits

- [touying-unistra-pristine](https://github.com/spidersouris/touying-unistra-pristine) by Enzo Doyen (MIT), itself based on components from [tud-slides](https://github.com/typst-tud/tud-slides).
- The official Gipsa-lab Beamer and PowerPoint templates (C. Baras, G. Becq, 2021-2024), which this theme's colors, layouts and assets are adapted from.
