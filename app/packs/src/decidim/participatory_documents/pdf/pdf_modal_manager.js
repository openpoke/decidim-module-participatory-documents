/* eslint-disable no-alert */
export default class PdfModalManager {
  constructor(options) {
    this.newSectionPath = options.newSectionPath;
    this.i18n = options.i18n;
    this.editSectionPath = options.editSectionPath;
    this.sectionPath = options.sectionPath;
    this.annotationsPath = options.annotationsPath;
    this.$modalLayout = $("#decidim");
    this.pdfViewer = options.pdfViewer;
    this.showInfo = options.showInfo;
    this.showAlert = options.showAlert;
    this.csrfToken = options.csrfToken;
    // events
    this.onSave = () => {};
    this.onCancel = () => {};
  }

  loadBoxModal(box) {
    $.ajax({
      url: this.editSectionPath(box.section),
      type: "GET"
    }).done((data) => this.populateModal(data, box)).
      fail(() => this.loadNewGroupModal(box)).
      always(() => {});
  }

  loadNewGroupModal(box) {
    $.ajax({
      url: this.newSectionPath,
      type: "GET"
    }).done((data) => this.populateModal(data, box));
  }

  populateModal(data, box) {
    this.$modalLayout.html(data);
    this.displayModal(box);
  }

  displayModal(box) {
    const close = document.getElementById("editor-modal-close");
    const title = document.getElementById("editor-modal-title");
    const remove = document.getElementById("editor-modal-remove");

    title.innerHTML = `Edit box ${box.id}, section ${box.section}`;

    this.$modalLayout.addClass("show");
    this.$modalLayout.foundation();

    this.registerSaveHandler(box);

    close.addEventListener("click", (evt) => {
      evt.stopPropagation();
      this.$modalLayout.removeClass("show");
    }, { once: true });

    remove.addEventListener("click", (evt) => {
      evt.stopPropagation();

      if (confirm(this.i18n.removeBoxConfirm)) {
        $.ajax({
          url: this.sectionPath(box.section),
          type: "DELETE"
        }).done(() => {
          this.pdfViewer._pages.
            filter((page) => page.boxEditor).
            filter((page) => Object.keys(page.boxEditor.boxes).length > 0).
            forEach((page) => {
              return Object.values(page.boxEditor.boxes).filter((item) => item.section === box.section).map(() => {
                Reflect.deleteProperty(page.layer.boxes, box.id);
                return box.destroy();
              });
            });
        }).
          fail((resp) => {
            this.showAlert(resp.responseText);
            box.destroy();
          }).
          always(() => {});
        this.$modalLayout.removeClass("show");
      }
    }, { once: true });
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
      then((data) => {
        box.setInfo();
        this.onSave(box, data);
        this.showInfo(this.i18n.created);
      }).
      catch((error) => {
        console.error("Error creating box, removing it from the UI", error);
        box.destroy();
        this.showAlert(this.i18n.operationFailed);
      });
  }

  registerSaveHandler(box) {
    const save = document.getElementById("editor-modal-save");
    save.addEventListener("click", (evt) => {
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
    }, { once: true });
  }
}
