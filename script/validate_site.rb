# frozen_string_literal: true

require "pathname"
require "uri"

SITE_ROOT = Pathname.new(File.expand_path("../_site", __dir__))
CANONICAL_ORIGIN = "https://carlofinocchiaro.github.io"

errors = []
html_files = SITE_ROOT.glob("**/*.html")
errors << "No generated HTML files found" if html_files.empty?

html_files.each do |file|
  html = file.read
  relative_path = file.relative_path_from(SITE_ROOT)

  %w[head body main].each do |element|
    errors << "#{relative_path}: missing <#{element}>" unless html.include?("<#{element}")
  end

  canonical = html[/<link rel="canonical" href="([^"]+)"/, 1]
  unless canonical&.start_with?(CANONICAL_ORIGIN)
    errors << "#{relative_path}: invalid canonical URL"
  end

  html.scan(/<img\b[^>]*>/i).each do |image|
    errors << "#{relative_path}: image missing alt" unless image.match?(/\balt="[^"]*"/i)
  end

  html.scan(/<a\b[^>]*target="_blank"[^>]*>/i).each do |link|
    errors << "#{relative_path}: target=_blank link missing noopener" unless link.match?(/\brel="[^"]*noopener[^"]*"/i)
  end

  html.scan(/\b(?:href|src)="([^"]+)"/i).flatten.each do |reference|
    next if reference.empty? || reference.start_with?("#")
    next if reference.match?(%r{\A(?:https?:|mailto:|tel:|data:|//)})

    path = URI.decode_www_form_component(reference.split(/[?#]/, 2).first)
    target = path.start_with?("/") ? SITE_ROOT.join(path.delete_prefix("/")) : file.dirname.join(path)
    target = target.join("index.html") if path.end_with?("/")
    errors << "#{relative_path}: missing internal resource #{reference}" unless target.file?
  end
end

bootstrap_pages = html_files.select { |file| file.read.include?("bootstrap@5.3.3") }
expected_bootstrap_page = SITE_ROOT.join("photography/index.html")
unless bootstrap_pages == [expected_bootstrap_page]
  errors << "Bootstrap must be loaded only by photography/index.html"
end

if errors.any?
  warn errors.join("\n")
  exit 1
end

puts "Validated #{html_files.length} HTML files"