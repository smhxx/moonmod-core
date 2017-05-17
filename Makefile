SHELL := /bin/bash

fix_path = $(shell sed -n -e ":loop" -e "s;[^/ ]*/\.\./;;g" -e "t loop" -e "p" <(echo "$(1)"))
get_output = $(call fix_path,$(shell sed -n "/^Output \".*\"/s;^.*\"\(.*\)\".*;$(call get_out_prefix,"$(1)")\1;p" "$(1)"))
get_inputs = $(call fix_path,$(shell sed -n "/^Main \".*\"/s;^.*\"\(.*\)\".*;$(call get_ins_prefix,"$(1)")/\1;p" "$(1)"))
get_out_prefix = $(shell sed -rn "s;^(.*(^|\/))(src|build)\/.*;\1;p" <(echo "$(1)"))
get_ins_prefix = $(call convert_dir,$(shell dirname $(1)))
check_output = $(shell if [ "$(call get_output,"$(1)")" == "$(2)" ]; then echo "$(1)"; fi)
convert_dir = $(shell sed -rn "s;[ ]?(.*)src(.*);\1build\2;p" <(echo "$(1)"))

all_src_squishies := $(shell find src -name squishy 2> /dev/null)
all_lib_squishies := $(shell find libraries/*/src -name squishy 2> /dev/null)
all_bld_squishies := $(foreach squishy,$(all_src_squishies),$(call convert_dir,"$(squishy)"))

get_src_squishy = $(strip $(foreach squishy,$(all_src_squishies),$(call check_output,"$(squishy)","$(1)")))
get_bld_squishy = $(if $(call get_src_squishy,"$(1)"),$(call convert_dir,$(call get_src_squishy,"$(1)")),$(error Unable to find squishy for file $(1)))

all_src_outputs = $(foreach squishy,$(all_src_squishies),$(call get_output,"$(squishy)"))
all_lib_outputs = $(foreach squishy,$(all_lib_squishies),$(call get_output,"$(squishy)"))

all_manifest_inputs = $(shell echo $$(sed -nr "s;^.*\"([^\"]*\.json)\".*;templates/\1;p" "templates/manifest.json"))

.PHONY: save dist test testdist libraries resources alwayscheck
.PRECIOUS: build/%.lua build/%/squishy dist/%.lua libraries/%

# Command line shortcuts
save: dist/save.json
	@if [ -e .savefile ]; then\
		dest=$$(head -n 1 .savefile);\
		echo "Copying to $$dest...";\
		mkdir -p $$(dirname $$dest);\
		cp -f dist/save.json $$dest;\
	else\
		echo "No save file specified, nothing to copy.";\
	fi
	@echo "Done!"

dist: $(call all_src_outputs)

libraries: $(call all_lib_outputs)

test: SILENT:="-s"
test: libraries
	@busted

testdist: SILENT:="-s"
testdist: libraries dist
	@busted -Xhelper="--use-dist"

resources:
	@echo "Pushing to gh-pages..."
	@git subtree push --prefix resources origin gh-pages
	@echo "Done!"

# Build Rules
build/%.lua: src/%.moon
	@moonc -o $@ $<

build/squishy: src/squishy
	@mkdir -p $(@D)
	@cp $< $@

build/%/squishy: src/%/squishy
	@mkdir -p $(@D)
	@cp $< $@

libraries/%: alwayscheck
	@make $(SILENT) -C $(shell echo "$@" | cut -d '/' -f-2) $(shell echo "$@" | cut -d '/' -f3-)

alwayscheck:

dist/save.json: templates/.save.json $(call all_src_outputs)
	@cp templates/.save.json dist/save.json
	@for source in $(call all_src_outputs); do\
		/bin/bash templates/.import.sh $$source;\
	done
	@echo "Updating last modified date..."
	@jq --arg date "$$(date +"%D %r")" '.Date=$$date' "dist/save.json" > dist/.save.json
	@mv -f "dist/.save.json" "dist/save.json"
	@echo "Finished creating save file"

templates/.save.json: templates/manifest.json $(call all_manifest_inputs)
	@echo "Building save template from manifest..."
	@/bin/bash templates/.build.sh
	@echo "Finished building save template"

.SECONDEXPANSION:
dist/%.lua: SILENT:="-s"
dist/%.lua: $$(call get_bld_squishy,$$@) $$(call get_inputs,$$(call get_src_squishy,$$@))
	@mkdir -p $(@D)
	@squish $(shell dirname $<)
