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

        validates :file, presence: true, file_content_type: { allow: ["application/pdf"] }, unless: :remove_file

        # ensure color and opacity are present
        def map_model(doc)
          self.box_color = doc.box_color.presence || "#1e98d7"
          self.box_opacity = doc.box_opacity.presence || 12
        end
      end
    end
  end
end
