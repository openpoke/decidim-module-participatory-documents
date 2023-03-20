# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class SuggestionAuthorCell < Decidim::ViewModel
      include Decidim::SanitizeHelper

      def show
        @suggestion = options[:suggestion]
        @reverse_order = options[:reverse_order]
        render
      end

      def author_avatar_url
        model.author.avatar.attached? ? avatar_url : default_avatar_url(:thumb)
      end

      def author_name
        model.author.name
      end

      def avatar
        model.author.avatar.attached? ? model.author.avatar : nil
      end

      def author_profile_path
        decidim.profile_path(model.author.nickname)
      end

      def creation_date
        date_at = model.try(:created_at)

        l date_at, format: :decidim_short
      end

      def suggestion
        model
      end

      private

      def default_avatar_url(_variant = nil)
        ActionController::Base.helpers.asset_pack_path("media/images/default-avatar.svg")
      end

      def avatar_url
        Rails.application.routes.url_helpers.rails_representation_path(model.author.avatar.variant(resize_to_fit: [30, 30]), only_path: true)
      end
    end
  end
end
