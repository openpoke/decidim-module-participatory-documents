# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class ValuationAssignmentForm < Decidim::Form
        mimic :valuator_role

        attribute :id, Integer
        attribute :suggestion_ids, Array

        validates :valuator_role, :suggestions, :current_component, presence: true
        validate :same_participatory_space

        def suggestions
          @suggestions ||= Decidim::ParticipatoryDocuments::Suggestion.where(id: suggestion_ids).uniq
        end

        def valuator_role
          @valuator_role ||= current_component.participatory_space.user_roles(:valuator).find_by(id: id)
        end

        def valuator_user
          return unless valuator_role

          @valuator_user ||= valuator_role.user
        end

        def same_participatory_space
          return if !valuator_role || !current_component

          errors.add(:id, :invalid) if current_component.participatory_space != valuator_role.participatory_space
        end
      end
    end
  end
end
