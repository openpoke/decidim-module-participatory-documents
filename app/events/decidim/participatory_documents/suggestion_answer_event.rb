# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    class SuggestionAnswerEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::AuthorEvent

      def resource_path
        @resource_path ||= if resource.suggestable.is_a?(Decidim::ParticipatoryDocuments::Document)
                             main_component_path(resource.suggestable.component)
                           else
                             main_component_path(resource.suggestable.document.component)
                           end
      end

      def resource_url
        @resource_url ||= if resource.suggestable.is_a?(Decidim::ParticipatoryDocuments::Document)
                            main_component_url(resource.suggestable.component)
                          else
                            main_component_url(resource.suggestable.document.component)
                          end
      end

      def resource_title
        title ||= if resource.suggestable.is_a?(Decidim::ParticipatoryDocuments::Document)
                    translated_attribute(resource.suggestable.title)
                  else
                    translated_attribute(resource.suggestable.document.title)
                  end

        Decidim::ContentProcessor.render_without_format(title, links: false).html_safe
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
