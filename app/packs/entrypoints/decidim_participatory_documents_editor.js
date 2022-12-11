import "../src/decidim/participatory_documents/pdf_admin.js"

import "entrypoints/decidim_participatory_documents_editor.scss";

import $ from "jquery"
import "foundation-sites";


const csrfToken = document.getElementsByName("csrf-token")[0].content;
$.ajaxSetup({
  headers: { "X-CSRF-Token": csrfToken }
});
