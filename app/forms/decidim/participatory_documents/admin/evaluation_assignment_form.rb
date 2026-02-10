# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class EvaluationAssignmentForm < Decidim::Form
        mimic :evaluator_role

        attribute :id, Integer
        attribute :suggestion_ids, Array

        validates :evaluator_role, :suggestions, :current_component, presence: true
        validate :same_participatory_space

        def suggestions
          # here we need to check for component
          @suggestions ||= Decidim::ParticipatoryDocuments::Suggestion.where(id: suggestion_ids).uniq.filter { |suggestion| suggestion.component == current_component }
        end

        def evaluator_role
          @evaluator_role ||= current_component.participatory_space.user_roles(:evaluator).find_by(id:)
        end

        def evaluator_user
          return unless evaluator_role

          @evaluator_user ||= evaluator_role.user
        end

        def same_participatory_space
          return if !evaluator_role || !current_component

          errors.add(:id, :invalid) if current_component.participatory_space != evaluator_role.participatory_space
        end
      end
    end
  end
end
