class AddDecidimParticipatoryDocumentsColors < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_participatory_documents_documents, :box_color, :string
    add_column :decidim_participatory_documents_documents, :box_opacity, :integer
  end
end
