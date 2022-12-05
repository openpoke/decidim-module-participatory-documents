import BoxControls from "./box_controls";

export default class BoxArea {
	constructor(layer, json) {
		this.layer = layer;
		this.json = json || { rect: {} };
		this.id = this.createBox(this.json.id, this.json.rect);
		this.setGroup(this.json && this.json.group)
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
	createBox(id, {left, top, width, height}) {
    this.div = document.createElement("div");
		this.div.draggable = false;
    this.div.id = id || "box-" + Date.now();
    this.div.classList.add("box");
    this.div.style.left = left + "%";
    this.div.style.top = top + "%";
    if(width && height) {
	    this.div.style.width = width + "%";
	    this.div.style.height = height + "%";
    }
    this.layer.div.appendChild(this.div);

    return this.div.id;
  }

  setGroup(group) {
  	if(!group) group = "group-" + Date.now();
  	this.group = group;
		this.div.dataset.boxGroup = group;
  }

  createControls() {
  	this.controls = new BoxControls(this);
		this.resize = new ResizeObserver(this._resize.bind(this));
		this.resize.observe(this.div);
	}

  getRect() {
    return {
      left: parseFloat(this.div.style.left),
      top: parseFloat(this.div.style.top),
      width: parseFloat(this.div.style.width),
      height: parseFloat(this.div.style.height)
    }
  }

  getInfo() {
		return {
			id: this.id,
			group: this.group,
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

  _bindEvents() {  	
  	this.div.addEventListener("mouseenter", this._mouseEnter.bind(this));
  	this.div.addEventListener("mouseleave", this._mouseLeave.bind(this));
  	this.div.addEventListener("mouseup", this._mouseUp.bind(this));
  	this.div.addEventListener("click", this._click.bind(this));
  }

	_click(e) {
		if(!this.layer.creating && !this.isMoving() && !this.isGrouping() && !this.isResizing()) {
			console.log("box click", e);
			e.stopPropagation();
			this.onClick(e);
  		window.addEventListener("click", this._blur.bind(this), {once: true});
		}
	}

	_blur(e) {
		if(!this.layer.creating) {
			this.onBlur(e);
		}
	}

	_mouseEnter(e) {
		if(!this.layer.creating && !this.isGrouping()) {
			this.blockSibilings();
			this.div.classList.add("hover");
			this.focusGroup();
			this.onEnter(e);
			// console.log("box mousenter", e, "widht/height", this.div.style.width, this.div.style.height);
		}	
	}

	_mouseLeave(e) {
		if(!this.layer.creating && !this.isGrouping()) {
			this.div.classList.remove("hover");
			this.blurGroup()
			this.unBlockSibilings();
			this.onLeave(e);
			// console.log("box mouseleave", e);
		}	
	}

	_mouseUp() {
		if(!this.layer.creating) {
			// delay changing resizing status to avoid triggering the click event in the box
			setTimeout(() => this.div.classList.remove("resizing"), 100);
			if(this.hasChanged()) {
				// console.log("box changed", e);
				this.onChange();
			}
		}
	}

	_resize(entries) {
		if(!this.layer.creating && this.div.classList.contains("hover")) {
			this.div.classList.add("resizing")
			let width = (100 * entries[0].contentRect.width / this.layer.div.clientWidth) + "%";
			let height = (100 * entries[0].contentRect.height / this.layer.div.clientHeight) + "%";
			// console.log("box resize", entries, this.div.style.width, this.div.style.height, "calculated", width, height);
			this.div.style.width = width;
			this.div.style.height = height;
		}
	}

	hasChanged() {
		if(JSON.stringify(this.getInfo()) != JSON.stringify(this.previousInfo)) {
			this.previousInfo = this.getInfo();
			return true;
		}
		return false;
	}

	// Not using getNodes because groups can span across layers
	focusGroup() {
		document.querySelectorAll(".polygon-ready .box").forEach(div => div.dataset.boxGroup == this.group && div.classList.add("focus"));
	}

	blurGroup() {
		document.querySelectorAll(".polygon-ready .box").forEach(div => div.classList.remove("focus"));
	}

	blockSibilings() {
		this.layer.blocked = true;
		this.layer.div.querySelectorAll(".box").forEach(div => div.id != this.id && div.classList.add("blocked"));
	}

	unBlockSibilings() {
		this.layer.blocked = false;
		this.layer.div.querySelectorAll(".box").forEach(div => div.classList.remove("blocked"));
	}

	destroy() {
		this.div.remove();
		this.resize.disconnect();
		this.onDestroy();
	}
}