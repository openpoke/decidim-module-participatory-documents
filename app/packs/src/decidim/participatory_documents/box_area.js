import BoxControls from "./box_controls";

export default class BoxArea {
	constructor(layer, left, top, width, height) {
		this.layer = layer;
		this.id = this.createBox(left, top, width, height);
		this.bindEvents();
		this.hover = false;
		console.log("box constructor", this);
		// events
		this.onClick = () => {};
		this.onEnter = () => {};
		this.onLeave = () => {};
	}

	createBox(left, top, width, height) {
    this.div = document.createElement("div");
		this.div.draggable = false;
    this.div.id = "box-" + Date.now();
    this.div.classList.add("box", "creating");
    this.div.style.left = left;
    this.div.style.top = top;
    if(width && height) {
	    this.div.style.width = width;
	    this.div.style.height = height;
    }
    this.layer.div.appendChild(this.div);

    return this.div.id;
  }

  bindEvents() {  	
  	this.div.addEventListener("mouseenter", this._mouseEnter.bind(this));
  	this.div.addEventListener("mouseleave", this._mouseLeave.bind(this));
  	this.div.addEventListener("click", this._click.bind(this));
  }

  createControls() {
  	this.controls = new BoxControls(this);
		this.resize = new ResizeObserver(this._resize.bind(this));
		this.resize.observe(this.div);
	}

	_click(e) {
		if(!this.layer.creating) {
			this.onClick(e);
		}
	}

	_mouseEnter(e) {
		if(!this.layer.creating) {
			this.blockSibilings();
			this.hover = true;
			this.div.classList.add("hover");
			this.onEnter(e);
			// console.log("box mousenter", e, "widht/height", this.div.style.width, this.div.style.height);
		}	
	}

	_mouseLeave(e) {
		if(!this.layer.creating) {
			this.hover = false;
			this.div.classList.remove("hover");
			this.unBlockSibilings();
			this.onLeave(e);
			// console.log("box mouseleave", e);
		}	
	}

	_resize(entries) {
		if(!this.layer.creating && this.div.classList.contains("hover")) {
			let width = (100 * entries[0].contentRect.width / this.layer.div.clientWidth) + "%";
			let height = (100 * entries[0].contentRect.height / this.layer.div.clientHeight) + "%";
			// console.log("box resize", entries, this.div.style.width, this.div.style.height, "calculated", width, height);
			this.div.style.width = width;
			this.div.style.height = height;
		}
	}

	blockSibilings() {
		this.layer.blocked = true;
		this.layer.div.querySelectorAll(".box").forEach(div => div.id != this.id && div.classList.add("blocked"));
	}

	unBlockSibilings() {
		this.layer.blocked = false;
		this.layer.div.querySelectorAll(".box").forEach(div => div.classList.remove("blocked"));
	}
}