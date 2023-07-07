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

      has_many :sections, class_name: "Decidim::ParticipatoryDocuments::Section", dependent: :restrict_with_error
      has_many :suggestions, class_name: "Decidim::ParticipatoryDocuments::Suggestion", dependent: :restrict_with_error, as: :suggestable
      has_many :annotations, through: :sections

      attr_accessor :remove_file

      def self.log_presenter_class_for(_log)
        Decidim::ParticipatoryDocuments::AdminLog::DocumentPresenter
      end

      def has_suggestions?
        suggestions.any? || annotations.any? { |annotation| annotation.suggestions.any? }
      end

      # rubocop:disable Rails/SkipsModelValidations
      def update_positions!
        transaction do
          boxes = annotations.reload.sort do |a, b|
            if a.page_number == b.page_number
              if a.rect["top"].to_i == b.rect["top"].to_i
                a.rect["left"].to_i <=> b.rect["left"].to_i
              else
                a.rect["top"].to_i <=> b.rect["top"].to_i
              end
            else
              a.page_number <=> b.page_number
            end
          end

          section_number = 0
          all_sections = {}
          boxes.each_with_index do |box, index|
            box.update_column(:position, index + 1)
            if all_sections[box.section_id]
              box.section.update_column(:position, all_sections[box.section_id])
            else
              section_number += 1
              box.section.update_column(:position, section_number)
            end
            all_sections[box.section_id] = section_number
          end
        end
      end
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
