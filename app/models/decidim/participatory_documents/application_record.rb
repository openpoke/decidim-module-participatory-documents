# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    # Main ActiveRecord application configuration.
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
