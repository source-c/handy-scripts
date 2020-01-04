#!/bin/bash

# (c) 2010-2020 MelKori

# generates a random password, defaults to 8 characters
#
# USAGE: passwd-gen [num-characters]

# You may want to modify NC to get the best performance depending on
# your usual choice of DEVICE and N.  For slower DEVICEs, it's better
# to have lower NC (wastes less usable characters).  For faster
# DEVICEs, it's better to have a higher NC (fewer slow shell loops).
# You may also modify SET to limit the result to some specific seq of syms:
#  SET="[:alnum:][:punct:]"    # the sets of allowed characters (see tr(1))
#  SET="${SET:-a-zA-Z0-9}"
#  SET="${SET:-'a-zA-Z0-9-_#?^!&@(%)~$'}"

function shuffle() {
   PWDA=(`printf "%s" ${1}|egrep -o .`)

   local idx rand_idx tmp
   for ((idx=${#PWDA[@]}; idx>=0 ; idx--)) ; do
        rand_idx=$(( RANDOM % ${#PWDA[@]} + 1 ))

        # Swap if the randomly chosen item is not the current item
        if (( rand_idx != idx )) ; then
            tmp=${PWDA[idx]}
            PWDA[idx]=${PWDA[rand_idx]}
            PWDA[rand_idx]=$tmp
        fi
   done
   echo $(printf "%s" "${PWDA[@]}"|tr -d "\n")
}

N="${1:-8}"                                # password length
NC="${NC:-4}"                              # number of characters in a "chunk"
SET="${SET:-'a-zA-Z0-9-_#?^!&@(%)~$'}"     # allowed characters
DEVICE="${DEVICE:-/dev/random}"            # device to get a chunks from

NA=0
PWD=""
while [ "${N}" -gt 0 ]; do
    ALL=$(head -c "${NC}" "${DEVICE}")
    let "NA = NA + ${#ALL}"
    NEW=$(echo -E "${ALL}" | tr -d -c "${SET}" 2>&- | head -c "${N}")
    PWD="${PWD}${NEW}"
    let "N = N - ${#NEW}"
done

# We have ${PWD} here originally taken from the device,
# but we gonna shuffle it a bit

PWDZ=$(shuffle $PWD)

echo "  Length of password : ${#PWDZ}"
echo "  Total bytes read   : ${NA}"
echo "  Device             : ${DEVICE}"
echo "  Set                : ${SET}"
echo "   ----------------- "
echo "  Result             : ${PWDZ}"

exit 0
