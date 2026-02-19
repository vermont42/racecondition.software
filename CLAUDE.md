# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Jekyll-based static blog for racecondition.software, Josh Adams's blog and website. The focus of the blog is primarily iOS development in Swift, but there are posts on other subjects of professional interest. The site is deployed to AWS S3 for static hosting.

## Common Commands

```bash
# Install dependencies
bundle install
yarn install

# Local development server (localhost:4000)
bundle exec jekyll serve

# Development with drafts and future posts
bundle exec jekyll serve --future --drafts --watch

# Build static site (outputs to _site/)
bundle exec jekyll build

# Run prose linting (CI/CD check)
bundle exec danger

# Create a new blog post interactively
scripts/new_post.sh
```

## Architecture

**Template Hierarchy:**
- `_layouts/default.html` - Base HTML structure with head, header, footer
- `_layouts/post.html` - Blog post layout (extends default)
- `_layouts/standalone.html` - Single pages like about, contact

**Key Directories:**
- `_posts/` - Published blog posts (YYYY-MM-DD-title.md naming convention)
- `_includes/` - Reusable template components (head.html, header.html, footer.html, image.html)
- `_data/talks.yml` - Speaking engagement data
- `css/` - Custom stylesheets (style.css, syntax.css)
- `img/` - Blog post images organized by post
- `node_modules/` - Frontend assets (Bootstrap 4.3.1, jQuery 3.5.0, Font Awesome 4.7.0)

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

Travis CI runs on each push:
1. `bundle exec jekyll build` - Verifies site builds
2. `bundle exec danger` - Prose linting with spell checking

The Dangerfile configures prose checks with ignored words for Apple platform terms (Swift, iOS, macOS, etc.).

## Development Workflow

When making changes to the site, start `bundle exec jekyll serve --livereload` in the background if it is not already running. Use the Claude in Chrome extension to view the site at localhost:4000 and verify that changes render correctly. Take screenshots to check layout, styling, and content before considering work complete.

## Writing Style

When generating prose for this blog (post content, descriptions, etc.), follow the writing style documented in `writing_style.md`. Key characteristics include: academic yet personal tone, thesis-driven organization with balanced argumentation, extensive footnotes and hyperlinking, cross-domain synthesis, and precise language with deliberate word choices.
