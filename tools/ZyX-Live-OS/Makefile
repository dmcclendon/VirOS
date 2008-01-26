#
# Makefile for the VirOS ZyX-Live-OS subdir
#

####################
# Global Variables #
####################
TOP = ../..
include $(TOP)/build/makefile.common


################
# Local Macros #
################

#########
# Files #
#########

# note/lesson-learned: whitespace after '\' made make unhappy

FILES = \
	etc_rc.d_init.d_functions.zyx_live \
	etc_rc.d_init.d_halt.zyx_live \
	findoverlay \
	live.fstab \
	live.init \
	live.nash_run_init \
	smirfgen.cfg 

###############
# Build Rules #
###############

all: 

clean:

install: 
	for file in $(FILES); do \
	$(INSTALL_SCRIPT) -D $${file} $(PREFIX)/lib/viros/tools/ZyX-Live-OS/$${file}; \
	done

uninstall:
	for file in $(FILES); do \
	rm -vf $(PREFIX)/lib/viros/tools/ZyX-Live-OS/$${file}; \
	done
