export default class PdfStateManager {
  constructor() {
    this.changes = [];
    this.evtAdded = false;
  }

  beforeUnload(evt) {
    evt.preventDefault();
    if (PdfDocStateManager.changes.length > 0){
      return evt.returnValue = "Are you sure you want to exit?";
    } else {
      return false;
    }
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

  setDirty(){
    if (this.evtAdded === false) {
      this.evtAdded = false
      window.addEventListener("beforeunload", this.beforeUnload, { capture: true });
    }
  }

  reset() {
    if (this.evtAdded && this.changes.length === 0){
      window.removeEventListener("beforeunload", this.beforeUnload, { capture: true });
    }
  }
}