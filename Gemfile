# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

# Inside the development app, the relative require has to be one level up, as
# the Gemfile is copied to the development_app folder (almost) as is.
base_path = ""
base_path = "../" if File.basename(__dir__) == "development_app"
require_relative "#{base_path}lib/decidim/participatory_documents/version"

DECIDIM_VERSION = Decidim::ParticipatoryDocuments::DECIDIM_VERSION

gem "decidim", DECIDIM_VERSION
gem "decidim-participatory_documents", path: "."

gem "bootsnap", "~> 1.4"
gem "puma", ">= 6.3.1"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri
  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "faker", "~> 3.3.1"
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "rubocop-faker"
  gem "web-console", "~> 4.2"
end

group :test do
  gem "codecov", require: false
end
