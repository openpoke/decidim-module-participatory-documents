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
      include Decidim::Publicable

      translatable_fields :title, :description

      has_one_attached :file
      validates_upload :file, uploader: Decidim::ParticipatoryDocuments::PdfDocumentUploader
      # compatibility with ratonvirus (see https://github.com/mainio/decidim-module-antivirus)
      validates :file, antivirus: true if ParticipatoryDocuments.antivirus_enabled

      has_many :sections, class_name: "Decidim::ParticipatoryDocuments::Section", dependent: :restrict_with_error
      has_many :suggestions, class_name: "Decidim::ParticipatoryDocuments::Suggestion", dependent: :restrict_with_error, as: :suggestable
      has_many :annotations, through: :sections

      attr_accessor :remove_file

      # the dynamic upload validator requires the organization,
      # if the object is not created yet is assigned from the context by the UploadValidationForm using this method
      attr_writer :organization

      # override the delegate from HasComponent for the dynamic upload validator
      def organization
        component&.organization || @organization
      end

      def self.log_presenter_class_for(_log)
        Decidim::ParticipatoryDocuments::AdminLog::DocumentPresenter
      end

      def has_suggestions?
        suggestions_including_sections.or(Suggestion.where(suggestable: annotations)).exists?
      end

      def suggestions_including_sections
        Suggestion.where(suggestable: self).or(Suggestion.where(suggestable: sections))
      end

      # rubocop:disable Rails/SkipsModelValidations
      def update_positions!
        transaction do
          boxes = annotations.includes(:section).sort_by { |box| [box.page_number.to_i, box.rect["top"].to_i, box.rect["left"].to_i] }

          boxes.each_with_index do |box, index|
            box.update_column(:position, index + 1) if box.position != index + 1
          end

          boxes.map(&:section).uniq.each_with_index do |section, index|
            section.update_column(:position, index + 1) if section.position != index + 1
          end
        end
      end
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
