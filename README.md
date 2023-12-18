# Assess non standard magistrates fee

* Ruby version
ruby 3.2.2

* Rails version
rails 7.0.42.0

## Getting Started

Clone the repository, and follow these steps in order.
The instructions assume you have [Homebrew](https://brew.sh) installed in your machine, as well as use some ruby version manager, usually [rbenv](https://github.com/rbenv/rbenv). If not, please install all this first.

**1. Pre-requirements**

* `brew bundle`
* `gem install bundler`
* `bundle install`

**2. Configuration**

* Copy `.env.development` to `.env.development.local` and modify with suitable values for your local machine
* Copy `.env.test` to `.env.test.local` and modify with suitable values for your local machine

```
# amend database url to use your local superuser role, typically your personal user
DATABASE_URL=postgresql://postgres@localhost/laa-claim-non-standard-magistrate-fee-dev
=>
DATABASE_URL=postgresql://john.smith@localhost/laa-claim-non-standard-magistrate-fee-dev
```

After you've defined your DB configuration in the above files, run the following:

* `bin/rails db:prepare` (for the development database)
* `RAILS_ENV=test bin/rails db:prepare` (for the test database)

**3. GOV.UK Frontend (styles, javascript and other assets)**

* `yarn install --frozen-lockfile`
* `rails assets:precompile` [require on first occassion at least]

**4. Database preparation**

## Seed data

To reduce the overhead and complexity of creating and updating seed data to rake
task have been added which can be used to either load the existing see data into
the system, or export data that has been generated via the Provide/App Store route.

### Loading data

```
rails custom_seeds:load
```

This reads the folders in db/seeds and loads the claim and the latest version data.
Any existing data for that claim will automatically be deleted during the import
process.

By default all folders are processed during the load.

### Storing data

```
rake custom_seeds:store[<claim_id>]
```

Records are stored based off of the claim ID and need to be processed one at a time.
It is expected that records will be generated in the Provider app and sent across
as opposed to being manually generated to avoid creating invalid data records.

### Adding users

```
rake user:add["first_name.last_name@wherever.com","first_name","last_name","my_role"]
```

To add a user into the database that can be authenticated into the app, use the command above.

On UAT the email must be an MoJ AzureAD email address (i.e. ending @justice.gov.uk) as
omniauthentication is handed off to AzureAD.

**5. Run app locally**

Once all the above is done, you should be able to run the application as follows:

`rails server` - will only run the rails server, usually fine if you are not making changes to the CSS.

You can also compile assets manually with `rails assets:precompile` at any time, and just run the rails server, without foreman.

If you ever feel something is not right with the CSS or JS, run `rails assets:clobber` to purge the local cache.
