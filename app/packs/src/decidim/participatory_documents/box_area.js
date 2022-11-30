export default class BoxArea {
	constructor(div) {
		this.div = div;
		this.id = this.div.id = "box-" + Date.now();
		this.div.draggable = true;
		this.layer = this.div.parentElement;
		this.moving = false;
		this.top = 0;
		this.left = 0;
		console.log("box constructor", this);
		this.init();
	}

	init() {
		this.resize = new ResizeObserver(this.onResize.bind(this));
		this.resize.observe(this.div);
		// setTimeout(()=>{
		// 	this.div.style.resize = "both;"
		// },1000);
		this.div.addEventListener("mousedown",this.onMouseDown.bind(this), true);
		// Alternate to "dragend". Has problems with resizing
		// this.div.addEventListener("mousemove", (e) => this.onMouseMove(e), true);
		this.div.addEventListener("mouseup", this.onMouseUp.bind(this), true);
		this.div.addEventListener("mouseleave", this.onMouseUp.bind(this), true);
		// Alternate to "mousemove"
		this.div.addEventListener("dragend", this.onDragEnd.bind(this), true);
	}

	onResize(e,b) {
		this.div.style.width = (100 * e[0].contentRect.width / this.layer.clientWidth) + "%";
		this.div.style.height = (100 * e[0].contentRect.height / this.layer.clientHeight) + "%";
		// console.log("box resize", e,b)
	}

	onDragEnd(e) {
		e.stopPropagation();
    let w = e.clientX - this.left - 3;
    let h = e.clientY - this.top - 3;
    let mousePercentLeft = (100 * w/this.layer.clientWidth)
    let mousePercentTop = (100 * h/this.layer.clientHeight)
    this.div.style.left = mousePercentLeft + "%";
    this.div.style.top = mousePercentTop + "%";
		this.div.classList.remove("grabbing");
		this.unblockSibilings();
		// console.log("box end", e, this.div);
	}

	onMouseDown(e) {
		e.stopPropagation();
		this.moving = true;
		this.div.classList.add("grabbing");
		this.blockSibilings();
	  this.left = this.layer.getBoundingClientRect().x + e.layerX;
	  this.top = this.layer.getBoundingClientRect().y + e.layerY;
		// console.log("box mousedown", e);
	}

	onMouseMove(e) {
		e.stopPropagation();
		if(this.moving) {
	    let w = e.clientX - this.left - 3;
	    let h = e.clientY - this.top - 3;
	    let mousePercentLeft = (100 * w/this.layer.clientWidth)
	    let mousePercentTop = (100 * h/this.layer.clientHeight)
	    this.div.style.left = mousePercentLeft + "%";
	    this.div.style.top = mousePercentTop + "%";
	    // console.log("box mousemove", this.div.style, e);
 		}
	}

	onMouseUp(e) {
		e.stopPropagation();
		this.moving = false;
		this.div.classList.remove("grabbing");
		this.unblockSibilings();
	  // console.log("box mouseup", this.div.style, e);
	}

	blockSibilings() {
		this.layer.classList.add("blocked")
		this.layer.querySelectorAll(".box").forEach(div => div.id != this.id && div.classList.add("blocked"));
	}

	unblockSibilings() {
		this.layer.classList.remove("blocked")
		this.layer.querySelectorAll(".box").forEach(div => div.classList.remove("blocked"));
	}
}