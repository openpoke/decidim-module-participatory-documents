export default class PdfStateManager {
  constructor() {
    this.changes = [];
    this.evtAdded = false;
    window.PdfDocStateManager = this;
  }

  beforeUnload(evt) {
    evt.preventDefault();
    if (!window.PdfDocStateManager.isEmpty()) {
      evt.returnValue = "Are you sure you want to exit?";
      return evt;
    } 
    return false;
    
  }

  setModifiedState(box) {
    let index = this.changes.indexOf(box.id);
    if (index === -1) {
      this.changes.push(box.id);
      this.setDirty();
    } else {
      this.changes.splice(index, 1);
      this.reset();
    }
  }

  setDirty() {
    if (this.evtAdded === false) {
      this.evtAdded = false
      window.addEventListener("beforeunload", this.beforeUnload, { capture: true });
    }
  }

  isEmpty() {
    return this.changes.length === 0;
  }

  reset() {
    if (this.evtAdded && this.isEmpty()) {
      window.removeEventListener("beforeunload", this.beforeUnload, { capture: true });
    }
  }
}
