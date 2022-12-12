# frozen_string_literal: true

class AddUidToDecidimParticipatoryDocumentsAnnotations < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_participatory_documents_annotations, :uid, :string, index: true
  end
end
