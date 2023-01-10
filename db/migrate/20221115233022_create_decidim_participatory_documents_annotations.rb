# frozen_string_literal: true

class CreateDecidimParticipatoryDocumentsAnnotations < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_participatory_documents_annotations do |t|
      t.belongs_to :document,
                   null: true,
                   index: false
      t.string :uid, index: true

      # t.jsonb :data
      t.jsonb :rect, default: {}
      t.integer :page_number, default: 1

      t.timestamps
    end
    add_reference :decidim_participatory_documents_annotations, :section, index: true, foreign_key: { to_table: :decidim_participatory_documents_sections }
  end
end
