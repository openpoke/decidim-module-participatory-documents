import Box from "./box";

export default class PolygonViewer {
  constructor(div, json, options) {
    this.div = div;
    this.json = json && json.length && json || [];
    this.boxes = {};
    this.i18n = options.i18n;
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
    // we don't handle pointer events here so links are clickable
    // each box will handle its own evens
    this.div.style.pointerEvents = "none";
    this.div.classList.add("polygon-ready");
    this.json.forEach((box) => {
      this.addBox(new Box(this, box));
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

  addBox(box) {
    this.boxes[box.id] = box;
  }
}
