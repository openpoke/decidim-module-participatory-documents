import BoxControlMove from './box_control_move';
import BoxControlGroup from './box_control_group';

export default class BoxControls {
	constructor(box) {
		this.box = box;
		this.createControls();
	}

	createControls() {
    this.div = document.createElement("div");
    this.div.classList.add("box-controls");
    this.box.div.appendChild(this.div);
		this.box.div.classList.add("admin")
		this.mover = new BoxControlMove(this);
		this.grouper = new BoxControlGroup(this);
	}
}