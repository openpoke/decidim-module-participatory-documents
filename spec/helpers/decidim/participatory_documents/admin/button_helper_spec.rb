# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryDocuments::Admin::ButtonHelper do
  describe "#button_builder" do
    it "returns a button with the given title and icon" do
      expect(helper.button_builder("Title", icon: "file-text-line")).to include("Title")
      expect(helper.button_builder("Title", icon: "file-text-line")).to include("file-text-line")
    end
  end

  describe "#btn_icon" do
    it "returns a button with the given icon" do
      expect(helper.btn_icon("file-text-line", "label")).to include("file-text-line")
      expect(helper.btn_icon("file-text-line", "label")).to include("label")
    end
  end
end
