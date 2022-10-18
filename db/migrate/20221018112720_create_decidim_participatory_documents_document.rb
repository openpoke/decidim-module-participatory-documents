# frozen_string_literal: true

class CreateDecidimParticipatoryDocumentsDocument < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_participatory_documents_documents do |t|
      t.jsonb :title
      t.jsonb :description
      t.belongs_to :decidim_component, null: false, index: { name: "participatory_documents_document_decidim_component" }
      t.references :decidim_author, null: false, index: { name: "participatory_documents_document_note_author" }
      t.timestamps
    end
  end
end
