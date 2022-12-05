# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class Zone < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::TranslatableResource
      include Decidim::TranslatableAttributes
      include Decidim::Publicable
      belongs_to :document, class_name: "Decidim::ParticipatoryDocuments::Document"
      has_many :annotations, class_name: "Decidim::ParticipatoryDocuments::Annotation"

      translatable_fields :title, :description
      POSSIBLE_STATES = %w(draft published private closed).freeze
    end
  end
end
