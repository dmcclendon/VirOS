#
# Makefile for the VirOS scripts subdir
#

####################
# Global Variables #
####################
TOP = ../..
include $(TOP)/build/makefile.common


################
# Local Macros #
################

################
# Script Files #
################

# note/lesson-learned: whitespace after '\' made make unhappy

SCRIPTS = \
	check-mirrors \
	dm-parts \
	findfreeport \
	functions \
	get_dna_of_vsi \
	libvopt.sh \
	libvsys.sh \
	lixmog \
	mutate \
	qfakeroot \
	qfakeroot.test.disk_image \
	qfakeroot.test.network \
	qrap \
	smirfgen \
	spawn \
	specvnc \
	synthesize \
	test.program.sh \
	transmogrify \
	update-mirrors \
	vcommon \
	vdefs \
	vmirmog \
	vreplace \
	vsys \
	webserver \
	zspawn


###############
# Build Rules #
###############

all: 

clean:

install: 
	for script in $(SCRIPTS); do \
	$(INSTALL_SCRIPT) -D $${script} $(PREFIX)/lib/viros/tools/scripts/$${script}; \
	done

uninstall:
	for script in $(SCRIPTS); do \
	rm -vf $(PREFIX)/lib/viros/tools/scripts/$${script}; \
	done
