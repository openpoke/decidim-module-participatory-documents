# frozen_string_literal: true

describe Decidim::ParticipatoryDocuments::Admin::ButtonHelper, type: :helper do
  let(:component) { create :participatory_documents_component }
  let(:document) { create(:participatory_documents_document, component: component) }

  describe "#button_builder" do
    it "returns a button with the given title and icon" do
      expect(helper.button_builder("Title", icon: "icon")).to include("Title")
      expect(helper.button_builder("Title", icon: "icon")).to include("icon")
    end
  end

  describe "#btn_icon" do
    it "returns a button with the given icon" do
      expect(helper.btn_icon("icon", "label")).to include("icon")
    end
  end
end
