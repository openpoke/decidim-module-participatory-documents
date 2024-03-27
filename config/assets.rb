# frozen_string_literal: true

# Base path of the module
base_path = File.expand_path("..", __dir__)

# Register an additional load path for webpack
Decidim::Webpacker.register_path("#{base_path}/app/packs")

# # Entrypoints for the module
Decidim::Webpacker.register_entrypoints(
  decidim_admin_participatory_documents: "#{base_path}/app/packs/entrypoints/decidim_admin_participatory_documents.js",
  decidim_participatory_documents_viewer: "#{base_path}/app/packs/entrypoints/decidim_participatory_documents_viewer.js",
  decidim_participatory_documents_viewer_off: "#{base_path}/app/packs/entrypoints/decidim_participatory_documents_viewer_off.js",
  decidim_participatory_documents_editor: "#{base_path}/app/packs/entrypoints/decidim_participatory_documents_editor.js",
  decidim_participatory_documents: "#{base_path}/app/packs/entrypoints/decidim_participatory_documents.js"
)

# Stylesheet imports for admin panel
# Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/participatory_documents/participatory_documents_admin", group: :admin)
