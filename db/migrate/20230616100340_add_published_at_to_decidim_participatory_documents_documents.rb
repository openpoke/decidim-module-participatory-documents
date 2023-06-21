# frozen_string_literal: true

class AddFinalPublishedAtToDecidimParticipatoryDocumentsDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_participatory_documents_documents, :published_at, :datetime, index: true
  end
end
