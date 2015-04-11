# Personal Tag Manager
Project for my bachlor's degree.

## Build & development

Run `grunt serve` for preview.

## Testing

Running `grunt test` will run the unit tests with mocha.

## Code coverage

Running `grunt mochaTest:coverage` will export the code coverage result in the `coverage.html` file.
Or you can run `./node_modules/mocha/bin/mocha --require coffee-coverage/register --compilers coffee:coffee-script/register -R html-cov --recursive test/ > coverage.html`.

For running with istanbul you can execute

`npm install istanbul`
`grunt build && ./node_modules/istanbul/lib/cli.js cover ./node_modules/mocha/bin/_mocha -- -R spec ./dist/test/ --recursive`

For switching mocha with vows you can run
`grunt build && ./node_modules/istanbul/lib/cli.js cover ./node_modules/vows/bin/vows -- -R spec ./dist/test/`


