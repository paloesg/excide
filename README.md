# Excide [ ![Codeship Status for hschin/excide](https://app.codeship.com/projects/2db702b0-b9a0-0135-5621-32473b6e6746/status?branch=master)](https://app.codeship.com/projects/259155)

The Excide web platform hosts the main website of Excide and several backend processes such as enquiries, reminders and surveys.

## System Dependencies

The following are needed by this project:

* [PostgreSQL](http://www.postgresql.org/)

## Getting Started

Clone this repository and bundle.

    git clone https://github.com/hschin/excide.git
    cd excide
    bundle install

Create a `database.yml` file from the sample and modify if necessary.
The defaults should be fine.

    cp config/database.yml.example config/database.yml

Create a `.env` file from the sample so [dotenv](https://github.com/bkeepers/dotenv) can set the required environment variables. Please obtain the missing values in the `.env` file with the project administrator.

    cp .env.sample .env

Create and initialize the database.
For rails version 4 and below;

    rake db:setup

Rails 5 and above:

		rails db:setup


Start the application server.

    bin/rails server

Access the application at [http://localhost:3000/](http://localhost:3000/).

## Testing

Run the test suite with [RSpec](https://github.com/rspec/rspec-rails).

    bin/rspec spec

Or have them run automatically with [Guard](https://github.com/guard/guard-rspec).

    bundle exec guard

## Branching

* `master` is the active development branch

Make a new branch to work on your development:

		git checkout -b <name_of_branch>


You can check the location of your branch using `git branch` command.

All local development should be done in the appropriately named branches:

* `feature/<branch_name>` for substantial new features or functions
* `enhance/<branch_name>` for minor feature or function enhancement
* `refactor/<branch_name>` for code refactoring of existing functions
* `bugfix/<branch_name>` for bug fixes

**WARNING: Do not merge your changes directly into your local master
branch and push to GitHub!!!**

If you are done developing the component you are working on, push your branch to github
and open a [pull request](https://help.github.com/articles/creating-a-pull-request/) to the `master` branch.

Give your pull request a title and describe what you are trying to
achieve with your code. The branch or release manager will review your
code and take the next appropriate actions.

## Deployment

The application is deployed to [Heroku](https://www.heroku.com/) at:

* [https://excide.herokuapp.com/](https://excide.herokuapp.com/)
* [https://excide-staging.herokuapp.com/](https://excide-staging.herokuapp.com/)

Ensure the Git remotes are set up:

    heroku git:remote --a excide --remote production
    heroku git:remote --a excide-staging --remote staging

To deploy, just run:

    git push staging master
    git push production master

Do remember to specify the app name when running Heroku commands like so:

    heroku run --a excide rake db:migrate
    heroku run --a excide-staging rake db:migrate

