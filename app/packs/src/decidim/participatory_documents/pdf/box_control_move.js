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

  _startMoving(evt) {
    evt.stopPropagation();
    this.box.div.classList.add("moving");
    this.left = this.layer.div.getBoundingClientRect().x + evt.layerX;
    // We need to substract the controls height because is aligned at the bottom
    this.top = this.layer.div.getBoundingClientRect().y + this.box.div.clientHeight - this.div.clientHeight + evt.layerY;
    // Binding mouseup and mousemove to the entire window so it works even if the mouse is outside the box
    window.addEventListener("mouseup", this._stopMoving.bind(this), { once: true });
    window.addEventListener("mousemove", this._move.bind(this));
    console.log("start moving", evt, this.box.div.style.left, this.box.div.style.top, this);
  }

  _stopMoving(evt) {
    evt.stopPropagation();
    window.removeEventListener("mousemove", this._move.bind(this));
    // delay removing the moving class to avoid triggering the click event in the box
    setTimeout(() => {
      this.box.setInfo();
      this.box.div.classList.remove("moving")
    }, 100);
    console.log("stop moving", evt, this);
  }

  _move(evt) {
    if (this.box.isMoving()) {
      evt.stopPropagation();
      let width = evt.clientX - this.left;
      let height = evt.clientY - this.top;
      let mousePercentLeft = (100 * width / this.layer.div.clientWidth)
      let mousePercentTop = (100 * height / this.layer.div.clientHeight)
      this.box.div.style.left = `${mousePercentLeft}%`;
      this.box.div.style.top = `${mousePercentTop}%`;
      // console.log("moving", evt, mousePercentLeft, mousePercentTop, this);
    }
  }
}
