#repo --name=released --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-8&arch=$basearch
repo --name=released --baseurl=http://mirrors1.kernel.org/fedora/releases/8/Everything/i386/os
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
services  --disabled=network,sshd --enabled=NetworkManager
# System timezone
timezone  US/Eastern
# X Window System configuration information
xconfig  --startxonboot
# Disk partitioning information
part /  --size=4096 --bytes-per-inode=4096

%post
# FIXME: it'd be better to get this installed from a package
cat > /etc/rc.d/init.d/fedora-live << EOF
#!/bin/bash
#
# live: Init script for live image
#
# chkconfig: 345 00 99
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

# enable swaps unless requested otherwise
swaps=\`blkid -t TYPE=swap -o device\`
if ! strstr "\`cat /proc/cmdline\`" noswap -a [ -n "\$swaps" ] ; then
  for s in \$swaps ; do
    action "Enabling swap partition \$s" swapon \$s
  done
fi

# configure X, allowing user to override xdriver
exists system-config-display --noui --reconfig --set-depth=24 \$xdriver

# add fedora user with no passwd
useradd -c "Fedora Live" fedora
passwd -d fedora > /dev/null

# turn off firstboot for livecd boots
echo "RUN_FIRSTBOOT=NO" > /etc/sysconfig/firstboot

# don't start yum-updatesd for livecd boots
chkconfig --level 345 yum-updatesd off 2>/dev/null

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

# workaround avahi segfault (#279301)
touch /etc/resolv.conf
/sbin/restorecon /etc/resolv.conf

chmod 755 /etc/rc.d/init.d/fedora-live
/sbin/restorecon /etc/rc.d/init.d/fedora-live
/sbin/chkconfig --add fedora-live

# save a little bit of space at least...
rm -f /boot/initrd*
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

%post
cat >> /etc/rc.d/init.d/fedora-live << EOF
# disable screensaver locking
gconftool-2 --direct --config-source=xml:readwrite:/etc/gconf/gconf.xml.defaults -s -t bool /apps/gnome-screensaver/lock_enabled false >/dev/null
# set up timed auto-login for after 60 seconds
sed -i -e 's/\[daemon\]/[daemon]\nTimedLoginEnable=true\nTimedLogin=fedora\nTimedLoginDelay=60/' /etc/gdm/custom.conf
if [ -e /usr/share/icons/hicolor/96x96/apps/fedora-logo-icon.png ] ; then
    cp /usr/share/icons/hicolor/96x96/apps/fedora-logo-icon.png /home/fedora/.face
    chown fedora:fedora /home/fedora/.face
    # TODO: would be nice to get e-d-s to pick this one up too... but how?
fi

EOF

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
