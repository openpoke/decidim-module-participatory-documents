# frozen_string_literal: true

class AddFinalPublishToDecidimParticipatoryDocumentsDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_participatory_documents_documents, :final_publish, :boolean, default: false
  end
end
