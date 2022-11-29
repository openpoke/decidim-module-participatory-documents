# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_participatory_documents_admin: "#{base_path}/app/packs/entrypoints/decidim_participatory_documents_admin.js",
  decidim_participatory_documents_admin_pdf: "#{base_path}/app/packs/entrypoints/decidim_participatory_documents_admin_pdf.js"
)
# Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/participatory_documents")
