#version=F12
# Firewall configuration
### todo: see if this can be removed without complications
### viros: traits are responsible for locking down
###firewall --enabled --service=mdns
firewall --disabled
# X Window System configuration information
xconfig  --startxonboot
### todo: own cgi in mirrors that responds appropriately
###repo --name=released --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-12&arch=$basearch
###repo --name=updates --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f12&arch=$basearch
repo --name=released --baseurl=http://mirrors1.kernel.org/fedora/releases/12/Everything/i386/os
### viros: todo experiment: should not be necessary to hide this but...
###repo --name=updates --baseurl=http://mirrors1.kernel.org/fedora/updates/12/i386
# System authorization information
auth --useshadow --enablemd5
# System keyboard
keyboard us

########include fedora-live-base.ks
# System language
lang en_US.UTF-8
# SELinux configuration
selinux --enforcing
# Installation logging level
logging --level=info

# System services
### handled in vml traits
###services --disabled="network,sshd" --enabled="NetworkManager"
###services  --disabled="network,sshd,nfs,nfslock" --enabled="NetworkManager"
# System timezone
###timezone  US/Eastern
timezone  America/Denver
# Disk partitioning information
### todo: make this settable in .vml as a synthopt
# note: unsure if --grow --asprimary --ondisk=sda are really needed
###part / --fstype="ext4" --size=3072
part /  --fstype="ext3" --size=4096 --grow --asprimary --ondisk=sda

%post
# FIXME: it'd be better to get this installed from a package
cat > /etc/rc.d/init.d/livesys << EOF
#!/bin/bash
#
# live: Init script for live image
#
#### chkconfig: 345 00 99
# chkconfig: 345 00 98
# description: Init script for live image.

. /etc/init.d/functions

if ! strstr "\`cat /proc/cmdline\`" liveimg || [ "\$1" != "start" ]; then
    exit 0
fi

if [ -e /.liveimg-configured ] ; then
    configdone=1
fi

exists() {
    which \$1 >/dev/null 2>&1 || return
    \$*
}

touch /.liveimg-configured


livedir="LiveOS"
for arg in \`cat /proc/cmdline\` ; do
  if [ "\${arg##live_dir=}" != "\${arg}" ]; then
    livedir=\${arg##live_dir=}
    return
  fi
done

#v
# enable swaps if requested
swaps=\`blkid -t TYPE=swap -o device\`
if strstr "\`cat /proc/cmdline\`" swap && [ -n "\$swaps" ] ; then
  for s in \$swaps ; do
    action "Enabling swap partition \$s" swapon \$s
  done
fi
if strstr "\`cat /proc/cmdline\`" swap && [ -f /mnt/live/\${livedir}/swap.img ] ; then
  action "Enabling swap file" swapon /mnt/live/\${livedir}/swap.img
fi

mountPersistentHome() {
  # support label/uuid
  if [ "\${homedev##LABEL=}" != "\${homedev}" -o "\${homedev##UUID=}" != "\${homedev}" ]; then
    homedev=\`/sbin/blkid -o device -t "\$homedev"\`
  fi

  # if we're given a file rather than a blockdev, loopback it
  if [ "\${homedev##mtd}" != "\${homedev}" ]; then
    # mtd devs don't have a block device but get magic-mounted with -t jffs2
    mountopts="-t jffs2"
  elif [ ! -b "\$homedev" ]; then
    loopdev=\`losetup -f\`
    if [ "\${homedev##/mnt/live}" != "\${homedev}" ]; then
      action "Remounting live store r/w" mount -o remount,rw /mnt/live
    fi
    losetup \$loopdev \$homedev
    homedev=\$loopdev
  fi

  # if it's encrypted, we need to unlock it
  if [ "\$(/sbin/blkid -s TYPE -o value \$homedev 2>/dev/null)" = "crypto_LUKS" ]; then
    echo
    echo "Setting up encrypted /home device"
    plymouth ask-for-password --command="cryptsetup luksOpen \$homedev EncHome"
    homedev=/dev/mapper/EncHome
  fi

  # and finally do the mount
  mount \$mountopts \$homedev /home
  # if we have /home under what's passed for persistent home, then
  # we should make that the real /home.  useful for mtd device on olpc
  if [ -d /home/home ]; then mount --bind /home/home /home ; fi
  [ -x /sbin/restorecon ] && /sbin/restorecon /home
  if [ -d /home/liveuser ]; then USERADDARGS="-M" ; fi
}

findPersistentHome() {
  for arg in \`cat /proc/cmdline\` ; do
    if [ "\${arg##persistenthome=}" != "\${arg}" ]; then
      homedev=\${arg##persistenthome=}
      return
    fi
  done
}

if strstr "\`cat /proc/cmdline\`" persistenthome= ; then
  findPersistentHome
elif [ -e /mnt/live/\${livedir}/home.img ]; then
  homedev=/mnt/live/\${livedir}/home.img
fi

# if we have a persistent /home, then we want to go ahead and mount it
if ! strstr "\`cat /proc/cmdline\`" nopersistenthome && [ -n "\$homedev" ] ; then
  action "Mounting persistent /home" mountPersistentHome
fi


if [ -n "\$configdone" ]; then
  exit 0
fi


EOF

chmod 755 /etc/rc.d/init.d/livesys
/sbin/restorecon /etc/rc.d/init.d/livesys
/sbin/chkconfig --add livesys

# work around for poor key import UI in PackageKit
rm -f /var/lib/rpm/__db*
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora

# go ahead and pre-make the man -k cache (#455968)
/usr/sbin/makewhatis -w

%end


%packages
@admin-tools
@base
@base-x
@core
@dial-up
@fonts
@games
@gnome-desktop
@graphical-internet
@hardware-support
@input-methods
@printing
@sound-and-video
NetworkManager-openvpn
NetworkManager-vpnc
abiword
anaconda
cheese
festival
festvox-slt-arctic-hts
isomd5sum
kernel
memtest86+
nss-mdns
sendmail
xz-lzma-compat
-a2ps
-acpid
-alacarte
-aspell-*
-autofs
-ccid
-compat*
-constantine-backgrounds-extras
-coolkey
-dasher
-desktop-backgrounds-basic
-ekiga
-esc
-evince-djvu
-evince-dvi
-evolution-help
-finger
-ftp
-gnome-games-help
-gnome-user-docs
-hpijs
-hplip
-hunspell-*
-isdn4k-utils
-jwhois
-krb5-auth-dialog
-krb5-workstation
-lzma
-minicom
-mpage
-mtr
-nfs-utils
-nss_db
-numactl
-pam_krb5
-pinfo
-policycoreutils-gui
-ql2100-firmware
-ql2200-firmware
-ql23xx-firmware
-ql2400-firmware
-quota
-redhat-lsb
-rpcbind
-rsh
-samba-client
-sane-backends
-seahorse
-smartmontools
-specspo
-tomboy
wget
-words
-xsane
-xsane-gimp
-yp-tools
-ypbind

%end
