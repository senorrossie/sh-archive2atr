#!/bin/bash
#----------
# Disk headers (16Byte):
#	DWORD - 32bit unsigned long (little endian)
#	WORD - 16bit unsigned short (little endian)
#	BYTE - 8bit unsigned char
#
#	Type 	Name		Description
#	WORD 	wMagic 		$0296 (sum of 'NICKATARI')
#	WORD 	wPars 		size of this disk image, in paragraphs (size/$10)
#	WORD 	wSecSize 	sector size. ($80 or $0100) bytes/sector
#	BYTE 	btParsHigh 	high part of size, in paragraphs (added by REV 3.00)
#	DWORD	dwCRC		32bit CRC of file (added by APE?)
#	DWORD	dwUnused 	unused
#	BYTE 	btFlags 	bit 0 (ReadOnly) (added by APE?)
#
# Disk Body:
#	Then there are continuous sectors. Some ATR files are incorrect:
#	 - if sector size is > $80 first three sectors should be $80 long.
#
# Implemented:
# Dens - Size - wMagi wPars wSecS
#   SD -  90k - 96 02 80 16 80 00
#   ED - 130k - 96 02 80 20 80 00
#   DD - 180k - 96 02 E8 2C 00 01
#   QD - 360k - 96 02 E8 59 00 01

function my_sio2bsd() {
	exec 3>&2
	exec 2>&-	;# Close STDERR

	pkill -9 sio2bsd
	sleep 2
	rm -rf /tmp/sio2bsd*
	sleep 1

	sio2bsd ${SIOPARM} ${DEST}.atr > ${DEST}.log &

	exec 2>&3	;# Restore STDERR
}

function create_atr() {
	DISKSIZE=${1:-$DENSITY}
	case $DISKSIZE in
		90)
			# SD - 90k
			printf "\x96\x02\x80\x16\x80\00\00\00\00\00\00\00\00\00\00\00" > ${DEST}.atr
			truncate -s +90k ${DEST}.atr
			printf "\nCreated new SD disk.\n"
			;;
		130)
			# ED - 130k
			printf "\x96\x02\x80\x20\x80\00\00\00\00\00\00\00\00\00\00\00" > ${DEST}.atr
			truncate -s +130k ${DEST}.atr
			printf "\nCreated new ED disk.\n"
			;;
		180)
			# DD - 180k
			printf "\x96\x02\xE8\x2C\x00\01\00\00\00\00\00\00\00\00\00\00" > ${DEST}.atr
			truncate -s +180k ${DEST}.atr
			printf "\nCreated new DD disk.\n"
			;;
		360)
			# QD - 360k
			printf "\x96\x02\xE8\x59\x00\01\00\00\00\00\00\00\00\00\00\00" > ${DEST}.atr
			truncate -s +360k ${DEST}.atr
			printf "\nCreated new QD disk.\n"
			;;
	esac
}

function do_Archive() {
	read -a DESC -p "One line description for the disk: " -e -i "`echo ${PREVDESC[@]}`"
	if [ "USEPREV" != "[yY]" ]; then
		PREVDESC=${DESC[@]}
	fi

	DEST="${DISKDIR}${DISK}"
	if [ ! -e ${DEST} ]; then
		create_atr ${DENSITY}
	else
		read -p "[!!] Image file exists. Overwrite [Y/n]?" DUMMY
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
	my_sio2bsd
	while [ "${RETRY}" == "true" ]; do
		printf "\nIf using the wrong disk type, press:\n"
		if [ "$DENSITY" == "90" ]; then
			printf " *\t's' for SD(90k),\n"
		else
			printf "\t's' for SD(90k),\n"
		fi
		if [ "$DENSITY" == "130" ]; then
			printf " *\t'e' for ED(130k),\n"
		else
			printf "\t'e' for ED(130k),\n"
		fi
		if [ "$DENSITY" == "180" ]; then
			printf " *\t'd' for DD(180k),\n"
		else
			printf "\t'd' for DD(180k),\n"
		fi
		if [ "$DENSITY" == "360" ]; then
			printf " *\t'q' for QD(360k),\n"
		else
			printf "\t'q' for QD(360k),\n"
		fi
		printf " !!\t'b' to tag the disk as having bad sectors in the %s.nfo file\t!!\n" "${DISK}"
		read -s -n 1 -p "Press any other key when copy is completed succesfully..." DUMMY
		case $DUMMY in
			[bB])
				printf "\nTagging ${DISK} as having bad sectors...\n"
				echo ${DESC[@]} > ${DEST}.nfo
				printf "\nBAD SECTORS\n" >> ${DEST}.nfo
				;;
			[dD])
				# DD - 180k
				DENSITY="180"
				create_atr 180
				printf "\nRetrying with disk type DD...\n"
				my_sio2bsd
				;;
			[eE])
				# ED - 130k
				DENSITY="130"
				create_atr 130
				printf "\nRetrying with disk type ED...\n"
				my_sio2bsd
				;;
			[qQ])
				# QD - 360k
				DENSITY="360"
				create_atr 360
				printf "\nRetrying with disk type QD...\n"
				my_sio2bsd
				;;
			[sS])
				# SD - 90k
				DENSITY="90"
				create_atr 90
				printf "\nRetrying with disk type SD...\n"
				my_sio2bsd
				;;
			*)
				echo
				RETRY=false
				;;
		esac
	done
	chown bware: ${DISKDIR}/${DISK}.*
}

function dsp_Settings(){
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
	dsp_Settings
	read -p "Write to ${CFGFILE} [Y/n]?" -n 1 DUMMY
	case $DUMMY in
		[yY])
			dsp_Settings > ${CFGFILE}
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
SIOPARM="${SIOPARM:--s ${SERIAL} -q pal}"

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
			DEST=${TOOLDISK}
			if [ ! -e ${DEST}.atr ]; then
				echo "Unable to locate tooldisk ${DEST}.atr, exiting..."
				break
			fi
			printf "\nMounting tooldisk.\n"
			my_sio2bsd
			printf " Boot the Atari and load your preferred disk copy tool. "
			read -s -n 1 -p "Press any key when copier is loaded succesfully..." DUMMY
			PREVDISK=""
			unset DUMMY
			;;
		[sS])
			upd_Settings
			PREVDISK=""
			;;
		*)
			DEST="${DISKDIR}/${DISK}"
			do_Archive
			;;
	esac
	DISK=""
	DEST=""
done

exec 2>&-	;# Close STDERR
pkill -9 sio2bsd
sleep 1
rm -rf /tmp/sio2bsd*