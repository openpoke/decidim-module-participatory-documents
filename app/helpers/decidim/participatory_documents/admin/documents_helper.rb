# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      module DocumentsHelper
        def pdf_manage_button(document)
          content_tag(:div, class: "flex--cc flex-gap--1") do
            if document.blank? && allowed_to?(:create, :participatory_document)
              new_pdf_btn
            elsif document.file.attached? && allowed_to?(:update, :participatory_document)
              edit_document_btn + edit_pdf_btn
            else
              edit_document_btn
            end
          end
        end

        private

        def button_builder(btn_title)
          btn_icon(btn_title) + content_tag(:span, btn_title)
        end

        def btn_icon(label)
          icon("document", class: "icon--document icon icon icon-document mr-xs", aria_label: label, role: "img")
        end

        def new_pdf_btn
          btn_title = t("actions.new", scope: "decidim.participatory_documents")

          content_tag(:a, title: btn_title, href: new_document_path, class: "button button--simple") do
            button_builder(btn_title)
          end
        end

        def edit_pdf_btn
          btn_title = t("actions.edit_pdf", scope: "decidim.participatory_documents")

          content_tag(:a, title: btn_title, href: edit_pdf_documents_path(id: document.id), class: "button small light success") do
            button_builder(btn_title)
          end
        end

        def edit_document_btn
          btn_title = t("actions.edit_document", scope: "decidim.participatory_documents")

          content_tag(:a, title: btn_title, href: edit_document_path(id: document.id), class: "button small light") do
            button_builder(btn_title)
          end
        end
      end
    end
  end
end
