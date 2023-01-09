# frozen_string_literal: true

class AddFieldsToDecidimParticipatoryDocumentsZones < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_participatory_documents_zones, :closed_at, :datetime
  end
end
