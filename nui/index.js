let Utils = {}

let locale
let format
Utils.translate = function (key) {
	if (!Lang.hasOwnProperty(locale)) {
		console.warn(`Language '${locale}' is not available. Using default 'en'.`);
		locale = 'en';
	}

	let langObj = Lang[locale];
	const keys = key.split('.');

	for (const k of keys) {
		if (!langObj.hasOwnProperty(k)) {
			console.warn(`Translation key '${key}' not found for language '${locale}'.`);
			return 'missing_translation';
		}
		langObj = langObj[k];
	}

	return langObj;
}

Utils.setLocale = function (current_locale) {
	locale = current_locale
};

Utils.setFormat = function (current_format) {
	format = current_format
};

Utils.loadLanguageFile = async function () {
	try {
		await new Promise((resolve, reject) => {
			let fileUrl = `lang/${locale}.js`;
			const script = document.createElement('script');
			script.src = fileUrl;

			script.onload = () => {
				resolve();
			};

			script.onerror = (event) => {
				reject(new Error('Failed to load language file: ' + fileUrl));
			};

			document.body.appendChild(script);

			const timeoutDuration = 10000; // 10 seconds
			setTimeout(() => {
				reject(new Error('Timeout: The script took too long to load the language file: ' + fileUrl));
			}, timeoutDuration);
		});
	} catch (error) {
		if (locale !== 'en') {
			console.warn(`Language '${locale}' is not available. Using default 'en'.`);
			Utils.setLocale('en')
			await Utils.loadLanguageFile();
		} else {
			throw error;
		}
	}
};

Utils.loadLanguageModules = async function (utils_module) {
	Utils.setLocale(utils_module.config.locale)
	Utils.setFormat(utils_module.config.format)
	await Utils.loadLanguageFile();
	Utils.deepMerge(Lang,utils_module.lang)
};

Utils.timeConverter = function (UNIX_timestamp, options = {}) {
	const timestampMillis = UNIX_timestamp * 1000;
	const formattedTime = new Date(timestampMillis).toLocaleString(locale, options);

	return formattedTime;
};

Utils.currencyFormat = function (number, decimalPlaces = null) {
	const options = {
		style: 'currency',
		currency: format.currency,
	};

	if (decimalPlaces != null) {
		options.minimumFractionDigits = decimalPlaces;
		options.maximumFractionDigits = decimalPlaces;
	}

	return new Intl.NumberFormat(format.location, options).format(number);
};

Utils.numberFormat = function (number, decimalPlaces = null) {
	const options = {};

	if (decimalPlaces != null) {
		options.minimumFractionDigits = decimalPlaces;
		options.maximumFractionDigits = decimalPlaces;
	}

	return new Intl.NumberFormat(format.location, options).format(number);
};

Utils.getCurrencySymbol = function () {
	const options = {
		style: 'currency',
		currency: format.currency,
		minimumFractionDigits: 0,
		maximumFractionDigits: 0,
	};

	return new Intl.NumberFormat(locale, options).format(0).replace(/\d/g, '').trim();
};

const requestQueue = [];
let isProcessing = false;

const processQueue = async () => {
	if (!isProcessing && requestQueue.length > 0) {
		isProcessing = true;
		const { event, data, route, cb } = requestQueue.shift();
		try {
			const response = await fetch(Utils.getRoute(route), {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json',
				},
				body: JSON.stringify({ event, data }),
			});

			if (!response.ok) {
				throw new Error(`Request failed with status: ${response.status}`);
			}

			const responseData = await response.json();

			if (cb) {
				cb(responseData);
			} else {
				if (responseData !== 200) {
					console.log(responseData);
				}
			}
		} catch (error) {
			console.error(`Error occurred while making a POST request with event: "${event}", data: "${JSON.stringify(data)}", and route: "${Utils.getRoute(route)}": ${error.message}`);
		} finally {
			isProcessing = false;
			setTimeout(function() {
				processQueue();
			}, 200);
		}
	}
};

Utils.post = function (event, data, route = 'post', cb) {
	requestQueue.push({ event, data, route, cb });
	processQueue();
};

let resource_name
Utils.getRoute = function (name) {
	return `https://${resource_name}/${name}`;
};

Utils.setResourceName = function (current_resource_name) {
	resource_name = current_resource_name
};

const modalTemplate = `
	<div id="confirmation-modal" class="modal fade">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title"></h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="Close">
						<span aria-hidden="true">&times;</span>
					</button>
				</div>
				<form id="form-confirmation-modal" style="margin: 0;">
					<div class="modal-body">
						
					</div>
					<div class="modal-footer">
						
					</div>
				</form>
			</div>
		</div>
	</div>
`;

Utils.showDefaultModal = function (action, body = Utils.translate('confirmation_modal_body')) {
	Utils.showCustomModal({
		title: Utils.translate('confirmation_modal_title'),
		body,
		buttons: [
			{ text: Utils.translate('confirmation_modal_cancel_button'), class: "btn btn-outline-primary", dismiss: true },
			{ text: Utils.translate('confirmation_modal_confirm_button'), class: "btn btn-primary", dismiss: true, action }
		]
	})
}

Utils.showDefaultDangerModal = function (action, body = Utils.translate('confirmation_modal_body')) {
	Utils.showCustomModal({
		title: Utils.translate('confirmation_modal_title'),
		body,
		buttons: [
			{ text: Utils.translate('confirmation_modal_cancel_button'), class: "btn btn-outline-danger", dismiss: true },
			{ text: Utils.translate('confirmation_modal_confirm_button'), class: "btn btn-danger", dismiss: true, action }
		]
	})
}
/*
const exampleConfig = {
	title: 'Custom Modal Title',
	body: 'Custom Modal Body Text',
	buttons: [
		{ text: 'Cancel', class: 'btn btn-outline-primary', dismiss: true },
		{ text: 'Confirm', class: 'btn btn-primary', dismiss: false, action: () => console.log('Confirmed') }
	],
	inputs: [
		{
			type: 'text', // Input type: text
			label: 'Text Input:',
			small: 'Small text',
			id: 'text-input-id',
			name: 'text-input-name',
			value: 'xxxx',
			required: true,
			placeholder: 'Enter text here'
		},
		{
			type: 'number', // Input type: number
			label: 'Number Input:',
			small: 'Small text',
			id: 'number-input-id',
			name: 'number-input-name',
			value: 10,
			min: 0,
			max: 10,
			required: true,
			placeholder: 'Enter a number'
		},
		{
			type: 'custom',
			html: `
				<div class="d-flex>
					// custom html
				</div>
			`
		},
		{
			type: 'select', // Input type: select
			label: 'Select Input:',
			id: 'select-input-id',
			name: 'select-input-name',
			required: true,
			options: [
				{ value: 'option1', text: 'Option 1' },
				{ value: 'option2', text: 'Option 2' },
				{ value: 'option3', text: 'Option 3' }
			]
		}
	],
	onSubmit: function(inputValues) {
		console.log("Form submitted with input values:", inputValues);
		// You can perform further actions with the input values here
	}
};
*/
Utils.showCustomModal = function (config) {
	// Check if the modal already exists
	const $existingModal = $('#confirmation-modal');
	if ($existingModal.length > 0) {
		return;
	}

	const modalConfig = {
		title: Utils.translate('confirmation_modal_title'),
		buttons: [],
		inputs: []
	};

	// Merge the provided config with the default modalConfig
	const mergedConfig = { ...modalConfig };
	Utils.deepMerge(mergedConfig, config);

	// Append the modal HTML to the body
	$('body').append(modalTemplate);

	// Cache the modal element
	const $modal = $('#confirmation-modal');
	const $modalBody = $modal.find('.modal-body');

	// Set modal content
	$modal.find('.modal-title').text(mergedConfig.title);

	if (mergedConfig.bodyImage) {
		const $imageContainer = $('<div>', { class: 'd-flex justify-content-center m-2' });
		const $image = $('<img>', { src: mergedConfig.bodyImage, class: 'w-50' });
		$imageContainer.append($image);
		$modalBody.append($imageContainer);
	}

	if (mergedConfig.body) {
		const $p = $('<p>', { id: 'modal-body-text', text: mergedConfig.body });
		$modalBody.append($p);
	}

	if (mergedConfig.bodyHtml) {
		$modalBody.append(mergedConfig.bodyHtml);
	}

	// Set modal inputs
	const $form = $modal.find('#form-confirmation-modal');
	mergedConfig.inputs.forEach(inputConfig => {
		const $inputContainer = $('<div>', { class: 'form-group mx-2' });
		
		if (inputConfig.type === 'select') {
			const $label = $('<label>', { text: inputConfig.label, for: inputConfig.id });
			const $select = $('<select>', { class: 'form-control', id: inputConfig.id, name: inputConfig.name, required: inputConfig.required });
			if (!Array.isArray(inputConfig.options)) {
				inputConfig.options = Object.values(inputConfig.options)
			}
			inputConfig.options.forEach(option => {
				const $option = $('<option>', { value: option.value, text: option.text });
				$select.append($option);
			});
			$inputContainer.append($label, $select);
		} else if (inputConfig.type === 'checkbox') {
			const $checkboxContainer = $('<div>', { class: 'form-check' });
			const $label = $('<label>', { for: inputConfig.id, class: 'form-check-label' });
			const $input = $('<input>', { type: 'checkbox', class: 'form-check-input', id: inputConfig.id, name: inputConfig.name, required: inputConfig.required });
			$label.text(inputConfig.label);
			$inputContainer.append($checkboxContainer.append($input, $label));
		} else if (inputConfig.type === 'slider' || inputConfig.type === 'range') {
			const $label = $('<label>', { text: inputConfig.label, for: inputConfig.id });
			if (!inputConfig.default) {
				inputConfig.default = inputConfig.max ?? 100
			}
			let range_slider = `
				<div class="range-slider mt-2" style='--min:${inputConfig.min || 0}; --max:${inputConfig.max || 100}; --step:${inputConfig.step || 1}; --value:${inputConfig.default}; --text-value:"${inputConfig.default}"; --prefix:"${inputConfig.isCurrency ? Utils.getCurrencySymbol() : ''} ";'>
					<input id="${inputConfig.id}" name="${inputConfig.name}" type="range" min="${inputConfig.min || 0}" max="${inputConfig.max || 100}" step="${inputConfig.step || 1}" value="${inputConfig.default}" oninput="this.parentNode.style.setProperty('--value',this.value); this.parentNode.style.setProperty('--text-value', JSON.stringify(this.value))">
					<output></output>
					<div class='range-slider__progress'></div>
				</div>`
			$inputContainer.append($label, range_slider);
		} else if (inputConfig.type === 'custom') {
			const $customInput = $(inputConfig.html);
			$inputContainer.append($customInput);
		} else {
			const $label = $('<label>', { text: inputConfig.label, for: inputConfig.id });
			const $input = $('<input>', { type: inputConfig.type, class: 'form-control', id: inputConfig.id, name: inputConfig.name, required: inputConfig.required, placeholder: inputConfig.placeholder, min: inputConfig.min, max: inputConfig.max, value: inputConfig.value });
			$inputContainer.append($label, $input);
		}
		if (inputConfig.small) {
			const $small = $('<small>', { text: inputConfig.small, class: 'text-muted', style: 'font-size: 12px;' });
			$inputContainer.append($small);
		}
		$modalBody.append($inputContainer);
	});

	if (mergedConfig.footerText) {
		const $p = $('<p>', { id: 'modal-footer-text', text: mergedConfig.footerText });
		$modalBody.append($p);
	}

	// Set modal buttons
	const $footer = $modal.find('.modal-footer');
	$footer.empty();
	mergedConfig.buttons.forEach(button => {
		const $button = $('<button>', { class: button.class, text: button.text, type: button.type ?? 'button' });
		if (button.dismiss) {
			$button.attr('data-dismiss', 'modal');
		}
		if (button.action) {
			$button.on('click', button.action);
		}
		$footer.append($button);
	});

	// Set modal form submit
	$form.on('submit', function (e) {
		e.preventDefault();

		if (config.onSubmit) {
			config.onSubmit(new FormData(e.target));
		}
		$modal.modal('hide');
	});

	// Show the modal
	$modal.modal({ show: true });

	// Remove the modal from the DOM when hidden
	$modal.on('hidden.bs.modal', function () {
		setTimeout(() => {
			$(this).remove();
		}, 50);
	});
};

Utils.deepMerge = function (target, source) {
	for (const key in source) {
		if (source.hasOwnProperty(key)) {
			if (typeof source[key] === 'function') {
				target[key] = source[key];
			} else if (source[key] instanceof Object && source[key] !== null) {
				if (!target.hasOwnProperty(key)) {
					target[key] = {};
				}
				Utils.deepMerge(target[key], source[key]);
			} else {
				target[key] = source[key];
			}
		}
	}
};

if (!String.prototype.format) {
	String.prototype.format = function() {
		var args = arguments;
		return this.replace(/{(\d+)}/g, function(match, number) { 
		return typeof args[number] != 'undefined'
			? args[number]
			: match
		;
		});
	};
}

/**
 * DEPRECATED: Use Utils.onInvalidInput(this) on input events instead.
 */
Utils.invalidMsg = function (textbox, min = null, max = null) {
	textbox.setCustomValidity('');
	if (textbox.value === '') {
		textbox.setCustomValidity(Utils.translate('custom_validity.fill_field'));
	}
	else if (textbox.validity.typeMismatch) {
		textbox.setCustomValidity(Utils.translate('custom_validity.invalid_value'));
	}
	else if (textbox.validity.rangeUnderflow && min !== null) {
		textbox.setCustomValidity(Utils.translate('custom_validity.more_than').format(min));
	}
	else if (textbox.validity.rangeOverflow && max !== null) {
		textbox.setCustomValidity(Utils.translate('custom_validity.less_than').format(max));
	}
	else if (textbox.validity.stepMismatch) {
		textbox.setCustomValidity(Utils.translate('custom_validity.invalid_value'));
	}
	else if (textbox.validity.patternMismatch) {
		textbox.setCustomValidity(Utils.translate('custom_validity.pattern_mismatch'));
	}
	else if (textbox.validity.tooLong) {
		textbox.setCustomValidity(Utils.translate('custom_validity.too_long'));
	}
	else if (textbox.validity.tooShort) {
		textbox.setCustomValidity(Utils.translate('custom_validity.too_short'));
	}
	textbox.reportValidity();
	return true;
}

Utils.onInvalidInput = function (textbox) { // oninvalid="Utils.onInvalidInput(this)"
	textbox.setCustomValidity('');
	
	const elementType = textbox.tagName.toLowerCase(); // 'input', 'select', 'textarea'
	const inputType = elementType === 'input' ? textbox.type.toLowerCase() : elementType; // 'text', 'email', 'select', etc.

	if (textbox.validity.valueMissing || textbox.value === '') {
		if (inputType == 'select') { 
			textbox.setCustomValidity(Utils.translate('custom_validity.select_fill_field'));
		} else {
			textbox.setCustomValidity(Utils.translate('custom_validity.fill_field'));
		}
	}
	else if (textbox.validity.typeMismatch || textbox.validity.badInput) {
		textbox.setCustomValidity(Utils.translate('custom_validity.invalid_value'));
	}
	else if (textbox.validity.rangeUnderflow) {
		const min = $(textbox).attr('min');
		textbox.setCustomValidity(Utils.translate('custom_validity.more_than').format(Utils.numberFormat(min)));
	}
	else if (textbox.validity.rangeOverflow) {
		const max = $(textbox).attr('max');
		textbox.setCustomValidity(Utils.translate('custom_validity.less_than').format(Utils.numberFormat(max)));
	}
	else if (textbox.validity.stepMismatch) {
		textbox.setCustomValidity(Utils.translate('custom_validity.invalid_value'));
	}
	else if (textbox.validity.patternMismatch) {
		textbox.setCustomValidity(Utils.translate('custom_validity.pattern_mismatch'));
	}
	else if (textbox.validity.tooLong) {
		textbox.setCustomValidity(Utils.translate('custom_validity.too_long'));
	}
	else if (textbox.validity.tooShort) {
		textbox.setCustomValidity(Utils.translate('custom_validity.too_short'));
	}
	return true;
}

/**
 * Sorts an object or an array of objects based on specified property paths.
 * If the input is an object, it converts it to an array of objects, including the original object's key as an `.id` property.
 * @param {Object|Array} input - The object or array to sort.
 * @param {Array|String} propertyPath - The path(s) to the property for sorting, can be a single path or an array of paths for multiple criteria.
 * @param {Boolean} ascending - Whether the sorting should be in ascending order. Defaults to true.
 * @returns {Array} - The sorted array of objects.
 */
Utils.sortElement = function(input, propertyPath, ascending = true) {
	let arrayToSort = [];

	// Convert input to an array of objects if it's not already one, including `.id`
	if (!Array.isArray(input)) {
		arrayToSort = Object.entries(input).map(([index, item]) => {
			if (item !== null && (typeof item === 'object' || Array.isArray(item))) {
				return { ...item, id: item.id || index };
			} else {
				return { value: item, id: index };
			}
		});
	} else {
		arrayToSort = input.map((item, index) => ({
			...item,
			id: item.id || index
		}));
	}

	// Convert propertyPath to an array if it's not already one
	if (!Array.isArray(propertyPath)) {
		propertyPath = [propertyPath];
	}

	// A helper function to safely access nested properties
	const resolvePath = (object, path) => {
		return path.split('.').reduce((accumulator, currentValue) => {
			return accumulator ? accumulator[currentValue] : undefined;
		}, object);
	};

	// The sorting function
	return arrayToSort.sort((a, b) => {
		for (let i = 0; i < propertyPath.length; i++) {
			const aValue = resolvePath(a, propertyPath[i]);
			const bValue = resolvePath(b, propertyPath[i]);
	
			if (typeof aValue === 'string' && typeof bValue === 'string') {
				const comparison = aValue.localeCompare(bValue);
				if (comparison !== 0) return ascending ? comparison : -comparison;
			} else {
				if (aValue < bValue) return ascending ? -1 : 1;
				if (aValue > bValue) return ascending ? 1 : -1;
			}
		}
		return 0; // if all criteria are equal
	});	
}

Utils.convertFileToBase64 = function (file, callback) {
	const reader = new FileReader();
	reader.onload = function(e) {
		callback(e.target.result);
	};
	reader.readAsDataURL(file);
}

$(function () {
	window.addEventListener('message', function (event) {
		var item = event.data;
		if (item.notification) {
			if (item.notification_type == "success") {
				vt.successo(item.notification,{
					position: "top-right",
					duration: 8000
				});
			} else if (item.notification_type == "info") {
				vt.importante(item.notification,{
					position: "top-right",
					duration: 8000
				});
			} else if (item.notification_type == "warning") {
				vt.aviso(item.notification,{
					position: "top-right",
					duration: 8000
				});
			} else if (item.notification_type == "error") {
				vt.erro(item.notification,{
					position: "top-right",
					duration: 8000
				});
			}
		}
		if (item.dark_theme != undefined) {
			if(item.dark_theme == 0){
				// Light theme
				$('#utils-css-light').prop('disabled', false);
				$('#utils-css-dark').prop('disabled', true);
			} else if(item.dark_theme == 1){
				// Dark theme
				$('#utils-css-dark').prop('disabled', false);
				$('#utils-css-light').prop('disabled', true);
			}
		}
	});

	document.onkeyup = function(data){
		if (data.key == 'Escape'){
			if ($("#confirmation-modal").is(":visible")){
				$('#confirmation-modal').modal('hide');
			} else if ($(".main").is(":visible")){
				$(".modal").modal('hide');
				Utils.post("close","")
			}
		}
	};

	// Notification
	(() => {
		const toastPosition = {
			TopLeft: "top-left",
			TopCenter: "top-center",
			TopRight: "top-right",
			BottomLeft: "bottom-left",
			BottomCenter: "bottom-center",
			BottomRight: "bottom-right"
		}

		const toastPositionIndex = [
			[toastPosition.TopLeft, toastPosition.TopCenter, toastPosition.TopRight],
			[toastPosition.BottomLeft, toastPosition.BottomCenter, toastPosition.BottomRight]
		]

		const svgs = {
			successo: '<svg viewBox="0 0 426.667 426.667" width="18" height="18"><path d="M213.333 0C95.518 0 0 95.514 0 213.333s95.518 213.333 213.333 213.333c117.828 0 213.333-95.514 213.333-213.333S331.157 0 213.333 0zm-39.134 322.918l-93.935-93.931 31.309-31.309 62.626 62.622 140.894-140.898 31.309 31.309-172.203 172.207z" fill="#6ac259"></path></svg>',
			aviso: '<svg viewBox="0 0 310.285 310.285" width=18 height=18> <path d="M264.845 45.441C235.542 16.139 196.583 0 155.142 0 113.702 0 74.743 16.139 45.44 45.441 16.138 74.743 0 113.703 0 155.144c0 41.439 16.138 80.399 45.44 109.701 29.303 29.303 68.262 45.44 109.702 45.44s80.399-16.138 109.702-45.44c29.303-29.302 45.44-68.262 45.44-109.701.001-41.441-16.137-80.401-45.439-109.703zm-132.673 3.895a12.587 12.587 0 0 1 9.119-3.873h28.04c3.482 0 6.72 1.403 9.114 3.888 2.395 2.485 3.643 5.804 3.514 9.284l-4.634 104.895c-.263 7.102-6.26 12.933-13.368 12.933H146.33c-7.112 0-13.099-5.839-13.345-12.945L128.64 58.594c-.121-3.48 1.133-6.773 3.532-9.258zm23.306 219.444c-16.266 0-28.532-12.844-28.532-29.876 0-17.223 12.122-30.211 28.196-30.211 16.602 0 28.196 12.423 28.196 30.211.001 17.591-11.456 29.876-27.86 29.876z" fill="#FFDA44" /> </svg>',
			importante: '<svg viewBox="0 0 23.625 23.625" width=18 height=18> <path d="M11.812 0C5.289 0 0 5.289 0 11.812s5.289 11.813 11.812 11.813 11.813-5.29 11.813-11.813S18.335 0 11.812 0zm2.459 18.307c-.608.24-1.092.422-1.455.548a3.838 3.838 0 0 1-1.262.189c-.736 0-1.309-.18-1.717-.539s-.611-.814-.611-1.367c0-.215.015-.435.045-.659a8.23 8.23 0 0 1 .147-.759l.761-2.688c.067-.258.125-.503.171-.731.046-.23.068-.441.068-.633 0-.342-.071-.582-.212-.717-.143-.135-.412-.201-.813-.201-.196 0-.398.029-.605.09-.205.063-.383.12-.529.176l.201-.828c.498-.203.975-.377 1.43-.521a4.225 4.225 0 0 1 1.29-.218c.731 0 1.295.178 1.692.53.395.353.594.812.594 1.376 0 .117-.014.323-.041.617a4.129 4.129 0 0 1-.152.811l-.757 2.68a7.582 7.582 0 0 0-.167.736 3.892 3.892 0 0 0-.073.626c0 .356.079.599.239.728.158.129.435.194.827.194.185 0 .392-.033.626-.097.232-.064.4-.121.506-.17l-.203.827zm-.134-10.878a1.807 1.807 0 0 1-1.275.492c-.496 0-.924-.164-1.28-.492a1.57 1.57 0 0 1-.533-1.193c0-.465.18-.865.533-1.196a1.812 1.812 0 0 1 1.28-.497c.497 0 .923.165 1.275.497.353.331.53.731.53 1.196 0 .467-.177.865-.53 1.193z" fill="#006DF0" /> </svg>',
			erro: '<svg viewBox="0 0 51.976 51.976" width=18 height=18> <path d="M44.373 7.603c-10.137-10.137-26.632-10.138-36.77 0-10.138 10.138-10.137 26.632 0 36.77s26.632 10.138 36.77 0c10.137-10.138 10.137-26.633 0-36.77zm-8.132 28.638a2 2 0 0 1-2.828 0l-7.425-7.425-7.778 7.778a2 2 0 1 1-2.828-2.828l7.778-7.778-7.425-7.425a2 2 0 1 1 2.828-2.828l7.425 7.425 7.071-7.071a2 2 0 1 1 2.828 2.828l-7.071 7.071 7.425 7.425a2 2 0 0 1 0 2.828z" fill="#D80027" /> </svg>'
		}

		const styles = `
			.vt-container {
				position: fixed;
				width: 100%;
				height: 100vh;
				top: 0;
				left: 0;
				z-index: 9999;
				display: flex;
				flex-direction: column;
				justify-content: space-between;
				pointer-events: none;
			}

			.vt-row {
				display: flex;
				justify-content: space-between;
			}

			.vt-col {
				flex: 1;
				margin: 10px 20px;
				display: flex;
				flex-direction: column;
				align-items: center;
			}

			.vt-col.top-left,
			.vt-col.bottom-left {
				align-items: flex-start;
			}

			.vt-col.top-right,
			.vt-col.bottom-right {
				align-items: flex-end;
			}

			.vt-card {
				display: flex;
				justify-content: center;
				align-items: center;
				padding: 12px 20px;
				box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
				border-radius: 4px;
				margin: 0px;
				transition: 0.3s all ease-in-out;
				pointer-events: all;
				border-left: 3px solid #8b8b8b;
				cursor: pointer;
			}

			.vt-card.successo {
				border-left: 3px solid #6ec05f;
			}

			.vt-card.aviso {
				border-left: 3px solid #fed953;
			}

			.vt-card.importante {
				border-left: 3px solid #1271ec;
			}

			.vt-card.erro {
				border-left: 3px solid #d60a2e;
			}

			.vt-card .text-group {
				margin-left: 15px;
			}

			.vt-card h4 {
				margin: 0;
				margin-bottom: 10px;
				font-size: 16px;
				font-weight: 500;
			}

			.vt-card p {
				margin: 0;
				font-size: 14px;
			}
		`

		const styleSheet = document.createElement("style")
		styleSheet.innerText = styles.replace((/  |\r\n|\n|\r/gm), "")
		document.head.appendChild(styleSheet)

		const vtContainer = document.createElement("div")
		vtContainer.className = "vt-container"

		for (const ri of [0, 1]) {
			const row = document.createElement("div")
			row.className = "vt-row"

			for (const ci of [0, 1, 2]) {
				const col = document.createElement("div")
				col.className = `vt-col ${toastPositionIndex[ri][ci]}`

				row.appendChild(col)
			}

			vtContainer.appendChild(row)
		}

		document.body.appendChild(vtContainer)

		window.vt = {
			options: {
				title: undefined,
				position: toastPosition.TopCenter,
				duration: 10000,
				closable: true,
				focusable: true,
				callback: undefined
			},
			successo(message, options) {
				show(message, options, "successo")
			},
			importante(message, options) {
				show(message, options, "importante")
			},
			aviso(message, options) {
				show(message, options, "aviso")
			},
			erro(message, options) {
				show(message, options, "erro")
			}
		}

		function show(message = "", options, type) {
			options = { ...window.vt.options, ...options }

			const col = document.getElementsByClassName(options.position)[0]

			const vtCard = document.createElement("div")
			vtCard.className = `vt-card ${type}`
			vtCard.innerHTML += svgs[type]
			vtCard.options = {
				...options, ...{
					message,
					type: type,
					yPos: options.position.indexOf("top") > -1 ? "top" : "bottom",
					isFocus: false
				}
			}

			setVTCardContent(vtCard)
			setVTCardIntroAnim(vtCard)
			setVTCardBindEvents(vtCard)
			autoDestroy(vtCard)

			

			col.appendChild(vtCard)
		}

		function setVTCardContent(vtCard) {
			const textGroupDiv = document.createElement("div")

			textGroupDiv.className = "text-group"

			if (vtCard.options.title) {
				textGroupDiv.innerHTML = `<h4>${vtCard.options.title}</h4>`
			}

			textGroupDiv.innerHTML += `<p>${vtCard.options.message}</p>`

			vtCard.appendChild(textGroupDiv)
		}

		function setVTCardIntroAnim(vtCard) {
			vtCard.style.setProperty(`margin-${vtCard.options.yPos}`, "-15px")
			vtCard.style.setProperty("opacity", "0")

			setTimeout(() => {
				vtCard.style.setProperty(`margin-${vtCard.options.yPos}`, "15px")
				vtCard.style.setProperty("opacity", "1")
			}, 50)
		}

		function setVTCardBindEvents(vtCard) {
			vtCard.addEventListener("click", () => {
				if (vtCard.options.closable) {
					destroy(vtCard)
				}
			})

			vtCard.addEventListener("mouseover", () => {
				vtCard.options.isFocus = vtCard.options.focusable
			})

			vtCard.addEventListener("mouseout", () => {
				vtCard.options.isFocus = false
				autoDestroy(vtCard, vtCard.options.duration)
			})
		}

		function destroy(vtCard) {
			vtCard.style.setProperty(`margin-${vtCard.options.yPos}`, `-${vtCard.offsetHeight}px`)
			vtCard.style.setProperty("opacity", "0")

			setTimeout(() => {
				if(typeof x !== "undefined"){
					vtCard.parentNode.removeChild(v)

					if (typeof vtCard.options.callback === "function") {
						vtCard.options.callback()
					}
				}
			}, 500)
		}

		function autoDestroy(vtCard) {
			if (vtCard.options.duration !== 0) {
				setTimeout(() => {
					if (!vtCard.options.isFocus) {
						destroy(vtCard)
					}
				}, vtCard.options.duration)
			}
		}
	})()
});