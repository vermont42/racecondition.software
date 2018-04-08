# [racecondition.software](https://racecondition.software)

*A Blog About Software Development*

![Logo](img/logo.png)

## About

This my website about software development. Eventually, this website will be a companion to a podcast also called Race Condition.

Lovingly built with [Jekyll](https://jekyllrb.com), [Bootstrap](https://getbootstrap.com), [jQuery](https://jquery.com), and [Font Awesome](https://fortawesome.github.io/Font-Awesome/). Gratefully copied from [Jesse Squires](https://github.com/jessesquires/jessesquires.com).

## Requirements

- [Bundler](https://bundler.io)
- [Yarn](https://yarnpkg.com/en/)

## Dependencies

### Gems

- [jekyll](https://jekyllrb.com) ([Latest](https://github.com/jekyll/jekyll/releases/latest))
- [jekyll-paginate](https://github.com/jekyll/jekyll-paginate)
- [jekyll-sitemap](https://github.com/jekyll/jekyll-sitemap)

#### Updating Gems

```bash
$ bundle update
```

### Yarn dependencies

- [Bootstrap](https://getbootstrap.com) ([pkg](https://yarnpkg.com/en/package/bootstrap))
- [jQuery](https://jquery.com) ([pkg](https://yarnpkg.com/en/package/jquery))
- [Font Awesome](https://fortawesome.github.io/Font-Awesome/) ([pkg](https://yarnpkg.com/en/package/font-awesome))
- [html5shiv](https://github.com/aFarkas/html5shiv) ([pkg](https://yarnpkg.com/en/package/html5shiv))
- [respond.js](https://github.com/scottjehl/Respond) ([pkg](https://yarnpkg.com/en/package/respond.js))

#### Updating Yarn dependencies

```bash
$ yarn update
```

### Other

- [Ubuntu Mono font](https://www.google.com/fonts/specimen/Ubuntu+Mono)

## Usage

#### Installation

```bash
$ git clone https://github.com/vermont42/racecondition.software.git
$ cd racecondition.software/
$ bundle install
$ yarn install
```

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

_Not tested._

## Verifying DNS setup

```bash
$ dig www.racecondition.software +nostats +nocomments +nocmd
```

_Not tested._

## License

> **Copyright &copy; 2018-present Josh Adams.**

<a rel="license" href="https://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="https://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.

All code is licensed under an [MIT License](https://opensource.org/licenses/MIT).

The *Ubuntu Mono* font is licensed under the [Ubuntu Font License](http://font.ubuntu.com/ufl/).
