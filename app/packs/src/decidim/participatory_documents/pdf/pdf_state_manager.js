/*
 * This class handles the global state of the PDF document while it is being edited.
 * It keeps track of the boxes that have been modified and it changes some UI classes
 * */
export default class PdfStateManager {
  constructor(options) {
    this.changes = [];
    this.evtAdded = false;
    this.element = options.saveButton;
    this.i18n = options.i18n;
    this.csrfToken = options.csrfToken;
    this.pdfViewer = options.pdfViewer;
    this.annotationsPath = options.annotationsPath;
    this.bindEvents();
    // events
    this.onSave = () => {};
  }

  beforeUnload(evt) {
    if (!this.isEmpty()) {
      evt.returnValue = this.i18n.confirmExit;
    }
  }

  add(box) {
    let index = this.changes.indexOf(box.id);
    if (index === -1) {
      this.changes.push(box.id);
      this.setDirty();
    }
  }

  remove(box) {
    let index = this.changes.indexOf(box.id);
    if (index >= 0) {
      this.changes.splice(index, 1);
      this.reset();
    }
  }
  setDirty() {
    if (this.evtAdded === false) {
      console.log("setDirty")
      this.evtAdded = true;
      if (this.element) {
        this.element.classList.add("alert");
      }

      window.addEventListener("beforeunload", this.beforeUnload.bind(this), { capture: true });
    }
  }

  isEmpty() {
    return this.changes.length === 0;
  }

  reset() {
    if (this.evtAdded && this.isEmpty()) {
      this.evtAdded = false;
      console.log("reset");
      if (this.element) {
        this.element.classList.remove("alert");
      }
      window.removeEventListener("beforeunload", this.beforeUnload.bind(this), { capture: true });
    }
  }

  bindEvents() {
    this.element.addEventListener("click", this.saveHandler.bind(this));
  }

  saveHandler(evt) {
    evt.stopPropagation();

    this.pdfViewer._pages.
      filter((page) => page.boxEditor).
      filter((page) => Object.keys(page.boxEditor.boxes).length > 0).
      forEach((page) => Object.values(page.boxEditor.boxes).map((box) => this.updateOrCreateBox(box, page.id)));
  }

  updateOrCreateBox(box, page) {
    let body = box.getInfo();
    body.pageNumber = page;

    fetch(`${this.annotationsPath}/${box.id}`, {
      method: "PUT",
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
      }).
      catch((error) => {
        console.error(error);
        // createBox(box, page);
      });
  }
}
