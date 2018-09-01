#!/bin/bash

function my_sio2bsd() {
	exec 3>&2
	exec 2>&-	;# Close STDERR

	pkill -9 sio2bsd
	sleep 2
	rm -rf /tmp/sio2bsd*
	sleep 1
	sio2bsd ${SIOPARM}${DISK}.atr > ${DISKDIR}${DISK}.log &
	exec 2>&3	;# Restore STDERR
}

BLANKED="/var/www/html/disks/Blank_MD130k.atr"
BLANCO=( "/var/www/html/disks/_Blank/Blank_MD130k.atr" "/var/www/html/disks/_Blank/Blank_SD90k.atr" "/var/www/html/disks/_Blank/Blank_DD180k.atr" )
DISKDIR="/var/www/html/disks/_personal/"
SIOPARM="-t pal -b 4 -s /dev/ttyUSB0 - - - ${DISKDIR}"
DISK=""
declare -a DESC

while [ "${DISK}" != "q" ]; do
	printf "\n\n *** DISK ARCHIVER ***\nREADY\n"
	read -p "Disk Name ('q' to Quit)? " DISK
	if [ "${DISK}" != q ]; then
		read -a DESC -p "One line description for the disk: "
		DEST="${DISKDIR}${DISK}.atr"
		if [ ! -e ${DEST} ]; then
			cp -a ${BLANCO[0]} ${DEST}
		fi
		echo ${DESC[@]} > ${DISKDIR}${DISK}.nfo

		RETRY=true
		while [ "${RETRY}" == "true" ]; do
			printf "\nIf using the wrong disk type, press 's' for SD or 'd' for DD or 'e' for ED...\n" 
			my_sio2bsd
			printf " !-!-! If you want to tag the current disk as cointaining Bad Sectors !-!-!\n"
			printf "  !-! Press the 'b' key to add that information to the ${DISK}.nfo file !-!\n"
			read -s -n 1 -p "Press any other key when copy is completed succesfully..." DUMMY
			case $DUMMY in
				[eE])
					cp -a ${BLANCO[0]} ${DEST}
					printf "\nRetrying with disk type ED...\n"
					;;
				[sS])
					cp -a ${BLANCO[1]} ${DEST}
					printf "\nRetrying with disk type SD...\n"
					;;
				[dD])
					cp -a ${BLANCO[2]} ${DEST}
					printf "\nRetrying with disk type DD...\n"
					;;
				[bB])
					printf "\nTagging ${DISK} as to contain bad sectors and move on...\n"
					printf "\nBAD SECTORS\n" >> ${DISKDIR}${DISK}.nfo
					RETRY=false
					;;
				*)
					echo
					RETRY=false
					;;
			esac
		done
		chown bware: ${DISKDIR}/${DISK}.*
	else 
		echo "Exiting upon request..."
	fi
done

exec 2>&-	;# Close STDERR
pkill -9 sio2bsd
sleep 1
rm -rf /tmp/sio2bsd*
 
