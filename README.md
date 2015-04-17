# Personal Tag Manager
Project for my bachlor's degree.

## Build & development

Run `grunt serve` for preview.

## Testing

Running `grunt test:api_app` will run the unit tests with mocha for the API application.

## Code coverage

Running `grunt mochaTest:coverage` will export the code coverage result in the `coverage.html` file.

Or you can run `./node_modules/mocha/bin/mocha --require coffee-coverage/register --compilers coffee:coffee-script/register -R html-cov --recursive test/ > coverage.html`.
