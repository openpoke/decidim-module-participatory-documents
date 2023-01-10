# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class Section < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::TranslatableResource
      include Decidim::TranslatableAttributes
      include Decidim::Publicable
      belongs_to :document, class_name: "Decidim::ParticipatoryDocuments::Document"
      has_many :annotations, class_name: "Decidim::ParticipatoryDocuments::Annotation", dependent: :restrict_with_error

      translatable_fields :title, :description
      def self.log_presenter_class_for(_log)
        Decidim::ParticipatoryDocuments::AdminLog::SectionPresenter
      end
    end
  end
end
