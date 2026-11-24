# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "decidim/participatory_documents/version"

Gem::Specification.new do |spec|
  spec.name = "decidim-participatory_documents"
  spec.version = Decidim::ParticipatoryDocuments::VERSION
  spec.authors = ["Ivan Vergés"]
  spec.email = ["ivan@pokecode.net"]

  spec.summary = "A module for Decidim to collect suggestions on areas defined on top of a PDF document."
  spec.description = "This module allows to upload a PDF and define areas on top of it that will become spaces for suggestions, improvements and other participative activities."
  spec.license = "AGPL-3.0"
  spec.homepage = "https://github.com/openpoke/decidim-module-participatory-documents"
  spec.required_ruby_version = ">= 3.4"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "decidim-admin", Decidim::ParticipatoryDocuments::COMPAT_DECIDIM_VERSION
  spec.add_dependency "decidim-core", Decidim::ParticipatoryDocuments::COMPAT_DECIDIM_VERSION
  spec.metadata["rubygems_mfa_required"] = "true"
end
