# [racecondition.software](https://racecondition.software)

*A Blog About Software Development*

![Logo](ico/logo.png)

## About

This is my website about software development, primarily, but not exclusively, on iOS and using Swift.

Built with [Jekyll](https://jekyllrb.com) and hand-written CSS — no front-end framework and no JavaScript dependencies. Gratefully forked from [Jesse Squires](https://github.com/jessesquires/jessesquires.com), though little of the original design survived the 2026 redesign.

## Requirements

- [Bundler](https://bundler.io)

## Dependencies

### Gems

- [jekyll](https://jekyllrb.com) ([Latest](https://github.com/jekyll/jekyll/releases/latest))
- [jekyll-paginate](https://github.com/jekyll/jekyll-paginate)
- [jekyll-sitemap](https://github.com/jekyll/jekyll-sitemap)
- [kramdown-parser-gfm](https://github.com/kramdown/parser-gfm)

#### Updating gems

```bash
$ bundle update
```

## Usage

#### Installation

```bash
$ git clone https://github.com/vermont42/racecondition.software.git
$ cd racecondition.software/
$ bundle install
$ git config core.hooksPath .githooks
```

That last command enables the repo's pre-commit hook, which rejects HEIC/HEIF images. It is per-clone local configuration and is not tracked by git, so a fresh clone runs no hook until it is set.

#### Building the site

```bash
$ bundle exec jekyll build
```

#### Previewing the site locally

```bash
$ bundle exec jekyll serve
# Now browse to http://localhost:4000
```

#### Writing a draft

```bash
$ bundle exec jekyll serve --future --drafts --watch
```

#### Creating a post

```bash
$ scripts/new_post.sh
```

#### Checking the built site

```bash
$ scripts/verify_site.sh
```

Validates the Atom feed, the JSON feed, and the sitemap, and confirms that every internal link in `_site/` resolves. CI runs it on every push, and again before the deploy syncs to S3.

## Deployment

Pushes to `master` are built and deployed to S3 and CloudFront by [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml). The CloudFront Function handling the `www` → apex and `/blog/` → `/archive/` redirects is checked in at [`infra/cloudfront/redirects.js`](infra/cloudfront/redirects.js).

## License

> **Copyright &copy; 2018-present Josh Adams.**

<a rel="license" href="https://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="https://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.
