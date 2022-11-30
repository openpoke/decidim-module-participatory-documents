import BoxArea from "./box_area";

export default class PolygonEditor {
	constructor(layer) {
		this.layer = layer;
		this.box = null;
		this.moving = true;
		this.top = 0;
		this.left = 0;
		this.boxes = {};
		this.init();
	}

	init() {
	  this.layer.style.pointerEvents = "all";
	  this.layer.classList.add("ready");
    this.layer.removeEventListener('mousedown', (e) => this.onMouseDown(e));
    this.layer.removeEventListener('mousemove', (e) => this.onMouseMove(e));
    this.layer.removeEventListener('mouseup', (e) => this.onMouseUp(e));
    this.layer.removeEventListener('mouseleave', (e) => this.onMouseUp(e));
    this.layer.removeEventListener('mouseout', (e) => this.onMouseUp(e));
    this.layer.addEventListener('mousedown', (e) => this.onMouseDown(e));
    this.layer.addEventListener('mousemove', (e) => this.onMouseMove(e));
    this.layer.addEventListener('mouseup', (e) => this.onMouseUp(e));
    // this.layer.addEventListener('mouseleave', (e) => this.onMouseUp(e));
    // this.layer.addEventListener('mouseout', (e) => this.onMouseUp(e));
	}

	onMouseDown(e) {
    const {left, top} = this.layer.getBoundingClientRect();
    let w = e.clientX - left - 3;
    let h = e.clientY - top - 3;
    let mousePercentLeft = (100 * w/this.layer.clientWidth)
    let mousePercentTop = (100 * h/this.layer.clientHeight)
	  this.blockBoxes();
    this.box = document.createElement("div");
    this.box.classList.add("box", "dragging");
    this.box.style.left = mousePercentLeft + "%";
    this.box.style.top = mousePercentTop + "%";
    this.layer.appendChild(this.box);
    this.moving = true;
	  this.left = this.layer.getBoundingClientRect().x;
	  this.top = this.layer.getBoundingClientRect().y;
	  // disable mouse events on all children
    // console.log('mousedown', e, "w/h", w, h, "box", this.box);
  }

  onMouseMove(e) {
    if(this.moving && this.box) {
      let w = e.clientX - this.left - 9;
      let h = e.clientY - this.top - 9;
      let boxPercentLeft = parseInt(this.box.style.left);
      let boxPercentTop = parseInt(this.box.style.top);
      let mousePercentLeft = 100 * w/this.layer.clientWidth;
      let mousePercentTop = 100 * h/this.layer.clientHeight;
      this.box.style.width = (mousePercentLeft - boxPercentLeft) + "%";
      this.box.style.height = (mousePercentTop - boxPercentTop) + "%";
      // console.log('mousemove', e,"mousePercent", mousePercentLeft,mousePercentTop, "box",this.box);
    }
  }
  
  onMouseUp(e) {
    if(this.moving && this.box) {
      this.box.classList.remove("dragging");
      if(this.box.clientWidth <= 5 && this.box.clientHeight <= 5) {
        this.box.remove();
      } else {
      	this.initBox();
      }
      // console.log('mouseup', e, "box", this.box);
      this.moving = false;
    	this.unblockBoxes();
    }
  }

  initBox() {
  	if(this.box && !this.boxes[this.box.id]) {
  		const box = new BoxArea(this.box);
  		this.boxes[box.id] = box;
  	}
  }

  blockBoxes() {
  	this.layer.querySelectorAll(".box").forEach(div => div.classList.add("blocked"));
	}
  unblockBoxes() {
  	this.layer.querySelectorAll(".box").forEach(div => div.classList.remove("blocked"));
	}
}