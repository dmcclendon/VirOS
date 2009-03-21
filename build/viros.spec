Name:		viros
Version:	0.5.2009_03_21
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
* Sat Mar 21 2009 Douglas McClendon <dmc@viros.org> - 0.5.20080321
- primarily, 1st pass at f10 compat

* Sun Mar 09 2009 Douglas McClendon <dmc@viros.org> - 0.5.20080309
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
