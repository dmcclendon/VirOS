#
# this file originated from fedora livecd-tools'
#
# /usr/share/livecd-tools/livecd-fedora-minimal.ks
#

lang en_US.UTF-8
keyboard us
#timezone US/Eastern
timezone US/Central
auth --useshadow --enablemd5
selinux --enforcing
firewall --disabled
part / --size 1024

#repo --name=development --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=rawhide&arch=$basearch
#repo --name=released --baseurl=http://mirrors1.kernel.org/fedora/releases/13/Everything/i386/os
repo --name=released --baseurl=http://ftp.scientificlinux.org/linux/scientific/6rolling/i386/os

%packages
@core
anaconda-runtime
bash
kernel
passwd
policycoreutils
chkconfig
authconfig
rootfiles

%end
