import BoxControls from "./box_controls";

export default class Box {
  constructor(layer, json) {
    this.layer = layer;
    this.json = json || { rect: {} };
    this.id = this.json.id;
    this.section = this.json.section;
    this.createBox(this.id, this.json.position, this.json.rect);
    this.setInfo();
    this._bindEvents();
    // console.log("box constructor", this);
    // events
    this.onClick = () => {};
    this.onBlur = () => {};
    this.onEnter = () => {};
    this.onLeave = () => {};
    this.onDestroy = () => {};
    this.onChange = () => {};
  }

  // Creates a box using percentanges, with and height are optional
  createBox(id, position, {left, top, width, height}) {
    this.div = document.createElement("div");
    this.div.draggable = false;
    this.div.id = `box-${id || Date.now()}`;
    this.div.dataset.position = position || this._getNextPosition();
    this.div.dataset.section = this.section;
    this.div.classList.add("box");
    this.div.style.left = `${this._sanitizePercent(left)}%`;
    this.div.style.top = `${this._sanitizePercent(top)}%`;
    // if width is not defined will use 15%
    this.div.style.width = `${this._sanitizePercent(width, 0, 100 - parseFloat(left)) || 15}%`;
    this.div.style.height = `${this._sanitizePercent(height, 0, 100 - parseFloat(top)) || 15}%`;
    console.log(width, this.div.style.width)
    this.layer.div.appendChild(this.div);
  }

  // setGroup(section) {
  //   this.group = `group-${section || Date.now()}`;
  //   this.div.dataset.boxGroup = this.group;
  // }

  createControls() {
    this.controls = new BoxControls(this);
    this.resize = new ResizeObserver(this._resize.bind(this));
    this.resize.observe(this.div);
  }

  getRect() {
    return {
      left: parseFloat(this.div.style.left) || 0,
      top: parseFloat(this.div.style.top) || 0,
      width: this._ensureCssPercent(this.div.style.width, this.div.ClientWidth),
      height: this._ensureCssPercent(this.div.style.height, this.div.ClientHeight)
    }
  }

  getInfo() {
    return {
      id: this.id,
      section: this.section,
      rect: this.getRect()
    }
  }

  setInfo(info) {
    this.previousInfo = info || this.getInfo();
  }

  isMoving() {
    return this.div.classList.contains("moving");
  }

  isGrouping() {
    return document.querySelectorAll(".polygon-ready .box.grouping").length
  }

  isResizing() {
    return this.div.classList.contains("resizing");
  }

  _getNextPosition() {
    return Object.keys(this.layer.boxes).length  + 2;
  }

  _ensureCssPercent(num, max) {
    if (num.indexOf("%") !== -1) {
      return parseFloat(num);
    }
    return this._sanitizePercent(100 * parseFloat(num) / max)

  }

  _sanitizePercent(num, min = 0, max = 100) {
    return Math.min(Math.max(parseFloat(num), min), max);
  }

  _bindEvents() {
    this.div.addEventListener("mouseenter", this._mouseEnter.bind(this));
    this.div.addEventListener("mouseleave", this._mouseLeave.bind(this));
    this.div.addEventListener("mouseup", this._mouseUp.bind(this));
    this.div.addEventListener("click", this._click.bind(this));
  }

  _click(evt) {
    if (!this.layer.creating && !this.isMoving() && !this.isGrouping() && !this.isResizing()) {
      console.log("box click", evt);
      evt.stopPropagation();
      this.onClick(evt);
      window.addEventListener("click", this._blur.bind(this), {once: true});
    }
  }

  _blur(evt) {
    if (!this.layer.creating) {
      this.onBlur(evt);
    }
  }

  _mouseEnter(evt) {
    if (!this.layer.creating && !this.isGrouping()) {
      this.blockSibilings();
      this.div.classList.add("hover");
      this.focusGroup();
      this.onEnter(evt);
      // console.log("box mousenter", evt, "widht/height", this.div.style.width, this.div.style.height);
    }
  }

  _mouseLeave(evt) {
    if (!this.layer.creating && !this.isGrouping()) {
      this.div.classList.remove("hover");
      this.blurGroup()
      this.unBlockSibilings();
      this.onLeave(evt);
      // console.log("box mouseleave", evt);
    }
  }

  _mouseUp() {
    if (!this.layer.creating) {
      // delay changing resizing status to avoid triggering the click event in the box
      setTimeout(() => this.div.classList.remove("resizing"), 100);
      if (this.hasChanged()) {
        this.onChange();
      }
    }
  }

  _resize(entries) {
    if (!this.layer.creating && this.div.classList.contains("hover")) {
      this.div.classList.add("resizing")
      let width = `${100 * entries[0].contentRect.width / this.layer.div.clientWidth}%`;
      let height = `${100 * entries[0].contentRect.height / this.layer.div.clientHeight}%`;
      // console.log("box resize", entries, this.div.style.width, this.div.style.height, "calculated", width, height);
      this.div.style.width = width;
      this.div.style.height = height;
      // We need to record changes about the dimensions}
      this.setInfo();
    }
  }


  hasChanged() {
    if (JSON.stringify(this.getInfo()) !== JSON.stringify(this.previousInfo)) {
      this.previousInfo = this.getInfo();
      return true;
    }
    return false;
  }

  // Not using getNodes because groups can span across layers
  focusGroup() {
    document.querySelectorAll(".polygon-ready .box").forEach((div) => div.dataset.section === this.section && div.classList.add("focus"));
  }

  blurGroup() {
    document.querySelectorAll(".polygon-ready .box").forEach((div) => div.classList.remove("focus"));
  }

  blockSibilings() {
    this.layer.blocked = true;
    this.layer.div.querySelectorAll(".box").forEach((div) => div.id !== this.div.id && div.classList.add("blocked"));
  }

  unBlockSibilings() {
    this.layer.blocked = false;
    this.layer.div.querySelectorAll(".box").forEach((div) => div.classList.remove("blocked"));
  }

  destroy() {
    this.div.remove();
    this.resize.disconnect();
    this.onDestroy();
  }
}
