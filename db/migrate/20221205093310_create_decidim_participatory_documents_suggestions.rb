# frozen_string_literal: true

class CreateDecidimParticipatoryDocumentsSuggestions < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_participatory_documents_suggestions do |t|
      t.jsonb :description
      t.string :state
      t.belongs_to :zone, null: false, index: { name: "participatory_documents_suggestion_zone" }
      t.references :decidim_author, polymorphic: true, null: false, index: { name: "participatory_documents_suggestion_author_id_and_type" }
      t.references :decidim_user_group, null: true, index: { name: "participatory_documents_suggestion_user_group" }
      t.timestamps
    end
  end
end
