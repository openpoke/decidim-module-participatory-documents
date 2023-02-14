# frozen_string_literal: true

class CreateDecidimParticipatoryDocumentsValuationAssignments < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_participatory_documents_valuation_assignments do |t|
      t.references :decidim_participatory_documents_suggestion, null: false, index: { name: "decidim_pd_valuation_assignment_suggestion" }
      t.references :valuator_role, polymorphic: true, null: false, index: { name: "decidim_pd_valuation_assignment_valuator_role" }

      t.timestamps
    end
  end
end