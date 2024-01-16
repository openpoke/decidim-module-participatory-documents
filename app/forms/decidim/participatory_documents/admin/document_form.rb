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
        attribute :organization

        attribute :file
        attribute :remove_file, Boolean, default: false

        # validates :file, presence: true, unless: :persisted?
        validates :file, passthru: { to: Document }, if: ->(form) { form.file.present? }
        validates :file, file_content_type: { allow: ["application/pdf"] }, if: ->(form) { form.file.present? }

        # ensure color and opacity are present
        def map_model(doc)
          self.box_color = doc.box_color.presence || "#1e98d7"
          self.box_opacity = doc.box_opacity.presence || 12
        end

        def organization
          attributes[:organization] || current_organization
        end
      end
    end
  end
end
