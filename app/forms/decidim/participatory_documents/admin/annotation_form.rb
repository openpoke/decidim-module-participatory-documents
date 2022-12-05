# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class AnnotationForm < Decidim::Form
        mimic :annotation
        include TranslatableAttributes

        attribute :rect
        attribute :page_number
        attribute :group_id

        translatable_attribute :title, String
        translatable_attribute :description, String

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
      end
    end
  end
end