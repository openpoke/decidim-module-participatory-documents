# frozen_string_literal: true

shared_examples "a pdf viewer allowing the storage host" do
  let(:connect_src) { response.headers["Content-Security-Policy"][/connect-src [^;]*/] }
  let(:default_connect_src) { Decidim::ContentSecurityPolicy.new(organization, Decidim.content_security_policies_extra).output_policy[/connect-src [^;]*/] }

  context "when the file is stored in a remote service" do
    before do
      allow(ActiveStorage::Blob.service).to receive(:url).and_return("https://storage.example.org/bucket/file.pdf?X-Amz-Signature=abc")
    end

    it "allows the storage host in the connect-src directive" do
      get :pdf_viewer

      expect(connect_src.split).to include("https://storage.example.org")
    end
  end

  context "when the remote service uses a custom port" do
    before do
      allow(ActiveStorage::Blob.service).to receive(:url).and_return("http://storage.example.org:9000/bucket/file.pdf")
    end

    it "keeps the port in the connect-src directive" do
      get :pdf_viewer

      expect(connect_src.split).to include("http://storage.example.org:9000")
    end
  end

  context "when the file is stored in the local service" do
    it "does not add the application host to the connect-src directive" do
      get :pdf_viewer

      expect(connect_src).to include("'self'")
      expect(connect_src).not_to include("test.host")
    end
  end

  context "when the document has no file attached" do
    let(:document) { create(:participatory_documents_document) }

    it "does not change the connect-src directive" do
      get :pdf_viewer

      expect(connect_src).to eq(default_connect_src)
    end
  end
end
