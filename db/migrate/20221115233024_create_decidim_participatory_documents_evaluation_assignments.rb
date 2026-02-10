# frozen_string_literal: true

class CreateDecidimParticipatoryDocumentsEvaluationAssignments < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_participatory_documents_evaluation_assignments do |t|
      t.references :decidim_participatory_documents_suggestion, null: false, index: { name: "decidim_pd_evaluation_assignment_suggestion" }
      t.references :evaluator_role, polymorphic: true, null: false, index: { name: "decidim_pd_evaluation_assignment_evaluator_role" }

      t.timestamps
    end
  end
end
