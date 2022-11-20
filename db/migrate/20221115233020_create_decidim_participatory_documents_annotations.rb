# frozen_string_literal: true

class CreateDecidimParticipatoryDocumentsAnnotations < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_participatory_documents_annotations do |t|

      t.belongs_to :document, index: { name: "document_annotations" }

      t.integer :annotation_type, default: 7  # this is PDFJS annotationType for polygon
      t.integer :thickness, default: 1
      t.integer :page_index
      t.integer :rotation
      t.float :opacity
      t.float :scale
      t.text :paths, array: true, default: []
      t.text :color, array: true, default: []
      t.text :rect, array: true, default: []
      t.jsonb :data

      t.timestamps
    end
  end
end
