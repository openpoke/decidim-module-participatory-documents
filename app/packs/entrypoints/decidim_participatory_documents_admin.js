// Images
require.context("../images", true)

import "entrypoints/decidim_participatory_documents_admin.scss";

$(() => {
    if ($(".js-bulk-action-form").length) {

        // select all checkboxes
        $(".js-check-all").change(function() {
            $(".js-check-all-proposal").prop("checked", $(this).prop("checked"));

            if ($(this).prop("checked")) {
                $(".js-check-all-proposal").closest("tr").addClass("selected");
                showBulkActionsButton();
            } else {
                $(".js-check-all-proposal").closest("tr").removeClass("selected");
                hideBulkActionsButton();
            }

            selectedProposalsCountUpdate();
        });

    }

});