# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class SectionForm < Decidim::Form
        include TranslatableAttributes

        mimic :section

        translatable_attribute :title, String

        validates :title, translatable_presence: true
      end
    end
  end
end
