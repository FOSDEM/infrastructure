"use strict";

const Mixer = function (apipath) {
	var vuLastUpdate = Date.now();
	var webSocket;

	const inputsShown = ['IN1', 'IN2', 'IN3', 'PC'];
	const outputsShown = ['OUT1', 'OUT2', 'HP1', 'HP2'];

	function intersect(a, b) {
		let t;
		if (b.length > a.length) t = b, b = a, a = t; // indexOf to loop over shorter
		return a.filter(function (e) {
			return b.indexOf(e) > -1;
		});
	}



	async function loadInfo() {
		return await fetch(`${apipath}/info`).then(x => x.json());
	}

	async function loadMultipliers() {
		return await fetch(`${apipath}/multipliers`).then(x => x.json());
	}

	async function loadMutes() {
		return await fetch(`${apipath}/mutes`).then(x => x.json());
	}

	async function onInputVolumeChange(input, e) {
	}

	async function updateVu(vuString) {
		const vu = JSON.parse(vuString);
		vuLastUpdate = Date.now()

		for(const [input, level] of Object.entries(vu.input)) {
			if(!inputsShown.includes(input)) continue;
			const meter = document.querySelector(`.inputs .channel[data-name=${input}] meter`);

			meter.value = level.rms;
		}
		for(const [output, level] of Object.entries(vu.output)) {
			if(!outputsShown.includes(output)) continue;
			const meter = document.querySelector(`.outputs .channel[data-name=${output}] meter`);

			meter.value = level.rms;
		}
	}

	function createSlider(initialMultiplier) {
		const slider = document.createElement('input');
		slider.type = 'range';
		slider.min = 0;
		slider.max = 1.8;
		slider.value = initialMultiplier;
		slider.step = 0.1;
		slider.setAttribute('list', 'volumes');

		return slider;
	}

	function createVuMeter() {
		const meter = document.createElement('meter');
		meter.min = -50;
		meter.high = -14;
		meter.optimum = -50;
		meter.low = -30;
		meter.max = 0;

		meter.value = -50;

		return meter;
	}

	function setupInputs(info, multipliers, mutes) {
		const inputs = document.getElementById('inputs');
		for(const input of intersect(info.inputs, inputsShown)) {
			const div = document.createElement('div');
			div.className = 'channel';
			div.dataset.name = input;

			const head = document.createElement('h3');

			head.innerText = input;

			const sliders = document.createElement('div');
			sliders.className = 'sliders';

			const volume = createSlider(multipliers.input[input]);
			volume.addEventListener('change', e => onInputVolumeChange(input, e));

			//              const slider = createSlider();
			const vu = createVuMeter();

			//              sliders.appendChild(slider);
			sliders.appendChild(vu);

			const mutelist = document.createElement('div');
			mutelist.className = 'mutes';
			for(const output of intersect(info.outputs, outputsShown)) {
				const mutech = document.createElement('div');

				const outputname = document.createElement('label');
				outputname.innerText = output;
				outputname.setAttribute('for', `mute-${input}-${output}`);

				const muted = document.createElement('input');
				muted.id = `mute-${input}-${output}`;
				muted.type = 'checkbox';

				muted.checked = !mutes[input][output];

				mutech.appendChild(outputname);
				mutech.appendChild(muted);

				mutelist.appendChild(mutech);
			}


			div.appendChild(head);

			div.appendChild(sliders);

			div.appendChild(mutelist);

			inputs.appendChild(div);
		}
	}

	function setupOutputs(info, multipliers) {
		const outputs = document.getElementById('outputs');
		for(const output of intersect(info.outputs, outputsShown)) {
			const div = document.createElement('div');
			div.className = 'channel';
			div.dataset.name = output;

			const head = document.createElement('h3');

			head.innerText = output;

			const sliders = document.createElement('div');
			sliders.className = 'sliders';

			//const volume = createOutputSlider(multipliers.input[input]);
			//volume.addEventListener('change', e => onInputVolumeChange(input, e));

			const slider = createSlider();
			const vu = createVuMeter();

			sliders.appendChild(slider);
			sliders.appendChild(vu);


			div.appendChild(head);

			div.appendChild(sliders);


			outputs.appendChild(div);
		}
	}

	function setupVuWebSocket(apipath) {
		if(webSocket) webSocket.close();
		webSocket = new WebSocket(`${apipath}/vu/ws`);
		webSocket.addEventListener('message', (e) => {updateVu(e.data); });
	}

	function setupMixer() {
		loadInfo(apipath).then(info => {
			loadMultipliers(apipath).then(multipliers => {
				loadMutes(apipath).then(mutes => {
					setupInputs(info, multipliers, mutes);
					setupOutputs(info, multipliers);
					setupVuWebSocket(apipath);
				})})}).then(_ => {
					setInterval(function() {
						let noUpdateMessage = document.getElementById('no-vu-update');
						if(Date.now() - vuLastUpdate >= 1000) {
							setupVuWebSocket(apipath);
							if(!noUpdateMessage) {
								const div = document.createElement('div');
								div.id = 'no-vu-update';
								div.innerText = 'No update from the mixer!';
								document.getElementById('errors').appendChild(div);
							}
						}
						else if(noUpdateMessage) {
							noUpdateMessage.parentElement.removeChild(noUpdateMessage);
						}
					}, 1000);
				});
	};

	setupMixer();
	return this;
}
