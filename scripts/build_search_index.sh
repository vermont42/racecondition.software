#!/usr/bin/env bash
#
# Builds the Pagefind search index into _site/pagefind/, plus site-words.json,
# the list of indexed words that the search page checks queries against. Run
# after 'bundle exec jekyll build' and before scripts/verify_site.sh, which
# checks that both exist, are newer than the pages, and cover every page
# marked data-pagefind-body.
#
# Pagefind is pinned here and nowhere else, so CI and local builds index with
# the same version. npx caches the package after the first run.
#
# Usage: scripts/build_search_index.sh [site_dir]   (default: _site)

set -euo pipefail

PAGEFIND_VERSION=1.5.2
# Pagefind strips punctuation from words by default, so "C++" and "C#" are
# indexed, and searched, as "c". Keeping these two makes them searchable as
# themselves; Pagefind still indexes the bare part too ("Pedometer++" is found
# by "pedometer"). build_search_words.rb must fold words the same way.
INCLUDE_CHARACTERS='#+'
SITE="${1:-_site}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ ! -d "$SITE" ]]; then
    echo "build_search_index: $SITE does not exist — run 'bundle exec jekyll build' first" >&2
    exit 1
fi

# Pagefind adds to an existing output directory rather than replacing it, and
# its chunk names are content hashes, so a rebuild into the directory that
# 'jekyll serve' keeps (keep_files in _config.yml) would accumulate stale ones.
rm -rf "${SITE:?}/pagefind"

npx --yes "pagefind@${PAGEFIND_VERSION}" --site "$SITE" --include-characters "$INCLUDE_CHARACTERS"

ruby "$REPO_ROOT/scripts/build_search_words.rb" "$SITE" "$INCLUDE_CHARACTERS"
