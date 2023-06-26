# frozen_string_literal: true

describe Decidim::ParticipatoryDocuments::Admin::DocumentsHelper, type: :helper do
  let(:component) { create :participatory_documents_component }
  let(:document) { create(:participatory_documents_document, component: component) }

  describe "#pdf_manage_button" do
    before do
      allow(document.file).to receive(:attached?).and_return(document_attached)
    end

    context "when document is blank and user is allowed to create a participatory_document" do
      let(:document_attached) { false }

      before do
        allow(helper).to receive(:allowed_to?).with(:create, :participatory_document).and_return(true)
        allow(helper).to receive(:new_pdf_btn).and_return("New PDF Button")
      end

      it "returns the new_pdf_btn" do
        result = helper.pdf_manage_button(nil)
        expect(result).to include("New PDF Button")
      end
    end

    context "when document is not blank, file is attached and user is allowed to update the document" do
      let(:document_attached) { true }

      before do
        allow(helper).to receive(:allowed_to?).with(:update, :participatory_document, document: document).and_return(true)
        allow(helper).to receive(:edit_boxes_btn).and_return("Edit participatory areas")
        allow(helper).to receive(:edit_document_btn).and_return("Edit/upload document")
        allow(helper).to receive(:preview_sections_btn).and_return("Preview and publishing sections")
      end

      it "returns the combination of edit_boxes_btn, edit_document_btn and preview_sections_btn" do
        result = helper.pdf_manage_button(document)
        expect(result).to include("Edit participatory areas", "Edit/upload document", "Preview and publishing sections")
      end
    end

    context "when document is not blank, file is not attached and user is allowed to update the document" do
      let(:document_attached) { false }

      before do
        allow(helper).to receive(:allowed_to?).with(:update, :participatory_document, document: document).and_return(true)
        allow(helper).to receive(:edit_document_btn).and_return("Edit/upload document")
      end

      it "returns the edit_document_btn" do
        result = helper.pdf_manage_button(document)
        expect(result).to include("Edit/upload document")
      end
    end
  end
end
