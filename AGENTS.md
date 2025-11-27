AGENTS (for automated agents working on this repo)

Build / Lint / Test commands
- Build site locally: `bundle exec jekyll build` or `bundle exec jekyll serve` for live preview
- Install Ruby dependencies: `bundle install` (uses `Gemfile`)
- Install JS deps & build assets: `npm install` then `npm run build` (or `grunt` if configured)
- Run a single test (JS): `npm test -- <path/to/testfile>` or `npx mocha <path/to/testfile>`
- Run all JS tests: `npm test`

Code style & conventions
- Language: primarily Ruby (Jekyll templates) + HTML/CSS/JS for assets. Prefer modern, readable constructs.
- Formatting: keep lines < 100 chars when possible; use consistent 2-space indentation in templates and JS.
- Imports / includes: in Ruby templates use Jekyll includes (`{% include file %}`) and keep include names kebab-case.
- JS: use `const`/`let` over `var`; prefer arrow functions for short callbacks; keep functions small and single-purpose.
- Types: JavaScript is untyped here—be explicit with runtime checks for DOM elements and external inputs.
- Naming: use descriptive, camelCase for JS variables and functions; kebab-case for filenames and CSS classes.
- Error handling: fail fast for build/test steps; catch/log errors in JS with informative messages and avoid silent failures.
- Tests: keep unit tests isolated; mock DOM where needed; prefer `describe`/`it` structure for Mocha.

Agent behavior notes
- Always read `AGENTS.md` before modifying files.
- Do not change project root structure without approval.
- If making edits, run the build and relevant tests locally before proposing changes.
- No Cursor or Copilot rules were found in repository.

