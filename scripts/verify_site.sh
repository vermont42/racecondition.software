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

echo "==> search index is present, current, and complete"
# Pagefind indexes only pages carrying data-pagefind-body (posts and standalone
# pages, minus those with search: false). Three checks, each catching a
# different way to ship a wrong index:
#   - missing: the build skipped scripts/build_search_index.sh;
#   - older than any indexed page: the pages were rebuilt after indexing (the
#     usual cause is 'jekyll serve', which keeps _site/pagefind/ across
#     rebuilds), so edits since then are not searchable;
#   - a different page count: pages were added or removed since indexing.
# Matching mtimes and counts do not prove the index matches each page word
# for word; in CI, build order guarantees that, and these checks catch the
# ways local builds break it.
if [[ ! -f "$SITE/pagefind/pagefind.js" || ! -f "$SITE/pagefind/site-words.json" ]]; then
    echo "verify_site: $SITE/pagefind/ is missing or incomplete — run scripts/build_search_index.sh" >&2
    exit 1
fi
ruby -rjson -e '
    site = ARGV[0]
    entry = File.join(site, "pagefind", "pagefind-entry.json")
    words = File.join(site, "pagefind", "site-words.json")
    indexed = JSON.parse(File.read(entry))["languages"].values.sum { |l| l["page_count"] }

    # Match the attribute inside a real tag, not the string in prose or in a
    # code sample, where the angle brackets arrive escaped.
    tag = /<[a-zA-Z][^<>]*\sdata-pagefind-body(?=[\s=\/>])/
    marked = Dir.glob(File.join(site, "**", "*.html")).select { |f| File.read(f, encoding: "UTF-8").match?(tag) }

    abort "verify_site: no pages are marked data-pagefind-body" if marked.empty?
    newest = marked.max_by { |f| File.mtime(f) }
    [entry, words].each do |artifact|
        next if File.mtime(artifact) >= File.mtime(newest)
        abort "verify_site: #{artifact} is older than #{newest} — rerun scripts/build_search_index.sh"
    end
    abort "verify_site: Pagefind indexed #{indexed} pages but #{marked.size} are marked data-pagefind-body" unless indexed == marked.size
    abort "verify_site: site-words.json lists no words" if JSON.parse(File.read(words))["words"].empty?
    puts "    #{indexed} pages indexed"
' "$SITE"

echo "==> internal links resolve"
ruby "$REPO_ROOT/scripts/check_links.rb" "$SITE"

echo "verify_site: all checks passed"
