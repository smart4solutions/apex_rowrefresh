if (typeof s4s === 'undefined') {
    var s4s = {};
}
s4s.apex = s4s.apex || {};

s4s.apex.rowrefresh = {
    // Initialize the module
    'init': function() {
        s4s.apex.rowrefresh.handleChange(this.action, this.triggeringElement);
    },

    // Handle the change event
    'handleChange': function (action, element) {
        var elementSelector = action.attribute01;
        var rowIdentifier = apex.item(action.attribute05).getValue();
        var $matchedElement = null;

        // Convert the page items attribute to a jQuery selector string
        var pageItemsSelector = action.attribute04
            .split(',')
            .map(function(item) { return '#' + item.trim(); })
            .join(',');

        // Make an AJAX call to fetch the data
        s4s.apex.rowrefresh.fetchRowData(action.ajaxIdentifier, pageItemsSelector).then(function(data) {
            if (rowIdentifier) {
                // Iterate over each matching element when the row identifier is available
                $(elementSelector).each(function () {
                    var $element = $(this);

                    // Loop through all data attributes to find a match
                    $.each(this.dataset, function (key, value) {
                        if (value === rowIdentifier) {
                            $matchedElement = $element;
                            return false;
                        }
                    });

                    if ($matchedElement) {
                        return false;
                    }
                });
            } else {
                // Fallback to the first closest element if no identifier is provided
                $matchedElement = $(element).closest(elementSelector).first();
            }

            if ($matchedElement && $matchedElement.length) {
                // Add apex event for succesfull refresh
                apex.event.trigger($matchedElement, 'after_refresh');
                // Replace the element with the new data
                $matchedElement.html(data.row_html);
            } else {
                console.error('Element not found for selector: ', elementSelector);
            }
        }).catch(function(error) {
            console.table(error);
        });
    },

    // Fetch the row data using AJAX
    'fetchRowData': function (ajaxIdentifier, pageItems) {
        return new Promise(function(resolve, reject) {
            apex.server.plugin(ajaxIdentifier, {
                pageItems: pageItems
            }, {
                success: function(data) {
                    resolve(data);
                },
                error: function(error) {
                    reject(error);
                }
            });
        });
    }
}