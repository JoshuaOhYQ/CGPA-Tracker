# CGPA Tracker

A neo-brutalist CGPA tracker in a single file (`index.html`): HTML, CSS and vanilla JS, no build step.

**Live site: [4cgpatracker.netlify.app](https://4cgpatracker.netlify.app/)**

You can also open `index.html` directly in a browser, or deploy the folder to any static host (Netlify config included).

## Your data and accounts

Anyone can use the site, and an account is optional. Either way, nobody else can see or change your grades.

### Without an account

- Everything you enter (semesters, subjects, grades, target CGPA) is saved in your browser's `localStorage` on your device. Nothing is sent to a server, and Netlify only serves the page.
- Your data stays on that one browser and device. To move it, click **Export** on one device and **Import** on the other.
- Clearing your browser's site data, or using a private or incognito window, removes it. Export a JSON backup now and then.

### With an account (once accounts are set up, see below)

- Click **Sign in** and use an email and password. Your data is saved to your account and appears on any device you sign in on.
- Changes save automatically a moment after you make them. The dot on the account button shows the status: mint means synced, yellow means saving, pink means offline or an error. Changes made offline sync when you reconnect.
- If this browser already has data when you sign in and your account has different data, the app asks which one to keep. It also offers to download this browser's copy first.
- Signing out removes your data from that browser, which matters on shared computers. It stays in your account.
- Your dark/light mode choice stays separate on each device.
- If two devices edit at the same time, the last one to save wins. Coming back to a tab pulls in any changes made on your other devices.

### Who can access what

- Each account can only read and write its own row in the database. Supabase's Row Level Security enforces this on the server, not just in the page.
- Only the site's code is public, and only the owner of the Netlify site or GitHub repo can change it. Don't commit your exported JSON backup to a public repo, because that would make your grades public.

## Setting up accounts (Supabase)

Until you do this, the site runs in browser-only mode and the **Sign in** button stays hidden.

1. Create a free project at [supabase.com](https://supabase.com).
2. In the project, open **SQL Editor**, paste the contents of [`supabase/setup.sql`](supabase/setup.sql), and click **Run**. This creates the `tracker_data` table and the rules that limit each user to their own row.
3. Go to **Authentication → URL Configuration**. Set **Site URL** to `https://4cgpatracker.netlify.app` and add `https://4cgpatracker.netlify.app/**` under **Redirect URLs**.
4. Decide how sign-up emails work. Supabase's built-in email sender only delivers to members of your Supabase team, and only 2 emails an hour, so your friends won't get confirmation emails. Pick one:
   - **Simplest:** turn off **Confirm email** in **Authentication → Sign In / Providers → Email**. New users are signed in as soon as they create an account. The "Email me a sign-in link" option still only works for your team.
   - **Proper:** connect your own email sender under **Authentication → Emails → SMTP Settings**. Resend and Brevo both have free tiers. Confirmation emails and sign-in links then work for everyone.
5. Go to **Project Settings → API Keys** and copy the **Project URL** and the **publishable** (or legacy **anon**) key.
6. Paste both into `index.html` near the top of the `<script>`:

   ```js
   const SUPABASE_URL = 'https://YOUR-PROJECT.supabase.co';
   const SUPABASE_KEY = 'sb_publishable_...';   // or the legacy anon key
   ```

   These two values are meant to be public. Never paste the **service_role** or **secret** key into the page.
7. Redeploy to Netlify by dragging the folder onto your site's **Deploys** page, or by pushing to GitHub if the site is linked to a repo.

The sign-in library is [supabase-js](https://github.com/supabase/supabase-js) 2.57.4, loaded from jsDelivr only when the two values are filled in.

## Features

- Big CGPA hero, latest semester GPA, credit hours earned, and a 0–4 progress ruler with your target marked.
- Semesters as timeline "chapters", each marked completed or upcoming. Add a subject with name, credits and grade, then press Enter. Blank credits default to 3, and the grade can stay "No grade yet".
- Inline editing everywhere. Deleting a subject or semester can be undone (Undo button or Ctrl+Z).
- The plan: set a target CGPA and see the GPA you need next semester. Credits come from your next upcoming semester, or from an estimate you type in.
- What-if mode: pick target grades on pending subjects and see your projected CGPA right away. You can also set every pending subject to one grade in a single step.
- Charts (Chart.js 4.4.1 from cdnjs): GPA vs CGPA trend, grade spread, credit load. Each chart also has a table view.
- Data is saved in `localStorage`, with optional accounts and cloud sync through Supabase. You can export or import a JSON backup.
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
