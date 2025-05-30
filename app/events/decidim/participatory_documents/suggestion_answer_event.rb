# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class SuggestionAnswerEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::AuthorEvent

      def resource_path
        @resource_path ||= main_component_path(document.component)
      end

      def resource_url
        @resource_url ||= main_component_url(document.component)
      end

      def resource_title
        @resource_title ||= Decidim::ContentProcessor.render_without_format(translated_attribute(document.title), links: false).html_safe
      end

      def document
        @document ||= if resource.suggestable.respond_to?(:document)
                        resource.suggestable.document
                      else
                        resource.suggestable
                      end
      end

      def event_has_roles?
        true
      end

      def resource_text
        translated_attribute(resource.answer)
      end
    end
  end
end
