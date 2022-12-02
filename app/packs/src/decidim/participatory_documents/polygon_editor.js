import BoxArea from "./box_area";

export default class PolygonEditor {
	constructor(div) {
		this.div = div;
		this.box = null;
		this.creating = false;
    this.blocked = false;
		this.top = 0;
		this.left = 0;
		this.boxes = {};
    // events
    this.onClick = () => {};
    this.onEnter = () => {};
    this.onLeave = () => {};
		this.init();
	}

	init() {
	  this.div.style.pointerEvents = "all";
	  this.div.classList.add("ready");
    this.div.removeEventListener('mousedown', this._mouseDown.bind(this));
    this.div.removeEventListener('mousemove', this._mouseMove.bind(this));
    this.div.removeEventListener('mouseup', this._mouseUp.bind(this));
    this.div.addEventListener('mousedown', this._mouseDown.bind(this));
    this.div.addEventListener('mousemove', this._mouseMove.bind(this));
    this.div.addEventListener('mouseup', this._mouseUp.bind(this));
	}

  _mouseDown(e) {
    if(!this.creating && !this.blocked) {
      this.blockBoxes();
      this.box = this._createBox(e);
      this.creating = true;
  	  this.left = this.div.getBoundingClientRect().x;
  	  this.top = this.div.getBoundingClientRect().y;
  	  // disable mouse events on all children
      console.log('mousedown',"e", e,  "this", this, "box div", this.box.div);
    }
  }

  _mouseMove(e) {
    if(!this.blocked && this.creating && this.box) {
      let w = e.clientX - this.left - 9;
      let h = e.clientY - this.top - 9;
      let boxPercentLeft = parseInt(this.box.div.style.left);
      let boxPercentTop = parseInt(this.box.div.style.top);
      let mousePercentLeft = 100 * w/this.div.clientWidth;
      let mousePercentTop = 100 * h/this.div.clientHeight;
      this.box.div.style.width = (mousePercentLeft - boxPercentLeft) + "%";
      this.box.div.style.height = (mousePercentTop - boxPercentTop) + "%";
      // console.log('mousemove', e,"mousePercent", mousePercentLeft,mousePercentTop, "box",this.box);
    }
  }
  
  _mouseUp(e) {
    if(!this.blocked && this.creating && this.box) {
      this.box.div.classList.remove("creating");
      if(this.box.div.clientWidth <= 5 && this.box.div.clientHeight <= 5) {
        this.box.div.remove();
        this.box = null;
      } else {
      	this._initBox();
      }
      // console.log('mouseup', e, "box", this.box.div);
      this.creating = false;
    	this.unblockBoxes();
    }
  }

  _createBox(e) {
    const {left, top} = this.div.getBoundingClientRect();
    let w = e.clientX - left - 3;
    let h = e.clientY - top - 3;
    let mousePercentLeft = (100 * w/this.div.clientWidth)
    let mousePercentTop = (100 * h/this.div.clientHeight)

    return new BoxArea(this, mousePercentLeft + "%", mousePercentTop + "%");
  }

  _initBox() {
  	if(!this.boxes[this.box.id]) {
      this.box.createControls();
  		this.box.onClick = (e) => this.onClick(this.box, e);
      this.box.onEnter = (e) => this.onEnter(this.box, e);
      this.box.onLeave = (e) => this.onLeave(this.box, e);
      this.boxes[this.box.id] = this.box;
  	}
  }

  blockBoxes() {
  	this.div.querySelectorAll(".box").forEach(div => div.classList.add("blocked"));
	}

  unblockBoxes() {
  	this.div.querySelectorAll(".box").forEach(div => div.classList.remove("blocked"));
	}
}