# Generic Makefile, by Blaise Lengrand

# Usefull predefined
MINIFY_JS_FLAGS_HARDCORE := \
	--compress sequences=true,dead_code=true,conditionals=true,booleans=true,unused=true,if_return=true,join_vars=true,drop_console=true \
	--mangle toplevel=true,eval=true \
	--lint -v

-include config.mk

# List all available targets (starting with 'target_*')
ALL_RULES := $(shell test -s config.mk && cat config.mk | grep -e '^minify_\|^dist_' |  awk -F':' '{print $$1}' | uniq)

# Predefined rules
all: config.mk $(ALL_RULES)
build: all
silent: VERBOSE := 0
silent: config.mk $(ALL_RULES)
verbose: VERBOSE := 2
verbose: config.mk $(ALL_RULES)

# Prevent makefile auto-clean
.SECONDARY:
# Use of rule-specific variables
.SECONDEXPANSION:
.PHONY: all silent verbose help build rebuild release

# Default values
PACKAGE ?= package.zip
STAMP_TXT ?= $(OUTPUT) (`date +'%Y.%m.%d'`)
VERBOSE ?= 1
BUILDDIR ?= .make
DISTDIR ?= dist
SRCS := 
OUTPUT := 

# Commands
PRINT_CMD := printf
MINIFY_JS_CMD := uglifyjs
MINIFY_CSS_CMD := uglifycss
CONCAT_CMD := cat
MKDIR_CMD := mkdir
RMDIR_CMD := rm
COPY_CMD := cp
PACK_CMD := zip

# Flags
PRINT_FLAGS ?=
MINIFY_JS_FLAGS ?= --compress --mangle -v --lint
MINIFY_CSS_FLAGS ?=
CONCAT_FLAGS ?=
MKDIR_FLAGS ?= -p
RMDIR_FLAGS ?= -rfd
COPY_FLAGS ?= -R
PACK_FLAGS ?= -o -r

# Available colors
COLOR_END := "\033[0m"
COLOR_RED := "\033[0;31m"
COLOR_YELLOW := "\033[0;33m"
COLOR_GREEN := "\033[0;32m"
COLOR_BLUE := "\033[0;34m"
COLOR_ORANGE := "\033[0;33m"
COLOR_DARK_GRAY := "\033[1;30m"
COLOR_CYAN := "\033[0;36m"

# Command update helpers
PRINT_V0 = @:
PRINT_V1 = @$(PRINT_CMD) $(PRINT_FLAGS)
PRINT_V2 = $(PRINT_V1)
PRINT = $(PRINT_V$(VERBOSE))
AT_V0 := @
AT_V1 := @
AT_V2 :=  
AT = $(AT_V$(VERBOSE))
COMMA := ,
# Updated commands
define MINIFY_JS
$(call MSG,MINJS,GREEN,$2);
$(AT)$(MINIFY_JS_CMD) $(MINIFY_JS_FLAGS) $1 -o $2;
endef
define MINIFY_CSS
$(call MSG,MINCSS,GREEN,$2);
$(AT)$(MINIFY_CSS_CMD) $(MINIFY_CSS_FLAGS) $1 > $2;
endef
define CONCAT
$(call MSG,CONCAT,GREEN,$2);
$(AT)$(CONCAT_CMD) $(CONCAT_FLAGS) $1 > $2;
endef
define MKDIR
$(if $(shell test -d $1 && echo 1),,$(call MSG,MKDIR,CYAN,$1);$(MKDIR_CMD) $(MKDIR_FLAGS) $1)
endef
define RMDIR
$(if $(shell test -d $1 && echo 1),$(call MSG,RMDIR,CYAN,$1);$(RMDIR_CMD) $(RMDIR_FLAGS) $1,)
endef
define COPY
$(call MSG,COPY,CYAN,$1);
$(AT)$(COPY_CMD) $(COPY_FLAGS) $1 $2;
endef
define PACK
$(call MSG,PACK,CYAN,$2);
$(AT)$(PACK_CMD) $(PACK_FLAGS) $2 $1 >/dev/null;
endef
define STAMP
$(call MSG,STAMP,GREEN,$1);
$(AT)echo "$(strip $2)" > .temp && cat $1 >> .temp && mv .temp $1;
endef

# Check that given variables are set and all have non-empty values,
# die with an error otherwise.
# Params:
#   1. Variable name to test.
#   2. (optional) Error message to print.
CHECK_DEFINED = \
	$(strip $(foreach 1,$1, \
		$(call __CHECK_DEFINED,$1,$(strip $(value 2)))))
__CHECK_DEFINED = \
	$(if $(value $1),, \
		@$(call ERROR, Undefined $1$(if $2, ($2))$(if $(value @), \
			required by target '$@')))

# Check if a tool is present
# Params:
#   1. Tool name
#   2. Message if not present
define CHECK_TOOL
$(if $(shell command -v $1 2>/dev/null),$(call MSG,CHECK,CYAN,$1),$(call ERROR,$2))
endef

# Checks if a file exists
# Params:
#   1. File
#   2. Message
#   3. (optional) Action to perform if it does not exists
define CHECK_FILE
$(if $(shell test -s $1 && echo 1),,$(shell $(if $(value 3),$3)))
$(if $(shell test -s $1 && echo 1),$(call MSG,CHECK,CYAN,$1),$(call ERROR,$2))
endef

# Print a formated message
#
# Params:
#   1. Type
#   2. Color (any available colors from COLOR_*)
#   3. Message
#   4. (optional) If set, the message will not be trunc
MSG_TRUNCATE_V0 =
MSG_TRUNCATE_V1 = $(if $(shell test 80 -gt $(shell printf "%s" "$3" | wc -m) && echo 1),$3,$(shell printf "%s" "$3" | cut -c 1-80)...)
MSG_TRUNCATE_V2 = $3
MSG_TRUNCATE = $(strip $(MSG_TRUNCATE_V$(VERBOSE)))
define MSG
$(PRINT) $(COLOR_END)$(COLOR_$2)$1$(COLOR_END)"\t\t$(if $(value 4),$3,$(MSG_TRUNCATE))\n"
endef

# Print an error message and exit
# Params:
#   1. Error message to print.
define ERROR
$(call MSG,ERROR,RED,"$(COLOR_RED)"$(strip $1)$(COMMA) abort."$(COLOR_END)",1)
@exit 1
endef

help:
	@printf "Generic Makefile by Blaise Lengrand\n"
	@printf "Usage: make [rule]\n"
	@printf "\n"
	@printf "By default, it will run all user rules starting with specific\n"
	@printf "names, the followings are currently supported:\n"
	@printf "\tminify_*\t\tMinify and concatenate the source files, available\n"
	@printf "\t        \t\tonly for *.js and *.css files.\n"	
	@printf "\tdist_*\t\tCopy the files or directory to the dist directory.\n"
	@printf "\n"
	@printf "List of rules available:\n"
	@printf "\tsilent\t\tNo verbosity, except error messages.\n"
	@printf "\tverbose\t\tHigh verbosity, including command executed.\n"
	@printf "\thelp\t\tDisplay this help message.\n"
	@printf "\tclean\t\tClean the environment and all generated files.\n"
	@printf "\tbuild\t\tBuild the targets.\n"
	@printf "\trebuild\t\tClean and re-build the targets.\n"
	@printf "\trelease\t\tRe-build the targets and generate the package.\n"
	@printf "\n"
	@printf "Configuration: config.mk\n"
	@printf "\tContains all user rules definitions. They use pre-made\n"
	@printf "\trules with the following options:\n"
	@printf "\tSRCS\t\tContains the sources files for the specific rule.\n"
	@printf "\tOUTPUT\t\tThe name of the output file (if relevant).\n"
	@printf "Example:\n"
	@printf "\tminify_main: SRCS := hello.js\n"
	@printf "\tminify_main: OUTPUT := hello.min.js\n"

# Check that all prerequired conditions are there
config.mk:
	$(call CHECK_FILE, config.mk, \
			'config.mk' does not exists or is empty$(COMMA) an empty template has been created, \
			make --no-print-directory help 2>/dev/null | sed 's/.*/#\0/' > config.mk)
	$(call CHECK_DEFINED, ALL_RULES, 'config.mk' contains no rules)

# Check if JS minify tools are present
check_minify_js:
	$(call CHECK_TOOL, $(MINIFY_JS_CMD), "Please install: sudo apt-get install npm && sudo npm install --global uglifyjs && uglifyjs --version")

# Check if CSS minify tools are present
check_minify_css:
	$(call CHECK_TOOL, $(MINIFY_CSS_CMD), "Please install: sudo apt-get install npm && sudo npm install --global uglifycss && uglifycss --version")

# Check if the packaging tools are present
check_pack:
	$(call CHECK_TOOL, $(PACK_CMD), "")

# Clean-up the created directoried
clean:
	$(call RMDIR,$(BUILDDIR)/)
	$(call RMDIR,$(DISTDIR)/)

# Clean and re-build the targets
rebuild:
	@+make --no-print-directory clean
	@+make --no-print-directory build

# Re-build all what is inside the dist directory and make a package of it all
release: check_pack
	$(call RMDIR,$(DISTDIR)/)
	@+make --no-print-directory build
	$(call MKDIR, `dirname "$(DISTDIR)/$(PACKAGE)"`/)
	$(call PACK,$(DISTDIR)/*,$(DISTDIR)/$(PACKAGE))

# Available source types for the target
SRCS_JS = $(filter %.js,$(SRCS))
SRCS_MIN_JS = $(SRCS_JS:%.js=$(BUILDDIR)/%.min.js)
SRCS_CSS = $(filter %.css,$(SRCS))
SRCS_MIN_CSS = $(SRCS_CSS:%.css=$(BUILDDIR)/%.min.css)

# Minify rule
minify_%: $$(SRCS_MIN_JS) $$(SRCS_MIN_CSS)
	$(call CHECK_DEFINED, SRCS, No sources specified)
	$(call CHECK_DEFINED, OUTPUT, No output specified)
	$(call MKDIR, `dirname "$(DISTDIR)/$(OUTPUT)"`/)
	$(call CONCAT, $(SRCS_MIN_JS) $(SRCS_MIN_CSS), "$(DISTDIR)/$(OUTPUT)")
	$(call STAMP, "$(DISTDIR)/$(OUTPUT)", /* $(STAMP_TXT) */)

# Dist rule
dist_%: $$(SRCS)
	$(call CHECK_DEFINED, SRCS, No sources specified)
	$(call MKDIR, "$(DISTDIR)/$(OUTPUT)")
	$(call COPY, $^, "$(DISTDIR)/$(OUTPUT)")

# js files
$(BUILDDIR)/%.min.js: check_minify_js %.js
	$(call MKDIR, `dirname $@`/)
	$(call MINIFY_JS, $(lastword $^), "$@")

# css files
$(BUILDDIR)/%.min.css: check_minify_css %.css
	$(call MKDIR, `dirname $@`/)
	$(call MINIFY_CSS, $(lastword $^), "$@")
