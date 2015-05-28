
excludes = require('../bower.json')['exclude']
bower = require('wiredep')(exclude: excludes)

module.exports =

  watch:
    coffee: [
      "app/scripts/*.coffee"
      "app/scripts/**/*.coffee"
    ]
    sass: [
      "app/styles/*.sass"
      "app/styles/**/*.sass"
    ]
    templates: [
      "app/templates/*.jade"
      "app/templates/**/*.jade"
    ]
    index: ["app/index.jade "]
    data: ["app/templates/data/**"]

  input:
    index: "app/index.jade"
    img:  "app/static/img/*"
    fonts: "app/fonts/*"
    sprites: "app/static/sprites/*"

    coffee: [
      "app/scripts/*.coffee"
      "app/scripts/**/*.coffee"
      "!app/scripts/lib/*.coffee"
      "!app/scripts/lib/**/*.coffee"
    ]
    sass: ["app/styles/main.sass"]

    sass_loadpath: [
      "app/styles/lib/"
      "bower_components/neat/app/assets/stylesheets"
      "bower_components/bootstrap-sass/vendor/assets/stylesheets"
      "bower_components/bootstrap-sass/vendor/assets/stylesheets/bootstrap"
      "bower_components/bourbon/app/assets/stylesheets"
      "bower_components/"
    ]
    vendor_css: bower.css
    vendor_js: bower.js

    templates: [
      "app/templates/*.jade"
      "app/templates/**/*.jade"
      "!app/templates/lib/**"
      "!app/templates/_*.jade"
      "!app/templates/**/_*.jade"
    ]

  output:
    root: "public"
    index: "index.html"

    assets:
      js: 'js',
      fonts: 'fonts',
      css: 'css',
      img: 'img',
      sprites: 'img/sprites'
      static: 'static'

    build:
      js: "build.js"
      css: "build.css"

    compiled:
      vendor_js: "compiled.0.vendor_js.js"
      vendor_css: "compiled.0.css.css"
      templates: "compiled.1.templates.js"
      coffee: "compiled.2.coffee.js"
      sass: "compiled.1.sass.css"

