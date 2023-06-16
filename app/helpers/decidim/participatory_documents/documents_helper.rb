# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module DocumentsHelper
      def back_edit_pdf_btn
        btn_title = t("actions.back_edit", scope: "decidim.participatory_documents")

        content_tag(:a,
                    title: btn_title,
                    href: Decidim::EngineRouter.admin_proxy(document.component).edit_pdf_documents_path(id: document.id),
                    class: "button small warning mr-s") do
          button_builder(btn_title, icon: "layers")
        end
      end

      def finish_publish_btn
        btn_title = t("actions.finish_publishing", scope: "decidim.participatory_documents")

        link_to(
          Decidim::EngineRouter.admin_proxy(document.component).final_publish_document_path(document),
          method: :post,
          data: { confirm: t("actions.confirm", scope: "decidim.participatory_documents") },
          class: "button small warning"
        ) do
          button_builder(btn_title, icon: "check")
        end
      end

      private

      def button_builder(btn_title, icon: "document")
        btn_icon(icon, btn_title) + content_tag(:span, btn_title)
      end

      def btn_icon(icon, label)
        icon(icon, class: "icon--document icon icon icon-document mr-xs", aria_label: label, role: "img")
      end
    end
  end
end
