import "../src/decidim/participatory_documents/pdf_admin.js"
import $ from "jquery"; // eslint-disable-line id-length
import "foundation-sites";

import "entrypoints/decidim_participatory_documents_editor.scss";

const csrfToken = document.getElementsByName("csrf-token");
$.ajaxSetup({
  headers: { "X-CSRF-Token": csrfToken.length && csrfToken[0].content }
});
