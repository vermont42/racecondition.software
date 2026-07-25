#!/usr/bin/env bash
#
# Post-build checks on _site. Run by .github/workflows/verify.yml on every
# push and pull request, and by the deploy workflow between the build and the
# S3 sync, so a build that fails these never reaches production.
#
# Usage: scripts/verify_site.sh [site_dir]   (default: _site)

set -euo pipefail

SITE="${1:-_site}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ ! -d "$SITE" ]]; then
    echo "verify_site: $SITE does not exist — run 'bundle exec jekyll build' first" >&2
    exit 1
fi

# xmllint is the canonical check, but it comes from libxml2-utils, which not
# every environment has. Ruby's REXML is equally strict about well-formedness
# and is always present, so fall back to it rather than skipping the check.
check_xml() {
    if command -v xmllint >/dev/null 2>&1; then
        xmllint --noout "$1"
    else
        ruby -rrexml/document -e 'REXML::Document.new(File.read(ARGV[0]))' "$1"
    fi
}

echo "==> Atom feed is well-formed XML"
# The production feed was invalid for four years because a subtitle contained a
# raw ampersand. This is the check that would have caught it.
check_xml "$SITE/feed.xml"

echo "==> JSON feed parses"
ruby -rjson -e 'JSON.parse(File.read(ARGV[0]))' "$SITE/feed.json"

echo "==> sitemap is well-formed XML"
check_xml "$SITE/sitemap.xml"

echo "==> internal links resolve"
ruby "$REPO_ROOT/scripts/check_links.rb" "$SITE"

echo "verify_site: all checks passed"
