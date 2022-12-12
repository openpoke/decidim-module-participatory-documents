export default class PdfStateManager {
  constructor() {
    this.changes = [];
    this.evtAdded = false;
  }

  beforeUnload(evt) {
    evt.preventDefault();
    if (!this.isEmpty()) {
      evt.returnValue = "Are you sure you want to exit?";
      return evt;
    } 
    return false;
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

  // setModifiedState(box) {
  //   let index = this.changes.indexOf(box.id);
  //   if (index === -1) {
  //    this.add(box);
  //   } else {
  //   }
  // }

  setDirty() {
    if (this.evtAdded === false) {
      this.evtAdded = false
      window.addEventListener("beforeunload", this.beforeUnload.bind(this), { capture: true });
    }
  }

  isEmpty() {
    return this.changes.length === 0;
  }

  reset() {
    if (this.evtAdded && this.isEmpty()) {
      window.removeEventListener("beforeunload", this.beforeUnload.bind(this), { capture: true });
    }
  }
}
