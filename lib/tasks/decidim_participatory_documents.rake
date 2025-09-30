# frozen_string_literal: true

namespace :decidim_participatory_documents do
  # Since we cannot install pdf.js as node module, nor we can use it from CDN, We are using the prebuilt version.
  desc "Downloads the pdf.js library to the designated application folder"
  task :install_pdf_js do
    download_pdfjs_to_application "public"
    apply_path_corrections_to_pdfjs "public"
  end

  desc "Create rack mime type initializer for .mjs files"
  task :create_mjs_initializer do
    Mime::Type.register "text/javascript", :mjs
    Rack::Mime::MIME_TYPES[".mjs"] = "text/javascript"
  end

  private

  def decidim_participatory_documents_path
    @decidim_participatory_documents_path ||= Pathname.new(decidim_participatory_documents_gemspec.full_gem_path) if Gem.loaded_specs.has_key?("decidim-participatory_documents")
  end

  def decidim_participatory_documents_gemspec
    @decidim_participatory_documents_gemspec ||= Gem.loaded_specs["decidim-participatory_documents"]
  end

  def download_pdfjs_to_application(destination_path)
    require "open-uri"
    require "zip"

    pdfjs_url = Decidim::ParticipatoryDocuments.pdfjs_url
    public_dir = rails_app_path.join(destination_path, "pdfjs")
    temp_dir = Rails.root.join("tmp/pdfjs")
    FileUtils.mkdir_p(temp_dir)
    FileUtils.rm_rf(public_dir)
    FileUtils.mkdir_p(public_dir)
    filename = File.basename(URI.parse(pdfjs_url).path)
    tmp_file = temp_dir.join(filename)

    # rubocop:disable Security/Open
    URI.open(pdfjs_url) do |remote_file|
      File.binwrite(tmp_file, remote_file.read)
    end
    # rubocop:enable Security/Open

    raise "The downloaded file is not a zip file: #{filename}" unless filename.end_with?(".zip")

    Zip::File.open(tmp_file) do |zip_file|
      zip_file.each do |entry|
        puts "Extracting #{public_dir.join(entry.name)}"
        f_path = File.join(public_dir, entry.name)
        FileUtils.mkdir_p(File.dirname(f_path))
        zip_file.extract(entry, f_path) unless File.exist?(f_path)
      end
    end
  end

  def apply_path_corrections_to_pdfjs(destination_path)
    viewer_file = rails_app_path.join(destination_path, "pdfjs/web/viewer.mjs")
    return unless File.exist?(viewer_file)

    content = File.read(viewer_file)
    new_content = content.gsub(%r{(["'`])\.\./([^"'`]+)\1}) do |match|
      match.sub("../", "/pdfjs/")
    end
    File.write(viewer_file, new_content) if new_content != content
  end
end

Rake::Task["decidim:upgrade:webpacker"].enhance do
  Rake::Task["decidim_participatory_documents:install_pdf_js"].invoke
  Rake::Task["decidim_participatory_documents:create_mjs_initializer"].invoke
end

Rake::Task["decidim:choose_target_plugins"].enhance do
  ENV["FROM"] = "#{ENV.fetch("FROM", nil)},decidim_participatory_documents"
end
