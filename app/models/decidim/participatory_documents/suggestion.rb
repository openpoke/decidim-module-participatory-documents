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

      has_many :notes, class_name: "Decidim::ParticipatoryDocuments::SuggestionNote", dependent: :destroy, counter_cache: :suggestion_notes_count

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
