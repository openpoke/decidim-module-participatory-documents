# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class ZoneForm < Decidim::Form
        include TranslatableAttributes

        attribute :uid

        translatable_attribute :title, String
        translatable_attribute :description, String

        attribute :published_at, DateTime, default: false
        attribute :private, Boolean, default: false
        attribute :closed_at, DateTime, default: false

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true

        def published?
          published_at.present? && published_at.to_i > 0
        end

        def closed?
          closed_at.present? && closed_at.to_i > 0
        end
      end
    end
  end
end
