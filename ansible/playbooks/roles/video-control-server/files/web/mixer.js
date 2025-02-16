"use strict";

const RetryingWebSocket = function(path, errorTime, errorMessage, errorContainer, onMessage) {
	const errorElement = document.createElement('div');
	errorElement.innerText = errorMessage;

	const ws = new ReconnectingWebSocket(path, null, {timeoutInterval: errorTime, reconnectInterval: 2000})
	ws.open();

	ws.addEventListener('message', e => {
		onMessage(e)
	});

	ws.addEventListener('close', e => {
		if(!errorContainer.contains(errorElement)) {
			errorContainer.appendChild(errorElement);
		}
	});
	ws.addEventListener('open', e => {
		if(errorContainer.contains(errorElement)) {
			errorContainer.removeChild(errorElement);
		}
	});

	return ws;
}

const Mixer = function (apipath, inputsShown, outputsShown, inputsControllable, outputsControllable, mutesControllable) {
	var levelsWs;
	var stateWs;

	//const inputsShown = ['IN1', 'IN2', 'IN3'];
	//const inputsShown = ['IN1', 'IN2', 'IN3', 'PC', 'USB1', 'USB2'];
	//const outputsShown = ['OUT1', 'OUT2', 'HP1', 'HP2'];
	//const outputsShown = ['OUT1', 'OUT2', 'HP1', 'HP2', 'USB1', 'USB2'];

	const inputLabels = {};
	const outputLabels = {'OUT1': '\u{1F4F9}', 'OUT2': '\u{1F50A}', 'HP1': '\u{1F3A7}L', 'HP2': '\u{1F3A7}R'};

	function getInputLabel(input) {
		if(input in inputLabels) return inputLabels[input];
		return input;
	}

	function getOutputLabel(output) {
		if(output in outputLabels) return outputLabels[output];
		return output;
	}

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

	async function toggleMute(channel, bus, value) {
		return await fetch(`${apipath}/muted/${channel}/${bus}/${value}`);
	}

	async function changeInputVolume(input, value) {
		return await fetch(`${apipath}/multipliers/input/${input}/${value}`);
	}

	async function changeOutputVolume(output, value) {
		return await fetch(`${apipath}/multipliers/output/${output}/${value}`);
	}

	async function updateVu(vuString) {
		const vu = JSON.parse(vuString);

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

	async function updateState(stateString) {
		const state = JSON.parse(stateString);

		for(const [channel, v] of Object.entries(state.mutes)) {
			for(const [bus, muted] of Object.entries(v)) {
				const checkbox = document.getElementById(`mute-${channel}-${bus}`);
				if(checkbox) checkbox.checked = !muted;
			}
		}
		for(const [channel, multiplier] of Object.entries(state.multipliers.input)) {
			const slider = document.querySelector(`.inputs [data-name=${channel}] input[type=range]`);
			if(slider) slider.value = multiplier;
			if(slider && multiplier > slider.max) slider.disabled = true;
		}
		for(const [bus, multiplier] of Object.entries(state.multipliers.output)) {
			const slider = document.querySelector(`.outputs [data-name=${bus}] input[type=range]`);
			if(slider) slider.value = multiplier;
			if(slider && multiplier > slider.max) slider.disabled = true;
		}
	}

	function createSlider(initialMultiplier = 0.0, controllable, onchange) {
		const slider = document.createElement('input');
		slider.type = 'range';
		slider.min = 0;
		slider.max = 1.8;
		slider.step = 0.1;
		if(!controllable || initialMultiplier > slider.max) slider.disabled = true;
		slider.setAttribute('list', 'volumes');
		setTimeout(() => {
			slider.value = initialMultiplier;
		}, 0.1);

		return slider;
	}

	function createVuMeter() {
		const meter = document.createElement('meter');

		meter.min = -60;
		//meter.min = -40;
		meter.high = 0;
		meter.optimum = -40;
		meter.low = -20;
		meter.max = +4;

		meter.value = -50;

		return meter;
	}

	function setupInputs(info) {
		const inputs = document.getElementById('inputs');
		for(const input of intersect(info.inputs, inputsShown)) {
			const div = document.createElement('div');
			div.className = 'channel';
			div.dataset.name = input;

			const head = document.createElement('h3');

			head.innerText = getInputLabel(input);

			const sliders = document.createElement('div');
			sliders.className = 'sliders';

			const slider = createSlider(0.0, inputsControllable.includes(input));
			const vu = createVuMeter();

			slider.oninput = () => changeInputVolume(input, slider.value);

			sliders.appendChild(slider);
			sliders.appendChild(vu);

			const mutelist = document.createElement('div');
			mutelist.className = 'mutes';
			for(const output of intersect(info.outputs, outputsShown)) {
				const mutech = document.createElement('div');

				const outputname = document.createElement('label');
				outputname.innerText = getOutputLabel(output);
				outputname.setAttribute('for', `mute-${input}-${output}`);

				const unmuted = document.createElement('input');
				unmuted.id = `mute-${input}-${output}`;
				if(!mutesControllable) unmuted.disabled = true;
				unmuted.type = 'checkbox';

//				unmuted.checked = !mutes[input][output];

				unmuted.oninput = () => toggleMute(input, output, !unmuted.checked);

				mutech.appendChild(outputname);
				mutech.appendChild(unmuted);

				mutelist.appendChild(mutech);
			}


			div.appendChild(head);

			div.appendChild(sliders);

			div.appendChild(mutelist);

			inputs.appendChild(div);
		}
	}

	function setupOutputs(info) {
		const outputs = document.getElementById('outputs');
		for(const output of intersect(info.outputs, outputsShown)) {
			const div = document.createElement('div');
			div.className = 'channel';
			div.dataset.name = output;

			const head = document.createElement('h3');

			head.innerText = getOutputLabel(output);

			const sliders = document.createElement('div');
			sliders.className = 'sliders';

			const slider = createSlider(0.0, outputsControllable.includes(output));
			const vu = createVuMeter();

			slider.oninput = () => changeOutputVolume(output, slider.value);

			sliders.appendChild(slider);
			sliders.appendChild(vu);


			div.appendChild(head);

			div.appendChild(sliders);


			outputs.appendChild(div);
		}
	}

	this.setupMixer = async () => {
		const info = await loadInfo(apipath);
		setupInputs(info);
		setupOutputs(info);
		const errors = document.getElementById('errors')
		levelsWs = new RetryingWebSocket(`${apipath}/vu/ws`, 500, 'No levels from mixer', errors, e => updateVu(e.data))
		stateWs = new RetryingWebSocket(`${apipath}/state/ws`, 5000, 'No state from mixer', errors, e => updateState(e.data))
	}

	return this;
}
