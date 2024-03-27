# frozen_string_literal: true

describe Decidim::ParticipatoryDocuments::Admin::DocumentsHelper do
  let(:component) { create(:participatory_documents_component) }
  let(:document) { create(:participatory_documents_document, component:) }

  describe "#pdf_manage_buttons" do
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
        result = helper.pdf_manage_buttons(nil)
        expect(result).to include("New PDF Button")
      end
    end

    context "when document is not blank, file is attached and user is allowed to update the document" do
      let(:document_attached) { true }

      before do
        allow(helper).to receive(:allowed_to?).with(:update, :participatory_document, document:).and_return(true)
        allow(helper).to receive_messages(edit_boxes_btn: "Edit participatory areas", edit_document_btn: "Edit/upload document", preview_sections_btn: "Preview and publishing sections")
      end

      it "returns the combination of edit_boxes_btn, edit_document_btn and preview_sections_btn" do
        result = helper.pdf_manage_buttons(document)
        expect(result).to include("Edit participatory areas", "Edit/upload document", "Preview and publishing sections")
      end
    end

    context "when document is not blank, file is not attached and user is allowed to update the document" do
      let(:document_attached) { false }

      before do
        allow(helper).to receive(:allowed_to?).with(:update, :participatory_document, document:).and_return(true)
        allow(helper).to receive(:edit_document_btn).and_return("Edit/upload document")
      end

      it "returns the edit_document_btn" do
        result = helper.pdf_manage_buttons(document)
        expect(result).to include("Edit/upload document")
      end
    end
  end
end
