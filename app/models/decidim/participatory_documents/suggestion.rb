# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class Suggestion < ApplicationRecord
      include Decidim::Authorable
      include Decidim::TranslatableResource
      include Decidim::TranslatableAttributes

      include Decidim::Traceable
      include Decidim::Loggable

      translatable_fields :body, :answer
      validates :body, presence: true

      delegate :organization, to: :suggestable
      belongs_to :suggestable, polymorphic: true
      has_many :valuation_assignments, class_name: "Decidim::ParticipatoryDocuments::ValuationAssignment",
                                       foreign_key: "decidim_participatory_documents_suggestion_id", dependent: :destroy

      def valuators
        valuator_role_ids = valuation_assignments.where(suggestion: self).pluck(:valuator_role_id)
        user_ids = participatory_space.user_roles(:valuator).where(id: valuator_role_ids).pluck(:decidim_user_id)
        participatory_space.organization.users.where(id: user_ids)
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
        where(query, value: value)
      end

      POSSIBLE_STATES = %w(not_answered evaluating accepted rejected withdrawn).freeze

      POSSIBLE_STATES.each do |possible|
        define_method(:"#{possible}?") do
          state == possible.to_s
        end
      end

      def answered?
        answered_at.present?
      end

      scope :sort_by_suggestable_asc, lambda {
        order(suggestable_type: :asc, suggestable_id: :asc)
      }

      scope :sort_by_suggestable_desc, lambda {
        order(suggestable_type: :desc, suggestable_id: :desc)
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
    end
  end
end
