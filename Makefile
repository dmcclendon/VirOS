#
# Makefile for the VirOS System Imaging Toolset
#

####################
# Global Variables #
####################
TOP         = .
include $(TOP)/build/makefile.common


SUBDIRS = \
	tools 

###############
# Build Rules #
###############

default:
	make all

all clean install uninstall: $(SUBDIRS)
	for subdir in $(SUBDIRS); do \
	(cd $${subdir}; $(MAKE) $@); \
	make $@_also; \
	done

all_also:
	ln -s ./tools/scripts/vsys ./viros
	ln -s fedora-11 ./ancestors/gzyx-0.4
	ln -s M-ZyX.vml ./strains/min.vml
	ln -s M-ZyX.vml ./strains/minimal.vml

clean_also:
	rm -vf ./viros
	rm -vf ./ancestors/gzyx-0.4
	rm -vf ./strains/min.vml
	rm -vf ./strains/minimal.vml

install_also:
	mkdir -p $(PREFIX)/lib/viros/ 
	cp -rv \
		./ancestors \
		./fitness \
		./strains \
		./traits \
		$(PREFIX)/lib/viros/ 
	mkdir -p $(PREFIX)/share/doc/
	cp -rv ./info $(PREFIX)/share/doc/viros-$(VERSION)
	mkdir -p $(PREFIX)/bin
	ln -s ../lib/viros/tools/scripts/vsys $(PREFIX)/bin/viros

uninstall_also:
	rm -rvf $(PREFIX)/lib/viros
	rm -rvf $(PREFIX)/share/doc/viros-$(VERSION)
	
tidy:
	@ echo "removing temporary and backup files"
	find . -name "*~" -exec rm -vf '{}' ';'
	find . -name "#~" -exec rm -vf '{}' ';'
	# lazy
	chmod -R g-w traits

release:
	@ echo "building release tarball"
	./tools/scripts/makerelease $(VERSION) $(RELEASE)

xrelease:
	make release
	tar xvjf viros-$(VERSION).tar.bz2

distclean:
	make tidy
	make clean
	rm -f viros-$(VERSION)-$(RELEASE).src.rpm 
	rm -f viros-$(VERSION)-$(RELEASE).i386.rpm 
	rm -f viros-$(VERSION).tar.bz2
	rm -rf viros-$(VERSION)

srpm:	
	rpmdev-setuptree
	make release
	cp viros-$(VERSION).tar.bz2 ${HOME}/rpmbuild/SOURCES/
	rpmbuild -bs build/viros.spec
	mv ${HOME}/rpmbuild/SRPMS/viros-$(VERSION)-$(RELEASE).src.rpm .

rpm:
	make srpm
	rpm -i viros-$(VERSION)-$(RELEASE).src.rpm 
	rpmbuild --rebuild viros-$(VERSION)-$(RELEASE).src.rpm 
	mv ${HOME}/rpmbuild/RPMS/i386/viros-$(VERSION)-$(RELEASE).i386.rpm .

vrepostuff:
	make rpm
	cp -av viros-$(VERSION)-$(RELEASE).i386.rpm ./vrepo/fedora/9/i386/
	cp -av viros-$(VERSION)-$(RELEASE).src.rpm ./vrepo/fedora/9/SRPMS/
	cp -av viros-$(VERSION).tar.bz2 ./vrepo/tarballs/
	createrepo ./vrepo/fedora/9/i386
	createrepo ./vrepo/fedora/9/SRPMS
