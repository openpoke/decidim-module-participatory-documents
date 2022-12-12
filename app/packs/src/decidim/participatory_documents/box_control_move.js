export default class BoxControlMove {
  constructor(control) {
    this.control = control;
    this.box = control.box;
    this.layer = control.box.layer;
    this.left = 0;
    this.top = 0;
    this.div = document.createElement("div");
    this.div.classList.add("move-control");
    this.div.title = this.layer.i18n.move;
    this.control.div.appendChild(this.div);
    this._bindEvents();
  }

  _bindEvents() {
    this.div.addEventListener("mousedown", this._startMoving.bind(this));
  }

  _startMoving(e) {
    e.stopPropagation();
    this.box.div.classList.add("moving");
    this.left = this.layer.div.getBoundingClientRect().x + e.layerX;
    // We need to substract the controls height because is aligned at the bottom
    this.top = this.layer.div.getBoundingClientRect().y + this.box.div.clientHeight - this.div.clientHeight + e.layerY;
    // Binding mouseup and mousemove to the entire window so it works even if the mouse is outside the box
    window.addEventListener("mouseup", this._stopMoving.bind(this), { once: true });
    window.addEventListener("mousemove", this._move.bind(this));
    console.log("start moving", e, this.box.div.style.left, this.box.div.style.top, this);
  }

  _stopMoving(e) {
    e.stopPropagation();
    window.removeEventListener("mousemove", this._move.bind(this));
    // delay removing the moving class to avoid triggering the click event in the box
    setTimeout(() => {
      this.box.setInfo();
      this.box.div.classList.remove("moving")
    }, 100);
    console.log("stop moving", e, this);
  }

  _move(e) {
    if (this.box.isMoving()) {
      e.stopPropagation();
      let w = e.clientX - this.left;
      let h = e.clientY - this.top;
      let mousePercentLeft = (100 * w / this.layer.div.clientWidth)
      let mousePercentTop = (100 * h / this.layer.div.clientHeight)
      this.box.div.style.left = `${mousePercentLeft}%`;
      this.box.div.style.top = `${mousePercentTop}%`;
      // console.log("moving", e, mousePercentLeft, mousePercentTop, this);
    }
  }
}
