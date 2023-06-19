# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module DocumentsHelper
      include Decidim::ParticipatoryDocuments::Admin::ButtonHelper

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
    end
  end
end
