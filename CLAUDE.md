# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Jekyll-based static blog for racecondition.software, Josh Adams's blog and website. The focus of the blog is primarily iOS development in Swift, but there are posts on other subjects of professional interest. The site is deployed to AWS S3 with CloudFront CDN.

## Common Commands

```bash
# Development with drafts and future posts
bundle exec jekyll serve --future --drafts --watch

# Check the built site (feeds, sitemap, internal links) — same checks as CI
scripts/verify_site.sh

# Create a new blog post interactively
scripts/new_post.sh

# Enable the repo's git hooks (one time per clone)
git config core.hooksPath .githooks
```

The `core.hooksPath` setting is local to each clone and is not tracked by git, so a
fresh clone will not run `.githooks/pre-commit` — which rejects HEIC/HEIF images,
by extension or by `ftyp` brand — until that command is run.

## Architecture

The site has no front-end dependencies: no Bootstrap, no jQuery, no Font Awesome, no build step beyond Jekyll. All CSS is hand-written in `css/style.css`, and all JavaScript is inline in `_includes/foot.html`.

`infra/cloudfront/` is the source of record for the CloudFront Function that serves the site's redirects.

## CI/CD

Every push to `master` deploys to production (`.github/workflows/deploy.yml`); a `scripts/verify_site.sh` failure stops the deploy before anything is uploaded. `.github/workflows/verify.yml` runs the same checks on every push and pull request.

There is no automated prose or spell check. Travis CI ran `bundle exec danger` until travis-ci.org shut down around 2021; the config, the Dangerfile, and the Danger gems were removed in 2026 rather than revived, since Danger is pull-request-oriented and this repo is pushed to directly.

## Development Workflow

When making changes to the site, start `bundle exec jekyll serve --livereload` in the background if it is not already running. Use the Claude in Chrome extension to view the site at localhost:4000 and verify that changes render correctly. Take screenshots to check layout, styling, and content before considering work complete.

UI changes must be verified for both desktop and mobile viewports. To test mobile sizes when the browser window can't be resized small enough, render the page in iframes at target widths (e.g., 375px for iPhone SE, 768px for iPad) using the Claude in Chrome extension's JavaScript tool.

## Writing Style

When generating prose for this blog (post content, descriptions, etc.), follow the writing style documented in `writing_style.md`. Key characteristics include: academic yet personal tone, thesis-driven organization with balanced argumentation, extensive footnotes and hyperlinking, cross-domain synthesis, and precise language with deliberate word choices.
