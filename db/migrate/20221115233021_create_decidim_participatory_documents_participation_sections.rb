# frozen_string_literal: true

class CreateDecidimParticipatoryDocumentsParticipationSections < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_participatory_documents_sections do |t|
      t.belongs_to :document,
                   null: true,
                   index: { name: "document_zones" }
      t.jsonb :title
      t.string :state
      t.string :uid, index: true
      t.timestamps
    end
  end
end
