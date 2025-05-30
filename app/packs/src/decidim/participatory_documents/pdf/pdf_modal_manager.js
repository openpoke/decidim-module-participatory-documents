import initLanguageChangeSelect from "src/decidim/admin/choose_language";

/* eslint-disable no-alert */
export default class PdfModalManager {
  constructor(options) {
    this.i18n = options.i18n;
    this.editSectionPath = options.editSectionPath;
    this.annotationsPath = options.annotationsPath;
    this.pdfViewer = options.pdfViewer;
    this.csrfToken = options.csrfToken;
    // UI
    this.modal = document.getElementById("editor-modal");
    this.modalContent = document.getElementById("editor-modal-content");
    this.modalWrapper = this.modal.querySelector(".form__wrapper");
    // events
    this.onSave = () => {};
    this.onDestroy = () => {};
    this.onError = () => {};
    this.onCancel = () => {};
  }

  loadBoxModal(box) {
    fetch(this.editSectionPath(box.section), {
      method: "GET",
      headers: {
        "X-CSRF-Token": this.csrfToken
      },
      credentials: "include"
    }).
      then((response) => {
        if (response.ok) {
          return response.text();
        }
        throw new Error(response.statusText);
      }).
      then((data) => this.populateModal(data, box)).
      catch((error) => this.onError(box, error));
  }

  populateModal(data, box) {
    this.modalWrapper.innerHTML = data;
    const uiSave = document.getElementById("editor-modal-save");
    const uiTitle = document.getElementById("editor-modal-title");
    const uiRemove = document.getElementById("editor-modal-remove");
    uiTitle.innerHTML = this.i18n.modalTitle.replace("%{box}", box.div.dataset.position).replace("%{section}", box.div.dataset.sectionNumber);
    // this.modal.addEventListener("click", (evt) => evt.stopPropagation(), { once: true });
    uiRemove.addEventListener("click", (evt) => this._removeHandler(box, evt), { once: true });
    uiSave.addEventListener("click", (evt) => this._saveHandler(box, evt), { once: true });
    this.openModal(box);
    // Admin in 0.28 still uses foundation to handle tabs
    $(this.modalWrapper).foundation();
    initLanguageChangeSelect(document.querySelectorAll("select.language-change"));
  }

  openModal() {
    window.Decidim.currentDialogs[this.modal.id].open();
  }

  closeModal() {
    window.Decidim.currentDialogs[this.modal.id].close();
  }

  createBox(box, page) {
    let body = box.getInfo();
    body.page_number = page; // eslint-disable-line camelcase

    fetch(this.annotationsPath, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": this.csrfToken
      },
      credentials: "include",
      body: JSON.stringify(body)
    }).
      then((response) => {
        if (response.ok) {
          return response.json();
        }
        throw new Error(response.statusText);
      }).
      then((resp) => {
        box.setInfo();
        this.modalContent.classList.remove("loading");
        this.closeModal();
        this.onSave(box, resp.data);
      }).
      catch((error) => {
        console.error("Error creating box, destroy it", error);
        this.modalContent.classList.remove("loading");
        this.closeModal();
        box.destroy();
        this.onError(box, error);
      });
  }

  _saveHandler(box, evt) {
    evt.stopPropagation();
    this.modalContent.classList.add("loading");
    let form = this.modal.querySelector("form");

    fetch(form.action, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": this.csrfToken
      },
      credentials: "include",
      body: new FormData(form)
    }).
      then((response) => {
        if (response.ok) {
          return response.json();
        }
        throw new Error(response.statusText);
      }).
      then(() => {
        this.createBox(box, this.pdfViewer.currentPageNumber);
      }).
      catch((error) => {
        console.error("Error saving box", error);
        this.modalContent.classList.remove("loading");
        this.populateModal(error, box);
      });
  }

  _removeHandler(box, evt) {
    evt.stopPropagation();

    if (confirm(this.i18n.removeBoxConfirm)) {
      // Do not call ajax if not persisted
      if (box.isPersisted()) {
        fetch(`${this.annotationsPath}/${box.id}`, {
          method: "DELETE",
          headers: {
            "X-CSRF-Token": this.csrfToken
          },
          credentials: "include"
        }).
          then((response) => {
            if (response.ok) {
              return response.json();
            }
            throw new Error(response.statusText);
          }).
          then(() => {
            box.destroy();
            this.onDestroy(box);
          }).
          catch((error) => {
            this.onError(box, error);
          });
      } else {
        box.destroy();
      }
    }
    this.closeModal();
  }
}
