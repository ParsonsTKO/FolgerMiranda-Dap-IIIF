# FOLGER DAP IIIF Server

This project is using [Cantaloupe](https://medusa-project.github.io/cantaloupe/)

### Install all local requirements

`make requirements`

### Installation

`make`

### Execute tests

`make test`

### Open your environment

`make open`

### See all commands available

`make help`

### Override configurations

Create the file `.env` with the environment variables, use the `.env.dist` file for reference.  

## Who do I talk to?

-   Repo owner or admin
-   Other community or team contact

## Publish your changes to ECR registry

### Tag your release

Look for the latest tag and follow the Semantic versioning

`make tag version=<semver number>`

### Publish you image

Set your AWS credentials and then execute the build and publish command

`make publish version=<semver number>`

## Publish your preview changes to ECR registry

Set your AWS credentials and then execute the build and publish command. To push th current branch to ECR execute the following comamnd:

`make preview`
