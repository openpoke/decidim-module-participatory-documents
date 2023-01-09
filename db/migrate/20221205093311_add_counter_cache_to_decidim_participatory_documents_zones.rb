# frozen_string_literal: true

class AddCounterCacheToDecidimParticipatoryDocumentsZones < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_participatory_documents_zones, :annotations_count, :integer, default: 0
    add_column :decidim_participatory_documents_zones, :suggestions_count, :integer, default: 0
  end
end
