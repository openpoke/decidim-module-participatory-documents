# frozen_string_literal: true

describe Decidim::ParticipatoryDocuments::DocumentsHelper do
  let(:component) { create(:participatory_documents_component) }
  let(:document) { create(:participatory_documents_document, component:) }

  describe "#back_edit_pdf_btn" do
    before do
      allow(helper).to receive(:button_builder).and_return("Go back to edit participatory sections")
    end

    it "returns the correct HTML for the button" do
      allow(helper).to receive(:document).and_return(document)
      result = helper.back_edit_pdf_btn
      expect(result).to include("Go back to edit participatory sections")
      expect(result).to include("href=\"#{Decidim::EngineRouter.admin_proxy(document.component).edit_pdf_documents_path(id: document.id)}\"")
      expect(result).to include("class=\"button button__sm button__warning\"")
    end
  end

  describe "#finish_publish_btn" do
    before do
      allow(helper).to receive(:button_builder).and_return("Publish participatory sections")
    end

    it "returns the correct HTML for the button" do
      allow(helper).to receive(:document).and_return(document)
      result = helper.finish_publish_btn
      expect(result).to include("Publish participatory sections")
      expect(result).to include("href=\"#{Decidim::EngineRouter.admin_proxy(document.component).publish_document_path(document)}\"")
      expect(result).to include("data-confirm=\"#{t("actions.confirm", scope: "decidim.participatory_documents")}\"")
      expect(result).to include("class=\"button button__sm button__success\"")
    end
  end
end
