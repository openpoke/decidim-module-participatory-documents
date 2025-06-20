# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class Suggestion < ApplicationRecord
      include Decidim::Authorable
      include Decidim::TranslatableResource
      include Decidim::TranslatableAttributes
      include Decidim::HasUploadValidations
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::AttachmentMethods
      include Decidim::HasAttachments

      translatable_fields :body, :answer

      has_one_attached :file

      delegate :attached?, to: :file

      delegate :organization, to: :suggestable, allow_nil: true
      belongs_to :suggestable, polymorphic: true
      has_many :valuation_assignments, class_name: "Decidim::ParticipatoryDocuments::ValuationAssignment",
                                       foreign_key: "decidim_participatory_documents_suggestion_id", dependent: :destroy

      delegate :participatory_space, :component, to: :suggestable, allow_nil: true

      has_many :notes, class_name: "Decidim::ParticipatoryDocuments::SuggestionNote", dependent: :destroy, counter_cache: :suggestion_notes_count

      scope :missing_answer, -> { where(answered_at: nil) }
      scope :not_published, -> { where(answer_is_published: false) }

      validate :validate_file_type, if: :attached?

      validates_upload :file, uploader: Decidim::AttachmentUploader

      POSSIBLE_STATES = %w(not_answered evaluating accepted rejected withdrawn).freeze

      POSSIBLE_STATES.each do |possible|
        scope "state_not_#{possible}".to_sym, -> { where.not(state: possible) }
        scope "state_#{possible}".to_sym, -> { where(state: possible) }

        define_method(:"#{possible}?") do
          state == possible.to_s
        end
        define_method(:"not_#{possible}?") do
          state != possible.to_s
        end
      end

      scope :having_text_answer, lambda {
        field = Arel::Nodes::InfixOperation.new("->>", arel_table[:answer], Arel::Nodes.build_quoted(I18n.locale))
        where(Arel::Nodes::InfixOperation.new("", field, Arel.sql("!= ''")))
      }

      def answered?
        answered_at.present?
      end

      def has_answer?
        translated_attribute(answer).present?
      end

      scope :sort_by_published_asc, lambda {
        field = Arel::Nodes::InfixOperation.new("->>", arel_table[:answer], Arel::Nodes.build_quoted(I18n.locale))
        order("answered_at ASC NULLS FIRST", Arel::Nodes::InfixOperation.new("", field, Arel.sql("ASC")))
      }

      scope :sort_by_published_desc, lambda {
        field = Arel::Nodes::InfixOperation.new("->>", arel_table[:answer], Arel::Nodes.build_quoted(I18n.locale))
        order("answered_at DESC NULLS LAST", Arel::Nodes::InfixOperation.new("", field, Arel.sql("DESC")))
      }

      scope :sort_by_suggestable_asc, lambda {
        joins("LEFT JOIN decidim_participatory_documents_documents d ON suggestable_id = d.id and suggestable_type= 'Decidim::ParticipatoryDocuments::Document'")
          .joins("LEFT JOIN decidim_participatory_documents_sections s ON suggestable_id = s.id and suggestable_type= 'Decidim::ParticipatoryDocuments::Section'")
          .order(Arel.sql("#{sort_by_suggestable_title_query} ASC NULLS FIRST"))
      }

      scope :sort_by_suggestable_desc, lambda {
        joins("LEFT JOIN decidim_participatory_documents_documents d ON suggestable_id = d.id and suggestable_type= 'Decidim::ParticipatoryDocuments::Document'")
          .joins("LEFT JOIN decidim_participatory_documents_sections s ON suggestable_id = s.id and suggestable_type= 'Decidim::ParticipatoryDocuments::Section'")
          .order(Arel.sql("#{sort_by_suggestable_title_query} DESC NULLS LAST"))
      }

      scope :sort_by_author_asc, lambda {
        joins("LEFT JOIN decidim_users ON decidim_users.id = decidim_author_id").order("decidim_users.name asc")
      }

      scope :sort_by_author_desc, lambda {
        joins("LEFT JOIN decidim_users ON decidim_users.id = decidim_author_id").order("decidim_users.name DESC")
      }

      def self.sort_by_translated_body_asc
        field = Arel::Nodes::InfixOperation.new("->>", arel_table[:body], Arel::Nodes.build_quoted(I18n.locale))
        order(Arel::Nodes::InfixOperation.new("", field, Arel.sql("ASC")))
      end

      def self.sort_by_translated_body_desc
        field = Arel::Nodes::InfixOperation.new("->>", arel_table[:body], Arel::Nodes.build_quoted(I18n.locale))
        order(Arel::Nodes::InfixOperation.new("", field, Arel.sql("DESC")))
      end

      ransacker :body do
        Arel.sql(%{cast("decidim_participatory_documents_suggestions"."body" as text)})
      end

      scope :sort_by_valuation_assignments_count_asc, lambda {
        order(Arel.sql("#{sort_by_valuation_assignments_count_nulls_last_query} ASC NULLS FIRST"))
      }

      scope :sort_by_valuation_assignments_count_desc, lambda {
        order(Arel.sql("#{sort_by_valuation_assignments_count_nulls_last_query} DESC NULLS LAST"))
      }

      def self.ransackable_scopes(_auth = nil)
        [:valuator_role_ids_has, :dummy_author_ids_has, :dummy_suggestable_id_has]
      end

      def self.dummy_author_ids_has(value)
        where(decidim_author_id: value)
      end

      def self.dummy_suggestable_id_has(value)
        if value.split("-").first == "d"
          where(suggestable_id: value.split("-").last, suggestable_type: "Decidim::ParticipatoryDocuments::Document")
        else
          where(suggestable_id: value.split("-").last, suggestable_type: "Decidim::ParticipatoryDocuments::Section")
        end
      end

      # method to filter by assigned valuator role ID
      def self.valuator_role_ids_has(value)
        query = <<-SQL.squish
        :value = any(
          (SELECT decidim_participatory_documents_valuation_assignments.valuator_role_id
          FROM decidim_participatory_documents_valuation_assignments
          WHERE decidim_participatory_documents_valuation_assignments.decidim_participatory_documents_suggestion_id = decidim_participatory_documents_suggestions.id
          )
        )
        SQL
        where(query, value:)
      end

      # Defines the base query so that ransack can actually sort by this value
      def self.sort_by_valuation_assignments_count_nulls_last_query
        <<-SQL.squish
        (
          SELECT COUNT(decidim_participatory_documents_valuation_assignments.id)
          FROM decidim_participatory_documents_valuation_assignments
          WHERE decidim_participatory_documents_valuation_assignments.decidim_participatory_documents_suggestion_id = decidim_participatory_documents_suggestions.id
          GROUP BY decidim_participatory_documents_valuation_assignments.decidim_participatory_documents_suggestion_id
        )
        SQL
      end

      def self.sort_by_suggestable_title_query
        Arel.sql("COALESCE(d.title->>'#{I18n.locale}', s.title->>'#{I18n.locale}')")
      end

      def valuators
        valuator_role_ids = valuation_assignments.where(suggestion: self).pluck(:valuator_role_id)
        user_ids = participatory_space.user_roles(:valuator).where(id: valuator_role_ids).pluck(:decidim_user_id)
        participatory_space.organization.users.where(id: user_ids)
      end

      def self.export_serializer
        Decidim::ParticipatoryDocuments::SuggestionSerializer
      end

      def validate_file_type
        allowed_extensions = organization.file_upload_settings["allowed_file_extensions"]["default"]
        allowed_content_types = organization.file_upload_settings["allowed_content_types"]["default"]

        file_extension = File.extname(file.blob.filename.to_s).delete(".")
        file_content_type = file.blob.content_type

        errors.add(:file, :invalid) unless allowed_extensions.include?(file_extension) && allowed_content_types.any? { |type| File.fnmatch(type, file_content_type) }
      end
    end
  end
end
