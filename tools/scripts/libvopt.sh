#!/bin/bash
#
#############################################################################
#
# libvopt.sh: a bash option handling library
#
#############################################################################
#
# Copyright 2007-2010 Douglas McClendon <dmc AT filteredperception DOT org>
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
# libvopt.sh example usage:
#
#vregopt debug boolean 1
#vregopt verbose boolean 0
#vregopt config string ""
#vregopt addmodules cumulative ""
#vparseopt "$@"
#
#
## if command was invoked with "--verbose --nodebug --addmodules thinga --config=/my/cfg --addmodules=thingb"
## then the following-
#
# echo $vopt_verbose
# echo $vopt_debug
# echo $vopt_config
# echo $vopt_addmodules
#
## would yield-
#
# 1
# 0
# /my/cfg
# thinga thingb
#


##
## globals
##
starttime="$( date +%Y%m%d%H%M%S )"
progname="$( basename $0 )"
progdir=$( ( pushd $( dirname $( readlink -e $0 ) ) > /dev/null 2>&1 ; \
    pwd ; popd > /dev/null 2>&1 ) )
rundir=$( pwd )
mypid=$$

vopts_numopts=0
vopts_numargs=0

##
## functions
##

##
## usage: default usage, should be overloaded by calling program
##
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
			# this used to be "x...", I have no idea why I put this here
			if [ "${suffix}" != "" ]; then
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


##
## vresetopts: reinitializes vopts, so that it can be used multiple times
##             on completely different option sets and arg strings
##
function vresetopts {
    vopts_numopts=0
    vopts_numargs=0
    unset vopts_args
    unset vopts_name
    unset vopts_vname
    unset vopts_type
    unset vopts_value
}

##
## vregopt: register an option name, type, and initial default value
##
function vregopt {
    opt_name=$1
    opt_type=$2
    opt_inherit=$4

    #
    # possibly inherit the default/initial value from the environment
    #
    if [ "${opt_inherit}" == "inherit" ]; then
	eval "inherited_value=\"\$vopt_${opt_name}\""
	if [ "${inherited_value}" == "" ]; then
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

##
## vshowopts: debugging function to print all vopt registered options
##
function vshowopts {
    for (( i=1 ; $i <= ${vopts_numopts} ; i=$(( $i + 1 )) )); do
	# todo - use vopt_optname instead of array (somehow?)
	echo "opt number $i - name is ${vopts_name[$i]}"
	echo "opt number $i - type is ${vopts_type[$i]}"
	echo "opt number $i - value is ${vopts_value[$i]}"
	eval "echo \"vopt_${vopts_name[$i]} is \$vopt_${vopts_name[$i]}\""
    done
}

function vshowargs {
    # this is mainly an example of something that can be done in the
    # calling program
    for (( i=1 ; $i <= ${#vopts_args[*]} ; i=$(( $i + 1 )) )); do
	echo "DEBUG: vopt_arg $i is ${vopts_args[$i]}"
    done
}


##
## handle_subtrait_vml
##
## this supports the ability to have dependencies specified by a trait
## note however, that unspliced traits will not currently go to the 
## trouble of unsplicing subtrait vml.
##
function handle_subtrait_vml {

    local trait
    local trait_base
    local trait_opts
    local traits_dir
    local trait_dir

    # arguably this code could be replicated in the two current 
    # callers of handle_subtrait_vml, instead of being here.
    if ( ! echo "${1}" | grep -q '^splice-' ); then return; fi

    trait=$( echo "${1}" | sed -e 's/^splice-//' )

    # todo: functionfiy: this code copied from mutate
    trait_base="$( echo "$trait" | sed -e 's/\:\:.*//' )"
    trait_opts="$( echo "$trait" | sed -e "s/^${trait_base}//" )"

    # this is a disconcerting use of a global, that is presumed 
    # to be defined, due to the fact that thus function will only
    # ever be called, if libvopt.sh was sourced by libvsys.sh which
    # defines viros_devenv
    if (($viros_devenv)); then
	traits_dir=${viros_devdir}/traits
    else
        traits_dir=${viros_prefix}/lib/viros/traits
    fi

    if [ -d "${trait_base}" ]; then
        trait_dir=$( normalize_path "${trait_base}" )
    elif [ -d "${traits_dir}/${trait_base}" ]; then
        trait_dir=$( normalize_path "${traits_dir}/${trait_base}" )
    else
	return
    fi

    if [ -f "${trait_dir}/trait-install/config.vml" ]; then
	vopt_read_config "${trait_dir}/trait-install/config.vml"
    fi

}

##
## vparseopt: function to parse argument string, given pre-registered options
##
function vparseopt {
    vopts_numargs=0

    # this is very gross.  the logic is, only utilize a default value for
    # config, if no config was specified as an option.  And ingest it first,
    # (regardless of order of vregopt).
    local defconfig
    local i
    defconfig=""
    for (( i=1 ; $i <= ${vopts_numopts} ; i=$(( $i + 1 )) )); do
	if [ "${vopts_name[$i]}" == "config" ]; then
	    defconfig=${vopts_value[$i]}
	fi
    done
    if ( echo "$@" | grep -vq "\-\-config=" ); then
	if ( echo "$@" | grep -vq "\-\-strain=" ); then
	    if [ "${defconfig}" != "" ]; then
		vopt_read_config ${defconfig}
	    fi
	fi
    fi

    #
    # parse each option
    #
    # if the option is a config or a strain(equivalent), then 
    # go ahead and parse it immediately, such that later options
    # can override values.
    #
    while (echo "$1" | grep -q "^-"); do
	local option
	option="$1"
	local option_handled
	option_handled=0
	shift
	local conf
	local vpo_config_read
	local option_handled
	local optval
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
			    if [ "${vopts_name[$i]}" == "traits" ]; then
				handle_subtrait_vml "${optval}"
			    fi
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
			    if [ "${vopts_name[$i]}" == "traits" ]; then
				handle_subtrait_vml "${1}"
			    fi
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

    local configfile_path_to_parse
    local line

    function parse_line {

	local tmpfile
	local optname
	local numvals
	local line
	local optvalues
	local found
	local i

	tmpfile=$( mktemp -t libvopt.$$.XXXXXXXXXX )
	splitter "$1" > $tmpfile
	optname=$( head -1 $tmpfile )
	# wow, I used a local
	# edunote: necessary because below when handle_subtrait_vml is called,
	#          numvals should not be changed by possible recursive calls
	#          that get back here.  Probably I should use lots more locals...
	numvals=0
	while read line; do
	    optvalues[$numvals]=$line
	    numvals=$(( $numvals + 1 ))
	done < $tmpfile
	numvals=$(( $numvals - 1 ))
	rm -f $tmpfile

	# support recursive configurations / inheritance
	if [ "$optname" == "config" ]; then
	    vopt_read_config "${optvalues[1]}"
	fi

	found=0
	for (( i=1 ; $i <= ${vopts_numopts} ; i=$(( $i + 1 )) )); do
	    if [ "$optname" == "${vopts_name[$i]}" ]; then
		found=$i
	    fi
	done

	if (( ! ${found} )); then
	    if [ "${LIBVOPT_IGNORE_UNKNOWN_OPTIONS}" != "" ]; then
		true
		#echo "libvopt.sh: config parser: warning: unknown option $optname"
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
		# todo: handle True, true, no<optname>, instead of just 0 and 1
		    vopts_value[$found]="${optvalues[1]}"
		    ;;
		string)
		    if [ $numvals -ne 1 ]; then 
			echo "libvopt.sh: config parser: fatal error: string type for option $optname but incorrect value (number of args)"
			exit 1
		    fi
		    # pretty gross...  splitter facilitated embedded quotes in values,
		    # and this will remove a single pair of outtermost quotes
		    # currently only used by vopt_vsysgen_boot_append_string
		    if $( echo ${optvalues[1]} | grep -q '^\".*\"$' ); then
			optvalues[1]=$( echo ${optvalues[1]} | sed -e 's/^\"\(.*\)\"$/\1/' )
		    fi
		    vopts_value[$found]="${optvalues[1]}"
		    ;;
		cumulative)
		    while (( $numvals )); do
			if [ "${vopts_name[$found]}" == "traits" ]; then
			    handle_subtrait_vml "${optvalues[$numvals]}"
			fi
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
    # end function parseline

    # handle null config option silently
    if [ "${1}" == "" ]; then return; fi

    configfile_path_to_parse=$( vfindfile "${1}" "vml cfg" ". ${LIBVOPT_CONFIGS_PATHS} ${vopt_add_search_paths}" )

# edunote: doing cat file |, rather than < file,
#          the while happens in a subshell, and variables don't persist
# cat ${configfile_path_to_parse} |
    while read line; do
	if ( echo "$line" | grep -q "^#" ); then
	    # todo: figure out proper negation syntax above
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

