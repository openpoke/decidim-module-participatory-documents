# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_participatory_documents_admin: "#{base_path}/app/packs/entrypoints/decidim_participatory_documents_admin.js",
  decidim_participatory_documents_viewer: "#{base_path}/app/packs/entrypoints/decidim_participatory_documents_viewer.js",
  decidim_participatory_documents_editor: "#{base_path}/app/packs/entrypoints/decidim_participatory_documents_editor.js",
  decidim_participatory_documents: "#{base_path}/app/packs/entrypoints/decidim_participatory_documents.js"
)
