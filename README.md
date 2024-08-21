# Dynamic Row Refresh with Custom Templates in Oracle APEX

## Overview

This Oracle APEX Dynamic Action plug-in allows you to refresh individual rows in a report or any region based on a custom template. It’s particularly useful when you want to update a specific row without refreshing the entire report, which can be crucial for maintaining user experience in long or paginated reports.

![image](preview.gif)

## Features

- Dynamically refreshes a single row in a region based on user interaction.
- Supports custom templates with dynamic PL/SQL conditions for row rendering.
- Maintains APEX as the single source of truth by evaluating the same conditions as APEX does for template selection.
- Flexibility to use the plug-in across different report regions.

## Attributes

| Attribute Name          | Description                                                                                         | Example                                                   |
|-------------------------|-----------------------------------------------------------------------------------------------------|-----------------------------------------------------------|
| **SQL Query**           | A PL/SQL block that returns the specific row data. Ensure that all bind or substitution variables used in the template condition are part of this query. | `SELECT * FROM my_table WHERE id = :P1_ITEM1`               |
| **Template Name**            | The name of the template used for rendering the row. The correct row template is selected based on the evaluated PL/SQL expression (template condition). | `My Custom Template`                                    |
| **Region Static ID**      | The Static ID from the region where the report is rendered in. The plug-in needs it to find metadata set for the columns, e.g. HTML Expressions (without Template Directives). | `p250_cr_tasks`                                         |
| **jQuery Selector**      | A jQuery selector that targets the row closest to the triggering element. The plug-in searches for the first occurrence of this selector starting from the triggering element. | `tr[data-row-id]`                                         |
| **Row Identifier**            | The name of the page-item used for identifying the row. The plug-in will go through all data attributes of the matched items for the `jQuery Selector` to identify the correct row. | `P1_ITEM1`                                    |
| **Show Spinner**            | Shows a spinner on the matched element before replacing the identified row, removes it when it's replaced. Only possible when `Row Indentifier` is provided. | `Yes/No`                                   |
| **Items to Submit** | A comma-separated list of page items to submit to the server for session state management. Ensure all necessary page items used in the query and conditions are included here. | `P1_ITEM1,P1_ITEM2`                                       |

## Plug-in Settings

- **Wait for Result**: Since the plug-in dynamically fetches and updates row content from the server, you want to ensure the operation completes before continuing. This ensures the row is only updated when new content is ready, preventing potential issues like multiple simultaneous updates. 
- **Throttle or Debounce**: For plug-in triggered by user interactions (e.g., typing in a search field), consider adding a throttle or debounce option. This limits how often the plug-in can be triggered within a certain time frame, reducing unnecessary server calls and improving performance.

## Usage Examples

### Dynamic Action on Browser Events (e.g. Click, Lose Focus)

1. **Create a Dynamic Action** in your page.
2. **Execution**
    - **Event Scope**: `Dynamic`
    - **Static Container (jQuery Selector)**: `#p1_table`
    - **Type**: `Immediate`
3. **When**
    - **Event**: `Click`
    - **Selection Type**: `jQuery Selector`
    - **jQuery Selector**: `tr[data-row-id]`
4. **Action**: `Set Value`
    - **Settings**:
        - **Set Type**: `Javascript Expression`
        - **Javascript Expression**: `this.triggeringElement.value`
    - **Affected Elements**:
        - **Selection Type**: `Item(s)`
        - **Item(s)**: `P1_ITEM1`
5. **Action**: `SMART4Solutions Rowrefresh [Plug-in]`
    - **Settings**:
        - **jQuery Selector**: `tr[data-row-id]`
        - **Template Name**: `'My Custom Template'`
    - **Source**:
        - **SQL Query**: `SELECT * FROM my_table WHERE id = :P1_ITEM1`
        - **Items to Submit**: `P1_ITEM1,P1_ITEM2`
    - **Execution**
        - **Stop Execution On Error**: `Yes` (optional, based on your needs)
        - **Wait for Result**: `Yes`

### Dynamic Action on Framework Events (e.g. Dialog Closed)

1. **Create a Dynamic Action** in your page.
2. **Execution**
    - **Event Scope**: `Static`
    - **Type**: `Immediate`
3. **When**
    - **Event**: `Dialog Closed`
    - **Selection Type**: `Region`
    - **Region**: `Cards`
4. **Action**: `Set Value`
    - **Settings**:
        - **Set Type**: `Dialog Return Item`
        - **Return Item**: `P2_ID`
    - **Affected Elements**:
        - **Selection Type**: `Item(s)`
        - **Item(s)**: `P1_ITEM1`
5. **Action**: `SMART4Solutions Rowrefresh [Plug-in]`
    - **Settings**:
        - **jQuery Selector**: `tr[data-row-id]`
        - **Row Identifier**: `P1_ITEM1`
        - **Template**: `'My Custom Template'`
    - **Source**:
        - **SQL Query**: `SELECT * FROM my_table WHERE id = :P1_ITEM1`
        - **Items to Submit**: `P1_ITEM1,P1_ITEM2`
    - **Execution**
        - **Stop Execution On Error**: `Yes` (optional, based on your needs)
        - **Wait for Result**: `Yes`

## Installation

1. Download and import the plug-in file into your APEX application.
2. Configure the plug-in by setting the required attributes.
3. Use the plug-in in your dynamic actions as described above.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Contribution

Feel free to contribute to the project by opening issues or submitting pull requests.