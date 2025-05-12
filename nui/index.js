let Utils = {};

let locale;
let format;
Utils.translate = function (key) {
    if (!Lang.hasOwnProperty(locale)) {
        console.warn(`Language '${locale}' is not available. Using default 'en'.`);
        locale = "en";
    }

    let langObj = Lang[locale];
    const keys = key.split(".");

    for (const k of keys) {
        if (!langObj.hasOwnProperty(k)) {
            console.warn(`Translation key '${key}' not found for language '${locale}'.`);
            return "missing_translation";
        }
        langObj = langObj[k];
    }

    return langObj;
};

Utils.setLocale = function (current_locale) {
    locale = current_locale;
};

Utils.setFormat = function (current_format) {
    format = current_format;
};

Utils.loadLanguageFile = async function () {
    try {
        await new Promise((resolve, reject) => {
            let fileUrl = `lang/${locale}.js`;
            const script = document.createElement("script");
            script.src = fileUrl;

            script.onload = () => {
                resolve();
            };

            script.onerror = (event) => {
                reject(new Error("Failed to load language file: " + fileUrl));
            };

            document.body.appendChild(script);

            const timeoutDuration = 10000; // 10 seconds
            setTimeout(() => {
                reject(new Error("Timeout: The script took too long to load the language file: " + fileUrl));
            }, timeoutDuration);
        });
    } catch (error) {
        if (locale !== "en") {
            console.warn(`Language '${locale}' is not available. Using default 'en'.`);
            Utils.setLocale("en");
            await Utils.loadLanguageFile();
        } else {
            throw error;
        }
    }
};

Utils.loadLanguageModules = async function (utils_module) {
    Utils.setLocale(utils_module.config.locale);
    Utils.setFormat(utils_module.config.format);
    await Utils.loadLanguageFile();
    Utils.deepMerge(Lang,utils_module.lang);
};

Utils.timeConverter = function (UNIX_timestamp, options = {}) {
    const timestampMillis = UNIX_timestamp * 1000;
    const formattedTime = new Date(timestampMillis).toLocaleString(locale, options);

    return formattedTime;
};

Utils.currencyFormat = function (number, decimalPlaces = null) {
    const options = {
        style: "currency",
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
        style: "currency",
        currency: format.currency,
        minimumFractionDigits: 0,
        maximumFractionDigits: 0,
    };

    return new Intl.NumberFormat(locale, options).format(0).replace(/\d/g, "").trim();
};

const requestQueue = [];
let isProcessing = false;

const processQueue = async () => {
    if (!isProcessing && requestQueue.length > 0) {
        isProcessing = true;
        const { event, data, route, cb } = requestQueue.shift();
        try {
            const response = await fetch(Utils.getRoute(route), {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
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

Utils.post = function (event, data, route = "post", cb) {
    requestQueue.push({ event, data, route, cb });
    processQueue();
};

let resource_name;
Utils.getRoute = function (name) {
    return `https://${resource_name}/${name}`;
};

Utils.setResourceName = function (current_resource_name) {
    resource_name = current_resource_name;
};

Utils.deepMerge = function (target, source) {
    for (const key in source) {
        if (source.hasOwnProperty(key)) {
            if (typeof source[key] === "function") {
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

Utils.showDefaultModal = function (action, body = Utils.translate("confirmation_modal_body")) {
    Utils.showCustomModal({
        title: Utils.translate("confirmation_modal_title"),
        body,
        buttons: [
            { text: Utils.translate("confirmation_modal_cancel_button"), class: "btn btn-outline-primary", dismiss: true },
            { text: Utils.translate("confirmation_modal_confirm_button"), class: "btn btn-primary", dismiss: true, action },
        ],
    });
};

Utils.showDefaultDangerModal = function (action, body = Utils.translate("confirmation_modal_body")) {
    Utils.showCustomModal({
        title: Utils.translate("confirmation_modal_title"),
        body,
        buttons: [
            { text: Utils.translate("confirmation_modal_cancel_button"), class: "btn btn-outline-danger", dismiss: true },
            { text: Utils.translate("confirmation_modal_confirm_button"), class: "btn btn-danger", dismiss: true, action },
        ],
    });
};
/*
const exampleConfig = {
    title: 'Custom Modal Title',
    body: 'Custom Modal Body Text',
    bodyHtml: '<p>Custom Modal Body Text that accept HTML</p>',
    bodyImage: "https://shuffle.dev/randomizer/saas/bootstrap-pstls/1.0.0/static_elements/footer/10_awz.jpg",
    footerText: "Custom Footer Text",
    buttons: [
        { text: Utils.translate('confirmation_modal_cancel_button'), class: 'btn btn-outline-primary', dismiss: true },
        { text: Utils.translate('confirmation_modal_confirm_button'), class: 'btn btn-primary', dismiss: false, action: () => console.log('Confirmed') }
        { text: 'Submit', class: 'btn btn-primary', dismiss: false, type: 'submit' }
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
    onSubmit: function(formData) {
        console.log("Form submitted with input values:", [...formData]);
        let amount = formData.get("number-input-name"); // Get by element name
        // You can perform further actions with the input values here
    }
};
*/
Utils.showCustomModal = function (config) {
    // Check if the modal already exists
    const $existingModal = $("#confirmation-modal");
    if ($existingModal.length > 0) {
        return;
    }

    const modalConfig = {
        title: Utils.translate("confirmation_modal_title"),
        buttons: [],
        inputs: [],
    };

    // Merge the provided config with the default modalConfig
    const mergedConfig = { ...modalConfig };
    Utils.deepMerge(mergedConfig, config);

    // Append the modal HTML to the body
    $("body").append(modalTemplate);

    // Cache the modal element
    const $modal = $("#confirmation-modal");
    const $modalBody = $modal.find(".modal-body");

    // Set modal content
    $modal.find(".modal-title").text(mergedConfig.title);

    if (mergedConfig.bodyImage) {
        const $imageContainer = $("<div>", { class: "d-flex justify-content-center m-2" });
        const $image = $("<img>", { src: mergedConfig.bodyImage, class: "w-50" });
        $imageContainer.append($image);
        $modalBody.append($imageContainer);
    }

    if (mergedConfig.body) {
        const $p = $("<p>", { id: "modal-body-text", text: mergedConfig.body });
        $modalBody.append($p);
    }

    if (mergedConfig.bodyHtml) {
        $modalBody.append(mergedConfig.bodyHtml);
    }

    // Set modal inputs
    const $form = $modal.find("#form-confirmation-modal");
    mergedConfig.inputs.forEach(inputConfig => {
        const $inputContainer = $("<div>", { class: "form-group mx-2" });

        if (inputConfig.type === "select") {
            const $label = $("<label>", { text: inputConfig.label, for: inputConfig.id });
            const $select = $("<select>", { class: "form-control", id: inputConfig.id, name: inputConfig.name, required: inputConfig.required });
            if (!Array.isArray(inputConfig.options)) {
                inputConfig.options = Object.values(inputConfig.options);
            }
            inputConfig.options.forEach(option => {
                const $option = $("<option>", { value: option.value, text: option.text });
                $select.append($option);
            });
            $inputContainer.append($label, $select);
        } else if (inputConfig.type === "checkbox") {
            const $checkboxContainer = $("<div>", { class: "form-check" });
            const $label = $("<label>", { for: inputConfig.id, class: "form-check-label" });
            const $input = $("<input>", { type: "checkbox", class: "form-check-input", id: inputConfig.id, name: inputConfig.name, required: inputConfig.required });
            $label.text(inputConfig.label);
            $inputContainer.append($checkboxContainer.append($input, $label));
        } else if (inputConfig.type === "slider" || inputConfig.type === "range") {
            const $label = $("<label>", { text: inputConfig.label, for: inputConfig.id });
            if (!inputConfig.default) {
                inputConfig.default = inputConfig.max ?? 100;
            }
            let range_slider = `
                <div class="range-slider mt-2" style='--min:${inputConfig.min || 0}; --max:${inputConfig.max || 100}; --step:${inputConfig.step || 1}; --value:${inputConfig.default}; --text-value:"${inputConfig.default}"; --prefix:"${inputConfig.isCurrency ? Utils.getCurrencySymbol() : ""} ";'>
                    <input id="${inputConfig.id}" name="${inputConfig.name}" type="range" min="${inputConfig.min || 0}" max="${inputConfig.max || 100}" step="${inputConfig.step || 1}" value="${inputConfig.default}" oninput="this.parentNode.style.setProperty('--value',this.value); this.parentNode.style.setProperty('--text-value', JSON.stringify(this.value))">
                    <output></output>
                    <div class='range-slider__progress'></div>
                </div>`;
            $inputContainer.append($label, range_slider);
        } else if (inputConfig.type === "custom") {
            const $customInput = $(inputConfig.html);
            $inputContainer.append($customInput);
        } else {
            const $label = $("<label>", { text: inputConfig.label, for: inputConfig.id });
            const $input = $("<input>", { type: inputConfig.type, class: "form-control", id: inputConfig.id, name: inputConfig.name, required: inputConfig.required, placeholder: inputConfig.placeholder, min: inputConfig.min, max: inputConfig.max, value: inputConfig.value });
            $inputContainer.append($label, $input);
        }
        if (inputConfig.small) {
            const $small = $("<small>", { text: inputConfig.small, class: "text-muted", style: "font-size: 12px;" });
            $inputContainer.append($small);
        }
        $modalBody.append($inputContainer);
    });

    if (mergedConfig.footerText) {
        const $p = $("<p>", { id: "modal-footer-text", text: mergedConfig.footerText });
        $modalBody.append($p);
    }

    // Set modal buttons
    const $footer = $modal.find(".modal-footer");
    $footer.empty();
    mergedConfig.buttons.forEach(button => {
        const $button = $("<button>", { class: button.class, text: button.text, type: button.type ?? "button" });
        if (button.dismiss) {
            $button.attr("data-dismiss", "modal");
        }
        if (button.action) {
            $button.on("click", button.action);
        }
        $footer.append($button);
    });

    // Set modal form submit
    $form.on("submit", function (e) {
        e.preventDefault();

        if (config.onSubmit) {
            config.onSubmit(new FormData(e.target));
        }
        $modal.modal("hide");
    });

    // Show the modal
    $modal.modal({ show: true });

    // Remove the modal from the DOM when hidden
    $modal.on("hidden.bs.modal", function () {
        setTimeout(() => {
            $(this).remove();
        }, 50);
    });
};

if (!String.prototype.format) {
    String.prototype.format = function() {
        let args = arguments;
        return this.replace(/{(\d+)}/g, function(match, number) {
            return typeof args[number] != "undefined"
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
    textbox.setCustomValidity("");
    if (textbox.value === "") {
        textbox.setCustomValidity(Utils.translate("custom_validity.fill_field"));
    }
    else if (textbox.validity.typeMismatch) {
        textbox.setCustomValidity(Utils.translate("custom_validity.invalid_value"));
    }
    else if (textbox.validity.rangeUnderflow && min !== null) {
        textbox.setCustomValidity(Utils.translate("custom_validity.more_than").format(min));
    }
    else if (textbox.validity.rangeOverflow && max !== null) {
        textbox.setCustomValidity(Utils.translate("custom_validity.less_than").format(max));
    }
    else if (textbox.validity.stepMismatch) {
        textbox.setCustomValidity(Utils.translate("custom_validity.invalid_value"));
    }
    else if (textbox.validity.patternMismatch) {
        textbox.setCustomValidity(Utils.translate("custom_validity.pattern_mismatch"));
    }
    else if (textbox.validity.tooLong) {
        textbox.setCustomValidity(Utils.translate("custom_validity.too_long"));
    }
    else if (textbox.validity.tooShort) {
        textbox.setCustomValidity(Utils.translate("custom_validity.too_short"));
    }
    textbox.reportValidity();
    return true;
};

Utils.onInvalidInput = function (textbox) { // oninvalid="Utils.onInvalidInput(this)"
    textbox.setCustomValidity("");

    const elementType = textbox.tagName.toLowerCase(); // 'input', 'select', 'textarea'
    const inputType = elementType === "input" ? textbox.type.toLowerCase() : elementType; // 'text', 'email', 'select', etc.

    if (textbox.validity.valueMissing || textbox.value === "") {
        if (inputType == "select") {
            textbox.setCustomValidity(Utils.translate("custom_validity.select_fill_field"));
        } else {
            textbox.setCustomValidity(Utils.translate("custom_validity.fill_field"));
        }
    }
    else if (textbox.validity.typeMismatch || textbox.validity.badInput) {
        textbox.setCustomValidity(Utils.translate("custom_validity.invalid_value"));
    }
    else if (textbox.validity.rangeUnderflow) {
        const min = $(textbox).attr("min");
        textbox.setCustomValidity(Utils.translate("custom_validity.more_than").format(Utils.numberFormat(min)));
    }
    else if (textbox.validity.rangeOverflow) {
        const max = $(textbox).attr("max");
        textbox.setCustomValidity(Utils.translate("custom_validity.less_than").format(Utils.numberFormat(max)));
    }
    else if (textbox.validity.stepMismatch) {
        textbox.setCustomValidity(Utils.translate("custom_validity.invalid_value"));
    }
    else if (textbox.validity.patternMismatch) {
        textbox.setCustomValidity(Utils.translate("custom_validity.pattern_mismatch"));
    }
    else if (textbox.validity.tooLong) {
        textbox.setCustomValidity(Utils.translate("custom_validity.too_long"));
    }
    else if (textbox.validity.tooShort) {
        textbox.setCustomValidity(Utils.translate("custom_validity.too_short"));
    }
    return true;
};

/**
 * Sorts an object or an array of objects based on specified property paths.
 * If the input is an object, it converts it to an array of objects, including the original object's key as an `.id` property.
 * @param {Object|Array} input - The object or array to sort.
 * @param {Array|String} propertyPath - The path(s) to the property for sorting, can be a single path or an array of paths for multiple criteria.
 * @param {Boolean} ascending - Whether the sorting should be in ascending order. Defaults to true.
 * @returns {Array} - The sorted array of objects.
 */
Utils.sortElement = function(input, propertyPath, ascending = true) {
    let arrayToSort;

    // Convert input to an array of objects if it's not already one, including `.id`
    if (!Array.isArray(input)) {
        arrayToSort = Object.entries(input).map(([index, item]) => {
            if (item !== null && (typeof item === "object" || Array.isArray(item))) {
                return { ...item, id: item.id || index };
            } else {
                return { value: item, id: index };
            }
        });
    } else {
        arrayToSort = input.map((item, index) => ({
            ...item,
            id: item.id || index,
        }));
    }

    // Convert propertyPath to an array if it's not already one
    if (!Array.isArray(propertyPath)) {
        propertyPath = [propertyPath];
    }

    // A helper function to safely access nested properties
    const resolvePath = (object, path) => {
        return path.split(".").reduce((accumulator, currentValue) => {
            return accumulator ? accumulator[currentValue] : undefined;
        }, object);
    };

    // The sorting function
    return arrayToSort.sort((a, b) => {
        for (let i = 0; i < propertyPath.length; i++) {
            const aValue = resolvePath(a, propertyPath[i]);
            const bValue = resolvePath(b, propertyPath[i]);

            if (typeof aValue === "string" && typeof bValue === "string") {
                const comparison = aValue.localeCompare(bValue);
                if (comparison !== 0) return ascending ? comparison : -comparison;
            } else {
                if (aValue < bValue) return ascending ? -1 : 1;
                if (aValue > bValue) return ascending ? 1 : -1;
            }
        }
        return 0; // if all criteria are equal
    });
};

Utils.convertFileToBase64 = function (file, callback) {
    const reader = new FileReader();
    reader.onload = function(e) {
        callback(e.target.result);
    };
    reader.readAsDataURL(file);
};

$(function () {
    Utils.setResourceName("lc_utils");
    window.addEventListener("message", function (event) {
        let item = event.data;
        if (item.notification) {
            vt.showNotification(item.notification, {
                position: item.position,
                duration: item.duration,

                title: item.title,
                closable: true,
                focusable: false,
                callback: undefined,
            }, item.notification_type);
        }
        if (item.progress_bar) {
            Utils.progressBar.startProgress(item.progress_bar_id, item.duration, item.label, item.color);
        }
        if (item.dark_theme != undefined) {
            if (item.dark_theme == 0){
                // Light theme
                $("#utils-css-light").prop("disabled", false);
                $("#utils-css-dark").prop("disabled", true);
            } else if (item.dark_theme == 1){
                // Dark theme
                $("#utils-css-dark").prop("disabled", false);
                $("#utils-css-light").prop("disabled", true);
            }
        }
    });

    document.onkeyup = function(data){
        if (data.key == "Escape"){
            if ($("#confirmation-modal").is(":visible")){
                $("#confirmation-modal").modal("hide");
            } else if ($(".main").is(":visible")){
                $(".modal").modal("hide");
                Utils.post("close","");
            }
        }
    };
});