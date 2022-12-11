import BoxArea from "./box_area";

export default class PolygonViewer {
  constructor(i18n, div, json) {
    this.div = div;
    this.json = json && json.length && json || [];
    this.boxes = {};
    this.i18n = i18n;
    // events
    this.onBoxClick = () => {};
    this.onBoxBlur = () => {};
    this.onBoxEnter = () => {};
    this.onBoxLeave = () => {};
    this.onBoxDestroy = () => {};
    this.onBoxChange = () => {};
    this.init();
  }

  init() {
    this.div.style.pointerEvents = "all";
    this.div.classList.add("polygon-ready");
    this.json.forEach((box) => {
      this.boxes[box.id] = new BoxArea(this, box);
      this.bindBoxEvents(this.boxes[box.id]);
    });
  }

  // return all boxes in this layer
  getBoxes() {
    return Object.keys(this.boxes).map((id) => this.boxes[id]);
  }

  bindBoxEvents(box) {
    box.onClick = (evt) => this.onBoxClick(box, evt);
    box.onBlur = (evt) => this.onBoxBlur(box, evt);
    box.onEnter = (evt) => this.onBoxEnter(box, evt);
    box.onLeave = (evt) => this.onBoxLeave(box, evt);
    box.onDestroy = (evt) => this.onBoxDestroy(box, evt);
    box.onChange = (evt) => this.onBoxChange(box, evt);
  }

  blockBoxes() {
    this.div.querySelectorAll(".box").forEach((div) => div.classList.add("blocked"));
  }

  unBlockBoxes() {
    this.div.querySelectorAll(".box").forEach((div) => div.classList.remove("blocked"));
  }
}
