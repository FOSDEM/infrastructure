"use strict";

class MixerCanvas {
	const lowerLimit = -60;
	const upperLimit = 4;

	const okDb = -30;
	const peakDb = 0;

	constructor() {
		this.canvas = document.createElement("canvas");
	}

	function getCanvas() {
		return this.canvas;
	}

	function drawLevel(rms, peak) {
		const ctx = this.canvas.getContext("2d");
		const height = canvas.height;
		const width = canvas.width;

		if(rms < okDb) ctx.fillStyle = "yellow";
		else if(rms < peakDb) ctx.fillStyle = "green";
		else ctx.fillStyle = "red";

		ctx.fillRect(0, 0, height * (rms - upperLimit) / (lowerLimit - upperLimit), width);
	}
}
