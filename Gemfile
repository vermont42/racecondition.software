source 'https://rubygems.org'

gem 'jekyll', '~> 4.4'
gem 'jekyll-paginate'
gem 'jekyll-sitemap'

# Jekyll defaults kramdown's input to GFM, and _config.yml asks for kramdown,
# so this parser is load-bearing for every post. Jekyll 4 does depend on it,
# but it is declared here anyway: the build broke once already when it was
# left to arrive as somebody else's transitive dependency.
gem 'kramdown-parser-gfm'

# Ruby 3 removed webrick from the standard library, and `jekyll serve` needs
# it. Not used by `jekyll build`, so CI would survive without it.
gem 'webrick'
