#!/bin/bash
#
#############################################################################
#
# libvsys.sh: initializes viros script environment
#
#############################################################################
#
# Copyright 2007 Douglas McClendon <dmc AT filteredperception DOT org>
#
#############################################################################
#
# This file is part of VirOS.
#
#    VirOS is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, version 3 of the License.
#
#    VirOS is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with VirOS.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################

#
# libvsys.sh: common viros system environment, meant to be sourced early
#

##
## sanity check
##
if [ "x${viros_prefix}" == "x" ]; then
    echo "$0: error: fatal: viros_prefix is not defined"
    exit 1
fi

##
## get runtime environment
##
starttime="$( date +%Y%m%d%H%M%S )"
rundir="$( pwd )"
progname="$( basename $0 )"
progdir=$( ( pushd $( dirname $( readlink -e $0 ) ) > /dev/null 2>&1 ; \
    pwd ; popd > /dev/null 2>&1 ) )
rundir=$( pwd )
mypid=$$

##
## explicitly set tmpdir to default if not set
##
if [ "x${TMPDIR}" == "x" ]; then
    export TMPDIR=/tmp
fi

##
## load libraries
##
if [ -f "${progdir}/libvopt.sh" ]; then
    source ${progdir}/vdefs
    source ${progdir}/libvopt.sh
    source ${progdir}/functions
    source ${progdir}/vcommon
    viros_scripts_dir="${progdir}"
    viros_devenv=1
    viros_devdir=$( ( pushd ${progdir}/../.. > /dev/null 2>&1 ; \
	pwd ; popd > /dev/null 2>&1 ) )
    viros_libdir=${viros_devdir}
    viros_ancestors_dir=${viros_devdir}/ancestors
    export PATH="${viros_devdir}/tools/bin:${viros_devdir}/tools/scripts:${PATH}"
    export LIBVOPT_CONFIGS_PATHS="${viros_devdir} ${viros_devdir}/strains ${viros_devdir}/tools ${LIBVOPT_CONFIGS_PATHS}"
elif [ -f ${viros_prefix}/lib/viros/scripts/libvopt.sh ]; then
    source  ${viros_prefix}/lib/viros/scripts/vdefs
    source  ${viros_prefix}/lib/viros/scripts/libvopt.sh
    source  ${viros_prefix}/lib/viros/scripts/functions
    source  ${viros_prefix}/lib/viros/scripts/vcommon
    viros_scripts_dir=${viros_prefix}/lib/viros/scripts
    viros_devenv=0
    viros_libdir=${viros_prefix}/lib/viros
    viros_ancestors_dir=${viros_prefix}/lib/viros/ancestors
    export PATH="${viros_prefix}/lib/viros/tools/bin:${viros_prefix}/lib/viros/tools/scripts:${PATH}"
    export LIBVOPT_CONFIGS_PATHS="${viros_prefix}/lib/viros ${viros_prefix}/lib/viros/strains ${LIBVOPT_CONFIGS_PATHS}"
else
    echo "${progname}: fatal error trying to find and load libvopt.sh library"
    exit 1
fi


# ugh (obviously unroll/remove as time rolls on)
if $( which qemu > /dev/null 2>&1 ); then
    if [ "${viros_qemu_cache_type}" == "dynamic" ]; then
	qemu_version=$( qemu --help 2>&1 | head -1 )
	if $( echo "${qemu_version}" | grep -q "verson 0\.10" ); then
	    viros_qemu_cache_type="writeback"
	else
	    viros_qemu_cache_type="writethrough"
	fi
    fi
fi
