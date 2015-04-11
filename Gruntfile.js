'use strict';

// # Globbing
// for performance reasons we're only matching one level down:
// 'test/spec/{,*/}*.js'
// use this if you want to recursively match all subfolders:
// 'test/spec/**/*.js'

module.exports = function (grunt) {

  // Load grunt tasks automatically
  require('load-grunt-tasks')(grunt);

  // Time how long tasks take. Can help when optimizing build times
  require('time-grunt')(grunt);

  // Configurable paths for the application
  var appConfig = {
    api_app: 'app/api_app',
    api_app_test: 'test/spec/api',
    api_app_dist: 'dist/api_app',
  };

  // Define the configuration for all the tasks
  grunt.initConfig({
    // Project settings
    yeoman: appConfig,

    nodemon: {
      api_app: {
        script: 'server.js',
        options: {
          nodeArgs: ['--debug'],
          callback: function (nodemon) {
            nodemon.on('log', function (event) {
              console.log(event.colour);
            });
          },
          env: {
            DB_SUFFIX: '_prod',
            PORT: '8100'
          },
          cwd: '<%= yeoman.api_app_dist %>/api',
          ignore: ['node_modules/**'],
          delay: 1000,
        }
      }
    },

    // Watches files for changes and runs tasks based on the changed files
    watch: {
      api_app: {
        files: ['<%= yeoman.api_app %>/**/*.{coffee,litcoffee,coffee.md}'],
        tasks: ['coffeelint:api_app', 'coffee:api_app']
      },
      api_app_test: {
        files: [
          '<%= yeoman.api_app_test %>/**/*.{coffee,litcoffee,coffee.md}',
          '<%= yeoman.api_app %>/**/*.{coffee,litcoffee,coffee.md}'
        ],
        tasks: ['coffeelint:api_app', 'coffeelint:api_app_test', 'mochaTest:api_app']
      },
      options: {
        event: ['changed', 'added', 'deleted']
      }
    },

    // Empties folders to start fresh
    clean: {
      api_app_dist: '<%= yeoman.api_app_dist %>'
    },

    coffeelint: {
      api_app: {
        files: {
          src: ['<%= yeoman.api_app %>/**/*.coffee']
        },
        options: {
          'arrow_spacing': {
            'level': 'error'
          },
          'braces_spacing': {
            'level': 'error'
          },
          'newlines_after_classes': {
            'level': 'error'
          },
          'no_empty_param_list': {
            'level': 'error'
          },
          'no_empty_functions': {
            'level': 'error'
          },
          'no_implicit_braces': {
            'level': 'error'
          },
          'no_implicit_parens': {
            'level': 'warn'
          },
          'no_interpolation_in_single_quotes': {
            'level': 'error'
          },
          'no_plusplus': {
            'level': 'error'
          },
          'no_stand_alone_at': {
            'level': 'error'
          },
          'no_unnecessary_double_quotes': {
            'level': 'error'
          },
          'space_operators': {
            'level': 'error'
          },
          'spacing_after_comma': {
            'level': 'error'
          },
          'cyclomatic_complexity': {
            'level': 'error'
          }
        }
      },
      api_app_test: {
        files: {
          src: ['<%= yeoman.api_app_test %>/**/*.coffee']
        },
        options: {
          'arrow_spacing': {
            'level': 'error'
          },
          'braces_spacing': {
            'level': 'error'
          },
          'newlines_after_classes': {
            'level': 'error'
          },
          'no_empty_param_list': {
            'level': 'error'
          },
          'no_empty_functions': {
            'level': 'error'
          },
          'no_implicit_braces': {
            'level': 'warn'
          },
          'no_interpolation_in_single_quotes': {
            'level': 'error'
          },
          'no_plusplus': {
            'level': 'error'
          },
          'no_stand_alone_at': {
            'level': 'error'
          },
          'no_unnecessary_double_quotes': {
            'level': 'error'
          },
          'space_operators': {
            'level': 'error'
          },
          'spacing_after_comma': {
            'level': 'error'
          },
          'cyclomatic_complexity': {
            'level': 'error'
          }
        }
      }
    },

    // Compiles CoffeeScript to JavaScript
    coffee: {
      options: {
        sourceMap: true,
        sourceRoot: ''
      },
      api_app: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.api_app %>',
          src: '**/*.coffee',
          dest: '<%= yeoman.api_app_dist %>',
          ext: '.js'
        }]
      },
    },

    // Run some tasks in parallel to speed up the build process
    concurrent: {
      api_app: {
        tasks: [
          'watch:api_app',
          'nodemon:api_app'
        ],
        options: {
          logConcurrentOutput: true
        }
      }
    },

    mochaTest: {
      api_app: {
        options: {
          require: 'coffee-script/register'
        },
        src: ['<%= yeoman.api_app_test %>/**/*.coffee']
      },
      api_app_coverage: {
        options: {
          reporter: 'html-cov',
          captureFile: 'coverage.html',
          quiet: true,
          clearRequireCache: true,
          require: ['coffee-script/register', 'coffee-coverage/register']
        },
        src: ['<%= yeoman.api_app_test %>/**/*.coffee']
      }
    }
  });

  grunt.registerTask('build:api_app', 'Build all coffeescript files to js', function (target) {
    grunt.task.run([
      'clean:api_app_dist',
      'coffeelint:app',
      //'coffeelint:api_app_test',
      'coffee:app',
      //'coffee:test'
    ]);
  });

  grunt.registerTask('test:api_app', 'Run tests while developing api app code', function (target) {
    grunt.task.run([
      //'clean:api_app_dist',
      'coffeelint:api_app',
      'coffeelint:api_app_test',
      //'coffee:api_app',
      'mochaTest:api_app',
      'watch:api_app_test'
    ]);
  });

  grunt.registerTask('serve:api_app', 'Compile then start a connect web server', function (target) {
    grunt.task.run([
      'clean:api_app_dist',
      'coffeelint:api_app',
      'coffeelint:api_app_test',
      'coffee:api_app',
      'concurrent:api_app'
    ]);
  });
};
