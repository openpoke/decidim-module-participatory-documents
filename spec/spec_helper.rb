# frozen_string_literal: true

require "decidim/dev"

ENV["ENGINE_ROOT"] = File.dirname(__dir__)

Decidim::Dev.dummy_app_path = File.expand_path(File.join(__dir__, "decidim_dummy_app"))

class AntivirusValidator < ActiveModel::EachValidator
  def self.fake_virus
    @fake_virus ||= false
  end

  class << self
    attr_writer :fake_virus
  end

  def validate_each(record, attribute, _value)
    record.errors.add(attribute, :virus) if AntivirusValidator.fake_virus
  end
end

require "decidim/dev/test/base_spec_helper"
