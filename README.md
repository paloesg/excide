# Excide

[![CircleCI](https://circleci.com/gh/hschin/excide.svg?style=svg&circle-token=f0bf150e8df63ae18c3f38683f3202a2e59fe5bb)](https://circleci.com/gh/hschin/excide)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/78b3a488b7c14a949e56b45e1505b241)](https://www.codacy.com?utm_source=github.com&utm_medium=referral&utm_content=hschin/excide&utm_campaign=Badge_Grade)

The Excide web platform hosts the main products for Paloe: Symphony, Motif, Overture and Conductor.

## System Dependencies

The following are needed by this project:

-   [PostgreSQL](http://www.postgresql.org/)

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
For rails 5 and above:

    rails db:setup

Install ImageMagick for Image Processing gem.

    brew install imagemagick vips

We use the Foreman gem to start all the processes needed to run the app. Currently, the 3 processes are rails server, webpacker dev server and mailcatcher. The processes are configured in the Procfile.dev file to run on your localhost.

    foreman start -f Procfile.dev

You can access the application in your browser at [http://localhost:3000/](http://localhost:3000/).

## Folder Structure Conventions

### A typical top-level directory layout (only include folders)

    .
    ├── app
        ├── adapters            # API integration methods like Xero etc
        ├── controllers         # Includes symphony, conductors, admin controllers
        ├── dashboards
        ├── decorators          # Design patterns for views
        ├── fields              # Custom methods used in administrate gem
        ├── helpers
        ├── jobs                # Activejob class
        ├── mailers             # Email sending (Action mailer)
        ├── models
        ├── policies            # Pundit policies for authorization
        ├── services            # Service object
        ├── views
        ├── webpacker           # Holds javascripts, css, images and fonts, compiled using webpacker
            ├── packs
            ├── src
                ├── fonts
                ├── images
                ├── javascripts
                ├── stylesheets
    ├── bin
    ├── config                  # Holds database, webpacker, gems etc configuration
    ├── db                      # Contain schemas and migration files
    ├── lib
    ├── log
    ├── node_modules
    ├── public
    ├── spec                    # Rspec testing
    ├── tmp
    ├── vendor
    ├── tmp
    └── README.md

## Testing

Run the test suite with [RSpec](https://github.com/rspec/rspec-rails).

    bin/rspec spec

Or have them run automatically with [Guard](https://github.com/guard/guard-rspec).

    bundle exec guard

## Branching

-   `master` is the active development branch

Make a new branch to work on your development:

    git checkout -b <branch-name>

You can check the location of your branch using `git branch` command.

All local development should be done in the appropriately named branches:

-   `feature/<branch-name>` for substantial new features or functions
-   `enhance/<branch-name>` for minor feature or function enhancement
-   `refactor/<branch-name>` for code refactoring of existing functions
-   `bugfix/<branch-name>` for bug fixes

**WARNING: Do not merge your changes directly into your local master
branch and push to GitHub!!!**

If you are done developing the component you are working on, push your branch to GitHub
and open a [pull request](https://help.github.com/articles/creating-a-pull-request/) to the `master` branch.

Give your pull request a title and describe what you are trying to
achieve with your code. The branch or release manager will review your
code and take the next appropriate actions.

## Deployment

The application is deployed to [Heroku](https://www.heroku.com/) at:

-   [https://excide.herokuapp.com/](https://excide.herokuapp.com/)
-   [https://excide-staging.herokuapp.com/](https://excide-staging.herokuapp.com/)

Ensure the Git remotes are set up:

    heroku git:remote --a excide --remote production
    heroku git:remote --a excide-staging --remote staging

To deploy, just run:

    git push staging master
    git push production master

Do remember to specify the app name when running Heroku commands like so:

    heroku run --a excide rake db:migrate
    heroku run --a excide-staging rake db:migrate

Heroku buildpack:

1. ImageMagick buildpack (For file's conversion using ActiveStorage's Image processing gem)

    - [https://github.com/DuckyTeam/heroku-buildpack-imagemagick/](https://github.com/DuckyTeam/heroku-buildpack-imagemagick/)

    heroku buildpacks:add https://github.com/DuckyTeam/heroku-buildpack-imagemagick --app HEROKU_APP_NAME

2. Others... (To be added!)
