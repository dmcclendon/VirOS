#repo --name=released --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-8&arch=$basearch
repo --name=released --baseurl=http://mirrors1.kernel.org/fedora/releases/8/Everything/i386/os

# for development purposes, not using updates
#repo --name=updates --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f8&arch=$basearch
#repo --name=updates --baseurl=http://mirrors1.kernel.org/fedora/updates/8/i386


# System authorization information
auth --useshadow --enablemd5
# Firewall configuration
firewall --disabled
# System keyboard
keyboard us
# System language
lang en_US.UTF-8
# SELinux configuration
selinux --enforcing
# System services
services  --disabled=network,sshd,nfs,nfslock --enabled=NetworkManager
# System timezone
timezone  US/Central
# X Window System configuration information
xconfig  --startxonboot
# Disk partitioning information
part /  --size=4096 --bytes-per-inode=4096

%post

# workaround avahi segfault (#279301)
touch /etc/resolv.conf
/sbin/restorecon /etc/resolv.conf

### VirOS: we might want to boot as a vsi in qemu
# save a little bit of space at least...
#rm -f /boot/initrd*
# make sure there aren't core files lying around
rm -f /core*

%end

%post --nochroot
cp $INSTALL_ROOT/usr/share/doc/*-release-*/GPL $LIVE_ROOT/GPL
cp $INSTALL_ROOT/usr/share/doc/HTML/readme-live-image/en_US/readme-live-image-en_US.txt $LIVE_ROOT/README

# only works on x86, x86_64
if [ "$(uname -i)" = "i386" -o "$(uname -i)" = "x86_64" ]; then
  cp /usr/bin/livecd-iso-to-disk $LIVE_ROOT/LiveOS
fi
%end

%packages
@base-x
@base
@core
@admin-tools
@dial-up
@hardware-support
@printing
@games
@graphical-internet
@graphics
@sound-and-video
@gnome-desktop
@afrikaans-support
@albanian-support
@arabic-support
@armenian-support
@assamese-support
@basque-support
@belarusian-support
@bengali-support
@bhutanese-support
@bosnian-support
@brazilian-support
@breton-support
@british-support
@bulgarian-support
@catalan-support
@chinese-support
@croatian-support
@czech-support
@danish-support
@dutch-support
@estonian-support
@ethiopic-support
@faeroese-support
@filipino-support
@finnish-support
@french-support
@gaelic-support
@galician-support
@georgian-support
@german-support
@greek-support
@gujarati-support
@hebrew-support
@hindi-support
@hungarian-support
@icelandic-support
@indonesian-support
@inuktitut-support
@irish-support
@italian-support
@japanese-support
@kannada-support
@khmer-support
@korean-support
@lao-support
@latvian-support
@lithuanian-support
@malay-support
@malayalam-support
@maori-support
@marathi-support
@northern-sotho-support
@norwegian-support
@oriya-support
@persian-support
@polish-support
@portuguese-support
@punjabi-support
@romanian-support
@russian-support
@samoan-support
@serbian-support
@sinhala-support
@slovak-support
@slovenian-support
@somali-support
@southern-ndebele-support
@southern-sotho-support
@spanish-support
@swati-support
@swedish-support
@tagalog-support
@tamil-support
@telugu-support
@thai-support
@tibetan-support
@tonga-support
@tsonga-support
@tswana-support
@turkish-support
@ukrainian-support
@urdu-support
@venda-support
@vietnamese-support
@welsh-support
@xhosa-support
@zulu-support
kernel
memtest86+
gparted
anaconda
isomd5sum
nss-mdns
NetworkManager-vpnc
NetworkManager-openvpn
abiword
gnumeric
evince
gnome-blog
scim-chewing
scim-pinyin
-specspo
-esc
-samba-client
-a2ps
-mpage
-redhat-lsb
-sox
-hplip
-hpijs
-coolkey
-ccid
-pinfo
-vorbis-tools
-wget
-compat*
-ql2100-firmware
-ql2200-firmware
-ql23xx-firmware
-ql2400-firmware
-xsane
-xsane-gimp
-sane-backends
-*debuginfo
-aspell-*
-man-pages-*
-scim-tables-*
-wqy-bitmap-fonts
-dejavu-fonts-experimental
-dejavu-fonts
-scim-lang-chinese
-gnome-user-docs
-gimp-help
-evolution-help
-autofs
-nss_db
-vino

%end
