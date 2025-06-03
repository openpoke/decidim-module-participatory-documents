# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "decidim/participatory_documents/version"

Gem::Specification.new do |spec|
  spec.name = "decidim-participatory_documents"
  spec.version = Decidim::ParticipatoryDocuments::VERSION
  spec.authors = ["Ivan Vergés"]
  spec.email = ["ivan@pokecode.net"]

  spec.summary = "A module for Decidim that facilitates the creation of proposals related to geolocated issues in a city."
  spec.description = "A module for Decidim that facilitates the creation of proposals related to geolocated issues in a city"
  spec.license = "AGPL-3.0"
  spec.homepage = "https://github.com/openpoke/decidim-module-participatory_documents"
  spec.required_ruby_version = ">= 3.2"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "decidim-admin", Decidim::ParticipatoryDocuments::COMPAT_DECIDIM_VERSION
  spec.add_dependency "decidim-core", Decidim::ParticipatoryDocuments::COMPAT_DECIDIM_VERSION
  # rubocop:disable Gemspec/DevelopmentDependencies
  spec.add_development_dependency "decidim-dev", Decidim::ParticipatoryDocuments::COMPAT_DECIDIM_VERSION
  # rubocop:enable Gemspec/DevelopmentDependencies
  spec.metadata["rubygems_mfa_required"] = "true"
end
