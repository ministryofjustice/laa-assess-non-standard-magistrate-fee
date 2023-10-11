# Events

Events are stored in the DB `events` table. We currently have two main type of events:

* Claim History events - these are events that appear on the `Claim History` tab
* Edit events - these are events that track changes to the claim data, these appear
  in the edit screen to show what has previously been chnaged to a record.

## Event type

We are using the rails STI (Single table Inheritance) feature, this allows use to have
a dedicated class for each event type. Each class is then responsible for implementing
the following methods:

* build - this is used to create a new instance of each Event, the standard `new` and
  `create` methods have been marked as private to avoid creating events in this manner.
* title - this is use in the `Claim History` tab as the bolded section of the `What`
  area, and defaults to the `<event_class>.title` in the locale file
* body - this is use in the `Claim History` tab as the non-bolded section of the `What`
  area, and defaults to an empty string.

## Creating new event records

Each event should store the information that is relevant to the event in the build
method, for simple events (NewVersion) it could be as simple as the event type and
claim, with no other information being required. For data changes it is expected
that the `field`, `from` and `to` values with be stored in the `data` field (example 1),
and if it is a numerical change, then the `delta` (example 2) should also be stored.


If the edit is to a sub object (work item, disbursement or letters and calls) then
the linked_type and link_id (unless letters and calls) should also be set.

The secondary user is expected to be set when an event with multiple users exists
(i.e. CaseAssignment), however it may prove this would be better achieved by storing
the secondard user in the `data` json.

```ruby
# Example 1
class Event::RiskChange
  def build(claim:, previous_risk:)
  	create(
  	  claim: claim,
  	  claim_version: claim.current_version
      details: {
        field: 'risk',
        from: previous_risk,
        to: claim.risk
      }
    )
  end
end

# Example 2
class Event::WorkItemTimeChange
  def build(claim:, work_item:, previous_time_spent:, current_user:)
    create(
      claim: claim,
      claim_version: claim.current_version
      primary_user: current_user,
      linked_type: 'work_item',
      linked_id: work_item.id,
      details: {
        field: 'time_psent',
        from: previous_time_spent,
        to: work_item.time_spent
        delta: work_item.time_spent - previous_time_spent
      }
    )
  end
end
```

## Identifier information

When looking at the planned text of the events it might make sense to includes some/all
of the desired identification data in the event record itself. This is open for discussion
and should be decided by the user as they work on events that have this requirement.

This needs greater consideration when the identifiers themselves are subject to change,
as is the case with the work item `type`.

## Transactions

Are events required to be generated in a transaction with the underlying data chnage that
triggered the event? In general this is a good idea as it enforces the system to never
get out of sync between the raw data and the change events.

This needs more discussion between the wider team to ensure we have agreement on the approach
for this.

## What is the delta for?

The plan was that by adding the delta's it would be easy to calculate the total chnage on
a field since a previous version - as a field can be changed multiple times. This is
generally easier to do in postgres that picking the first record. This needs to be tested
to ensure that it works as a sound theory in practise.
