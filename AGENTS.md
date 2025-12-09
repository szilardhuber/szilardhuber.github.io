AGENTS (for automated agents working on this repo)

Build / Lint / Test commands
- Build site locally: `bundle exec jekyll build` or `bundle exec jekyll serve` for live preview
- Install Ruby dependencies: `bundle install` (requires `github-pages` gem)
- Install JS deps: `npm install` (Grunt-based build system)
- Build assets: `grunt` (compiles LESS, minifies JS, optimizes images)
- Lint JS: `grunt jshint` (lints all JS in assets/js/ except plugins)
- Watch for changes: `grunt dev` (auto-rebuilds on file changes)
- Clean built assets: `grunt clean`
- Note: No test suite exists for this Jekyll blog

Code style & conventions
- Language: Jekyll/Liquid templates, HTML, LESS for styles, jQuery for JS
- Formatting: 2-space indentation; keep lines under 100 chars where practical
- Includes: use `{% include file.html %}` in templates; keep filenames kebab-case with leading underscore (e.g., `_head.html`)
- JS: jQuery-based; use `$()` for DOM ready; semicolons required; keep plugins in `assets/js/plugins/`
- CSS: write LESS in `assets/less/`; main entry point is `main.less`; use existing mixins from `mixins.less`
- Naming: kebab-case for files/CSS classes, camelCase for JS variables/functions
- Posts: markdown in `_posts/` with format `YYYY-MM-DD-title.md`; include YAML frontmatter
- Error handling: jQuery callbacks should fail gracefully; validate DOM elements exist before manipulation

Agent behavior notes
- Always read `AGENTS.md` before modifying files
- Run `grunt` after editing LESS or JS to rebuild minified assets
- Test locally with `bundle exec jekyll serve` before committing
- No Cursor or Copilot rules found in repository

