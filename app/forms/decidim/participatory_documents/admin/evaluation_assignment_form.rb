# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class EvaluationAssignmentForm < Decidim::Form
        mimic :evaluator_role

        attribute :id, Integer
        attribute :evaluator_role_ids, Array
        attribute :suggestion_ids, Array

        validates :evaluator_roles, :suggestions, :current_component, presence: true
        validate :same_participatory_space

        def suggestions
          # here we need to check for component
          @suggestions ||= Decidim::ParticipatoryDocuments::Suggestion.where(id: suggestion_ids).uniq.filter { |suggestion| suggestion.component == current_component }
        end

        def evaluator_roles
          @evaluator_roles ||= current_component.participatory_space.user_roles(:evaluator).where(id: evaluator_role_ids)
        end

        def same_participatory_space
          return if evaluator_roles.empty? || !current_component

          evaluator_roles.each do |evaluator_role|
            errors.add(:evaluator_role_ids, :invalid) if current_component.participatory_space != evaluator_role.participatory_space
          end
        end
      end
    end
  end
end
