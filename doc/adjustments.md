# Adjustments

Adjustments are tracked via the events table as we only store the current state of the claim in the main JSON record.

## Calculating the initial state

As we only store the current value of claim (i.e. after any adjustments have been applied) when we need to display the provider requested amounts in the view we need to calculate this using the event data stream.

To avoid N+1 queries when doing this calulation in the index screen the `BaseViewModel` the build method loads and applies the adjustment data to each instance created. This allows the logic for this to be isolated within the application and avoid it being repeated in multiple ways in different locations.

To determine the initial value we look at the from value on the first adjustment (sorted by created at).

## View model

In order to load adjustments on a view model the following needs to be present:

* `LINKED_TYPE` - this is used to select the adjustments (events) required to be loaded vased on the `linked_type` field on teh event record
* `< BaseWithAdjustments` - we need to inherit from this class as it add the `adjustments` attribute and `value_from_first_event` helper.

## Form object

The `BaseAdjustmentForm` acts as the base when making adjustments to the data. It provides the following helps:

* `process_field` - which generates the `Event::Edit` records as required.
* `linked` - provides standard approach to linking the `Event` record to the current data record - this is currently overwritten for letters and calls, however this will be adjusted to provide a standard interface moving forward
* `claim`,`explanation`, `current_user` and `item` attributes which are required to make the underlying implemenation work

In order to use this form the following method need to be implemented:

* `data_has_changed?` - this requires true if no data has been changed during this edit (i.e. against the current JSON values)
* `selected_record` - this is the hash of data the adjustment will change - this needs to be pointing to the same object as stored in the claim JSON, as this ensure after updating the data in the `selected_record` hash, saving the claim record will write the update to the DB
* `save` - does what it says on the tin - should use the `process_field` method to create the required events

### The item object

The item object is the `ViewModel` representation of the data being changed. This is useful as it allows the lookup of the provider requested value and avoid having the logic for that in multiple places.
