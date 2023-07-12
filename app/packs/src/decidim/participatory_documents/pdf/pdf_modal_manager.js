/* eslint-disable no-alert */
export default class PdfModalManager {
  constructor(options) {
    this.i18n = options.i18n;
    this.editSectionPath = options.editSectionPath;
    this.annotationsPath = options.annotationsPath;
    this.pdfViewer = options.pdfViewer;
    this.csrfToken = options.csrfToken;
    // UI
    this.modalLayout = document.getElementById("decidim");
    this.modalLayout.addEventListener("click", this._closeHandler.bind(this));
    // events
    this.onSave = () => {};
    this.onDestroy = () => {};
    this.onError = () => {};
    this.onCancel = () => {};
  }

  loadBoxModal(box) {
    $.ajax({
      url: this.editSectionPath(box.section),
      type: "GET"
    }).done((data) => this.populateModal(data, box)).
      fail((error) => this.onError(box, error));
  }

  populateModal(data, box) {
    this.modalLayout.innerHTML = data;
    this.displayModal(box);
  }

  displayModal(box) {
    const modal = document.getElementById("editor-modal");
    const uiSave = document.getElementById("editor-modal-save");
    const uiClose = document.getElementById("editor-modal-close");
    const uiTitle = document.getElementById("editor-modal-title");
    const uiRemove = document.getElementById("editor-modal-remove");
    uiTitle.innerHTML = this.i18n.modalTitle.replace("%{box}", box.div.dataset.position).replace("%{section}", box.sectionNumber);

    this.modalLayout.classList.add("show");
    $(this.modalLayout).foundation();

    modal.addEventListener("click", (evt) => evt.stopPropagation(), { once: true });
    uiClose.addEventListener("click", this._closeHandler.bind(this), { once: true });
    uiRemove.addEventListener("click", (evt) => this._removeHandler(box, evt), { once: true });
    uiSave.addEventListener("click", (evt) => this._saveHandler(box, evt), { once: true });
  }

  createBox(box, page) {
    let body = box.getInfo();
    body.pageNumber = page;

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
        throw new Error(" ");
      }).
      then((resp) => {
        box.setInfo();
        this.onSave(box, resp.data);
      }).
      catch((error) => {
        console.error("Error creating box, removing it from the UI", error);
        box.destroy();
        this.onError(box, error);
      });
  }

  _saveHandler(box, evt) {
    evt.stopPropagation();
    let $form = $(this.modalLayout).find("form");

    $.ajax({
      type: $form.attr("method"),
      url: $form.attr("action"),
      data: $form.serialize()
    }).done(() => {
      this.modalLayout.classList.remove("show");
      this.createBox(box, this.pdfViewer.currentPageNumber);
    }).
      fail((data) => this.populateModal(data.responseText, box));
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
            throw new Error(" ");
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
      this.modalLayout.classList.remove("show");
    }
  }

  _closeHandler(evt) {
    evt.stopPropagation();
    this.modalLayout.classList.remove("show");
  }
}
