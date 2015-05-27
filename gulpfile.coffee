

gulp = require 'gulp'

gulp_sync = require 'run-sequence'

$require = require 'rekuire'

$config = $require 'config/config'

path = require 'path'

browserify = require 'browserify'

through = require 'through2'

gutil = require 'gulp-util'
coffee = require 'gulp-coffee'
rename = require 'gulp-rename'
sourcemaps = require 'gulp-sourcemaps'
ng_template = require 'gulp-angular-templatecache'
jade = require 'gulp-jade'
inject = require 'gulp-inject'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
sass = require 'gulp-sass'
ruby_sass = require 'gulp-ruby-sass'

css_min = require 'gulp-cssmin'

size = require('gulp-size')



browser_sync = require 'browser-sync'

ng_annotate = require 'gulp-ng-annotate'

spawn = require('child_process').spawn


del = require 'del'

$error_handler = (err) ->
  gutil.log err.message
  @emit 'end'


$print = through.obj (file,enc,cb) ->
  console.log file.contents.toString()
  @push file
  do cb

$js_dest = ->
  new gulp.dest(path.join($config.output.root, $config.output.assets.js))

$css_dest = -> gulp.dest path.join($config.output.root, $config.output.assets.css)


#BoneHeaded Path Resolutions

$js_compiled = (read = false) ->
  gulp.src path.join($config.output.root, $config.output.assets.js, '*.js'), read: read

$css_compiled = (read = false) ->
  gulp.src path.join($config.output.root, $config.output.assets.css, '*.css'), read: read


$js_compiled_min = ->
  src = path.join($config.output.root,$config.output.assets.js,$config.output.build.js)
  gulp.src(src, read: false)

$css_compiled_min = ->
  src = path.join($config.output.root,$config.output.assets.css,$config.output.build.css)
  gulp.src(src, read: false)



$bfy = -> new through.obj (file,enc,cb) ->
  browserify(file, { debug: true, baseDir: 'app' })
  .transform('coffeeify')
  .bundle (err,src) =>
 	  if err
      @emit 'error', err
    else
      file.contents = new Buffer src
      @push file
    do cb


gulp.task 'inject', ->

  gulp.src $config.input.index
    .pipe do jade
    .pipe inject(do $js_compiled, ignorePath: $config.output.root)
    .pipe inject(do $css_compiled, ignorePath: $config.output.root)
    #.pipe $print
    .pipe gulp.dest $config.output.root


gulp.task 'inject.min', ->

  gulp.src $config.input.index
    .pipe do jade
    .pipe inject(do $js_compiled_min, ignorePath: $config.output.root)
    .pipe inject(do $css_compiled_min, ignorePath: $config.output.root)
    #.pipe $print
    .pipe gulp.dest $config.output.root


gulp.task 'clean', (cb) ->
  del $config.output.root, cb


gulp.task 'bower:info', ->
  wiredep = require 'wiredep'
  excludes = require('./bower.json')['exclude']
  bower = wiredep exclude: excludes

  Object.keys(bower).forEach (key) ->
    if Array.isArray(bower[key])
      console.log gutil.colors.magenta("Bower " + key + ":")
      console.log gutil.colors.yellow(bower[key].join("\n")), "\n"

  console.log gutil.colors.magenta("Bower excluding:")
  console.log gutil.colors.red(excludes.join("\n")), "\n"


  

gulp.task 'default', (cb) ->
  gulp_sync 'clean', ['scripts', 'styles'], 'inject', 'serve', 'watch', cb

gulp.task 'prod', (cb) ->
  gulp_sync 'clean', ['scripts', 'styles' ], 'uglify', 'inject.min', cb

gulp.task 'scripts', ['scripts:coffee','scripts:ng-jade','scripts:vendor']

gulp.task 'styles', ['styles:sass','styles:vendor']

gulp.task 'uglify', ['uglify:js', 'uglify:css'], ->


gulp.task 'copy', ->
  gulp.src($config.input.fonts)
    .pipe(gulp.dest(path.join($config.output.root,$config.output.assets.fonts)))


gulp.task 'uglify:js', ->
  $js_compiled(true)
    .on 'error', $error_handler
    .pipe concat($config.output.build.js)
    .pipe do uglify
    .pipe size showFiles: true, gzip: true
    .pipe do $js_dest


#gulp.task 'scripts:vendor', ['scripts:vendor:css', 'bundle_vendor:js']

gulp.task 'styles:vendor', ->
    gulp.src $config.input.vendor_css
      .pipe do sourcemaps.init
      .pipe concat $config.output.compiled.vendor_css
      .pipe do sourcemaps.write
      .pipe do $css_dest

gulp.task 'scripts:vendor', ->
    gulp.src $config.input.vendor_js
      .pipe do sourcemaps.init
      .pipe concat $config.output.compiled.vendor_js
      .pipe do sourcemaps.write
      .pipe do $js_dest


gulp.task 'uglify:css', ->
  $css_compiled(true)
    .on 'error', $error_handler
    .pipe concat($config.output.build.css)
    .pipe do css_min
    .pipe size showFiles: true, gzip: true
    .pipe do $css_dest

gulp.task 'scripts:ng-jade', ->
  gulp.src $config.input.templates
    .pipe do jade
    .on 'error', $error_handler
    .pipe ng_template(standalone: true)
    .on 'error', $error_handler
    .pipe rename($config.output.compiled.templates)
    .pipe do $js_dest
    #.pipe $print
  

gulp.task 'config', ->
  gutil.log $config

gulp.task 'styles:sass', ->
  gulp.src $config.input.sass
  .pipe do sourcemaps.init
  .pipe sass(indentedSyntax: true, includePaths: $config.input.sass_loadpath)
  .on 'error', (err) -> $error_handler.call(@, message: err.toString())
  .pipe do sourcemaps.write
  .pipe rename($config.output.compiled.sass)
  .pipe do $css_dest



gulp.task 'scripts:coffee', ->
  gulp.src $config.input.coffee, base: 'app'
  .pipe do sourcemaps.init
  .pipe concat $config.output.compiled.coffee
  .pipe coffee bare: false
  .on 'error', (err) -> $error_handler.call(@, message: err.toString())
  .pipe do sourcemaps.write
  .pipe do $bfy
  .on 'error', $error_handler
  .pipe do sourcemaps.init
  .pipe do ng_annotate
  .on 'error', $error_handler
  .pipe do sourcemaps.write
  .pipe gulp.dest path.join($config.output.root, $config.output.assets.js)


gulp.task 'scripts:vendor', ->
  gulp.src $config.input.vendor_js
  .on 'error', $error_handler
  .pipe do sourcemaps.init
  .pipe concat($config.output.compiled.vendor_js, newLine: ';')
  #.pipe do ng_annotate
  .pipe do sourcemaps.write
  .pipe gulp.dest path.join($config.output.root, $config.output.assets.js)


gulp.task "serve", ->
  assets = new RegExp "^/(#{(value for key, value of $config.output.assets).join('|')})"
  browser_sync
    server:
      baseDir: $config.output.root
    port: 8888
    open: false



gulp.task "watch", ->
  gulp.watch $config.watch.sass, ['styles:sass', browser_sync.reload]
  gulp.watch $config.watch.coffee, ['scripts:coffee', browser_sync.reload]
  gulp.watch $config.watch.templates, ['scripts:ng-jade', browser_sync.reload]
  gulp.watch $config.watch.index, ['inject', browser_sync.reload]
  

gulp.task "srvr", ->
  spawnChildren = (e) ->
    
    # kill previous spawned process
    srvr.kill()  if srvr
    
    # `spawn` a child `gulp` process linked to the parent `stdio`
    srvr = spawn("node", ["--harmony", "server.js"], { stdio: "inherit" })
    return
  srvr = undefined
  spawnChildren()
  return

gulp.task "auto", ->
  spawnChildren = (e) ->
    
    # kill previous spawned process
    p.kill()  if p
    
    # `spawn` a child `gulp` process linked to the parent `stdio`
    p = spawn("gulp",
      stdio: "inherit"
    )
    return
  p = undefined
  gulp.watch "gulpfile.coffee", spawnChildren
  spawnChildren()
  return

