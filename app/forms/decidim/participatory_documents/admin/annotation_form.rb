# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class AnnotationForm < Decidim::Form
        mimic :annotation

        attribute :id, Integer
        attribute :rect, Hash
        attribute :page_number, Integer
        attribute :section, Integer

        validate :rect_valid_hash

        private

        def rect_valid_hash
          return if rect[:left] && rect[:top]

          errors.add(:rect, :invalid)
        end
      end
    end
  end
end
