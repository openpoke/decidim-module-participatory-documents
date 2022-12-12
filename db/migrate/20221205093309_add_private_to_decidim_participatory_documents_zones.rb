# frozen_string_literal: true

class AddPrivateToDecidimParticipatoryDocumentsZones < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_participatory_documents_zones, :private, :boolean
  end
end
