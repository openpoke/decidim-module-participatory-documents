# frozen_string_literal: true

class RemoveUserGroupFromParticipatoryDocuments < ActiveRecord::Migration[7.2]
  def up
    remove_index :decidim_participatory_documents_documents, name: "decidim_pd_document_user_group"
    remove_column :decidim_participatory_documents_documents, :decidim_user_group_id
    remove_index :decidim_participatory_documents_suggestions, name: "decidim_pd_suggestion_user_group"
    remove_column :decidim_participatory_documents_suggestions, :decidim_user_group_id
  end

  def down
    add_column :decidim_participatory_documents_documents, :decidim_user_group_id, :bigint
    add_index :decidim_participatory_documents_documents, :decidim_user_group_id, name: "decidim_pd_document_user_group"
    add_column :decidim_participatory_documents_suggestions, :decidim_user_group_id, :bigint
    add_index :decidim_participatory_documents_suggestions, :decidim_user_group_id, name: "decidim_pd_suggestion_user_group"
  end
end
