# frozen_string_literal: true

if ENV["SIMPLECOV"]
  SimpleCov.start do
    # We ignore some of the files because they are never tested
    add_filter "/config/"
    add_filter "/db/"
    add_filter "lib/decidim/participatory_documents/version.rb"
    add_filter "lib/decidim/participatory_documents/component.rb"
    add_filter "lib/decidim/participatory_documents/test"
    add_filter "/spec"
  end

  SimpleCov.merge_timeout 1800

  if ENV["CI"]
    require "simplecov-cobertura"
    SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
  end
end
