#!/bin/bash
#
#############################################################################
#
# libvopt.sh: a bash option handling library
#
#############################################################################
#
# Copyright 2007 Douglas McClendon <dmc AT filteredperception DOT org>
#
#############################################################################
#
#This file is part of VirOS.
#
#    VirOS is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
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



starttime="$( date +%Y%m%d%H%M%S )"
progname="$( basename $0 )"
progdir=$( ( pushd $( dirname $( readlink -e $0 ) ) > /dev/null 2>&1 ; \
    pwd ; popd > /dev/null 2>&1 ) )
rundir=$( pwd )
mypid=$$

vopts_numopts=0
vopts_numargs=0


function usage {
    echo "vlib: unhandled error condition encountered, goodbye!"
    exit 1
}

function vfindfile {

    targetfile=$1
    shift
    suffixes=$1
    shift
    search_path_list="$@"


    if ( ! echo "$targetfile" | grep -q "^/" ); then
        searchdone=0
        for searchpath in ${search_path_list}; do
            if ((! $searchdone)); then
                if [ -f "${searchpath}/${targetfile}" ]; then
                    targetfile="${searchpath}/${targetfile}"
                    searchdone=1
		else
		    for suffix in $suffixes; do
			if [ "x${suffix}" != "x" ]; then
			    if [ -f "${searchpath}/${targetfile}.${suffix}" ]; then
				targetfile="${searchpath}/${targetfile}.${suffix}"
				searchdone=1
			    fi
			fi
		    done
		fi
	    fi
	done
    fi

    echo $targetfile
}


function vresetopts {
    vopts_numopts=0
    vopts_numargs=0
    unset vopts_args
    unset vopts_name
    unset vopts_vname
    unset vopts_type
    unset vopts_value
}

function vregopt {
    opt_name=$1
    opt_type=$2
    opt_inherit=$4

    if [ "x${opt_inherit}" == "xinherit" ]; then
	eval "inherited_value=\"\$vopt_${opt_name}\""
	if [ "x${inherited_value}" == "x" ]; then
	    opt_init=$3
	else
	    opt_init=${inherited_value}
	fi
    else
	opt_init=$3
    fi


    vopts_numopts=$(( $vopts_numopts + 1 ))
    vopts_name[$vopts_numopts]=$opt_name
    vopts_vname[$vopts_numopts]=vopt_${opt_name}
    vopts_type[$vopts_numopts]=$opt_type
    vopts_value[$vopts_numopts]=$opt_init
}

function vshowopts {
    for (( i=1 ; $i <= ${vopts_numopts} ; i=$(( $i + 1 )) )); do
	echo "opt number $i - name is ${vopts_name[$i]}"
	echo "opt number $i - type is ${vopts_type[$i]}"
	echo "opt number $i - value is ${vopts_value[$i]}"
	eval "echo \"vopt_${vopts_name[$i]} is \$vopt_${vopts_name[$i]}\""
    done
}

function vshowargs {
    for (( i=1 ; $i <= ${#vopts_args[*]} ; i=$(( $i + 1 )) )); do
	echo "DEBUG: vopt_arg $i is ${vopts_args[$i]}"
    done
}

function vparseopt {
    vopts_numargs=0

    defconfig=""
    for (( i=1 ; $i <= ${vopts_numopts} ; i=$(( $i + 1 )) )); do
	if [ "x${vopts_name[$i]}" == "xconfig" ]; then
	    defconfig=${vopts_value[$i]}
	fi
    done
    if ( echo "$@" | grep -vq "\-\-config=" ); then
	if ( echo "$@" | grep -vq "\-\-strain=" ); then
	    if [ "x${defconfig}" != "x" ]; then
		vopt_read_config ${defconfig}
	    fi
	fi
    fi

    while (echo "$1" | grep -q "^-"); do
	option="$1"
	option_handled=0
	shift
	if ( echo "$option" | grep -q  "^--config=" ); then
	    conf=$( echo "$option" | sed -e "s/^--config=//" )
	    vopt_read_config $conf
	    vpo_config_read=1
	    option_handled=1
	elif ( echo "$option" | grep -q  "^--strain=" ); then
	    conf=$( echo "$option" | sed -e "s/^--strain=//" )
	    vopt_read_config $conf
	    vpo_config_read=1
	    option_handled=1
	else
	    for (( i=1 ; $i <= ${vopts_numopts} ; i=$(( $i + 1 )) )); do
		if ( echo "$option" | grep -q  "^--${vopts_name[$i]}=" ); then
		    optval=$( echo "$option" | sed -e "s/^--${vopts_name[$i]}=//" )
		    case "${vopts_type[$i]}" in
			string)
			    vopts_value[$i]="$optval"
			    ;;
			cumulative)
			    vopts_value[$i]="${vopts_value[$i]} $optval"
			    ;;
			*)
			    usage
			    ;;
		    esac
		    option_handled=1
		elif [ "$option" == "--${vopts_name[$i]}" ]; then
		    case "${vopts_type[$i]}" in
			boolean)
			    vopts_value[$i]=1
			    ;;
			string)
			    if (( ! $# )); then usage; fi 
			    vopts_value[$i]="$1"
			    shift
			    ;;
			cumulative)
			    if (( ! $# )); then usage; fi 
			    vopts_value[$i]="${vopts_value[$i]} $1"
			    shift
			    ;;
			*)
			    usage
			    ;;
		    esac
		    option_handled=1
		elif [ "$option" == "--no${vopts_name[$i]}" ]; then 
		    if [ "${vopts_type[$i]}" == "boolean" ]; then
			vopts_value[$i]=0
		    else
			usage
		    fi
		    option_handled=1
		fi
	    done
	    if ((! ${option_handled})); then
		vopts_numargs=$(( $vopts_numargs + 1 ))
		vopts_args[$vopts_numargs]="$option"
	    fi
	fi
    done

    for (( i=1 ; $i <= ${vopts_numopts} ; i=$(( $i + 1 )) )); do
	eval "vopt_${vopts_name[$i]}='${vopts_value[$i]}'"
    done

    while (( $# )); do
	vopts_numargs=$(( $vopts_numargs + 1 ))
	vopts_args[$vopts_numargs]=$1
	shift
    done

    if (($vopt_debug)); then vshowopts; fi

    return 0
}

function vopt_read_config {

    function parse_line {
	tmpfile=$( mktemp -t libvopt.$$.XXXXXXXXXX )
	splitter "$1" > $tmpfile
	optname=$( head -1 $tmpfile )
	numvals=0
	while read line; do
	    optvalues[$numvals]=$line
	    numvals=$(( $numvals + 1 ))
	done < $tmpfile
	numvals=$(( $numvals - 1 ))
	rm -f $tmpfile

	if [ "$optname" == "config" ]; then
	    vopt_read_config ${optvalues[1]}
	fi

	found=0
	for (( i=1 ; $i <= ${vopts_numopts} ; i=$(( $i + 1 )) )); do
	    if [ "$optname" == "${vopts_name[$i]}" ]; then
		found=$i
	    fi
	done

	if (( ! ${found} )); then
	    if [ "x${LIBVOPT_IGNORE_UNKNOWN_OPTIONS}" != "x" ]; then
		true
	    else
		echo "libvopt.sh: config parser: fatal error: unknown option $optname"
		exit 1
	    fi
	else
	    case "${vopts_type[$found]}" in
		boolean)
		    if [ $numvals -ne 1 ]; then 
			echo "libvopt.sh: config parser: fatal error: boolean type for option $optname but incorrect value (number of args)"
			exit 1
		    fi
		    vopts_value[$found]="${optvalues[1]}"
		    ;;
		string)
		    if [ $numvals -ne 1 ]; then 
			echo "libvopt.sh: config parser: fatal error: string type for option $optname but incorrect value (number of args)"
			exit 1
		    fi
		    if $( echo ${optvalues[1]} | grep -q '^\".*\"$' ); then
			optvalues[1]=$( echo ${optvalues[1]} | sed -e 's/^\"\(.*\)\"$/\1/' )
		    fi
		    vopts_value[$found]="${optvalues[1]}"
		    ;;
		cumulative)
		    while (( $numvals )); do
			vopts_value[$found]="${vopts_value[$found]} ${optvalues[$numvals]}"
			numvals=$(( $numvals - 1 ))
		    done
		    ;;
		*)
		    echo "libvopt.sh: config parser: fatal error: uknown type type ${vopts_type[$found]} for option $1"
		    exit 1
		    ;;
	    esac
	fi

    }

    if [ "x${1}" == "x" ]; then return; fi

    configfile_path_to_parse=$( vfindfile "${1}" "vml cfg" ". ${LIBVOPT_CONFIGS_PATHS} ${vopt_add_search_paths}" )

    while read line; do
	if ( echo "$line" | grep -q "^#" ); then
	    true
	elif ( echo "$line" | grep -q '^\s*$' ); then
	    true
	else
	    eval "parse_line '$line'"
	fi
    done < $configfile_path_to_parse

    for (( i=1 ; $i <= ${vopts_numopts} ; i=$(( $i + 1 )) )); do
	eval "vopt_${vopts_name[$i]}='${vopts_value[$i]}'"
    done

    return
}

