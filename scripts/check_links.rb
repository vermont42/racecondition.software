#!/usr/bin/env ruby
# frozen_string_literal: true

# Checks that every internal href/src in the built site resolves to a real
# file. External links are not fetched — this is a build check, not a link-rot
# crawler, so it stays fast and never fails because someone else's server is
# down.
#
# Usage: ruby scripts/check_links.rb [site_dir]   (default: _site)

require 'set'

SITE = ARGV[0] || '_site'

abort "check_links: #{SITE} does not exist — build the site first" unless Dir.exist?(SITE)

# Attributes worth checking. srcset is deliberately included: a typo there is
# invisible until a particular viewport asks for that candidate.
ATTR_PATTERN = /(?:href|src)\s*=\s*"([^"]*)"/i
SRCSET_PATTERN = /srcset\s*=\s*"([^"]*)"/i

SKIP_PREFIXES = %w[http:// https:// // mailto: tel: data: javascript: #].freeze

missing = []
checked = 0

# A link resolves if any of these exist: the literal path, the path with
# index.html appended (Jekyll's pretty permalinks), or the path with .html
# appended (extensionless links that S3 would 302 to a directory).
def resolves?(path)
  return true if File.file?(path)
  return true if File.file?(File.join(path, 'index.html'))
  return true if File.file?("#{path}.html")

  false
end

Dir.glob(File.join(SITE, '**', '*.html')).sort.each do |file|
  html = File.read(file, encoding: 'UTF-8', invalid: :replace, undef: :replace)
  dir = File.dirname(file)

  targets = html.scan(ATTR_PATTERN).flatten
  targets += html.scan(SRCSET_PATTERN).flatten.flat_map do |srcset|
    srcset.split(',').map { |candidate| candidate.strip.split(/\s+/).first }
  end

  targets.compact.uniq.each do |raw|
    link = raw.strip
    next if link.empty?
    next if SKIP_PREFIXES.any? { |prefix| link.downcase.start_with?(prefix) }

    # Drop the query and fragment; neither affects which file is served.
    path = link.split('#').first.to_s.split('?').first.to_s
    next if path.empty?

    resolved = path.start_with?('/') ? File.join(SITE, path) : File.join(dir, path)

    checked += 1
    next if resolves?(resolved)

    missing << [file.sub("#{SITE}/", ''), link]
  end
end

if missing.empty?
  puts "check_links: OK — #{checked} internal references resolve"
  exit 0
end

warn "check_links: #{missing.length} broken internal reference(s)"
missing.each { |source, link| warn "  #{source} -> #{link}" }
exit 1
