# frozen_string_literal: true

namespace :decidim_participatory_documents do
  # Since we cannot install pdf.js as node module, nor we can use it from CDN, We are using the prebuilt version.
  desc "Copies the pdf.js library from plugin root to designated application folder"
  task :install_pdf_js do
    copy_pdfjs_to_application "public"
  end

  private

  def decidim_participatory_documents_path
    @decidim_participatory_documents_path ||= Pathname.new(decidim_participatory_documents_gemspec.full_gem_path) if Gem.loaded_specs.has_key?("decidim-participatory_documents")
  end

  def decidim_participatory_documents_gemspec
    @decidim_participatory_documents_gemspec ||= Gem.loaded_specs["decidim-participatory_documents"]
  end

  def copy_pdfjs_to_application(destination_path = origin_path)
    FileUtils.cp_r(decidim_participatory_documents_path.join("pdfjs"), rails_app_path.join(destination_path))
  end
end

Rake::Task["decidim:webpacker:upgrade"].enhance do
  Rake::Task["decidim_participatory_documents:install_pdf_js"].invoke
end
