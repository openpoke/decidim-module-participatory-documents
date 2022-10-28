# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class Document < ApplicationRecord
      self.table_name = :decidim_participatory_documents_documents

      include Decidim::HasComponent
      include Decidim::Authorable
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::TranslatableResource
      include Decidim::HasUploadValidations

      translatable_fields :title, :description

      has_one_attached :file
      validates_upload :file, uploader: Decidim::ParticipatoryDocuments::DocumentUploader

      attr_accessor :remove_file
    end
  end
end
