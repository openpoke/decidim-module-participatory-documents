import SuggestionUploadModal from "src/decidim/participatory_documents/upload_modal";

document.addEventListener("DOMContentLoaded", () => {
  console.log("[UploadModalInitializer] Initializing Suggestion UploadModal...");
  window.SuggestionUploadModal = new SuggestionUploadModal();
});
