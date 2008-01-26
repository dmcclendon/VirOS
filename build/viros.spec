Name:		viros
Version:	0.5.2008_01_26
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
* Mon Jan 28 2008 Douglas McClendon <dmc@viros.org> - 0.5.20080126
- further extensive and rapid development.  

* Thu Jan 24 2008 Douglas McClendon <dmc@viros.org> - 0.5.20080125
- further extensive and rapid development.  

* Thu Jan 24 2008 Douglas McClendon <dmc@viros.org> - 0.5.20080124
- first public rpm release expected to work for on-line tutorial purposes

* Tue Jan 22 2008 Douglas McClendon <dmc@viros.org> - 0.5.20080122
- second public rpm release, progress still too fast to track in detail

* Mon Jan 07 2008 Douglas McClendon <dmc@viros.org> - 0.5.20080107
- initial rpm-ified release
