# CGPA Tracker

A neo-brutalist CGPA tracker in a single file (`index.html`): HTML, CSS and vanilla JS, no build step.
Open `index.html` in a browser, or deploy the folder to any static host (Netlify config included).

## Features

- Big CGPA hero, latest semester GPA, credit hours earned, and a 0–4 progress ruler with your target marked.
- Semesters as timeline "chapters", each marked completed or upcoming. Add a subject with name, credits and grade, then press Enter. Blank credits default to 3, and the grade can stay "No grade yet".
- Inline editing everywhere. Deleting a subject or semester can be undone (Undo button or Ctrl+Z).
- The plan: set a target CGPA and see the GPA you need next semester. Credits come from your next upcoming semester, or from an estimate you type in.
- What-if mode: pick target grades on pending subjects and see your projected CGPA right away. You can also set every pending subject to one grade in a single step.
- Charts (Chart.js 4.4.1 from cdnjs): GPA vs CGPA trend, grade spread, credit load. Each chart also has a table view.
- Data is saved in `localStorage`. You can export or import a JSON backup.
- Dark mode, keyboard accessible, respects reduced motion, works at phone width.

## Customising the grading scale

**In the app:** click **Grade scale** at the top. Rename letters, change points (0–4.00), add or remove grades, then press **Save scale**.
If you rename a letter, every subject using it is updated to the new name. If you remove a letter that subjects still use, they show "not in scale" until you choose another grade.

**In code (to change the default for new users):** edit `DEFAULT_SCALE` near the top of the `<script>` in `index.html`:

```js
const DEFAULT_SCALE = [
  ['A+', 4.00], ['A', 4.00], ['A-', 3.67], /* ... */ ['F', 0.00]
].map(([letter, points]) => ({ letter, points }));
```

Grade chips are coloured by points: 3.67+ mint, 2.67+ yellow, 1.67+ pink, below that plain. Change the cut-offs in `tierOf()`.

## Customising colours

All colours are CSS variables at the top of the `<style>` block:

| Token | Used for |
|---|---|
| `--bg`, `--surface`, `--surface-2` | page paper, cards, focused inputs |
| `--text`, `--muted` | text |
| `--ink`, `--shadow` | thick borders and hard offset shadows |
| `--yellow`, `--pink`, `--mint` | the three accent fills |
| `--series-1`, `--series-2` | chart lines: semester GPA and cumulative CGPA |
| `--focus` | keyboard focus ring |

Dark mode has its own copy of these tokens, in **two** places: under `@media (prefers-color-scheme: dark)` and under `:root[data-theme="dark"]`. Update both.
Text on yellow, pink and mint is always black (`.accent` scope), so keep those accents light enough for black text.
Border weight and shadow offset are `--bw` and `--sh`. Fonts are `--font-display`, `--font-body` and `--font-mono`, loaded from Google Fonts in `<head>`.
