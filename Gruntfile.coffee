module.exports = ->
  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    # CoffeeScript compilation
    coffee:
      spec:
        options:
          bare: true
        expand: true
        cwd: 'spec'
        src: ['**.coffee']
        dest: 'spec'
        ext: '.js'

    # Browser build of NoFlo
    noflo_browser:
      build:
        files:
          'browser/noflo-indexeddb.js': ['package.json']

    # JavaScript minification for the browser
    uglify:
      options:
        report: 'min'
      noflo:
        files:
          './browser/noflo-indexeddb.min.js': ['./browser/noflo-indexeddb.js']

    # Automated recompilation and testing when developing
    watch:
      files: ['spec/*.coffee', 'components/*.coffee']
      tasks: ['test']

    # Cross-browser testing
    connect:
      server:
        options:
          base: ''
          port: 9999
    mocha_phantomjs:
      all:
        options:
          output: 'spec/result.xml'
          reporter: 'spec'
          urls: ['http://localhost:9999/spec/runner.html']

    'saucelabs-mocha':
      all:
        options:
          urls: ['http://127.0.0.1:9999/spec/runner.html']
          browsers: [
              browserName: 'googlechrome'
            ,
              browserName: 'internet explorer'
              version: '11'
          ]
          build: process.env.TRAVIS_JOB_ID
          testname: 'noflo-indexeddb browser tests'
          tunnelTimeout: 5
          concurrency: 1
          detailedError: true

    # Coding standards
    coffeelint:
      components: ['components/*.coffee']

  # Grunt plugins used for building
  @loadNpmTasks 'grunt-noflo-browser'
  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-contrib-uglify'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-contrib-watch'
  @loadNpmTasks 'grunt-coffeelint'

  # Grunt plugins used for browser testing
  @loadNpmTasks 'grunt-contrib-connect'
  @loadNpmTasks 'grunt-mocha-phantomjs'
  @loadNpmTasks 'grunt-saucelabs'

  # Our local tasks
  @registerTask 'build', 'Build NoFlo for the chosen target platform', (target = 'all') =>
    @task.run 'coffee'
    @task.run 'noflo_browser'
    @task.run 'uglify'

  @registerTask 'test', 'Build NoFlo and run automated tests', (target = 'all') =>
    @task.run 'coffeelint'
    @task.run 'build'
    @task.run 'connect'
    @task.run 'mocha_phantomjs'

  @registerTask 'crossbrowser', 'Build, run tests on cross-browser environment', (target = 'all') =>
    @task.run 'test'
    @task.run 'saucelabs-mocha'

  @registerTask 'default', ['test']
