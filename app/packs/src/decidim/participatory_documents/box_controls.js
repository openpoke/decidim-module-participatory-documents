export default class BoxControls {
	constructor(box) {
		this.box = box;
		this.moving = false;
		this.left = 0;
		this.top = 0;
		this.createControls();
		this.bindControls();
	}

	createControls() {
    this.div = document.createElement("div");
    this.div.classList.add("box-controls");
    this.moveEl = document.createElement("span");
    this.moveEl.classList.add("move-control");
    this.moveEl.innerHTML = "Move";
    this.div.appendChild(this.moveEl);
    this.box.div.appendChild(this.div);
		this.box.div.classList.add("admin")
	}

	bindControls() {
		this.moveEl.addEventListener("mousedown", this.startMoving.bind(this));
	}

	startMoving(e) {
		e.stopPropagation();
		this.moving = true;
		// this.box.blockSibilings();
		this.box.div.classList.add("moving");
	  this.left = this.box.layer.div.getBoundingClientRect().x + e.layerX;
	  // We need to substract the controls height because is aligned at the bottom
	  this.top = this.box.layer.div.getBoundingClientRect().y + this.box.div.clientHeight - this.div.clientHeight + e.layerY;
	  // Binding mouseup and mousemove to the entire window so it works even if the mouse is outside the box
		window.addEventListener("mouseup", this.stopMoving.bind(this), { once: true });
		window.addEventListener("mousemove", this.move.bind(this));
		console.log("start moving", e, this.box.div.style.left, this.box.div.style.top, this);

	}

	stopMoving(e) {
		e.stopPropagation();
		window.removeEventListener("mousemove", this.move.bind(this));
		this.moving = false;
		// this.box.unBlockSibilings();
		this.box.div.classList.remove("moving");
		console.log("stop moving", e, this);
	}

	move(e) {
		if(this.moving) {
			e.stopPropagation();
	    let w = e.clientX - this.left;
	    let h = e.clientY - this.top;
	    let mousePercentLeft = (100 * w/this.box.layer.div.clientWidth)
	    let mousePercentTop = (100 * h/this.box.layer.div.clientHeight)
	    this.box.div.style.left = mousePercentLeft + "%";
	    this.box.div.style.top = mousePercentTop + "%";

			// console.log("moving", e, mousePercentLeft, mousePercentTop, this);
		}
	}
}