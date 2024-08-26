var s4s = s4s || {};
s4s.apex = s4s.apex || {};

s4s.apex.rowrefresh = {
    // Initialize the module
    'init': function () {
        s4s.apex.rowrefresh.handleChange(this.action, this.triggeringElement);
    },

    // Handle the change event
    'handleChange': function (action, triggeringElement) {
        let elementSelector = action.attribute01;
        let pageItems = action.attribute04;
        let rowIdentifier = apex.item(action.attribute05).getValue();
        let extraOptions = action.attribute08;
        let [matchedElement, matchedAttribute] = this.getMatchedElement(elementSelector, rowIdentifier, triggeringElement);

        if (extraOptions.includes('SHOW_SPINNER') && matchedElement) {
            var spinnerElement = this.showSpinner(matchedElement, matchedAttribute, rowIdentifier);
        }

        if (matchedElement) {
            this.fetchRowData(action.ajaxIdentifier, pageItems).then(function (data) {
                if (extraOptions.includes('USE_HANDLEBARS')) {
                    data.row_html = s4s.apex.rowrefresh.renderTemplate(data.row_html, data.row_data);
                }
                
                matchedElement.outerHTML = data.row_html;

                apex.event.trigger(matchedElement, 'after_refresh');
            }).catch(function (error) {
                console.error('Error fetching row data:', error);
            }).finally(function () {
                if (extraOptions.includes('SHOW_SPINNER') && spinnerElement) {
                    spinnerElement.remove();
                }
            });
        } else {
            console.error('Element not found for selector: ', elementSelector);
        }
    },

    // Fetch the row data using AJAX
    'fetchRowData': function (ajaxIdentifier, pageItems) {
        return new Promise(function (resolve, reject) {
            apex.server.plugin(ajaxIdentifier, {
                pageItems: pageItems.split(',').map(function (item) {
                    return '#' + item.trim();
                }).join(',')
            }, {
                success: resolve,
                error: reject
            });
        });
    },

    // Get the matched element based on the selector and row identifier
    'getMatchedElement': function (elementSelector, rowIdentifier, triggeringElement) {
        let matchedElement, matchedAttribute = null;
    
        if (rowIdentifier) {
            document.querySelectorAll(elementSelector).forEach(function (element) {
                for (let attr of element.attributes) {
                    if (attr.name.startsWith('data-') && attr.value === rowIdentifier) {
                        matchedElement = element;
                        matchedAttribute = attr.name;
                        return;  // Exit the loop early when a match is found
                    }
                }
            });
        } else {
            matchedElement = triggeringElement.closest(elementSelector);
        }
    
        return [matchedElement, matchedAttribute];
    },

    // Show a spinner on the matched element
    'showSpinner': function (matchedElement, matchedAttribute, rowIdentifier) {
        let spinnerSelector = `.${matchedElement.classList[0]}[${matchedAttribute}="${rowIdentifier}"]`;
        return apex.util.showSpinner(spinnerSelector);
    },

    // Render the template with Handlebars
    'renderTemplate': function (template, dataObject) {
        let handlebarsTemplate = template
            .replace(/{if (.*?)\/}/g, '{{#if $1}}')
            .replace(/{else\/}/g, '{{else}}')
            .replace(/{endif\/}/g, '{{/if}}');

        let compiledTemplate = Handlebars.compile(handlebarsTemplate);
        return compiledTemplate(dataObject);
    }
};
