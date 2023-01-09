# frozen_string_literal: true

class ChangeDecidimParticipatoryDocumentsSections < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_participatory_documents_sections, :uid, :string, index: true
  end
end
