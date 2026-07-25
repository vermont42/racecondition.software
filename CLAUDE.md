# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Jekyll-based static blog for racecondition.software, Josh Adams's blog and website. The focus of the blog is primarily iOS development in Swift, but there are posts on other subjects of professional interest. The site is deployed to AWS S3 with CloudFront CDN.

## Common Commands

```bash
# Install dependencies
bundle install

# Local development server (localhost:4000)
bundle exec jekyll serve

# Development with drafts and future posts
bundle exec jekyll serve --future --drafts --watch

# Build static site (outputs to _site/)
bundle exec jekyll build

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

**Template Hierarchy:**
- `_layouts/default.html` - Base HTML structure with head, header, footer
- `_layouts/post.html` - Blog post layout (extends default)
- `_layouts/standalone.html` - Single pages like about, contact

**Key Directories:**
- `_posts/` - Published blog posts (YYYY-MM-DD-title.md naming convention)
- `_includes/` - Reusable template components (head.html, header.html, footer.html, foot.html, image.html)
- `_data/talks.yml` - Speaking engagement data
- `css/` - Custom stylesheets (style.css, syntax.css)
- `img/` - Blog post images organized by post
- `ico/` - Logo, avatar, and favicons
- `scripts/` - Development scripts (new_post.sh, verify_site.sh, check_links.rb)
- `infra/cloudfront/` - Source of record for the CloudFront Function that serves the site's redirects

The site has no front-end dependencies: no Bootstrap, no jQuery, no Font Awesome, no build step beyond Jekyll. All CSS is hand-written in `css/style.css`, and all JavaScript is inline in `_includes/foot.html`.

## Blog Post Format

```yaml
---
layout: post
title: "Post Title"
subtitle: "Optional subtitle"
image:
    file: "path/to/image.jpg"
    alt: "Alt text"
    caption: "Optional caption"
    source_link: "Optional link"
    half_width: false
date-updated: "Optional update date"
---

> Initial excerpt text (appears in listings)

<!--excerpt-->

Main post content here.
```

Use `{% include image.html %}` for responsive images within posts.

## CI/CD

### Deployment

A GitHub Actions workflow (`.github/workflows/deploy.yml`) automatically deploys the site on every push to `master`:
1. Builds the Jekyll site
2. Runs `scripts/verify_site.sh` — a failure here stops the deploy before anything is uploaded
3. Syncs `_site/` to the S3 bucket in three passes, each setting a `Cache-Control` lifetime appropriate to what it uploads
4. Invalidates the CloudFront cache

### Verification

`.github/workflows/verify.yml` runs on every push and pull request. It builds the site and runs `scripts/verify_site.sh`, which validates `feed.xml` and `sitemap.xml` as XML, parses `feed.json`, and confirms via `scripts/check_links.rb` that every internal `href`/`src` in `_site/` resolves to a real file.

There is no automated prose or spell check. Travis CI ran `bundle exec danger` until travis-ci.org shut down around 2021; the config, the Dangerfile, and the Danger gems were removed in 2026 rather than revived, since Danger is pull-request-oriented and this repo is pushed to directly.

## Development Workflow

When making changes to the site, start `bundle exec jekyll serve --livereload` in the background if it is not already running. Use the Claude in Chrome extension to view the site at localhost:4000 and verify that changes render correctly. Take screenshots to check layout, styling, and content before considering work complete.

UI changes must be verified for both desktop and mobile viewports. To test mobile sizes when the browser window can't be resized small enough, render the page in iframes at target widths (e.g., 375px for iPhone SE, 768px for iPad) using the Claude in Chrome extension's JavaScript tool.

## Writing Style

When generating prose for this blog (post content, descriptions, etc.), follow the writing style documented in `writing_style.md`. Key characteristics include: academic yet personal tone, thesis-driven organization with balanced argumentation, extensive footnotes and hyperlinking, cross-domain synthesis, and precise language with deliberate word choices.
