# Personal Tag Manager
Project for my bachlor's degree. The scope of this project is to generate a JSON config for a tag management library.

This project has 3 applications:

* A RESTful API
* A Config interface

## Prerequisites

* MongoDB
* Node.js
* Grunt (`npm install -g grunt-cli`)
* Bower (`npm install bower -g`)
* Install NPM dependencies (`npm install`)
* Install Bower dependencies (`bowe install`)

##Populating the user database
Run the following command to add users accounts in the mongo database:
`DB_SUFFIX='_prod' DB_CONNECTION_STRING='mongodb://localhost/personal_tag_manager' node ./dist/api_app/database/seeds/user_seeder.js`

## RESTful API APP
The API application is build in node.js. The code is written in coffescript.

### Preview
Run `grunt serve:api_app` to launch the application.
You can access the APP here: [http://localhost:8100/documentation](http://localhost:8100/documentation).

### Developing
Run `grunt watch:api_app_test` while developing. Each time the resources will change, the API tests will be run automatically.

### Test
Run `grunt test:api_app` to run the test suite of the API application.

### Coverage
Run `grunt test:api_app_coverage` to run the test suite of the API application. The results will be saved in the `coverage.html` file.

Or you can run `./node_modules/mocha/bin/mocha --require coffee-coverage/register --compilers coffee:coffee-script/register -R html-cov --recursive test/ > coverage.html`.

## UI Config APP
The UI app is built in React and Reflux. For the UI app to work, the API must also be launched.

### Preview
Run `grunt serve:ui_app_dist` to launch the application. All the resources will be precompiled before the launch.
You can access the APP here: [http://localhost:8000/](http://localhost:8000/).

### Developing
Run `grunt serve:ui_app` to launch the application with webpack-dev-server. Each time the resources will change, the page will refresh automatically.
You can access the APP here: [localhost:8000/webpack-dev-server/](localhost:8000/webpack-dev-server/).

## Previewing both apps
Run `grunt serve` to launch all the applications.

## Configuration options
The following options can be changed in the `package.json` file

* __db_connection\_string__ (default: mongodb://localhost/personal_tag_manager) - The prefix of the connection string to the mongo database. The application will create the necessary databases at runtime
* __api_app\_port__ (default: 8100) - The port used by the API APP.
* __ui_app\_port__ (default: 8000) - The port used by the UI APP.
* __storage_port__ (default: 8200) - The port from where the generated libraries will be served.

## Build

Run `grunt build` for building the assets for all the files. The files will be saved in the `dist` folder.
