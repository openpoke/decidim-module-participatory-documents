class CreateDecidimParticipatoryDocumentsAnnotations < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_participatory_documents_annotations do |t|

      t.belongs_to :document,
                   null: true,
                   index: false
      t.jsonb :data

      t.timestamps
    end
  end
end
