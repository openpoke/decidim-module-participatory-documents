# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class Document < ApplicationRecord
      self.table_name = :decidim_participatory_documents_documents

      include Decidim::HasComponent
      include Decidim::Authorable
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::TranslatableResource

      translatable_fields :title, :description
    end
  end
end
