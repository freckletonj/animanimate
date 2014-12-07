sh = require 'execSync'
path = require 'path'
gulp = require 'gulp'
gutil = require 'gulp-util'
stylus = require 'gulp-stylus'
coffee = require 'gulp-coffee'
watch = require 'gulp-watch'
rimraf = require 'gulp-rimraf'

SRC_DIR = './src'
LIB_DIR = './lib'
APP_DIR = './app'

ENTRYPOINT = "#{LIB_DIR}/app.js"

# TODO watch stylus
STYLUS_DIR = "#{SRC_DIR}/css"
STYLUS = "#{STYLUS_DIR}/**/*.styl"

JADE_DIR = SRC_DIR
JADE = "#{JADE_DIR}/**/*.jade"

COFFEE_DIR = "#{SRC_DIR}/js"
COFFEE = "#{COFFEE_DIR}/**/*.coffee"

###
Helpers
###

compileJade = (inputDir, outputDir) ->
  cmd = sh.exec "jade #{inputDir} -o #{outputDir}"
  gutil.log cmd.stdout
  gutil.log "  [jade] Compiled #{inputDir} to #{outputDir}"

compileStylus = (input, outputDir) ->
  gulp.src(input)
    .pipe(stylus({linenos: true})).on('error', gutil.log)
    .pipe(gulp.dest(outputDir))
    .on 'finish', (err) ->
      gutil.log err if err
      gutil.log "  [stylus] Compiled #{input} to #{outputDir}"

compileCoffee = (inputDir, outputDir) ->
  cmd = sh.exec "coffee -c -o #{outputDir} #{inputDir}"
  gutil.log cmd.stdout
  gutil.log "  [coffee] Compiled #{inputDir} to #{outputDir}"

runBrowserify = (input, output) ->
  cmd = sh.exec "browserify #{input} --no-cache -o #{output}"
  gutil.log cmd.stdout
  gutil.log "  [browserify] Compiled #{input} to #{output}"

###
# Clean
###

gulp.task 'clean-html', ->
  gulp.src([
      "#{APP_DIR}/*.html"
  ], {read: false}).pipe(rimraf())

gulp.task 'clean-js', ->
  gulp.src([
      "#{LIB_DIR}/*"
      "#{APP_DIR}/js/*.js"
  ], {read: false}).pipe(rimraf())

gulp.task 'clean-css', ->
  gulp.src([
      "#{APP_DIR}/css/*.css"
  ], {read: false}).pipe(rimraf())

# Clean all built files
gulp.task 'clean', ['clean-html', 'clean-js', 'clean-css']

###
# Build
###

gulp.task 'jade', ['clean-html'], -> compileJade JADE_DIR, APP_DIR

gulp.task 'stylus', ['clean-css'], ->
  compileStylus "#{STYLUS_DIR}/app.styl", "#{APP_DIR}/css"

gulp.task 'coffee', ['clean-js'], -> compileCoffee COFFEE_DIR, LIB_DIR

gulp.task 'browserify', ['coffee'], ->
  runBrowserify ENTRYPOINT, "#{APP_DIR}/js/app.js",

# Build everything
gulp.task 'build', ['jade', 'stylus', 'browserify']

###
# Watch
###

gulp.task 'watch-jade', ['jade'], ->
  gulp.watch(JADE, ['jade'])
    .on('error', gutil.log)

gulp.task 'watch-stylus', ['stylus'], ->
  gulp.watch(STYLUS, ['stylus'])
    .on('error', gutil.log)

gulp.task 'watch-coffee', ['browserify'], ->
  gulp.watch(COFFEE, ['browserify'])
    .on('error', gutil.log)

# Watch everything
gulp.task 'watch', ['build', 'watch-jade', 'watch-stylus', 'watch-coffee']

# Watch everything by default
gulp.task 'default', ['watch']