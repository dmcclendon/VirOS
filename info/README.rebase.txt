#!/usr/bin/env bash
cat << EOF >> /dev/null
=============================================================================
=============================================================================

                   VirOS Ancestor Rebasing Guide

=============================================================================
=============================================================================


=============================================================================
Overview
-----------------------------------------------------------------------------

Rebasing against a major ancestor/upstream release is currently a rather
involved process.  As the wisdom of pushing as much as possible upstream
progresses, as well as refactoring/resequencing VirOS itself continues,
this process should hopefully reach some nearly push-button level minimum.
But...  that's tomrrow, this is today, and here are the notes used for
the f12 rebase

=============================================================================
Creating a new ancestor type as a copy of the previous version
-----------------------------------------------------------------------------

EOF

# set old and new ancestor versions
old_fbase=11
new_fbase=12

old_orkbase="0.9.$(( ${old_fbase} - 9 ))"
old_gbase="0.$(( ${old_fbase} - 7 ))"
# not quite so automatic
old_gbase="${old_gbase}.1"

new_orkbase="0.9.$(( ${new_fbase} - 9 ))"
new_gbase="0.$(( ${new_fbase} - 7 )).0"


# calculate abbreviations
old_gbase_short=$( echo ${old_gbase} | sed -e 's/\([^\.]*\.[^\.]*\).*/\1/' )
new_gbase_short=$( echo ${new_gbase} | sed -e 's/\([^\.]*\.[^\.]*\).*/\1/' )

echo -en "\n\nrebasing parameters:\n\n"
echo "old_fbase: ${old_fbase}"
echo "new_fbase: ${new_fbase}"

echo "old_orkbase: ${old_orkbase}"
echo "old_gbase: ${old_gbase}"
echo "old_gbase_short: ${old_gbase_short}"

echo "new_orkbase: ${new_orkbase}"
echo "new_gbase: ${new_gbase}"
echo "new_gbase_short: ${new_gbase_short}"

echo -en "\n\n</rebasing parameters>\n\n"

progdir=$( dirname $( readlink -e "${0}" ) )
progname=$( basename $( readlink -e "${0}" ) )

cd ${progdir}/../..

echo "pwd is $( pwd )"

rm -f ancestors/fedora-${new_fbase}
cp -av \
   ancestors/fedora-${old_fbase} \
   ancestors/fedora-${new_fbase}

rm -f ancestors/default
ln -s \
    g-zyx-${new_gbase_short} \
    ancestors/default

cp \
    strains/F-ZyX-${old_gbase_short}.ks \
    strains/F-ZyX-${new_gbase_short}.ks 

cp \
    strains/F-ZyX-${old_gbase_short}.vml \
    strains/F-ZyX-${new_gbase_short}.vml 

cp \
    strains/Fork-ZyX-${old_orkbase}.vml \
    strains/Fork-ZyX-${new_orkbase}.vml 

cp \
    strains/G-ZyX-${old_gbase}.vml \
    strains/G-ZyX-${new_gbase}.vml

cp \
    strains/Guitar-ZyX-${old_gbase}.vml \
    strains/Guitar-ZyX-${new_gbase}.vml


cat << EOF >> /dev/null
=============================================================================

check
- then edit .vml files, making appropriate adjustments
  - todo: just make good sed commands in script above

Creating the initial ancestor specific lowlevel config (kickstart/preseed/)
-----------------------------------------------------------------------------

check
- get spin-kickstarts package from fedora repo, use non-updates as that
  is presumably what was used to spin the main release (though update
  looks to be pretty minimal via changelogs, so I'll use, easy enough
  to 3way diff that later if suspect)
- 3way merge, in one window, meld prior fedora vs gz ks, then in
  edit window, merge previous gz into current fedora

check
mirror_base_dir="/mnt/big/pub/org/info/mirrors"
# make ${mirror_base_dir}/f${new_fbase}/viros.mirrors.cfg
# note: this could be a simple automagic cgi script
ls -1A ${mirror_base_dir}/f${new_fbase}/ | grep ___ \
    > ${mirror_base_dir}/f${new_fbase}/viros.mirrors.cfg

check
- fitness/zbuild 
  - mirrors.cfg path
  - strain_version

check (need to improve)
- ancestor vxmog qfakeroot.config has hardcoded memtest86+ version

check (but ugly)
new - copied compose.repos to compose.repos.f12, and adjusted in all the new vml

=========== one time (not obviously subsequently relevent) issues ==============

d need unused common defaults for netinstiso and checksum, to feed to
  - tools/scripts/synthesize, adust defaults
  - tools/scripts/generate, ditto
  - strains/F-ZyX-0.4.vml, ditto
  - unused because new F-ZyX-VERSION.vml will have the used version

d nash gone, now switch_root

d plymouth

d added qreaper back to synth, though after removing some acpi= kern args

d memtest version in qfakeroot.config of zyx-live vxmog

d rc.sysinit.zyx

******************** undone/todo

todo- actually test persistent /home with 0.4.1, litd rebase, lusb-creator-mod



****************** defer till f12 native

- functions/halt
- unwind ksflatten workaround (if indeed bug is fixed)
- xrandr brightness... gdm , etc x11 prefdm (--no-daemon is called by event.d, so have it do startx

================================================================================
================================================================================
EOF

