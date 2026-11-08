#!/usr/bin/env ruby
# frozen_string_literal: true

# Writes _site/pagefind/site-words.json: every distinct word Pagefind indexed,
# folded the same way the search page folds a query. The search page checks
# each query word against this list before searching, because when a word
# matches nothing, Pagefind retries with a shortened form of it ("kubernetes"
# matches a lone "K") instead of returning nothing.
#
# The words come from Pagefind's own fragments, the text it actually indexed,
# rather than from the HTML, so the list cannot drift from the index.
#
# Usage: ruby scripts/build_search_words.rb site_dir include_characters
#   include_characters: the extra characters passed to Pagefind's
#   --include-characters (it always keeps "_" as well).

require 'json'
require 'set'
require 'zlib'

site, extra = ARGV
abort 'usage: build_search_words.rb site_dir include_characters' unless site && extra

pagefind = File.join(site, 'pagefind')
fragments = Dir.glob(File.join(pagefind, 'fragment', '*.pf_fragment'))
abort "build_search_words: no fragments in #{pagefind} — run Pagefind first" if fragments.empty?

keep = "_#{extra}"
# Pagefind indexes a word both whole, minus punctuation it does not keep
# ("long-running" -> "longrunning", "C++," -> "c++"), and as its parts
# ("long", "running"). The list includes both, so the check agrees with what a
# search can match.
strip = /[^\p{L}\p{N}#{Regexp.escape(keep)}]/
split = /[^\p{L}\p{N}]+/

# Lowercase and drop diacritics, matching Pagefind's default diacritic-
# insensitive search and the search page's own folding.
def fold(text)
  text.unicode_normalize(:nfd).gsub(/\p{M}/, '').downcase
end

words = Set.new
fragments.each do |path|
  raw = Zlib::GzipReader.open(path, &:read)
  # Pagefind prefixes its decompressed payloads with a signature.
  fragment = JSON.parse(raw.delete_prefix('pagefind_dcd'))
  text = [fragment['content'], fragment.dig('meta', 'title')].compact.join(' ')

  text.split(/\s+/).each do |token|
    folded = fold(token)
    whole = folded.gsub(strip, '')
    words << whole unless whole.empty?
    folded.split(split).each { |part| words << part unless part.empty? }
  end
end

# The page asks only whether some indexed word starts with the query word, so a
# word that is a prefix of another ("exist" of "existing") adds nothing. In
# sorted order, a word's extensions follow it directly, so comparing each word
# with its successor finds them all.
sorted = words.to_a.sort
maximal = sorted.each_with_index.reject { |word, i| sorted[i + 1]&.start_with?(word) }.map(&:first)

out = File.join(pagefind, 'site-words.json')
File.write(out, JSON.generate({ 'keep' => keep, 'words' => maximal }))
puts "build_search_words: #{maximal.size} words (of #{words.size} distinct) from #{fragments.size} pages -> #{out}"
