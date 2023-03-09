export default class BoxControlGroup {
  constructor(control) {
    this.control = control;
    this.box = control.box;
    this.layer = control.box.layer;
    this.div = document.createElement("div");
    this.div.classList.add("group-control");
    this.div.title = this.layer.i18n.group;
    this.control.div.appendChild(this.div);
    this._bindEvents();
  }

  _bindEvents() {
    this.div.addEventListener("click", this._startGrouping.bind(this));
  }

  _startGrouping(evt) {
    evt.stopPropagation();
    this.box.div.addEventListener("click", this._groupBox.bind(this));
    this.box.div.classList.add("grouping");
    document.querySelectorAll(".polygon-ready .box").forEach((div) => {
      // just in case
      if (div.id !== this.box.id) {
        div.classList.remove("grouping", "mark-group", "focus");
      }

      if (div.dataset.section === this.box.section) {
        div.classList.add("mark-group");
      }
    });
    // Set all layers with the grouping property so we can join boxes in different layers
    document.querySelectorAll(".polygon-ready").forEach((div) => {
      div.classList.add("grouping");
      div.dataset.groupBoxId = this.box.id;
      div.dataset.groupBoxSection = this.box.section;
    });
    window.addEventListener("click", this._stopGrouping.bind(this), { once: true });
    console.log("start grouping", evt, this.section);
  }

  _stopGrouping(evt) {
    evt.stopPropagation();
    this.box.div.removeEventListener("click", this._groupBox.bind(this));
    document.querySelectorAll(".polygon-ready .box").forEach((div) => div.classList.remove("mark-group", "hover", "blocked", "grouping", "focus"));
    document.querySelectorAll(".polygon-ready").forEach((div) => div.classList.remove("grouping"));
    console.log("stop grouping", evt, this);
  }

  _groupBox(evt) {
    console.log("group box", this)
    evt.stopPropagation();
    if (this.box.isGrouping() && this.layer.div.dataset.groupBoxId !== this.box.id) {
      if (this.box.section === this.layer.div.dataset.groupBoxSection) {
        this.box.div.classList.remove("mark-group");
      } else {
        this.box.div.classList.add("mark-group");
        this.box.section = this.layer.div.dataset.groupBoxSection;
        this.box.dataset.section = this.layer.div.dataset.groupBoxSection;
      }
      this.box.onChange();
      console.log("group this", this.layer.div.dataset.groupBoxId, this.box.id, evt, this.box.section);
    }
  }
}
