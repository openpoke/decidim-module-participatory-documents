/*
 * This class handles the global state of the PDF document while it is being edited.
 * It keeps track of the boxes that have been modified and it changes some UI classes
 * */
export default class PdfStateManager {
  constructor(options) {
    this.changes = [];
    this.element = options.saveButton;
    this.i18n = options.i18n;
    this.csrfToken = options.csrfToken;
    this.pdfViewer = options.pdfViewer;
    this.annotationsPath = options.annotationsPath;
    this.bindEvents();
    // events
    this.onSave = () => {};
    this.onError = () => {};
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
      if (this.isEmpty()) {
        this.reset();
      }
    }
  }

  destroy(box) {
    this.remove(box);
    this.pdfViewer._pages.
      filter((page) => page.boxEditor).
      forEach((page) => page.boxEditor.removeBox(box));
  }

  isEmpty() {
    return this.changes.length === 0;
  }

  bindEvents() {
    this.element.addEventListener("click", this._saveHandler.bind(this));
  }

  setDirty() {
    // console.log("setDirty", this)
    if (this.element) {
      this.element.classList.add("alert");
    }
    if (!this.beforeUnloadHandler) {
      // create a global reference to ensure the method is the same on adding and removing
      this.beforeUnloadHandler = this._beforeUnload.bind(this);
      window.addEventListener("beforeunload", this.beforeUnloadHandler, { capture: true });
    }
  }

  reset() {
    this.changes = [];
    if (this.element) {
      this.element.classList.remove("alert");
      this.element.classList.remove("loading");
    }

    window.removeEventListener("beforeunload", this.beforeUnloadHandler, { capture: true });
    this.beforeUnloadHandler = null;
  }


  _beforeUnload(evt) {
    if (!this.isEmpty()) {
      evt.returnValue = this.i18n.confirmExit;
    }
  }

  _saveHandler(evt) {
    evt.preventDefault();
    if (this.element.classList.contains("loading")) {
      return;
    }
    this.element.classList.add("loading");
    this.processed = {};
    this.errors = {};
    this.totalBoxes = 0;
    this.finishedBoxes = 0;
    this.pdfViewer._pages.
      filter((page) => page.boxEditor).
      filter((page) => Object.keys(page.boxEditor.boxes).length > 0).
      forEach((page) => Object.values(page.boxEditor.boxes).map((box) => this._updateOrCreateBox(box, page.id)));

    if (this.totalBoxes === 0) {
      this.reset();
    }
  }

  _updateOrCreateBox(box, page) {
    let body = box.getInfo();
    body.page_number = page; // eslint-disable-line camelcase
    this.totalBoxes += 1;

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
        const current = this._currentBox(box, page);

        current.setInfo(resp.data);
        this._setProcessed(current, resp.data);
      }).
      catch((error) => {
        this._setProcessed(box, null, error);
      });
  }

  // The page layer can be rebuilt while the request is pending, the box shown is then a new object
  _currentBox(box, page) {
    const pageView = this.pdfViewer._pages[page - 1];

    return (pageView && pageView.boxEditor && pageView.boxEditor.boxes[box.id]) || box;
  }

  _setProcessed(box, data, error) {
    if (data) {
      this.processed[box.id] = data;
    } else {
      this.errors[box.id] = error;
    }

    this.finishedBoxes += 1;

    if (this.finishedBoxes === this.totalBoxes) {
      if (Object.keys(this.errors).length > 0) {
        // Some boxes are not saved, keep the unsaved changes warning
        this.element.classList.remove("loading");
        this.onError(this.errors);
      } else {
        this.reset();
        this.onSave(this.processed);
      }
    }
  }
}
