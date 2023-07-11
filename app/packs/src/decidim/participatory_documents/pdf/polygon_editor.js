import PolygonViewer from "./polygon_viewer";
import Box from "./box";

export default class PolygonEditor extends PolygonViewer {
  constructor(div, boxes, options) {
    super(div, boxes, options);
    this.div.classList.add("admin");
    this.box = null;
    this.creating = false;
    this.top = 0;
    this.left = 0;
  }

  init() {
    super.init();
    // The editor needs to draw boxes over the underlying layer
    // this effectively disables pointer events on the layer (so links are not clickable).
    // But that's okey for the editor, it's for creating the boxes.
    this.div.style.pointerEvents = "all";
    // add controls to existing boxes
    this.getBoxes().map((box) => box.createControls());
    this.div.addEventListener("mousedown", this._mouseDown.bind(this));
    this.div.addEventListener("mousemove", this._mouseMove.bind(this));
    this.div.addEventListener("mouseup", this._mouseUp.bind(this));
  }

  isBlocked() {
    return this.div.classList.contains("blocked");
  }

  removeBox(box) {
    Reflect.deleteProperty(this.boxes, box.id);
  }

  _mouseDown(evt) {
    if (!this.creating && !this.isBlocked()) {
      this.blockBoxes();
      this.box = this._createBoxFromMouseEvent(evt);
      this.creating = true;
      this.left = this.div.getBoundingClientRect().x;
      this.top = this.div.getBoundingClientRect().y;
      // disable mouse events on all children
      console.log("mousedown", "evt", evt,  "this", this, "box div", this.box.div);
    }
  }

  _mouseMove(evt) {
    if (!this.isBlocked() && this.creating && this.box) {
      let width = evt.clientX - this.left - 9;
      let height = evt.clientY - this.top - 9;
      let boxPercentLeft = parseInt(this.box.div.style.left, 10);
      let boxPercentTop = parseInt(this.box.div.style.top, 10);
      let mousePercentLeft = 100 * width / this.div.clientWidth;
      let mousePercentTop = 100 * height / this.div.clientHeight;
      this.box.div.style.width = `${mousePercentLeft - boxPercentLeft}%`;
      this.box.div.style.height = `${mousePercentTop - boxPercentTop}%`;
      // console.log('mousemove', evt,"mousePercent", mousePercentLeft,mousePercentTop, "box",this.box);
    }
  }
  
  _mouseUp() {
    if (!this.isBlocked() && this.creating && this.box) {
      this.box.div.classList.remove("creating");
      if (this.box.div.clientWidth <= 5 && this.box.div.clientHeight <= 5) {
        this.box.div.remove();
        this.box = null;
      } else {
        this._initBox();
      }
      // console.log('mouseup', evt, "box", this.box.div);
      this.creating = false;
      this.unBlockBoxes();
    }
  }

  _createBoxFromMouseEvent(evt) {
    const {left, top} = this.div.getBoundingClientRect();
    let width = evt.clientX - left - 3;
    let height = evt.clientY - top - 3;
    let mousePercentLeft = 100 * width / this.div.clientWidth;
    let mousePercentTop = 100 * height / this.div.clientHeight;
    // % corresponding to 1px
    width = 1 / this.div.clientWidth;
    height = 1 / this.div.clientHeight;

    return new Box(this, { rect: { left: mousePercentLeft, top: mousePercentTop, width: width, height: height} });
  }

  _initBox() {
    console.log("init box", this.box)
    if (!this.boxes[this.box.id]) {
      this.box.createControls();
      this.bindBoxEvents(this.box);
      this.box.setInfo();
      this.box.onChange();
      this.boxes[this.box.id] = this.box;
    }
  }
}
