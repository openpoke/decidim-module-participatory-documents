# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      module DocumentsHelper
        def pdf_manage_button(document)
          content_tag(:div, class: "flex--cc flex-gap--1") do
            if document.blank? && allowed_to?(:create, :participatory_document)
              new_pdf_btn
            elsif document.file.attached? && allowed_to?(:update, :participatory_document, document: document)
              edit_boxes_btn + edit_document_btn + preview_sections_btn
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

        def preview_sections_btn
          btn_title = t("actions.preview_publishing_sections", scope: "decidim.participatory_documents")

          button_to(
            final_publish_document_path(document),
            method: :post,
            class: "button small light success",
            data: { confirm: t("actions.confirm", scope: "decidim.participatory_documents") },
            style: "margin-bottom: 0;"
          ) do
            button_builder(btn_title, icon: "eye")
          end
        end

        private

        def button_builder(btn_title, icon: "document")
          btn_icon(icon, btn_title) + content_tag(:span, btn_title)
        end

        def btn_icon(icon, label)
          icon(icon, class: "icon--document icon icon icon-document mr-xs", aria_label: label, role: "img")
        end

        def new_pdf_btn
          btn_title = t("actions.new", scope: "decidim.participatory_documents")

          content_tag(:a, title: btn_title, href: new_document_path, class: "button button--simple") do
            button_builder(btn_title)
          end
        end

        def edit_boxes_btn
          btn_title = t("actions.edit_boxes", scope: "decidim.participatory_documents")

          content_tag(:a, title: btn_title, href: edit_pdf_documents_path(id: document.id), class: "button small light") do
            button_builder(btn_title, icon: "layers")
          end
        end

        def edit_document_btn
          btn_title = t("actions.edit_document", scope: "decidim.participatory_documents")

          content_tag(:a, title: btn_title, href: edit_document_path(id: document.id), class: "button small light alert") do
            button_builder(btn_title)
          end
        end
      end
    end
  end
end
