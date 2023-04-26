# Ribon Core Api

## How to run the project

Obs: You need rails installed to run those commands. You can check how to
install it [here](https://www.howtoforge.com/tutorial/ubuntu-ruby-on-rails/).

- clone this repository: `git clone git@github.com:RibonDAO/core-api.git`
- run the bundle install command: `bundle install`
- copy the .env.example to a .env file `cp .env.example .env` (notice that there are some variables that you have to grab on your own. Right below you can see how to get them)
- run the database setup command: `rails db:setup`
- run the rails server: `rails s`

You can check the http://localhost:3000/ and see if the Rails welcome page appears.

## With Dockerfile
  - clone this repository: `git clone git@github.com:RibonDAO/core-api.git`
  - copy the .docker-compose.yml.sample to a .docker-compose.yml file `cp .docker-compose.yml.sample .docker-compose.yml`
  - run docker-compose up
Your project will be running on http://localhost:8080/

or if you already have the interface project on your machine you can use our script to run the whole project:
  - clone this repository: `git clone git@github.com:RibonDAO/core-api.git`
  - clone the interface repository: `git clone git@github.com:RibonDAO/interface.git`
  - run ./script.sh inside one of the projects
The app will be running on http://localhost:3000/

## How to run the tests

- run the command: `rspec`

## Environments
Currently there is a continuous deploy that sends the new versions of the code to 3 environments.
They are:
- Development: [development link](http://dev-api.eba-fktmq9bg.us-east-1.elasticbeanstalk.com/admin)
- Staging: [staging link](https://staging-dapp-api.ribon.io/admin)
- Production: [production link](https://staging-dapp-api.ribon.io/admin)

The development environment is where we can do tests. It is used by the front end development environment
as an api where the data is fetched. It is updated everytime the `develop` branch receives a new PR.

The staging environment is a replica of the production environment, but with a different database. We use them
to validate new features and test some things without damaging the production database. It is 
updated everytime a new PR is merged into the `main` branch.

The production enviroment is where the real users are. Everytime the `main` branch is updated, so the production environment is.

All the environments are hosted in the AWS elastic beanstalk environment. If you need to work on something related to this hosting,
call the Ribon developers team to have the access.

## How to get some needed environment variables
- `RIBON_WALLET_PRIVATE_KEY`: use a private key from a test wallet of yours. You can create a free wallet at [metamask](https://metamask.io/) and export it's private key
- `STRIPE_PUBLISHABLE_KEY`, `STRIPE_SECRET_KEY` and `STRIPE_ENDPOINT_SECRET`: You can get all those 3 variables registering on [stripe](https://stripe.com/). You can create a test account there. Those variables are not needed if you are not using any of the credit card payment features. All of those are test keys.
- `SENTRY_DSN_URL`: not needed for development environment 
- `MUMBAI_NODE_URL`: you can get a node_url at [alchemy](https://www.alchemy.com/). You can get a free registration an then create a project on any network (check those in which ribon has a contract deployed).
