#!/bin/bash
#----------
# Disk headers:
#  SD -  90k - 96 02 80 16 80 00
#  ED - 130k - 96 02 80 20 80 00
#  DD - 180k - 96 02 E8 2C 00 01

function my_sio2bsd() {
	exec 3>&2
	exec 2>&-	;# Close STDERR

	pkill -9 sio2bsd
	sleep 2
	rm -rf /tmp/sio2bsd*
	sleep 1
	sio2bsd ${SIOPARM} ${DISK}.atr > ${DISKDIR}${DISK}.log &
	exec 2>&3	;# Restore STDERR
}

function create_atr() {
	DISKSIZE=${1:-$DENSITY}
	case $DISKSIZE in
		90)
			# SD - 90k
			printf "\x96\x02\x80\x16\x80\00\00\00\00\00\00\00\00\00\00\00" > ${DEST}
			truncate -s +90k ${DEST}
			printf "\nCreated new SD disk.\n"
			;;
		130)
			# ED - 130k
			printf "\x96\x02\x80\x20\x80\00\00\00\00\00\00\00\00\00\00\00" > ${DEST}
			truncate -s +130k ${DEST}
			printf "\nCreated new ED disk.\n"
			;;
		180)
			# DD - 180k
			printf "\x96\x02\xE8\x2C\x00\01\00\00\00\00\00\00\00\00\00\00" > ${DEST}
			truncate -s +180k ${DEST}
			printf "\nCreated new DD disk.\n"
			;;
	esac
}

function do_Archive() {
	read -a DESC -p "One line description for the disk: " -e -i "`echo ${PREVDESC[@]}`"
	if [ "USEPREV" != "[yY]" ]; then
		PREVDESC=${DESC[@]}
	fi

	DEST="${DISKDIR}${DISK}.atr"
	if [ ! -e ${DEST} ]; then
		create_atr ${DENSITY}
	else
		read -p "[!!] Image file exists. Overwrite [Y/n]?" -n 1 DUMMY
		case $DUMMY in
			[yY])
				create_atr ${DENSITY}
				;;
			[nN])
				printf "Image file not cleared.\n"
				;;
		esac
		unset DUMMY
	fi

	echo ${DESC[@]} > ${DISKDIR}${DISK}.nfo

	RETRY=true
	while [ "${RETRY}" == "true" ]; do
		printf "\nIf using the wrong disk type, press 's' for SD or 'd' for DD or 'e' for ED...\n" 
		my_sio2bsd
		printf " !-!-! If you want to tag the current disk as containing Bad Sectors !-!-!\n"
		printf " !-! Press the 'b' key to add that information to the ${DISK}.nfo file !-!\n"
		read -s -n 1 -p "Press any other key when copy is completed succesfully..." DUMMY
		case $DUMMY in
			[bB])
				printf "\nTagging ${DISK} as to contain bad sectors and move on...\n"
				printf "\nBAD SECTORS\n" >> ${DISKDIR}${DISK}.nfo
				RETRY=false
				;;
			[dD])
				# DD - 180k
				DENSITY="180"
				create_atr ${DENSITY}
				printf "\nRetrying with disk type DD...\n"
				;;
			[eE])
				# ED - 130k
				DENSITY="130"
				create_atr ${DENSITY}
				printf "\nRetrying with disk type ED...\n"
				;;
			[sS])
				# SD - 90k
				DENSITY="90"
				create_atr ${DENSITY}
				printf "\nRetrying with disk type SD...\n"
				;;
			*)
				echo
				RETRY=false
				;;
		esac
	done
	chown bware: ${DISKDIR}/${DISK}.*
}

function upd_Settings(){
	printf "\n\nUpdate Settings...\n"
	read -p "Default density [90/130/180] [Current: $DENSITY]: " -e -i "$DENSITY" DENSITY
	read -p "Initial disk name: " -e DISK
	read -p "Use previous values (Disk name/Description) [y/n] [Current: $USEPREV]: " -e -i "$USEPREV" USEPREV
	read -p "Image directory [Current: $DISKDIR]: " -e -i "$DISKDIR" DISKDIR
	read -p "Tooldisk (No extension) [Current: $TOOLDISK]: " -e -i "$TOOLDISK" TOOLDISK
	read -p "Serial device [Current: $SERIAL]: " -e -i "$SERIAL" SERIAL
	read -p "sio2bsd parameters [Current: $SIOPARM]: " -e -i "$SIOPARM" SIOPARM

	printf "\nNew settings:\n"
	printf "# Settings\n"
	printf "DENSITY=\"%s\"\t\t\t\t;# Default density (90/130/180)\n" "${DENSITY}"
	printf "DISK=\"%s\"\t\t\t\t;# Initial disk name\n" "${DISK}"
    printf "PREVDISK=\"\${DISK}\"\n"
	printf "USEPREV=\"%s\"\t\t\t;# Use previous values (Disk name/Description)\n" "${USEPREV}"
	printf "DISKDIR=\"%s\"\t\t\t;# Directory to store images, log and nfo files\n" "${DISKDIR}"
	printf "TOOLDISK=\"%s\"\t\t;# Tooldisk name (no extension, assuming .atr)\n" "${TOOLDISK}"
	printf "SERIAL=\"%s\"\t\t;# SIO2* Serial device name\n" "${SERIAL}"
	printf "SIOPARM=\"%s\"\t;# sio2bsd parameters\n" "${SIOPARM}"
	printf "\n\n"
	read -p "Write to ${CFGFILE} [Y/n]?" -n 1 DUMMY
	case $DUMMY in
		[yY])
			printf "# Settings\n" > ${CFGFILE}
			printf "DENSITY=\"%s\"\t\t\t\t;# Default density (90/130/180)\n" "${DENSITY}" >> ${CFGFILE}
			printf "DISK=\"%s\"\t\t\t\t;# Initial disk name\n" "${DISK}" >> ${CFGFILE}
			printf "PREVDISK=\"\${DISK}\"\n" >> ${CFGFILE}
			printf "USEPREV=\"%s\"\t\t\t;# Use previous values (Disk name/Description)\n" "${USEPREV}" >> ${CFGFILE}
			printf "DISKDIR=\"%s\"\t\t\t;# Directory to store images, log and nfo files\n" "${DISKDIR}" >> ${CFGFILE}
			printf "TOOLDISK=\"%s\"\t\t;# Tooldisk name (no extension, assuming .atr)\n" "${TOOLDISK}" >> ${CFGFILE}
			printf "SERIAL=\"%s\"\t\t;# SIO2* Serial device name\n" "${SERIAL}" >> ${CFGFILE}
			printf "SIOPARM=\"%s\"\t;# sio2bsd parameters\n" "${SIOPARM}" >> ${CFGFILE}
			printf "\n\n"
			;;
		[nN])
			printf "Configfile not updated.\n"
			;;
	esac
	unset DUMMY
}

# Load settings
CFGFILE="${0%.*}.cfg"
source $CFGFILE 2>/dev/null

# Sane defaults (in case config file is missing)
DENSITY="${DENSITY:-130}"
DISK="${DISK:-}"
PREVDISK="${DISK}"
USEPREV="y"
DISKDIR="${DISKDIR:-./}"
TOOLDISK="${TOOLDISK:-Tooldisk}"
SERIAL="${SERIAL:-/dev/ttyS2}"
SIOPARM="${SIOPARM:--s ${SERIAL} -q pal }"

# Declare empty arrays
declare -a DESC
declare -a PREVDESC

while [ "${DISK}" != "q" ]; do
	printf "\n\n *** DISK ARCHIVER ***\nREADY\n"
	read -p "Disk Name ('q' to Quit, 's' for Settings, 't' to load Tooldisk)? " -e -i "${PREVDISK}" DISK
	if [ "USEPREV" != "[yY]" ]; then
		PREVDISK="${DISK}"
	fi

	case "${DISK}" in
		[qQ])
			echo "Exiting upon request..."
			break
			;;
		[tT])
			DISK=${TOOLDISK}
			if [ ! -e ${DISK}.atr ]; then
				echo "Unable to locate tooldisk ${DISKDIR}${DISK}.atr, exiting..."
				break
			fi
			printf "\nMounting tooldisk.\n"
			my_sio2bsd
			printf " Boot the Atari and load your preferred disk copy tool. "
			read -s -n 1 -p "Press any key when copier is loaded succesfully..." DUMMY
			PREVDISK=""
			;;
		[sS])
			upd_Settings
			PREVDISK=""
			;;
		*)
			do_Archive
			;;
	esac
	DISK=""
done

exec 2>&-	;# Close STDERR
pkill -9 sio2bsd
sleep 1
rm -rf /tmp/sio2bsd*