# Assess non standard magistrates fee



## Seed data

To reduce the overhead and complexity of creating and updating seed data to rake
task have been added which can be used to either load the existing see data into
the system, or export data that has been generated via the Provide/App Store route.

### Loading data

```
rake custom_seeds:load
```

This reads the folders in db/seeds and loads the claim and the latest version data.
Any existing data for that claim will automatically be deleted during the import
process.

By default all folders are processed during the load.

### Storing data

```
rake custom_seeds:store[<claim_id>]
```

Records are stored based of the claim ID and need to be processed one at a time.
It is expected that records will be generated in teh Provider app and sent across
as apposed to being menually generated to avoid creating invalid data records.