var s4s = s4s || {}
s4s.apex = s4s.apex || {};

s4s.apex.rowrefresh = {
    // Initialize the module
    'init': function () {
        s4s.apex.rowrefresh.handleChange(this.action, this.triggeringElement);
    },

    // Handle the change event
    'handleChange': function (action, element) {
        let elementSelector = action.attribute01;
        let rowIdentifier = apex.item(action.attribute05).getValue();
        let showSpinner = action.attribute06;
        let spinnerElement, matchedElement, matchedAttribute = null;

        // Convert the page items attribute to a selector string
        let pageItemsSelector = action.attribute04
            .split(',')
            .map(function (item) { return '#' + item.trim(); })
            .join(',');

        console.debug('handleChange: submitting page items', pageItemsSelector);

        if (rowIdentifier) {
            // Iterate over each matching element when the row identifier is available
            document.querySelectorAll(elementSelector).forEach(function (element) {
                // Loop through all data attributes to find a match
                for (let attr of element.attributes) {
                    if (attr.name.startsWith('data-') && attr.value === rowIdentifier) {
                        matchedElement = element;
                        matchedAttribute = attr.name;
                        return true;  // Breaks the loop
                    }
                }
            });

            if (showSpinner === 'Y') {
                let selector = matchedElement ? `.${matchedElement.classList[0]}[${matchedAttribute}="${rowIdentifier}"]` : null;
                console.debug('handleChange: apply spinner on', selector);

                spinnerElement = apex.util.showSpinner(selector);
            }
        } else {
            // Fallback to the closest matching element if no identifier is provided
            matchedElement = element.closest(elementSelector);
        }

        if (matchedElement) {
            // Make an AJAX call to fetch the data
            s4s.apex.rowrefresh.fetchRowData(action.ajaxIdentifier, pageItemsSelector).then(function (data) {
                // Add apex event for successful refresh
                apex.event.trigger(matchedElement, 'after_refresh');

                // Replace the element with the new data
                matchedElement.outerHTML = data.row_html;
            }).catch(function (error) {
                console.error('Error fetching row data:', error);
            }).finally(function () {
                if (showSpinner === 'Y' && spinnerElement) {
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
                pageItems: pageItems
            }, {
                success: function (data) {
                    resolve(data);
                },
                error: function (error) {
                    reject(error);
                }
            });
        });
    }
}
