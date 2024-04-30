#!/bin/bash

: '
.NAME 
	automactc-osx.sh

.SYNOPSIS
    Script that act as a wrapper to run AutoMacTC from MDE Live-Response in MacOS

.EXAMPLE
    automactc-osx.sh "-t <target>"

.VERSION
    1.0  - Initial release
    1.1  - Changed unarchiving from tar to unzip
		 - Create targets for specific modules to avoid -all argument
			-t browsers: firefox, safari, chrome, cookies
			-t users: users, utmpx, ssh, terminalstate, bash
			-t execution: mru, coreanalytics, installhistory
			-t quarantine: quarantines
			-t logs: unifiedlogs, asl, auditlog, syslog, eventtaps
			-t system: pslist, lsof, netstat, netconfig, systeminfo

.TODO
	- Modules autoruns, dirlist, quicklook, spotlight to be incorporated as targets
	- To be tested with Python 2.7

.AUTHOR
    Francisco Gomez Marin <franciscogm@gmail.com>
    Created: 01/21/2022
'

##
## Variables
##

# Targets
T_BROWSERS="firefox safari chrome cookies"
T_USERS="users utmpx ssh terminalstate bash"
T_EXECUTION="mru coreanalytics installhistory"
T_QUARANTINE="quarantines"
T_LOGS="unifiedlogs asl auditlog syslog eventtaps"
T_SYSTEM="pslist lsof netstat netconfig systeminfo"

# Environment
DL_DIR="/Library/Application Support/Microsoft/Defender/response"
DL_DIR_TMP="/Library/Application Support/Microsoft/Defender/response/TMP-IR"
AUTOMACTC_ZIP="automactc-osx.zip"
AUTOMACTC_BIN="$DL_DIR_TMP/automactc-master/automactc.py"
HOSTNAME=`hostname`
AUTOMACTC_ARGS="-p DFIR -nl -q -np"

# Set minimum required versions
PYTHON_MINIMUM_MAJOR=2
PYTHON_MINIMUM_MINOR=7

##
## Functions
##
help()
{
	echo "Usage:"
	echo -e "\trun automactc-osx.sh \"-t <TARGET>\""
	echo ""
	echo -e "Options:"
	echo -e "\t-t <TARGET> - target can be ONE of these: browsers, users, execution, quarantine, logs, system"
	exit 1
}

function check_Python()
{
	PYTHON_MINIMAL_VERSION="270"
	PYTHON_PATH="`which python3`" 
	PYTHON_VER="`$PYTHON_PATH -c 'import sys; version=sys.version_info[:3]; print("{0}{1}{2}".format(*version))'`"
	if [[ -z $PYTHON_PATH || $PYTHON_VER -lt $PYTHON_MINIMAL_VERSION ]]; then
		echo "[*] Python version not compatible or not found."
		exit 1
	else
		echo "[*] Python found on $PYTHON_PATH" 
	fi
}

function check_AutoMacTC()
{   
    if [ ! -f "$DL_DIR/$AUTOMACTC_ZIP" ]; then
		echo ""
        echo "[*] AutoMacTC package has not been copied yet. Run putfile command first:"
		echo ""
        echo "	putfile automactc-osx.zip"
        exit 1
    fi
}

function pre_AutoMacTc()
{
	if [[ -z $1 ]]; then 
		help
	fi
	while getopts "ht:" opt; do
		case "${opt}" in
			t)	target="${OPTARG}"
				case "${target}" in
					browsers) 
						AUTOMACTC_TARGETS="$T_BROWSERS" 
						;;
					user|users) 
						AUTOMACTC_TARGETS="$T_USERS" 
						;;
					exec|execution) 
						AUTOMACTC_TARGETS="$T_EXECUTION" 
						;;
					quarantine) 
						AUTOMACTC_TARGETS="$T_QUARANTINE" 
						;;
					logs) 
						AUTOMACTC_TARGETS="$T_LOGS" 
						;;
					system) 
						AUTOMACTC_TARGETS="$T_SYSTEM" 
						;;
					*)
						echo "[ERROR] No valid option passed as argument."
						exit 1
				esac
				AUTOMACTC_ARGS+=" -m ${AUTOMACTC_TARGETS}"
				;;
			h|*) help ;;
		esac
	done

	# Check for Python installation
	check_Python

	echo -n "[*] Preparing AutoMacTC... "

	# Prepare AutoMacTC
	check_AutoMacTC

    if [[ ! -d "$DL_DIR_TMP" ]]; then
    	mkdir "$DL_DIR_TMP"
	fi

	unzip -qq -o "$DL_DIR/$AUTOMACTC_ZIP" -d "$DL_DIR_TMP"

	if [[ -f "$AUTOMACTC_BIN" ]]; then
		chmod +x "$AUTOMACTC_BIN"
	else
		echo "[ERROR] AutoMacTC not found"
		exit 1
	fi
	echo "[DONE]"
}

#
# Run AutoMacTC
#
function run_AutoMacTc()
{
	echo "[*] Running AutoMacTC ..."
	echo ""
	echo "  [+] $PYTHON_PATH \"$AUTOMACTC_BIN\" $AUTOMACTC_ARGS"
    $PYTHON_PATH "$AUTOMACTC_BIN" $AUTOMACTC_ARGS -o "$DL_DIR_TMP"
	if [ ! $? -eq 0 ]; then
   		echo "[ERROR] AutoMacTC failed"
		exit 1
	fi
	echo ""
}

#
# Clean working directory and generate the download command
#
function post_AutoMacTc()
{
	echo -n "[*] Cleaning step... "
	rm -rf "$DL_DIR/automactc-osx.zip"
	rm -rf "$DL_DIR_TMP/automactc"
	rm -rf "$TMP_IR_DIR/automactc"
	echo "[DONE]"

	echo "[*] Download output by typing the following command:"
	echo ""
	echo "	getfile \""`ls -t "$DL_DIR_TMP/DFIR"*tar.gz | head -1`"\""
}

##
## Run
##
pre_AutoMacTc $1 $2
run_AutoMacTc
post_AutoMacTc

#
# Exit
#
exit 0
