# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class DocumentForm < Decidim::Form
        include Decidim::HasUploadValidations
        include Decidim::TranslatableAttributes
        translatable_attribute :title, String
        translatable_attribute :description, String

        mimic :document

        attribute :file
        attribute :remove_file, Boolean, default: false

        validates :title, :description, translatable_presence: true
      end
    end
  end
end
