#!/usr/bin/env python3
"""Re-skin the built Jaffle Logistics shareholder deck in the Fivetran + dbt Labs corporate theme.

The deck itself is built from its parts in boxysean/jaffle-logistics-europe (slides/build_deck.py);
this script takes that built, single-file Reveal.js deck and writes a themed copy beside it. Nothing
about the slides' content or order changes - only how they look:

    1. fonts: the pixel font and IBM Plex Mono become Inter / Inter Tight, with Plex Mono kept
       for code and small labels
    2. palette: the deck's colour variables, and the few colours written straight into its SVGs,
       are mapped onto the corporate palette (navy, blue, orange, pink on white)
    3. chrome: theme.css is appended after the deck's own CSS, with the logo and background
       images in assets/ inlined as data URIs so the result is still one self-contained file
    4. headlines: all-caps headlines are set in sentence case at load time (see CASE_SCRIPT)

Run:
    python3 slides/build_deck.py --variant light --out /tmp/deck.html      # in jaffle-logistics-europe
    python3 slides/corporate/build_corporate.py /tmp/deck.html --out slides/corporate/presentation.html
"""
import argparse
import base64
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
ASSETS = os.path.join(HERE, "assets")
REVEAL = "reveal.js@5.2.1"

FONTS = ('<link href="https://fonts.googleapis.com/css2?family=Inter:ital,wght@0,400;0,500;0,600;0,700;1,400'
         '&family=Inter+Tight:wght@600&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">')

# colours written straight into the slides' SVG and inline styles (the CSS uses variables)
HEX = {
    "#5fd3c8": "#4e83f7",  # teal-hi -> brand blue
    "#ffb000": "#ff6704",  # amber -> brand orange
    "#ff3d6e": "#e3346f",  # hot -> brand pink
    "#a06bff": "#632ff5",  # violet
    "#1d6b68": "#a7c4fe",  # teal -> light blue
    "#e4f3ef": "#001526",  # text -> navy
    "#8fb5bb": "#5a6b7d",  # dim
    "#050b18": "#ffffff",  # deep -> white
    "#0a1630": "#ffffff",  # navy -> white
    "#0f2145": "#f4f7fd",  # navy-2 -> tint
}

# words that keep their own casing when an all-caps headline is set in sentence case
CASE_SCRIPT = r"""
<script>
(function () {
  var KEEP = {AI:1, SL:1, RAG:1, DAG:1, MCP:1, Q1:1, Q2:1, Q3:1, Q4:1, FY2025:1, EUR:1, CFO:1, COO:1, CRO:1, BI:1, SQL:1, HUB:1, AMS:1};
  var PROPER = {JAFFLE:'Jaffle', LOGISTICS:'Logistics', PARIS:'Paris', AMSTERDAM:'Amsterdam', BERLIN:'Berlin',
    VIENNA:'Vienna', 'ZÜRICH':'Zürich', WERKE:'Werke', JANUARY:'January', DBT:'dbt', FIVETRAN:'Fivetran',
    CLAUDE:'Claude', CHATGPT:'ChatGPT'};
  function sentence(s) {
    var start = true;
    return s.replace(/[A-Za-zÀ-ÿ0-9][A-Za-zÀ-ÿ0-9_\-']*|[.!?:]/g, function (w) {
      if (/^[.!?:]$/.test(w)) { start = true; return w; }
      var up = w.toUpperCase(), out;
      if (KEEP[up]) out = up;
      else if (PROPER[up]) out = PROPER[up];
      else if (/[0-9]/.test(w)) out = w;
      else out = w.toLowerCase();
      if (start && out !== 'dbt') out = out.charAt(0).toUpperCase() + out.slice(1);
      start = false;
      return out;
    });
  }
  // only text that is entirely capitals (a mixed-case headline was already written that way)
  var SEL = '.hd h2, .sect h2, .title-box h1, .lt-cards .lbl, .lt-wires .verdict, .lt-flow .st .nm:not(.code), ' +
            '.lt-big .figs .v, .lt .callout .v, .lt .facts .v, .sect .panel div';
  document.querySelectorAll(SEL).forEach(function (el) {
    var w = document.createTreeWalker(el, NodeFilter.SHOW_TEXT), n, nodes = [];
    while ((n = w.nextNode())) {
      var p = n.parentElement;
      if (p.closest('.no, .when, .kick, .tab, code')) continue;
      nodes.push(n);
    }
    var all = nodes.map(function (x) { return x.nodeValue; }).join('');
    if (!/[A-Z]{2}/.test(all) || /[a-z]/.test(all.replace(/dbt/g, ''))) return;
    var first = true;
    nodes.forEach(function (x) {
      if (!/[A-Za-z]/.test(x.nodeValue)) return;
      var t = sentence(x.nodeValue);
      // a run after the first only continues the sentence
      if (!first && /^[A-Z][a-z]/.test(t) && !/^\s*[.!?:]/.test(x.nodeValue)) {
        var head = t.split(/\s/)[0];
        if (!PROPER[head.toUpperCase()]) t = t.charAt(0).toLowerCase() + t.slice(1);
      }
      x.nodeValue = t; first = false;
    });
  });
})();
</script>
"""


def data_uri(name):
    mime = "image/png" if name.endswith(".png") else "image/jpeg"
    with open(os.path.join(ASSETS, name), "rb") as fh:
        return f"data:{mime};base64,{base64.b64encode(fh.read()).decode('ascii')}"


def theme_css():
    with open(os.path.join(HERE, "theme.css"), encoding="utf-8") as fh:
        css = fh.read()
    for token, name in [("__LOGO_BADGE__", "logo-badge.png"), ("__LOGO_LOCKUP__", "logo-lockup.png"),
                        ("__TITLE_BG__", "title-bg.jpg"), ("__SECTION_BG__", "section-bg.jpg")]:
        css = css.replace(token, data_uri(name))
    return css


def build(src):
    html = src
    # 1. fonts, and Reveal pinned to an exact version
    html = re.sub(r'<link href="https://fonts\.googleapis\.com/css2\?[^"]*" rel="stylesheet">', FONTS, html, count=1)
    html = html.replace("reveal.js@5/", f"{REVEAL}/")
    html = html.replace("<title>Jaffle Logistics — Shareholder Briefing</title>",
                        "<title>Jaffle Logistics — Shareholder Briefing · Fivetran + dbt Labs</title>")
    # 2. hard-coded colours (attribute values and inline styles only; the variables are redefined in CSS)
    for old, new in HEX.items():
        html = re.sub(rf'(?i)(fill|stroke|stop-color|color|background)(=["\']|:\s*){old}\b',
                      lambda m: m.group(1) + m.group(2) + new, html)
    # the Jaffle title slide (the second title-box) gets its own class, so the CSS can find it
    html = re.sub(r'<section((?![^>]*class=)[^>]*)>(\s*<div class="frame">\s*<div class="panel title-box">)',
                  r'<section class="ttl"\1>\2', html)
    # 3. the theme, last in the stylesheet so it wins
    head_end = html.index("</style>")
    html = html[:head_end] + theme_css() + html[head_end:]
    # 4. sentence-case headlines, before Reveal lays the deck out
    reveal_tag = f'<script src="https://cdn.jsdelivr.net/npm/{REVEAL}/dist/reveal.js"></script>'
    html = html.replace(reveal_tag, CASE_SCRIPT + reveal_tag, 1)
    return html


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("deck", help="the built deck, from jaffle-logistics-europe's slides/build_deck.py")
    ap.add_argument("--out", default=os.path.join(HERE, "presentation.html"))
    args = ap.parse_args()
    with open(args.deck, encoding="utf-8") as fh:
        out = build(fh.read())
    with open(args.out, "w", encoding="utf-8") as fh:
        fh.write(out)
    print(f"wrote {os.path.relpath(args.out)}")


if __name__ == "__main__":
    main()
