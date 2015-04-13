'use strict';

// # Globbing
// for performance reasons we're only matching one level down:
// 'test/spec/{,*/}*.js'
// use this if you want to recursively match all subfolders:
// 'test/spec/**/*.js'

var mountFolder = function (connect, dir) {
  return connect.static(require('path').resolve(dir));
};

var webpackDistConfig = require('./webpack.dist.config.js'),
    webpackDevConfig = require('./webpack.config.js');

module.exports = function (grunt) {

  // Load grunt tasks automatically
  require('load-grunt-tasks')(grunt);

  // Time how long tasks take. Can help when optimizing build times
  require('time-grunt')(grunt);

  // Configurable paths for the application
  var appConfig = {
    test: 'test',
    api_app: 'app/api_app',
    api_app_port: 8100,
    api_app_test: 'test/spec/api',
    api_app_dist: 'dist/api_app',
    ui_app: 'app/ui_app',
    ui_app_port: 8000,
    ui_app_dist: 'dist/ui_app',
  };

  // Define the configuration for all the tasks
  grunt.initConfig({
    // Project settings
    yeoman: appConfig,

    webpack: {
      options: webpackDistConfig,

      ui_app_dist: {
        cache: false
      }
    },

    'webpack-dev-server': {
      options: {
        hot: true,
        port: '<%= yeoman.ui_app_port %>',
        webpack: webpackDevConfig,
        publicPath: '/assets/',
        contentBase: './<%= yeoman.ui_app %>/',
      },

      start: {
        keepAlive: true,
      }
    },

    connect: {
      options: {
        port: '<%= yeoman.ui_app_port %>'
      },

      ui_app_dist: {
        options: {
          keepalive: true,
          middleware: function (connect) {
            return [
              mountFolder(connect, appConfig.ui_app_dist)
            ];
          }
        }
      }
    },

    open: {
      options: {
        delay: 500
      },
      ui_app_dev: {
        path: 'http://localhost:<%= connect.options.port %>/webpack-dev-server/'
      },
      ui_app_dist: {
        path: 'http://localhost:<%= connect.options.port %>/'
      },
      api_app: {
        path: 'http://localhost:<%= yeoman.api_app_port %>/documentation'
      }
    },

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
            PORT: '<%= yeoman.api_app_port %>'
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
          '<%= yeoman.test %>/helpers/**/*.{coffee,litcoffee,coffee.md}',
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
      api_app_dist: '<%= yeoman.api_app_dist %>',
      ui_app_dist: {
        files: [{
          dot: true,
          src: [
            '<%= yeoman.ui_app_dist %>'
          ]
        }]
      }
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

    copy: {
      ui_app_dist: {
        files: [
          // includes files within path
          {
            flatten: true,
            expand: true,
            src: ['<%= yeoman.ui_app %>/*'],
            dest: '<%= yeoman.ui_app_dist %>/',
            filter: 'isFile'
          },
          {
            flatten: true,
            expand: true,
            src: ['<%= yeoman.ui_app %>/images/*'],
            dest: '<%= yeoman.ui_app_dist %>/images/'
          },
        ]
      }
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
      },
      both_apps: {
        tasks: [
          'connect:ui_app_dist',
          'nodemon:api_app'
        ]
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
    },

    karma: {
      unit: {
        configFile: 'karma.conf.js'
      }
    },
  });

  grunt.registerTask('build', 'Build all coffeescript files to js', function (target) {
    grunt.task.run([
      'clean:api_app_dist',
      'coffeelint:api_app',
      'coffee:api_app',
      'clean:ui_app_dist',
      'copy:ui_app_dist',
      'webpack'
    ]);
  });

  grunt.registerTask('test', 'Run tests while developing app code', function (target) {
    if (target === 'api_app') {
      return grunt.task.run([
        'coffeelint:api_app',
        'coffeelint:api_app_test',
        'mochaTest:api_app',
        'watch:api_app_test'
      ]);
    }

    return grunt.task.run(['karma']);
  });

  grunt.registerTask('serve', 'Compile then start a connect web server', function (target) {
    if (target === 'api_app') {
      return grunt.task.run([
        'clean:api_app_dist',
        'coffeelint:api_app',
        'coffeelint:api_app_test',
        'coffee:api_app',
        'open:api_app',
        'concurrent:api_app'
      ]);
    }

    if (target === 'ui_app') {
      grunt.task.run([
        'open:ui_app_dev',
        'webpack-dev-server'
      ]);
    }

    if (target === 'ui_app_dist') {
      grunt.task.run([
        'build',
        'open:ui_app_dist',
        'connect:ui_app_dist'
      ]);
    }

    return grunt.task.run([
      'build',
      'open:ui_app_dist',
      'open:api_app',
      'concurrent:both_apps'
    ]);
  });

  grunt.registerTask('default', []);
};
