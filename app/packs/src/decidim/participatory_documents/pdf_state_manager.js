export default class PdfStateManager {
  constructor() {
    this.changes = [];
    this.evtAdded = false;
  }

  beforeUnload(evt) {
    if (!this.isEmpty()) {
      evt.returnValue = "Are you sure you want to exit?";
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
      window.removeEventListener("beforeunload", this.beforeUnload.bind(this), { capture: true });
    }
  }
}
