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
      validates_upload :file, uploader: Decidim::ParticipatoryDocuments::PdfDocumentUploader

      has_many :zones, class_name: "Decidim::ParticipatoryDocuments::Zone", dependent: :restrict_with_error
      has_many :annotations, through: :zones

      attr_accessor :remove_file

      def self.log_presenter_class_for(_log)
        Decidim::ParticipatoryDocuments::AdminLog::DocumentPresenter
      end
    end
  end
end
