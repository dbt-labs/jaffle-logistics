# Shareholder deck, Fivetran + dbt Labs theme

`presentation.html` is the Jaffle Logistics shareholder deck
([published here](https://boxysean.github.io/jaffle-logistics-europe/shareholder-deck/presentation.html),
built from `slides/` in [boxysean/jaffle-logistics-europe](https://github.com/boxysean/jaffle-logistics-europe))
re-skinned in the corporate Fivetran + dbt Labs theme: navy title and section slides with the
template's colour blocks, white content slides with a navy Inter headline, hairline cards, IBM Plex
Mono labels, and the logo badge with the brand gradient along the foot of every slide.

Only the look changes. Every slide, number, chart, fragment step and speaker note is the original's.
Open the file in a browser: arrow keys to move, `s` for speaker notes, `f` for full screen.

## Rebuilding

The theme is applied to the *built* deck, so the slides stay in one place:

    # in jaffle-logistics-europe
    python3 slides/build_deck.py --variant light --out /tmp/deck.html
    # here
    python3 slides/corporate/build_corporate.py /tmp/deck.html --out slides/corporate/presentation.html

The full deck (`build_deck.py` without `--variant light`) themes the same way.

- `build_corporate.py` swaps the fonts, maps the colours written into the slides' SVGs, appends
  `theme.css` with the images inlined, and sets the all-caps headlines in sentence case at load time.
- `theme.css` holds the palette (the deck's colour variables, redefined) and the chrome.
- `assets/` holds the logo lock-up, the logo badge, and the title and section backgrounds, taken
  from the Fivetran + dbt Labs slide template.
