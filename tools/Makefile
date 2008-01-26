#
# Makefile for the VirOS System Imaging Toolset tools subdir
#

####################
# Global Variables #
####################
TOP         = ..
include $(TOP)/build/makefile.common


SUBDIRS = \
	bin \
	checkport \
	scripts \
	splitter \
	ZyX-Live-OS

all clean install uninstall: $(SUBDIRS)
	for subdir in $(SUBDIRS); do (cd $${subdir}; $(MAKE) $@); done

default:
	make all
