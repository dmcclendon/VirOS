Name:		viros
Version:	0.6.2009_12_21
#Release:	1%{?dist}
Release:	1.zyx
Summary:	System Image Synthesis Toolset

Group:		System Environment/Base
License:	GPL
URL:		http://viros.org
Source0:	%{name}-%{version}.tar.bz2
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires:	gcc, make
Requires:	perl, bash, squashfs-tools, httpd, pykickstart, vnc, vnc-server, qemu, wget

%description
Tools for generating derivative OS distributions, including LiveCD/DVD/ISO/USBs
and complete installed system disk images suitable for virtualization.  Currently
Fedora is supported.  CentOS, Ubuntu and Debian support are on the horizon.

%prep
%setup -q


%build
#%NOTconfigure
#make %NOT{?_smp_mflags}
make


%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/usr
make install PREFIX=${RPM_BUILD_ROOT}/usr


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
#/lib/viros/bases/common/arap.orig.httpd.conf
/usr/bin
/usr/lib/viros
/usr/share


%changelog
* Mon Dec 21 2009 Douglas McClendon <dmc@viros.org> - 0.6.2009_12_21
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

* Sun Jul 27 2009 Douglas McClendon <dmc@viros.org> - 0.5.20090727
- for Guitar-ZyX-0.3

* Sat Mar 21 2009 Douglas McClendon <dmc@viros.org> - 0.5.20090321
- primarily, 1st pass at f10 compat

* Sun Mar 09 2009 Douglas McClendon <dmc@viros.org> - 0.5.20090309
- maintenence release - Guitar-ZyX

* Fri Nov 07 2008 Douglas McClendon <dmc@viros.org> - 0.5.20081107
- maintenence release - f9 compat
- trait splice/unsplice replaces addtrait
- bases renamed to ancestors

* Fri Feb 29 2008 Douglas McClendon <dmc@viros.org> - 0.5.20080229
- further extensive and rapid development.  
- (interim changelogs deleted)

* Mon Jan 07 2008 Douglas McClendon <dmc@viros.org> - 0.5.20080107
- initial rpm-ified release
