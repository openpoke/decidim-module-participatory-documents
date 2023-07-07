# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      module DocumentsHelper
        include ButtonHelper

        def pdf_manage_button(document)
          content_tag(:div, class: "flex--cc flex-gap--1") do
            if document.blank? && allowed_to?(:create, :participatory_document)
              new_pdf_btn
            elsif document.file.attached? && allowed_to?(:update, :participatory_document, document: document)
              edit_document_btn + edit_boxes_btn + preview_sections_btn
            elsif allowed_to?(:update, :participatory_document, document: document)
              edit_document_btn
            end
          end
        end

        def back_btn
          btn_title = t("actions.back", scope: "decidim.participatory_documents")

          content_tag(:a, title: btn_title, href: manage_component_path(current_component), class: "button small button--simple") do
            button_builder(btn_title, icon: "caret-left")
          end
        end

        def boolean_label(active)
          content_tag(:span, class: "label #{active ? "success" : "alert"}") do
            t(active ? "yes" : "no", scope: "decidim.participatory_documents")
          end
        end

        private

        def preview_sections_btn
          btn_title = t("actions.preview_publishing_sections", scope: "decidim.participatory_documents")

          content_tag(:a, title: btn_title, href: main_component_path(document.component), class: "button small success") do
            button_builder(btn_title, icon: "eye")
          end
        end

        def new_pdf_btn
          btn_title = t("actions.new", scope: "decidim.participatory_documents")

          content_tag(:a, title: btn_title, href: new_document_path, class: "button button--simple") do
            button_builder(btn_title)
          end
        end

        def edit_boxes_btn
          btn_title = t("actions.edit_boxes", scope: "decidim.participatory_documents")

          content_tag(:a, title: btn_title, href: edit_pdf_documents_path(id: document.id), class: "button small warning") do
            button_builder(btn_title, icon: "layers")
          end
        end

        def edit_document_btn
          btn_title = t("actions.edit_document", scope: "decidim.participatory_documents")

          content_tag(:a, title: btn_title, href: edit_document_path(id: document.id), class: "button small alert") do
            button_builder(btn_title)
          end
        end
      end
    end
  end
end
