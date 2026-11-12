# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module ParticipatorySpaceUserRoleOverride
      extend ActiveSupport::Concern
      included do
        has_many :suggestion_evaluation_assignments,
                 class_name: "Decidim::ParticipatoryDocuments::EvaluationAssignment",
                 as: :evaluator_role,
                 dependent: :destroy
      end
    end
  end
end
