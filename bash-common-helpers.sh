# Copyright (c) 2014 Martin Burger
# Released under the MIT License (MIT)
# https://github.com/martinburger/bash-common-helpers/blob/master/LICENSE

################################################################################
#
# SEE README.MD ON HOW TO USE THE FUNCTIONS PROVIDED BY THIS LIBRARY.
#
################################################################################

#
# SCRIPT INITIALIZATION --------------------------------------------------------
#

# cmn_init
#
# Should be called at the beginning of every shell script.
#
# Exits your script if you try to use an uninitialised variable and exits your
# script as soon as any statement fails to prevent errors snowballing into
# serious issues.
#
# Example:
# cmn_init
#
# See: http://www.davidpashley.com/articles/writing-robust-shell-scripts/
#
function cmn_init {
  # Will exit script if we would use an uninitialised variable:
  set -o nounset
  # Will exit script when a simple command (not a control structure) fails:
  set -o errexit
}

# cmn_assert_running_as_root
#
# Makes sure that the script is run as root. If it is, the function just
# returns; if not, it prints an error message and exits with return code 1 by
# calling `cmn_die`.
#
# Example:
# cmn_assert_running_as_root
#
# Note that this function uses variable $EUID which holds the "effective" user
# ID number; the EUID will be 0 even though the current user has gained root
# priviliges by means of su or sudo.
#
# See: http://www.linuxjournal.com/content/check-see-if-script-was-run-root-0
#
function cmn_assert_running_as_root {
  if [[ ${EUID} -ne 0 ]]; then
    cmn_die "This script must be run as root!"
  fi
}

#
# PRINTING TO THE SCREEN -------------------------------------------------------
#

# cmn_echo_info message ...
#
# Writes the given messages in green letters to standard output.
#
# Example:
# cmn_echo_info "Task completed."
#
function cmn_echo_info {
  local green=$(tput setaf 2)
  local reset=$(tput sgr0)
  echo -e "${green}$@${reset}"
}

# cmn_echo_important message ...
#
# Writes the given messages in yellow letters to standard output.
#
# Example:
# cmn_echo_important "Please complete the following task manually."
#
function cmn_echo_important {
  local yellow=$(tput setaf 3)
  local reset=$(tput sgr0)
  echo -e "${yellow}$@${reset}"
}

# cmn_echo_warn message ...
#
# Writes the given messages in red letters to standard output.
#
# Example:
# cmn_echo_warn "There was a failure."
#
function cmn_echo_warn {
  local red=$(tput setaf 1)
  local reset=$(tput sgr0)
  echo -e "${red}$@${reset}"
}

#
# ERROR HANDLING ---------------------------------------------------------------
#

# cmn_die message ...
#
# Writes the given messages in red letters to standard error and exits with
# error code 1.
#
# Example:
# cmn_die "An error occurred."
#
function cmn_die {
  local red=$(tput setaf 1)
  local reset=$(tput sgr0)
  echo >&2 -e "${red}$@${reset}"
  exit 1
}

#
# AVAILABILITY OF COMMANDS AND FILES -------------------------------------------
#

# cmn_assert_command_is_available command
#
# Makes sure that the given command is available.
#
# Example:
# cmn_assert_command_is_available "ping"
#
# See: http://stackoverflow.com/a/677212/66981
#
function cmn_assert_command_is_available {
  local cmd=${1}
  type ${cmd} >/dev/null 2>&1 || cmn_die "Cancelling because required command '${cmd}' is not available."
}

# cmn_assert_file_exists file
#
# Makes sure that the given regular file exists. Thus, is not a directory or
# device file.
#
# Example:
# cmn_assert_file_exists "myfile.txt"
#
function cmn_assert_file_exists {
  local file=${1}
  if [[ ! -f "${file}" ]]; then
    cmn_die "Cancelling because required file '${file}' does not exist."
  fi
}

# cmn_assert_file_does_not_exist file
#
# Makes sure that the given file does not exist.
#
# Example:
# cmn_assert_file_does_not_exist "file-to-be-written-in-a-moment"
#
function cmn_assert_file_does_not_exist {
  local file=${1}
  if [[ -e "${file}" ]]; then
    cmn_die "Cancelling because file '${file}' exists."
  fi
}

#
# USER INTERACTION -------------------------------------------------------------
#

# cmn_ask_to_continue message
#
# Asks the user - using the given message - to either hit 'y/Y' to continue or
# 'n/N' to cancel the script.
#
# Example:
# cmn_ask_to_continue "Do you want to delete the given file?"
#
# On yes (y/Y), the function just returns; on no (n/N), it prints a confirmative
# message to the screen and exits with return code 1 by calling `cmn_die`.
#
function cmn_ask_to_continue {
  local msg=${1}
  local waitingforanswer=true
  while ${waitingforanswer}; do
    read -p "${msg} (hit 'y/Y' to continue, 'n/N' to cancel) " -n 1 ynanswer
    case ${ynanswer} in
      [Yy] ) waitingforanswer=false; break;;
      [Nn] ) echo ""; cmn_die "Operation cancelled as requested!";;
      *    ) echo ""; echo "Please answer either yes (y/Y) or no (n/N).";;
    esac
  done
  echo ""
}

# cmn_ask_for_password variable_name prompt
#
# Asks the user for her password and stores the password in a read-only
# variable with the given name.
#
# The user is asked with the given message prompt. Note that the given prompt
# will be complemented with string ": ".
#
# This function does not echo nor completely hides the input but echos the
# asterisk symbol ('*') for each given character. Furthermore, it allows to
# delete any number of entered characters by hitting the backspace key. The
# input is concluded by hitting the enter key.
#
# Example:
# cmn_ask_for_password "THEPWD" "Please enter your password"
#
# See: http://stackoverflow.com/a/24600839/66981
#
function cmn_ask_for_password {
  local VARIABLE_NAME=${1}
  local MESSAGE=${2}

  echo -n "${MESSAGE}: "
  stty -echo
  local CHARCOUNT=0
  local PROMPT=''
  local CHAR=''
  local PASSWORD=''
  while IFS= read -p "${PROMPT}" -r -s -n 1 CHAR
  do
    # Enter -> accept password
    if [[ ${CHAR} == $'\0' ]] ; then
      break
    fi
    # Backspace -> delete last char
    if [[ ${CHAR} == $'\177' ]] ; then
      if [ ${CHARCOUNT} -gt 0 ] ; then
        CHARCOUNT=$((CHARCOUNT-1))
        PROMPT=$'\b \b'
        PASSWORD="${PASSWORD%?}"
      else
        PROMPT=''
      fi
    # All other cases -> read last char
    else
      CHARCOUNT=$((CHARCOUNT+1))
      PROMPT='*'
      PASSWORD+="${CHAR}"
    fi
  done
  stty echo
  readonly ${VARIABLE_NAME}=${PASSWORD}
  echo
}

# cmn_ask_for_password_twice variable_name prompt
#
# Asks the user for her password twice. If the two inputs match, the given
# password will be stored in a read-only variable with the given name;
# otherwise, it exits with return code 1 by calling `cmn_die`.
#
# The user is asked with the given message prompt. Note that the given prompt
# will be complemented with string ": " at the first time and with
# " (again): " at the second time.
#
# This function basically calls `cmn_ask_for_password` twice and compares the
# two given passwords. If they match, the password will be stored; otherwise,
# the functions exits by calling `cmn_die`.
#
# Example:
# cmn_ask_for_password_twice "THEPWD" "Please enter your password"
#
function cmn_ask_for_password_twice {
  local VARIABLE_NAME=${1}
  local MESSAGE=${2}
  local VARIABLE_NAME_1="${VARIABLE_NAME}_1"
  local VARIABLE_NAME_2="${VARIABLE_NAME}_2"

  cmn_ask_for_password "${VARIABLE_NAME_1}" "${MESSAGE}"
  cmn_ask_for_password "${VARIABLE_NAME_2}" "${MESSAGE} (again)"

  if [ "${!VARIABLE_NAME_1}" != "${!VARIABLE_NAME_2}" ] ; then
    cmn_die "Error: password mismatch"
  fi

  readonly ${VARIABLE_NAME}="${!VARIABLE_NAME_2}"
}

#
# FILE UTILITIES ---------------------------------------------------------------
#

# cmn_replace_in_files search replace file ...
#
# Replaces given string 'search' with 'replace' in given files.
#
# Important: The replacement is done in-place. Thus, it overwrites the given
# files, and no backup files are created.
#
# Note that this function is intended to be used to replace fixed strings; i.e.,
# it does not interpret regular expressions. It was written to replace simple
# placeholders in sample configuration files (you could say very poor man's
# templating engine).
#
# This functions expects given string 'search' to be found in all the files;
# thus, it expects to replace that string in all files. If a given file misses
# that string, a warning is issued by calling `cmn_echo_warn`. Furthermore,
# if a given file does not exist, a warning is issued as well.
#
# To replace the string, perl is used. Pattern metacharacters are quoted
# (disabled). The search is a global one; thus, all matches are replaced, and
# not just the first one.
#
# Example:
# cmn_replace_in_files placeholder replacement file1.txt file2.txt
#
function cmn_replace_in_files {

  local search=${1}
  local replace=${2}
  local files=${@:3}

  for file in ${files[@]}; do
    if [[ -e "${file}" ]]; then
      if ( grep --fixed-strings --quiet "${search}" "${file}" ); then
        perl -pi -e "s/\Q${search}/${replace}/g" "${file}"
      else
        cmn_echo_warn "Could not find search string '${search}' (thus, cannot replace with '${replace}') in file: ${file}"
      fi
    else
        cmn_echo_warn "File '${file}' does not exist (thus, cannot replace '${search}' with '${replace}')."
    fi
  done

}

#
# PARSING INI FILES ------------------------------------------------------------
#

# cmn_parse_ini_file [--boolean --prefix=STRING] file
#
# Parses given ini file using Ruediger Meier's "simple INI file parser".
#
# Example:
# cmn_parse_ini_file "mycfg.ini" --prefix "TESTING"
#
# Now, variables in assumed section [somevars] will be available as
# ${TESTING__somevars__varname}.
#
# Important: This function expects that `cmn_init` was called before.
#
# Hint: The default prefix is INI. Thus, if not specified as above, the
# variables names would be: ${INI__somevars__varname}
#
# Please note the the parser is included at the end of this file. Thus, you do
# not need to install that parser.
#
# See: https://github.com/rudimeier/bash_ini_parser
#
function cmn_parse_ini_file {

  set +o nounset
  set +o errexit
  read_ini $@ && rc=$? || rc=$?
  set -o errexit
  set -o nounset

  if [[ ${rc} != 0 ]] ; then
    cmn_die "read_ini exited with error code ${rc}."
  fi

}

# cmn_assert_ini_variables_exist variable_name ...
#
# Makes sure that the given INI variables exist. The variables are specified by
# name.
#
# This function is intended to provide the user feedback if her INI file would
# miss some expected variable.
#
# Example:
# cmn_assert_ini_variables_exist "TESTING__somevars__var1" "TESTING__somevars__var2"
#
# This function uses indirect expansion: Bash uses the value of the variable
# formed from the rest of parameter as the name of the variable. This way,
# we can check if a variable with the given name is set.
#
function cmn_assert_ini_variables_exist {
  for variable in ${@}; do
    if [[ -z "${!variable-}" ]]; then
      cmn_die "Missing variable in INI file: ${variable}"
    fi
  done
}



#
#
# Ruediger Meier's "simple INI file parser" follows.
# Commit: 8fb95e3b335823bc85604fd06c32b0d25f2854c5
# Date: 2014-10-21T08:40:19Z
#
#



#
# Copyright (c) 2009    Kevin Porter / Advanced Web Construction Ltd
#                       (http://coding.tinternet.info, http://webutils.co.uk)
# Copyright (c) 2010-2014     Ruediger Meier <sweet_f_a@gmx.de>
#                             (https://github.com/rudimeier/)
#
# License: BSD-3-Clause, see LICENSE file
#
# Simple INI file parser.
#
# See README for usage.
#
#




function read_ini()
{
	# Be strict with the prefix, since it's going to be run through eval
	function check_prefix()
	{
		if ! [[ "${VARNAME_PREFIX}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] ;then
			echo "read_ini: invalid prefix '${VARNAME_PREFIX}'" >&2
			return 1
		fi
	}
	
	function check_ini_file()
	{
		if [ ! -r "$INI_FILE" ] ;then
			echo "read_ini: '${INI_FILE}' doesn't exist or not" \
				"readable" >&2
			return 1
		fi
	}
	
	# enable some optional shell behavior (shopt)
	function pollute_bash()
	{
		if ! shopt -q extglob ;then
			SWITCH_SHOPT="${SWITCH_SHOPT} extglob"
		fi
		if ! shopt -q nocasematch ;then
			SWITCH_SHOPT="${SWITCH_SHOPT} nocasematch"
		fi
		shopt -q -s ${SWITCH_SHOPT}
	}
	
	# unset all local functions and restore shopt settings before returning
	# from read_ini()
	function cleanup_bash()
	{
		shopt -q -u ${SWITCH_SHOPT}
		unset -f check_prefix check_ini_file pollute_bash cleanup_bash
	}
	
	local INI_FILE=""
	local INI_SECTION=""

	# {{{ START Deal with command line args

	# Set defaults
	local BOOLEANS=1
	local VARNAME_PREFIX=INI
	local CLEAN_ENV=0

	# {{{ START Options

	# Available options:
	#	--boolean		Whether to recognise special boolean values: ie for 'yes', 'true'
	#					and 'on' return 1; for 'no', 'false' and 'off' return 0. Quoted
	#					values will be left as strings
	#					Default: on
	#
	#	--prefix=STRING	String to begin all returned variables with (followed by '__').
	#					Default: INI
	#
	#	First non-option arg is filename, second is section name

	while [ $# -gt 0 ]
	do

		case $1 in

			--clean | -c )
				CLEAN_ENV=1
			;;

			--booleans | -b )
				shift
				BOOLEANS=$1
			;;

			--prefix | -p )
				shift
				VARNAME_PREFIX=$1
			;;

			* )
				if [ -z "$INI_FILE" ]
				then
					INI_FILE=$1
				else
					if [ -z "$INI_SECTION" ]
					then
						INI_SECTION=$1
					fi
				fi
			;;

		esac

		shift
	done

	if [ -z "$INI_FILE" ] && [ "${CLEAN_ENV}" = 0 ] ;then
		echo -e "Usage: read_ini [-c] [-b 0| -b 1]] [-p PREFIX] FILE"\
			"[SECTION]\n  or   read_ini -c [-p PREFIX]" >&2
		cleanup_bash
		return 1
	fi

	if ! check_prefix ;then
		cleanup_bash
		return 1
	fi

	local INI_ALL_VARNAME="${VARNAME_PREFIX}__ALL_VARS"
	local INI_ALL_SECTION="${VARNAME_PREFIX}__ALL_SECTIONS"
	local INI_NUMSECTIONS_VARNAME="${VARNAME_PREFIX}__NUMSECTIONS"
	if [ "${CLEAN_ENV}" = 1 ] ;then
		eval unset "\$${INI_ALL_VARNAME}"
	fi
	unset ${INI_ALL_VARNAME}
	unset ${INI_ALL_SECTION}
	unset ${INI_NUMSECTIONS_VARNAME}

	if [ -z "$INI_FILE" ] ;then
		cleanup_bash
		return 0
	fi
	
	if ! check_ini_file ;then
		cleanup_bash
		return 1
	fi

	# Sanitise BOOLEANS - interpret "0" as 0, anything else as 1
	if [ "$BOOLEANS" != "0" ]
	then
		BOOLEANS=1
	fi


	# }}} END Options

	# }}} END Deal with command line args

	local LINE_NUM=0
	local SECTIONS_NUM=0
	local SECTION=""
	
	# IFS is used in "read" and we want to switch it within the loop
	local IFS=$' \t\n'
	local IFS_OLD="${IFS}"
	
	# we need some optional shell behavior (shopt) but want to restore
	# current settings before returning
	local SWITCH_SHOPT=""
	pollute_bash
	
	while read -r line || [ -n "$line" ]
	do
#echo line = "$line"

		((LINE_NUM++))

		# Skip blank lines and comments
		if [ -z "$line" -o "${line:0:1}" = ";" -o "${line:0:1}" = "#" ]
		then
			continue
		fi

		# Section marker?
		if [[ "${line}" =~ ^\[[a-zA-Z0-9_]{1,}\]$ ]]
		then

			# Set SECTION var to name of section (strip [ and ] from section marker)
			SECTION="${line#[}"
			SECTION="${SECTION%]}"
			eval "${INI_ALL_SECTION}=\"\${${INI_ALL_SECTION}# } $SECTION\""
			((SECTIONS_NUM++))

			continue
		fi

		# Are we getting only a specific section? And are we currently in it?
		if [ ! -z "$INI_SECTION" ]
		then
			if [ "$SECTION" != "$INI_SECTION" ]
			then
				continue
			fi
		fi

		# Valid var/value line? (check for variable name and then '=')
		if ! [[ "${line}" =~ ^[a-zA-Z0-9._]{1,}[[:space:]]*= ]]
		then
			echo "Error: Invalid line:" >&2
			echo " ${LINE_NUM}: $line" >&2
			cleanup_bash
			return 1
		fi


		# split line at "=" sign
		IFS="="
		read -r VAR VAL <<< "${line}"
		IFS="${IFS_OLD}"
		
		# delete spaces around the equal sign (using extglob)
		VAR="${VAR%%+([[:space:]])}"
		VAL="${VAL##+([[:space:]])}"
		VAR=$(echo $VAR)


		# Construct variable name:
		# ${VARNAME_PREFIX}__$SECTION__$VAR
		# Or if not in a section:
		# ${VARNAME_PREFIX}__$VAR
		# In both cases, full stops ('.') are replaced with underscores ('_')
		if [ -z "$SECTION" ]
		then
			VARNAME=${VARNAME_PREFIX}__${VAR//./_}
		else
			VARNAME=${VARNAME_PREFIX}__${SECTION}__${VAR//./_}
		fi
		eval "${INI_ALL_VARNAME}=\"\${${INI_ALL_VARNAME}# } ${VARNAME}\""

		if [[ "${VAL}" =~ ^\".*\"$  ]]
		then
			# remove existing double quotes
			VAL="${VAL##\"}"
			VAL="${VAL%%\"}"
		elif [[ "${VAL}" =~ ^\'.*\'$  ]]
		then
			# remove existing single quotes
			VAL="${VAL##\'}"
			VAL="${VAL%%\'}"
		elif [ "$BOOLEANS" = 1 ]
		then
			# Value is not enclosed in quotes
			# Booleans processing is switched on, check for special boolean
			# values and convert

			# here we compare case insensitive because
			# "shopt nocasematch"
			case "$VAL" in
				yes | true | on )
					VAL=1
				;;
				no | false | off )
					VAL=0
				;;
			esac
		fi
		

		# enclose the value in single quotes and escape any
		# single quotes and backslashes that may be in the value
		VAL="${VAL//\\/\\\\}"
		VAL="\$'${VAL//\'/\'}'"

		eval "$VARNAME=$VAL"
	done  <"${INI_FILE}"
	
	# return also the number of parsed sections
	eval "$INI_NUMSECTIONS_VARNAME=$SECTIONS_NUM"

	cleanup_bash
}
