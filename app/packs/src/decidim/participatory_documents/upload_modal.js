import UploadModal from "src/decidim/direct_uploads/upload_modal";

export default class SuggestionUploadModal {
  constructor() {
    this.observer = new MutationObserver(() => this.initialize());
    this.observer.observe(document.body, { childList: true, subtree: true });
  }

  initialize() {
    const participationModal = document.getElementById("participationModal");

    if (participationModal?.classList.contains("active")) {
      console.log("[UploadModal] First modal opened, initializing file upload...");

      this.fileUploadButton = document.querySelector("#suggestion_file_button");
      if (!this.fileUploadButton) {
        console.log("[UploadModal] File upload button not found yet...");
        return;
      }

      this.observer.disconnect();
      this.modal = new UploadModal(this.fileUploadButton);

      this.registerEvents();
    }
  }

  registerEvents() {
    this.fileUploadButton.addEventListener("click", (event) => this.openModal(event));
    this.modal.input.addEventListener("change", (event) => this.handleFileChange(event));
    this.modal.saveButton.addEventListener("click", (event) => this.saveFile(event));
    this.modal.cancelButton.addEventListener("click", (event) => this.cancelUpload(event));
    this.modal.modal.addEventListener("click", (event) => this.closeModalOnOutsideClick(event));

    const closeBtn = this.modal.modal.querySelector(`[data-dialog-close="${this.modal.modal.id.replace("-content", "")}"]`);
    if (closeBtn) {
      closeBtn.addEventListener("click", () => this.closeModal());
    }
  }

  openModal(event) {
    event.preventDefault();
    event.stopPropagation();

    const modalId = this.fileUploadButton.getAttribute("data-dialog-open");
    const uploadModalElement = document.getElementById(modalId);

    if (!uploadModalElement) {
      console.error(`[UploadModal] Upload modal with ID '${modalId}' not found.`);
      return;
    }

    uploadModalElement.classList.add("is-open");
    uploadModalElement.setAttribute("aria-hidden", "false");
  }

  handleFileChange(event) {
    console.log("[UploadModal] File input changed", event.target.files);
    this.modal.uploadFiles(event.target.files);
  }

  saveFile(event) {
    event.preventDefault();
    console.log("[UploadModal] Save button clicked in upload modal.");

    this.modal.updateAddAttachmentsButton();

    const form = document.querySelector("#new_suggestion_");
    if (form && this.modal.items.length > 0) {
      const file = this.modal.items[0];
      const hiddenInput = document.createElement("input");
      hiddenInput.type = "hidden";
      hiddenInput.name = "suggestion[file]";
      hiddenInput.value = file.hiddenField;
      form.appendChild(hiddenInput);
      console.log("[UploadModal] Hidden input appended to form:", hiddenInput);
    }

    this.closeModal();
  }

  cancelUpload(event) {
    event.preventDefault();
    console.log("[UploadModal] Cancel button clicked in upload modal.");
    this.modal.cleanAllFiles();
    this.closeModal();
  }

  closeModalOnOutsideClick(event) {
    if (event.target === this.modal.modal) {
      console.log("[UploadModal] Clicked outside modal, closing.");
      this.closeModal();
    }
  }

  closeModal() {
    this.modal.modal.classList.remove("is-open");
    this.modal.modal.setAttribute("aria-hidden", "true");
  }
}
