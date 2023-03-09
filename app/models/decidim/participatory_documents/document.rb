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

      has_many :sections, class_name: "Decidim::ParticipatoryDocuments::Section", dependent: :restrict_with_error
      has_many :suggestions, class_name: "Decidim::ParticipatoryDocuments::Suggestion", dependent: :restrict_with_error, as: :suggestable
      has_many :annotations, through: :sections

      attr_accessor :remove_file

      def box_color
        @box_color ||= attributes[:box_color] || "#1e98d7"
      end

      def self.log_presenter_class_for(_log)
        Decidim::ParticipatoryDocuments::AdminLog::DocumentPresenter
      end
    end
  end
end
