# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class ZoneForm < Decidim::Form
        include TranslatableAttributes

        attribute :uid

        translatable_attribute :title, String
        translatable_attribute :description, String

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
      end
    end
  end
end
