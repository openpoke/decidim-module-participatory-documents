export default class BoxControlGroup {
  constructor(control) {
    this.control = control;
    this.box = control.box;
    this.layer = control.box.layer;
    this.div = document.createElement("div");
    this.div.classList.add("control", "group");
    this.div.title = this.layer.i18n.group;
    this.control.div.appendChild(this.div);
    this._bindEvents();
  }

  _bindEvents() {
    this.div.addEventListener("click", this._startGrouping.bind(this));
    this.groupBoxHandler = this._groupBox.bind(this);
    this.box.div.addEventListener("click", this.groupBoxHandler);
  }

  _startGrouping(evt) {
    evt.stopPropagation();
    if (this.box.div.classList.contains("grouping")) {
      this._stopGrouping(evt);
      return;
    }
    this.box.div.classList.add("grouping");
    document.querySelectorAll(".polygon-ready .box").forEach((div) => {
      // just in case
      if (div.id !== this.box.div.id) {
        div.classList.remove("grouping", "mark-group", "focus");
      }
      if (div.dataset.sectionNumber === this.box.div.dataset.sectionNumber) {
        div.classList.add("mark-group");
      }
    });
    // Set all layers with the grouping property so we can join boxes in different layers
    document.querySelectorAll(".polygon-ready").forEach((div) => {
      div.classList.add("grouping");
      div.dataset.groupBoxId = this.box.div.id;
      div.dataset.groupBoxSection = this.box.div.dataset.section;
      div.dataset.groupBoxNumber = this.box.div.dataset.sectionNumber;
    });
    window.addEventListener("click", this._stopGrouping.bind(this), { once: true });
    window.addEventListener("keydown", (keyEvent) => {
      if (keyEvent.key === "Escape" || keyEvent.keyCode === 27) {
        this._stopGrouping(keyEvent);
      }
    }, { once: true });
    console.log("start grouping", evt, this);
  }

  _stopGrouping(evt) {
    evt.stopPropagation();
    this.box.div.removeEventListener("click", this.groupBoxHandler);
    document.querySelectorAll(".polygon-ready .box").forEach((div) => div.classList.remove("mark-group", "hover", "blocked", "grouping", "focus"));
    document.querySelectorAll(".polygon-ready").forEach((div) => div.classList.remove("grouping"));
    console.log("stop grouping", evt, this);
  }

  _groupBox(evt) {
    console.log("group box", this)
    evt.stopPropagation();
    if (this.box.isGrouping() && this.layer.div.dataset.groupBoxId !== this.box.div.id) {
      if (this.box.div.dataset.sectionNumber === this.layer.div.dataset.groupBoxNumber) {
        this.box.div.classList.remove("mark-group");
        if (this.box.sectionNumber === parseInt(this.layer.div.dataset.groupBoxNumber, 10)) {
          console.log("reset to original", this.box)
          // reset section to the original
          this.box.setSection(-1);
        } else {
          this.box.setSection(this.box.section, this.box.sectionNumber);
        }
      } else {
        this.box.div.classList.add("mark-group");
        this.box.setSection(this.layer.div.dataset.groupBoxSection, this.layer.div.dataset.groupBoxNumber);
      }
      this.box.onChange();
      console.log("group this", this.layer.div.dataset.groupBoxId, this.box.div.id, evt, this.box.div.dataset.sectionNumber);
    }
  }
}
