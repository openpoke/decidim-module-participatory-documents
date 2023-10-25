# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryDocuments
  describe ExportMySuggestionsJob do
    let!(:document) { create(:participatory_documents_document, :with_suggestions) }
    let(:organization) { document.component.organization }
    let!(:user) { create(:user, organization: organization) }

    it "sends an email with the result of the export" do
      described_class.perform_now(user, document, "CSV")

      email = last_email
      expect(email.subject).to include("suggestions")
      attachment = email.attachments.first

      expect(attachment.read.length).to be_positive
      expect(attachment.mime_type).to eq("application/zip")
      expect(attachment.filename).to match(/^suggestions-[0-9]+-[0-9]+-[0-9]+-[0-9]+\.zip$/)
    end

    describe "CSV" do
      it "uses the CSV exporter" do
        export_data = double

        expect(Decidim::Exporters::CSV)
          .to(receive(:new).with(anything, MySuggestionSerializer))
          .and_return(double(export: export_data))

        expect(Decidim::ExportMailer)
          .to(receive(:export).with(user, anything, export_data))
          .and_return(double(deliver_now: true))

        described_class.perform_now(user, document, "CSV")
      end
    end

    describe "JSON" do
      it "uses the JSON exporter" do
        export_data = double

        expect(Decidim::Exporters::JSON)
          .to(receive(:new).with(anything, MySuggestionSerializer))
          .and_return(double(export: export_data))

        expect(Decidim::ExportMailer)
          .to(receive(:export).with(user, anything, export_data))
          .and_return(double(deliver_now: true))

        described_class.perform_now(user, document, "JSON")
      end
    end

    describe "XLSX" do
      it "uses the XLSX exporter" do
        export_data = double

        expect(Decidim::Exporters::Excel)
          .to(receive(:new).with(anything, MySuggestionSerializer))
          .and_return(double(export: export_data))

        expect(Decidim::ExportMailer)
          .to(receive(:export).with(user, anything, export_data))
          .and_return(double(deliver_now: true))

        described_class.perform_now(user, document, "Excel")
      end
    end
  end
end
