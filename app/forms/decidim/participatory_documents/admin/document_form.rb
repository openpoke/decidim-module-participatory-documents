# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class DocumentForm < Decidim::Form
        include Decidim::HasUploadValidations
        include Decidim::TranslatableAttributes

        mimic :document

        translatable_attribute :title, String
        translatable_attribute :description, String

        attribute :box_color, String, default: "#1e98d7"
        attribute :box_opacity, Integer, default: 12

        attribute :file
        attribute :remove_file, Boolean, default: false

        def box_color
          @box_color ||= attributes[:box_color] || "#1e98d7"
        end
      end
    end
  end
end
