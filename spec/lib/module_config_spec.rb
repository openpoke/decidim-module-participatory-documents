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
      let(:config) { JSON.parse cmd_capture("bin/rails runner 'puts Decidim::ParticipatoryDocuments.config.to_json'", env: env) }

      def cmd_capture(cmd, env: {})
        Dir.chdir(test_app) do
          Open3.capture2(env.merge("RUBYOPT" => "-W0"), cmd)[0]
        end
      end

      it "has the correct configuration" do
        expect(config).to eq({
                               "max_export_text_length" => 11,
                               "min_suggestion_length" => 33,
                               "max_suggestion_length" => 77
                             })
      end
    end
  end
end
