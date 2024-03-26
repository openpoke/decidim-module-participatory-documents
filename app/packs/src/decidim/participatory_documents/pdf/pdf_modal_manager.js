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
    this.modalContent = this.modal.querySelector(".form__wrapper");
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
    this.modalContent.innerHTML = data;
    this.displayModal(box);
  }

  displayModal(box) {
    const uiSave = document.getElementById("editor-modal-save");
    const uiClose = document.querySelector('[data-dialog-close="editor-modal"]');
    const uiTitle = document.getElementById("editor-modal-title");
    const uiRemove = document.getElementById("editor-modal-remove");
    uiTitle.innerHTML = this.i18n.modalTitle.replace("%{box}", box.div.dataset.position).replace("%{section}", box.div.dataset.sectionNumber);

    window.Decidim.currentDialogs[this.modal.id].open();

    // this.modal.addEventListener("click", (evt) => evt.stopPropagation(), { once: true });
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
        throw new Error(response.statusText);
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
    let form = this.modal.querySelector("form");
console.log("saving", form)

    fetch(form.action, {
      method: "PATCH",
      headers: {
        // "Content-Type": form.encoding,
        // "Accept": "application/json",
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
      then((resp) => {
        this.createBox(box, this.pdfViewer.currentPageNumber);
      }).
      catch((error) => {
        console.error("Error saving box, removing it from the UI", error);
        this.populateModal(error, box);
      });


    // $.ajax({
    //   type: $form.attr("method"),
    //   url: $form.attr("action"),
    //   data: $form.serialize()
    // }).done(() => {
    //   this.createBox(box, this.pdfViewer.currentPageNumber);
    // }).
    //   fail((data) => this.populateModal(data.responseText, box));
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
  }
}
