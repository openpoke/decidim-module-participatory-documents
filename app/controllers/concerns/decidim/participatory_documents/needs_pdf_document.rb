# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    # This module provides methods and helpers for the pdf_viewer/editor
    module NeedsPdfDocument
      extend ActiveSupport::Concern

      included do
        helper_method :document, :box_color_as_rgba, :pdf_custom_style, :pdf_i18n

        protected

        def document
          @document ||= Decidim::ParticipatoryDocuments::Document.find_by(component: current_component)
        end

        def box_color_as_rgba(document, opacity: nil)
          opacity ||= document.box_opacity
          return "rgba(30, 152, 215, 0.12);" unless document.box_color.present? && opacity.present?

          document.box_color + (opacity * 2.55).round.to_s(16).rjust(2, "0")
        end

        def pdf_custom_style
          @pdf_custom_style ||= begin
            css = <<~CSS
              <style media="all">
                .annotationEditorLayer .box {
                  background-color: #{box_color_as_rgba(document)};
                  border-color: #{document.box_color};
                }
                .annotationEditorLayer .box::before {
                  background-color: #{document.box_color};
                }
                .annotationEditorLayer .box .box-controls .control {
                  background-color: #{document.box_color};
                }
                #notifications {
                  background-color: #{box_color_as_rgba(document, opacity: 60)};
                }
              </style>
            CSS
            css.html_safe
          end
        end

        def pdf_i18n
          {
            startSuggesting: "Click on a marked area to participate!",
            confirmExit: "Are you sure you want to exit?",
            operationFailed: "The Operation has failed",
            allSaved: "All the boxes data has been saved to DB",
            removed: "The box has been removed",
            removeBoxConfirm: "Are you sure you want to delete?",
            updated: "The box has been updated",
            created: "The box has been created",
            move: "Move",
            group: "Group",
            startEditing: "Start creating boxes for participation by clicking and dragging. Once created, boxes can be resized, moved or grouped."
          }
        end
      end
    end
  end
end
