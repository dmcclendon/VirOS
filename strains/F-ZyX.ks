#version=F9
###repo --name=released --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-10&arch=$basearch
###repo --name=updates --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f10&arch=$basearch
## viros todo: add or verify basearch handling by mirrorlist
#repo --name=released --baseurl=http://mirrors1.kernel.org/fedora/releases/10/Everything/$basearch/os
repo --name=released --baseurl=http://mirrors1.kernel.org/fedora/releases/10/Everything/i386/os
# anaconda claims to ignore this duplcate repo
#repo --name=updates --baseurl=http://mirrors1.kernel.org/fedora/updates/10/i386
# Firewall configuration
firewall --disabled
# X Window System configuration information
xconfig  --startxonboot
# System authorization information
auth --useshadow --enablemd5
# System keyboard
keyboard us
# System language
lang en_US.UTF-8
# SELinux configuration
selinux --enforcing

# System services
###services  --disabled=network,sshd --enabled=NetworkManager
services  --disabled=network,sshd,nfs,nfslock --enabled=NetworkManager
# System timezone
###timezone  US/Eastern
timezone  America/Denver
#timezone  America/Los_Angeles
# Disk partitioning information
part /  --size=4096

%post
# FIXME: it'd be better to get this installed from a package
cat > /etc/rc.d/init.d/compat-live << EOF
#!/bin/bash
#
# live: Init script for live image
#
# chkconfig: 345 00 98
# description: Init script for live image.

. /etc/init.d/functions

if ! strstr "\`cat /proc/cmdline\`" liveimg || [ "\$1" != "start" ] || [ -e /.liveimg-configured ] ; then
    exit 0
fi

exists() {
    which \$1 >/dev/null 2>&1 || return
    \$*
}

touch /.liveimg-configured

# mount live image
if [ -b /dev/live ]; then
   mkdir -p /mnt/live
   mount -o ro /dev/live /mnt/live
fi

# enable swaps unless requested otherwise
swaps=\`blkid -t TYPE=swap -o device\`
if ! strstr "\`cat /proc/cmdline\`" noswap -a [ -n "\$swaps" ] ; then
  for s in \$swaps ; do
    action "Enabling swap partition \$s" swapon \$s
  done
fi

# add fedora user with no passwd
useradd -c "Compat Guest Live User" cguest
passwd -d cguest > /dev/null

# turn off firstboot for livecd boots
chkconfig --level 345 firstboot off 2>/dev/null

# don't start yum-updatesd for livecd boots
chkconfig --level 345 yum-updatesd off 2>/dev/null

# don't do packagekit checking by default
gconftool-2 --direct --config-source=xml:readwrite:/etc/gconf/gconf.xml.defaults -s -t string /apps/gnome-packagekit/frequency_get_updates never >/dev/null
gconftool-2 --direct --config-source=xml:readwrite:/etc/gconf/gconf.xml.defaults -s -t string /apps/gnome-packagekit/frequency_refresh_cache never >/dev/null
gconftool-2 --direct --config-source=xml:readwrite:/etc/gconf/gconf.xml.defaults -s -t bool /apps/gnome-packagekit/notify_available false >/dev/null

# apparently, the gconf keys aren't enough
mkdir -p /home/cguest/.config/autostart
echo "X-GNOME-Autostart-enabled=false" >> /home/cguest/.config/autostart/gpk-update-icon.desktop
chown -R cguest:cguest /home/cguest/.config



# don't start cron/at as they tend to spawn things which are
# disk intensive that are painful on a live image
chkconfig --level 345 crond off 2>/dev/null
chkconfig --level 345 atd off 2>/dev/null
chkconfig --level 345 anacron off 2>/dev/null
chkconfig --level 345 readahead_early off 2>/dev/null
chkconfig --level 345 readahead_later off 2>/dev/null

# Stopgap fix for RH #217966; should be fixed in HAL instead
touch /media/.hal-mtab

# workaround clock syncing on shutdown that we don't want (#297421)
sed -i -e 's/hwclock/no-such-hwclock/g' /etc/rc.d/init.d/halt
EOF

# bah, hal starts way too late
cat > /etc/rc.d/init.d/compat-late-live << EOF
#!/bin/bash
#
# live: Late init script for live image
#
# chkconfig: 345 98 01
# description: Late init script for live image.

. /etc/init.d/functions

if ! strstr "\`cat /proc/cmdline\`" liveimg || [ "\$1" != "start" ] || [ -e /.liveimg-late-configured ] ; then
    exit 0
fi

exists() {
    which \$1 >/dev/null 2>&1 || return
    \$*
}

touch /.liveimg-late-configured

# read some variables out of /proc/cmdline
for o in \`cat /proc/cmdline\` ; do
    case \$o in
    ks=*)
        ks="\${o#ks=}"
        ;;
    xdriver=*)
        xdriver="--set-driver=\${o#xdriver=}"
        ;;
    esac
done


# if liveinst or textinst is given, start anaconda
if strstr "\`cat /proc/cmdline\`" liveinst ; then
   /usr/sbin/liveinst \$ks
fi
if strstr "\`cat /proc/cmdline\`" textinst ; then
   /usr/sbin/liveinst --text \$ks
fi

# configure X, allowing user to override xdriver
if [ -n "\$xdriver" ]; then
   exists system-config-display --noui --reconfig --set-depth=24 \$xdriver
fi

EOF

# workaround avahi segfault (#279301)
touch /etc/resolv.conf
/sbin/restorecon /etc/resolv.conf

chmod 755 /etc/rc.d/init.d/compat-live
/sbin/restorecon /etc/rc.d/init.d/compat-live
/sbin/chkconfig --add compat-live

chmod 755 /etc/rc.d/init.d/compat-late-live
/sbin/restorecon /etc/rc.d/init.d/compat-late-live
/sbin/chkconfig --add compat-late-live

# work around for poor key import UI in PackageKit
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora

# save a little bit of space at least...
###rm -f /boot/initrd*
# make sure there aren't core files lying around
###rm -f /core*

%end

%post --nochroot
cp $INSTALL_ROOT/usr/share/doc/*-release-*/GPL $LIVE_ROOT/GPL
cp $INSTALL_ROOT/usr/share/doc/HTML/readme-live-image/en_US/readme-live-image-en_US.txt $LIVE_ROOT/README

# only works on x86, x86_64
if [ "$(uname -i)" = "i386" -o "$(uname -i)" = "x86_64" ]; then
  if [ ! -d $LIVE_ROOT/LiveOS ]; then mkdir -p $LIVE_ROOT/LiveOS ; fi
  cp /usr/bin/livecd-iso-to-disk $LIVE_ROOT/LiveOS
fi
%end

%post
cat >> /etc/rc.d/init.d/compat-live << EOF
# disable screensaver locking
gconftool-2 --direct --config-source=xml:readwrite:/etc/gconf/gconf.xml.defaults -s -t bool /apps/gnome-screensaver/lock_enabled false >/dev/null
# set up timed auto-login for after 60 seconds
###cat >> /etc/gdm/custom.conf << FOE
###[daemon]
###TimedLoginEnable=true
###TimedLogin=cguest
###TimedLoginDelay=60
###FOE

EOF

%end

%packages
@base-x
@base
@core
@fonts
@admin-tools
@dial-up
@hardware-support
@printing
@games
@graphical-internet
@graphics
@sound-and-video
@gnome-desktop
@albanian-support
@arabic-support
@assamese-support
@basque-support
@belarusian-support
@bengali-support
@brazilian-support
@british-support
@bulgarian-support
@catalan-support
@chinese-support
@czech-support
@danish-support
@dutch-support
@estonian-support
@finnish-support
@french-support
@galician-support
@georgian-support
@german-support
@greek-support
@gujarati-support
@hebrew-support
@hindi-support
@hungarian-support
@indonesian-support
@italian-support
@japanese-support
@kannada-support
@korean-support
@latvian-support
@lithuanian-support
@macedonian-support
@malayalam-support
@marathi-support
@nepali-support
@norwegian-support
@oriya-support
@persian-support
@polish-support
@portuguese-support
@punjabi-support
@romanian-support
@russian-support
@serbian-support
@slovak-support
@slovenian-support
@spanish-support
@swedish-support
@tamil-support
@telugu-support
@thai-support
@turkish-support
@ukrainian-support
@vietnamese-support
@welsh-support
kernel
nss-mdns
festival
abiword
isomd5sum
NetworkManager-openvpn
NetworkManager-vpnc
festvox-slt-arctic-hts
memtest86+
anaconda
scim-chewing
scim-pinyin
gnumeric
-tomboy
-gnome-user-docs
-vino
-nss_db
-acpid
-ql23xx-firmware
-a2ps
-lklug-fonts
-autofs
-sox
-hpijs
-ccid
-mpage
-*debuginfo
-jomolhari-fonts
-sane-backends
-esc
-abyssinica-fonts
-compat*
-man-pages-*
-samba-client
-dasher
-specspo
-scim-lang-chinese
-vorbis-tools
-ql2200-firmware
-ql2400-firmware
-scim-python*
-pinfo
-evolution-help
-scim-tables-*
-wget
-xsane
-evince-djvu
-coolkey
-xsane-gimp
-aspell-*
-f-spot
-hplip
-gimp-help
-hunspell-*
-ql2100-firmware
-wqy-bitmap-fonts
-dejavu-fonts-experimental
-evince-dvi
-ekiga
-redhat-lsb

%end
