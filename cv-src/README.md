# CV source

The two CV PDFs served from `../assets/` are generated from the HTML in this
folder. Edit the HTML, run the build, commit the regenerated PDFs.

```
./build.sh
```

Outputs:

| source       | PDF                                           |
| ------------ | --------------------------------------------- |
| `cv-en.html` | `../assets/Rafael-Ribeiro-da-Silva-CV-EN.pdf` |
| `cv-pt.html` | `../assets/Rafael-Ribeiro-da-Silva-CV-PT.pdf` |

The build needs headless Google Chrome, plus Ghostscript for the shrink pass
(`brew install ghostscript`). Without Ghostscript it still produces a correct
PDF, just around 40% larger. Override the browser with
`CHROME=/path/to/chrome ./build.sh`.

You can also open either file in a browser — the pages render on screen the
same way they print.

## Things that will bite you

- **One font size per glyph subset.** Chrome embeds a *separate* font subset
  for every distinct `font-size` in the document, so adding one new size costs
  roughly 15 KB. `cv.css` deliberately reuses a short scale — 7.5, 9.3, 9.8,
  10.25, 11.4, 12.6, 13.5, 14.7, 15.5, 16, 34. Pick the nearest existing value
  instead of inventing a new one. Ghostscript does not merge them for you.
- **Font stack.** `cv.css` resolves to Arial / Liberation Sans. These are
  metric-compatible, which is why the PDF looks the same whether it was built
  on macOS or Linux. Swapping in another family moves every line break.
- **The name is `nowrap`.** It has to stay on one line, and at 34px it clears
  the contact block by about 47px. A longer string or a larger size will run
  into it.
- **Fixed pages.** Each `.page` is a hard 210×297mm box, so content does not
  reflow across pages. If you add a paragraph, check that page one still ends
  on the Millennium bcp entry and that nothing runs under the footer rule.
- **`class="dense"`** on `cv-pt.html` shaves a few pixels off some vertical
  padding. Portuguese runs longer than English and needs it to fit the same
  two pages.
- **`photo.jpg`** is a 528px crop; Ghostscript resamples it to 300 dpi. Do not
  point the HTML at the 1254px original — Chrome re-encodes WebP losslessly
  and the PDF jumps to 2 MB.
- These files are published along with the rest of the site, so they carry a
  `noindex` meta tag.
