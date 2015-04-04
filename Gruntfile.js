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
    app: require('./bower.json').appPath || 'app',
    test: 'test',
    dist: 'dist',
  };

  // Define the configuration for all the tasks
  grunt.initConfig({
    // Project settings
    yeoman: appConfig,

    nodemon: {
      api: {
        script: 'server.js',
        options: {
          nodeArgs: ['--debug'],
          callback: function (nodemon) {
            nodemon.on('log', function (event) {
              console.log(event.colour);
            });
          },
          env: {
            DB_SUFFIX: '',
            PORT: '8000'
          },
          cwd: '<%= yeoman.dist %>/api',
          ignore: ['node_modules/**'],
          delay: 1000,
        }
      }
    },

    // Watches files for changes and runs tasks based on the changed files
    watch: {
      app: {
        files: ['<%= yeoman.app %>/**/*.{coffee,litcoffee,coffee.md}'],
        tasks: ['coffeelint:app', 'newer:coffee:app']
      },
      test: {
        files: ['<%= yeoman.test %>/**/*.{coffee,litcoffee,coffee.md}'],
        tasks: ['coffeelint:app', 'mochaTest:app']
      }
    },

    // Empties folders to start fresh
    clean: {
      dist: '<%= yeoman.dist %>'
    },

    coffeelint: {
      app: {
        files: {
          src: ['<%= yeoman.app %>/**/*.coffee']
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
      test: {
        files: {
          src: ['<%= yeoman.test %>/**/*.coffee']
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
      app: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>',
          src: '**/*.coffee',
          dest: '<%= yeoman.dist %>',
          ext: '.js'
        }]
      }
    },

    // Run some tasks in parallel to speed up the build process
    concurrent: {
      app: {
        tasks: [
          'watch:app',
          'watch:test',
          'nodemon:api'
        ],
        options: {
          logConcurrentOutput: true
        }
      }
    },

    mochaTest: {
      app: {
        options: {
          require: 'coffee-script/register'
        },
        src: ['<%= yeoman.test %>/**/*.coffee']
      },
      coverage: {
        options: {
          reporter: 'html-cov',
          captureFile: 'coverage.html',
          quiet: true,
          clearRequireCache: true,
          require: 'coffee-coverage/register'
        },
        src: ['<%= yeoman.test %>/**/*.coffee']
      }
    }
  });

  grunt.registerTask('default', 'Compile then start a connect web server', function (target) {
    grunt.task.run([
      'clean:dist',
      'coffeelint:app',
      'coffeelint:test',
      'coffee:app',
      'watch:app'
    ]);
  });

  grunt.registerTask('serve', 'Compile then start a connect web server', function (target) {
    grunt.task.run([
      'clean:dist',
      'coffeelint:app',
      'coffeelint:test',
      'coffee:app',
      'mochaTest:app',
      'concurrent:app'
    ]);
  });
};
