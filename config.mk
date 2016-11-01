#Generic Makefile by Blaise Lengrand
#Usage: make [rule]
#
#By default, it will run all user rules starting with specific
#names, the followings are currently supported:
#	minify_*		Minify and concatenate the source files, available
#	        		only for *.js and *.css files.
#	dist_*		Copy the files or directory to the dist directory.
#
#List of rules available:
#	silent		No verbosity, except error messages.
#	verbose		High verbosity, including command executed.
#	help		Display this help message.
#	clean		Clean the environment and all generated files.
#	build		Build the targets.
#	rebuild		Clean and re-build the targets.
#	release		Re-build the targets and generate the package.
#
#Configuration: config.mk
#	Contains all user rules definitions. They use pre-made
#	rules with the following options:
#	SRCS		Contains the sources files for the specific rule.
#	OUTPUT		The name of the output file (if relevant).
#Example:
#	minify_main: SRCS := hello.js
#	minify_main: OUTPUT := hello.min.js

minify_irrequire: SRCS := srcs/irrequire.js
minify_irrequire: OUTPUT := irrequire.min.js

STAMP_TXT := irRequire $(OUTPUT) (`date +'%Y.%m.%d'`) by Blaise Lengrand
MINIFY_JS_FLAGS := $(MINIFY_JS_FLAGS_HARDCORE)