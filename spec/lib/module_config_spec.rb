# frozen_string_literal: true

require "spec_helper"
require "open3"

module Decidim
  describe ParticipatoryDocuments do
    describe "default configuration from ENV" do
      let(:test_app) { Rails.root }
      let(:env) do
        {
          "MAX_EXPORT_TEXT_LENGTH" => export,
          "MIN_SUGGESTION_LENGTH" => min,
          "MAX_SUGGESTION_LENGTH" => max
        }
      end
      let(:export) { "11" }
      let(:min) { "33" }
      let(:max) { "77" }
      let(:settings) { %w(max_export_text_length min_suggestion_length max_suggestion_length antivirus_enabled pdfjs_url pdfjs_checksum) }
      let(:runner) { "puts %w(#{settings.join(" ")}).index_with { |name| Decidim::ParticipatoryDocuments.public_send(name) }.to_json" }
      let(:config) { JSON.parse cmd_capture("bin/rails runner '#{runner}'", env:) }

      def cmd_capture(cmd, env: {})
        Dir.chdir(test_app) do
          Open3.capture3(env.merge("RUBYOPT" => "-W0", "RAILS_ENV" => "test", "DISABLE_SPRING" => "1"), cmd).tap { |_out, err, st| raise err unless st.success? }[0]
        end
      end

      it "has the correct configuration" do
        expect(config).to eq({
                               "max_export_text_length" => 11,
                               "min_suggestion_length" => 33,
                               "max_suggestion_length" => 77,
                               "antivirus_enabled" => false,
                               "pdfjs_url" => "https://github.com/mozilla/pdf.js/releases/download/v5.2.133/pdfjs-5.2.133-dist.zip",
                               "pdfjs_checksum" => "82c6de8955024d1733dfb74aa50bb6e2f210dbb479c90e2c29fe2bbd4ff446dc"
                             })
      end
    end

    describe ".configure" do
      around do |example|
        original = described_class.max_export_text_length
        example.run
        described_class.max_export_text_length = original
      end

      it "sets the options of the module" do
        described_class.configure { |config| config.max_export_text_length = 20 }

        expect(described_class.max_export_text_length).to eq(20)
        expect(described_class.config.max_export_text_length).to eq(20)
      end
    end
  end
end
