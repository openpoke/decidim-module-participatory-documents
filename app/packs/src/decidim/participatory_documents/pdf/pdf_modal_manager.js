/* eslint-disable no-alert */
export default class PdfModalManager {
  constructor(options) {
    this.i18n = options.i18n;
    this.editSectionPath = options.editSectionPath;
    this.sectionPath = options.sectionPath;
    this.annotationsPath = options.annotationsPath;
    this.pdfViewer = options.pdfViewer;
    this.csrfToken = options.csrfToken;
    // UI
    this.$modalLayout = $("#decidim");
    // events
    this.onSave = () => {};
    this.onError = () => {};
    this.onCancel = () => {};
  }

  loadBoxModal(box) {
    $.ajax({
      url: this.editSectionPath(box.section),
      type: "GET"
    }).done((data) => this.populateModal(data, box)).
      fail((error) => this.onError(box, error)).
      always(() => {});
  }

  populateModal(data, box) {
    this.$modalLayout.html(data);
    this.displayModal(box);
  }

  displayModal(box) {
    const uiSave = document.getElementById("editor-modal-save");
    const uiClose = document.getElementById("editor-modal-close");
    const uiTitle = document.getElementById("editor-modal-title");
    const uiRemove = document.getElementById("editor-modal-remove");
    uiTitle.innerHTML = `Edit box ${box.id}, section ${box.section}`;

    this.$modalLayout.addClass("show");
    this.$modalLayout.foundation();

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
    let form = this.$modalLayout.find("form");

    $.ajax({
      type: form.attr("method"),
      url: form.attr("action"),
      data: form.serialize()
    }).done(() => {
      this.$modalLayout.removeClass("show");
      this.createBox(box, this.pdfViewer.currentPageNumber);
    }).
      fail((data) => this.populateModal(data.responseText, box));
  }

  _removeHandler(box, evt) {
    evt.stopPropagation();

    if (confirm(this.i18n.removeBoxConfirm)) {
      console.log("remove box", box)
      // Do not call ajax if not persisted
      if (box.id) {
        $.ajax({
          url: this.sectionPath(box.section),
          type: "DELETE"
        }).done(() => {
          this.pdfViewer._pages.
            filter((page) => page.boxEditor && Object.keys(page.boxEditor.boxes).length > 0).
            forEach((page) => {
              return Object.values(page.boxEditor.boxes).filter((item) => item.section === box.section).map((item) => {
                Reflect.deleteProperty(item.layer.boxes, item.id);
                return item.destroy();
              });
            });
        }).
          fail((resp) => {
            this.onError(box, resp);
          }).
          always(() => {});
      } else {
        Reflect.deleteProperty(box.layer.boxes, box.id);
        box.destroy();
      }
      this.$modalLayout.removeClass("show");
    }
  }

  _closeHandler(evt) {
    evt.stopPropagation();
    this.$modalLayout.removeClass("show");
  }
}
