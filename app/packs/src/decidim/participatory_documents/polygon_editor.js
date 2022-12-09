import PolygonViewer from "./polygon_viewer";
import BoxArea from "./box_area";

export default class PolygonEditor extends PolygonViewer {
  constructor(div, boxes) {
    super(div, boxes);
    this.div.classList.add("admin");
    this.box = null;
    this.creating = false;
    this.blocked = false;
    this.top = 0;
    this.left = 0;
  }

  init() {
    super.init();
    // add controls to existing boxes
    this.getBoxes().map((box) => box.createControls());
    this.div.removeEventListener("mousedown", this._mouseDown.bind(this));
    this.div.removeEventListener("mousemove", this._mouseMove.bind(this));
    this.div.removeEventListener("mouseup", this._mouseUp.bind(this));
    this.div.addEventListener("mousedown", this._mouseDown.bind(this));
    this.div.addEventListener("mousemove", this._mouseMove.bind(this));
    this.div.addEventListener("mouseup", this._mouseUp.bind(this));
  }

  _mouseDown(e) {
    if (!this.creating && !this.blocked) {
      this.blockBoxes();
      this.box = this._createBoxFromMouseEvent(e);
      this.creating = true;
      this.left = this.div.getBoundingClientRect().x;
      this.top = this.div.getBoundingClientRect().y;
      // disable mouse events on all children
      console.log("mousedown", "e", e,  "this", this, "box div", this.box.div);
    }
  }

  _mouseMove(e) {
    if (!this.blocked && this.creating && this.box) {
      let w = e.clientX - this.left - 9;
      let h = e.clientY - this.top - 9;
      let boxPercentLeft = parseInt(this.box.div.style.left);
      let boxPercentTop = parseInt(this.box.div.style.top);
      let mousePercentLeft = 100 * w / this.div.clientWidth;
      let mousePercentTop = 100 * h / this.div.clientHeight;
      this.box.div.style.width = `${mousePercentLeft - boxPercentLeft}%`;
      this.box.div.style.height = `${mousePercentTop - boxPercentTop}%`;
      // console.log('mousemove', e,"mousePercent", mousePercentLeft,mousePercentTop, "box",this.box);
    }
  }
  
  _mouseUp() {
    if (!this.blocked && this.creating && this.box) {
      this.box.div.classList.remove("creating");
      if (this.box.div.clientWidth <= 5 && this.box.div.clientHeight <= 5) {
        this.box.div.remove();
        this.box = null;
      } else {
        this._initBox();
      }
      // console.log('mouseup', e, "box", this.box.div);
      this.creating = false;
      this.unBlockBoxes();
    }
  }

  _createBoxFromMouseEvent(e) {
    const {left, top} = this.div.getBoundingClientRect();
    let w = e.clientX - left - 3;
    let h = e.clientY - top - 3;
    let mousePercentLeft = (100 * w / this.div.clientWidth)
    let mousePercentTop = (100 * h / this.div.clientHeight)

    return new BoxArea(this, { rect: { left: mousePercentLeft, top: mousePercentTop} });
  }

  _initBox() {
    if (!this.boxes[this.box.id]) {
      this.box.createControls();
      this.bindBoxEvents(this.box);
      this.box.setInfo();
      this.boxes[this.box.id] = this.box;
    }
  }
}
