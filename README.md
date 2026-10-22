# Avery Steinberg Menu

Based on bradymenu. Static site with an embedded progress timeline covering 43 Mondays, October 19, 2026 through August 9, 2027.

Torah Reading is intentionally blank. Portion in English, Haftorah Reading, and Zoom are omitted. The Service retains the original marked passages and teacher example playback. Practice recordings always save as `Avery Steinberg` in `averymenu_service_recordings_v1`; teacher examples are read from the original example table and are never overwritten.

Homework, timeline cells, and private notes use dedicated Avery tables. No Brady homework, progress, notes, or practice recordings were copied. Reading-specific timeline rows are omitted until Avery's readings are assigned; service blessing rows remain.

The timeline retains the existing teacher editor login and permissions, with a separate browser session storage key. No new passcode was created.

## Build

The root and `timeline/` are ready for GitHub Pages. Timeline source is in `timeline-src/`:

```powershell
cd timeline-src
npm ci --no-audit --no-fund
npm run build
```

Commit the resulting `timeline/` files alongside source changes. The initial database setup is recorded in `supabase/setup.sql` and has already been applied to the connected project.

Validation: TypeScript and Vite production build; browser checks for menu navigation, date endpoints and column count, marked service controls, microphone capture with an intercepted Avery-only save payload, and empty homework; public REST checks for dedicated Avery tables.
