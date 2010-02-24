Name:		viros
Version:	0.6.2010_02_24
#Release:	1%{?dist}
Release:	1.zyx
Summary:	System Image Synthesis Toolset

Group:		System Environment/Base
License:	GPL
URL:		http://viros.org
Source0:	%{name}-%{version}.tar.bz2
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

# it really almost is noarch, perhaps could be (bash splitter needed)
#BuildArch:      noarch
BuildRequires:	bash
BuildRequires:	gcc
BuildRequires:	make
Requires:	bash
Requires:	perl 
Requires:	squashfs-tools
Requires:	httpd
Requires:	pykickstart
Requires:	tigervnc
Requires:	tigervnc-server
Requires:	qemu
Requires:	wget
Requires:	pyvnc2swf


Buildroot:	 %{_tmppath}/%{name}-%{version}-%{release}-root


%description
The VirOS(tm) toolset is for generating derivative OS
distributions, including LiveCD/DVD/ISO/USBs and complete
installed system disk images suitable for virtualization.
Currently Fedora is supported.  CentOS, Ubuntu and Debian
upport are on the roadmap.


%prep
%setup -q


%build
make %{?_smp_mflags}


%install
rm -rf $RPM_BUILD_ROOT
# todo: make consistent with zli
#make install DESTDIR=$RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT PREFIX=${RPM_BUILD_ROOT}/usr
desktop-file-validate $RPM_BUILD_ROOT/%{_datadir}/applications/viros.desktop


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc AUTHORS COPYING README
%{_bindir}/%{name}
%{_datadir}/%{name}/
%{_sbindir}/*
%attr(0644,root,root) %{_datadir}/applications/%{name}.desktop


%changelog

* Wed Feb 24 2010 Douglas McClendon <dmc.dev@gzyx.org> - 0.6.2010_02_24
- misc cleanups for Guitar-ZyX-0.5.0
- ISOLABEL back to CDLABEL for the benefit of unetbootin

* Fri Feb 12 2010 Douglas McClendon <dmc.dev@gzyx.org> - 0.6.2010_02_12
- misc cleanups
- initrd to initramfs
- vxmog: correctly clean up other kernels
- f-zyx: selinux initialization as per contemporary mkinitrd
- synthesize: removed some acpi= workarounds, added qreaper workaround
- style: decided x$ is needless (until I see proof otherwise)
- bugs: TMPDIR environment checking corrected
- smirfgen/xmog: ancestor bootsplash integration
- smirfgen: put kmods in natural subdirs
- smirfgen: parse ldd output a bit better
- zbuild: new smirfgen only xmog mode (zyx-smirfgen xmog)

* Wed Jan 18 2010 Douglas McClendon <dmc.dev@gzyx.org> - 0.6.2010_01_20
- for the actual build of Guitar-ZyX-0.4.1

* Mon Jan 18 2010 Douglas McClendon <dmc.dev@gzyx.org> - 0.6.2010_01_18
- for Guitar-ZyX-0.4.1

* Mon Dec 21 2009 Douglas McClendon <dmc.dev@gzyx.org> - 0.6.2009_12_21
- new mutateopt of save_traits to put trait source in output
- new trait:/trait-install/config.vml for trait dependencies
- no longer strip out comments
- guest_smirf: no longer rely on host files if virthost specified
- use per ancenstor major version strain configs (easier rebasing)
- sha256sum instead of sha1sum as per upstream defaults
- add /lib/terminfo to initramfs for less (ala livecd-tools)
- fixed typo in LiveOS smirgen.cfg for splash files
- strain: g-zyx: add empathy for voice chat
- for Guitar-ZyX-0.4

* Sun Jul 27 2009 Douglas McClendon <dmc.dev@gzyx.org> - 0.5.20090727
- for Guitar-ZyX-0.3

* Sat Mar 21 2009 Douglas McClendon <dmc.dev@gzyx.org> - 0.5.20090321
- primarily, 1st pass at f10 compat

* Sun Mar 09 2009 Douglas McClendon <dmc.dev@gzyx.org> - 0.5.20090309
- maintenence release - Guitar-ZyX

* Fri Nov 07 2008 Douglas McClendon <dmc.dev@gzyx.org> - 0.5.20081107
- maintenence release - f9 compat
- trait splice/unsplice replaces addtrait
- bases renamed to ancestors

* Fri Feb 29 2008 Douglas McClendon <dmc.dev@gzyx.org> - 0.5.20080229
- further extensive and rapid development.  
- (interim changelogs deleted)

* Mon Jan 07 2008 Douglas McClendon <dmc.dev@gzyx.org> - 0.5.20080107
- initial rpm-ified release
