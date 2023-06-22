import BoxControls from "./box_controls";

export default class Box {
  constructor(layer, json) {
    this.layer = layer;
    this.json = json || { rect: {} };
    this.id = this.json.id || -Object.keys(layer.boxes).length;
    this.section = this.json.section || 0;
    this.sectionNumber = this.json.section_number || 0;
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
    this.setSection(this.section, this.sectionNumber);
    this.div.classList.add("box");
    this.div.style.left = `${this._sanitizePercent(left)}%`;
    this.div.style.top = `${this._sanitizePercent(top)}%`;
    // if width is not defined will use 15%
    this.div.style.width = `${this._sanitizePercent(width, 0, 100 - parseFloat(left)) || 15}%`;
    this.div.style.height = `${this._sanitizePercent(height, 0, 100 - parseFloat(top)) || 15}%`;

    // add the number of the box in the middle
    let span = document.createElement("span");
    span.innerHTML = this.div.dataset.position;
    this.div.appendChild(span)
    this.layer.div.appendChild(this.div);
  }

  setSection(section, sectionNumber) {
    if (section) {
      this.div.dataset.sectionNumber = sectionNumber || this._getNextSectionNumber();
      this.div.dataset.section = section;
    } else {
      // ensure a new section will be created in the next save
      this.div.dataset.sectionNumber = this.sectionNumber || this._getNextSectionNumber();
      this.div.dataset.section = this.section;
    }
  }

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
      // Section in the dataset can be manipulated by the group editor
      // this.section is always the original
      section: this.div.dataset.section,
      rect: this.getRect()
    }
  }

  setInfo(data) {
    if (data) {
      if (data.id) {
        this.layer.removeBox(this)
        this.id = data.id;
        this.layer.addBox(this)
      }
      this.section = data.section || this.section;
      this.div.dataset.section = this.section;
    }
    if (this.isPersisted()) {
      this.div.classList.add("persisted");
    }
    this.previousInfo = this.getInfo();
  }

  isPersisted() {
    return this.id && this.id > 0;
  }

  isMoving() {
    return this.div.classList.contains("moving");
  }

  isGrouping() {
    return document.querySelectorAll(".polygon-ready .box.grouping").length;
  }

  isResizing() {
    return this.div.classList.contains("resizing");
  }

  _getNextPosition() {
    return document.querySelectorAll(".polygon-ready .box").length + 1;
  }

  _getNextSectionNumber() {
    let positions = new Set();
    document.querySelectorAll(".polygon-ready .box").forEach((div) => positions.add(div.dataset.sectionNumber));
    return positions.size + 1;
  }

  _ensureCssPercent(num, max) {
    if (num.indexOf("%") !== -1) {
      return parseFloat(num);
    }
    return this._sanitizePercent(100 * parseFloat(num) / max);

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
      console.log("box click", evt, this);
      evt.stopPropagation();
      this.onClick(evt);
      window.addEventListener("click", this._blur.bind(this), { once: true });
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
      console.log("mouseup", this.hasChanged())
      // delay changing resizing status to avoid triggering the click event in the box
      setTimeout(() => this.div.classList.remove("resizing"), 100);
      if (this.hasChanged()) {
        this.setInfo();
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
    }
  }


  hasChanged() {
    return JSON.stringify(this.getInfo()) !== JSON.stringify(this.previousInfo);
  }

  // Not using getNodes because groups can span across layers
  focusGroup() {
    document.querySelectorAll(".polygon-ready .box").forEach((div) => div.dataset.sectionNumber === this.div.dataset.sectionNumber && div.classList.add("focus"));
  }

  blurGroup() {
    document.querySelectorAll(".polygon-ready .box").forEach((div) => div.classList.remove("focus"));
  }

  blockSibilings() {
    document.querySelectorAll(".polygon-ready").forEach((layer) => {
      layer.classList.add("blocked");
      layer.querySelectorAll(".box").forEach((div) => div.id !== this.div.id && div.classList.add("blocked"));
    });
  }

  unBlockSibilings() {
    document.querySelectorAll(".polygon-ready").forEach((layer) => {
      layer.classList.remove("blocked");
      layer.querySelectorAll(".box").forEach((div) => div.classList.remove("blocked"));
    });
  }

  destroy() {
    this.div.remove();
    this.resize.disconnect();
    this.onDestroy();
  }
}
