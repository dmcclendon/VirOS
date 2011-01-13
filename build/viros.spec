Name:		viros
Version:	0.7.2011_01_09
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
# for splitter (little whitespace standalone tool)
BuildRequires:	glibc-static
BuildRequires:	make
Requires:	bash
Requires:	perl 
Requires:	squashfs-tools
Requires:	httpd
Requires:	pykickstart
Requires:	tigervnc
Requires:	tigervnc-server
# sad, so sad, that apparently this is not easily satisfiable
# on stock el6-x86...
# todo: add qemu build (single target) to this specfile
#Requires:	qemu
Requires:	wget
# optional actually (and currently needs x11vnc from rpmforge)
#Requires:	pyvnc2swf


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
mkdir -p $RPM_BUILD_ROOT/usr/share/viros
#desktop-file-validate $RPM_BUILD_ROOT/%{_datadir}/applications/viros.desktop


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc info/README info/AUTHORS info/COPYING info/ROADMAP info/STYLE info/DESIGN
%{_bindir}/%{name}
%{_libdir}/%{name}/
%{_datadir}/%{name}/
#%{_sbindir}/*
#%attr(0644,root,root) %{_datadir}/applications/%{name}.desktop


%changelog

* Sun Jan 09 2011 Douglas McClendon <dmc.viros@cloudsession.com> - 0.7.2011_01_09
- bugfix: qemu not provided by stock el6-x86 repos, so presume it is provided for now
- bugfix: broken and missing documentation in output rpm
- bugfix: update-mirrors.el6 needed an exclude file
- bugfix: strains min/minimal and even platform have correct symlinks
- bugfix: generate was not exporting boot_iso_sha256sum to synthesize
- bugfix: update-mirrors now sans .el6, and exclude file generated on the fly
- tuning: changed qemu mem reqs from 512 to 422, better for my netbook, and seems fine
- aesthetic: fixed VNC titlebar sed renaming
- bugfix/workround: live booted rootfs(/) should now be 755 instead of 775(group:root)
- generate renamed to spawn, zgen to zspawn, more inline with the metaphor
- zgen: fitness/zbuild->scripts/zgen, now with update-mirrors phase by default
- fix add_search_paths and trait_dirs option parsing
- trait for x-zyx: bootsplash-solar
- bugfix: make rpm(&repos) (for non-primary-developers tree)
-  even verified make release from made release is idempotent
- forensic-mode: cheat code to prevent liveos from probing lvm/mdadm
- info/README: added system requirements outline
- update-mirrors: now takes an arg, synth/generate/mutate also utilize good defaults
- check-mirrors: new script for mass checking of rpmsigs


* Fri Dec 31 2010 Douglas McClendon <dmc.viros@cloudsession.com> - 0.7.2010_12_31
- mutate: make verbose logs a bit quieter (pushd/popd output)
- strains: min and minimal symlinks fixed (untested)
- README updated to highlight new update-mirrors.el6 script
- bug-id-3145642: smirfgen cp arg, a missing kernel hangs a build
- note: bug-id comes from the new tracker setup at viros.sf.net
- trait-wmctrl: fix post script so wmctrl actually gets installed
- trait-zli: 0.2.7 update
- x-zyx: fix final yum repos by moving release trait after c.r uninst (untested)
- note: this is an untested release, 12_26 built xz0601, noting filed bugs


* Sun Dec 26 2010 Douglas McClendon <dmc.viros@cloudsession.com> - 0.7.2010_12_26
- noudevsync workaround for el6
- several misc fixes
- for x-zyx-0.6.0.1

* Fri Dec 17 2010 Douglas McClendon <dmc.viros@cloudsession.com> - 0.6.2010_12_17
- support el6
- get_dna_of_vsi... hardcoded for el6 temporarily
- add glibc-static to BuildRequires

* Wed Feb 24 2010 Douglas McClendon <dmc.viros@cloudsession.com> - 0.6.2010_02_24
- misc cleanups for Guitar-ZyX-0.5.0
- ISOLABEL back to CDLABEL for the benefit of unetbootin

* Fri Feb 12 2010 Douglas McClendon <dmc.viros@cloudsession.com> - 0.6.2010_02_12
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

* Wed Jan 18 2010 Douglas McClendon <dmc.viros@cloudsession.com> - 0.6.2010_01_20
- for the actual build of Guitar-ZyX-0.4.1

* Mon Jan 18 2010 Douglas McClendon <dmc.viros@cloudsession.com> - 0.6.2010_01_18
- for Guitar-ZyX-0.4.1

* Mon Dec 21 2009 Douglas McClendon <dmc.viros@cloudsession.com> - 0.6.2009_12_21
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

* Sun Jul 27 2009 Douglas McClendon <dmc.viros@cloudsession.com> - 0.5.2009_07_27
- for Guitar-ZyX-0.3

* Sat Mar 21 2009 Douglas McClendon <dmc.viros@cloudsession.com> - 0.5.2009_03_21
- primarily, 1st pass at f10 compat

* Sun Mar 09 2009 Douglas McClendon <dmc.viros@cloudsession.com> - 0.5.2009_03_09
- maintenence release - Guitar-ZyX

* Fri Nov 07 2008 Douglas McClendon <dmc.viros@cloudsession.com> - 0.5.2008_11_07
- maintenence release - f9 compat
- trait splice/unsplice replaces addtrait
- bases renamed to ancestors

* Fri Feb 29 2008 Douglas McClendon <dmc.viros@cloudsession.com> - 0.5.2008_02_29
- further extensive and rapid development.  
- (interim changelogs deleted)

* Mon Jan 07 2008 Douglas McClendon <dmc.viros@cloudsession.com> - 0.5.2008_01_07
- initial rpm-ified release
