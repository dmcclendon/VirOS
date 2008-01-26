#
# this file originated from fedora livecd-tools'
#
# /usr/share/livecd-tools/livecd-fedora-minimal.ks
#

lang en_US.UTF-8
keyboard us
timezone US/Eastern
auth --useshadow --enablemd5
selinux --enforcing
firewall --disabled
part / --size 1024

#repo --name=development --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=rawhide&arch=$basearch
repo --name=released --baseurl=http://mirrors1.kernel.org/fedora/releases/8/Everything/i386/os

%packages
@core
bash
kernel
passwd
policycoreutils
chkconfig
authconfig
rootfiles

%end
