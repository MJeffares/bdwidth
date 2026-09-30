#!/bin/bash

HOME_DIR="${HOME}/klipper"

if [  -d "$1" ] ; then
    
	echo "$1"
	HOME_DIR=""$1"/klipper"
fi

BDDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"


if [ ! -d "$HOME_DIR" ] ; then
    echo ""
    echo "path error doesn't exist in "$HOME_DIR""
    echo ""
    echo "bdwidth sensor path: "$BDDIR""
    echo ""
    echo "usage example:./install.sh /home/pi  or ./install.sh /home/mks "
    echo "Error!!"
    exit 1
fi

echo "klipper path:  "$HOME_DIR""
echo "bdwidth sensor path: "$BDDIR""
echo ""

echo "linking bdwidth.py to klippy."

if [ -e "${HOME_DIR}/klippy/extras/bdwidth.py" ]; then
    rm "${HOME_DIR}/klippy/extras/bdwidth.py"
fi
ln -s "${BDDIR}/bdwidth.py" "${HOME_DIR}/klippy/extras/bdwidth.py"


if ! grep -q "klippy/extras/bdwidth.py" "${HOME_DIR}/.git/info/exclude"; then
    echo "klippy/extras/bdwidth.py" >> "${HOME_DIR}/.git/info/exclude"
fi

### the following section adds bdwidth to moonraker update manager if it exists, but does not fail the install if it doesn't
# Determine Moonraker config path (checks modern and legacy folder structures)
if [ -f "$HOME/printer_data/config/moonraker.conf" ]; then
    CONF_PATH="$HOME/printer_data/config/moonraker.conf"
elif [ -f "$HOME/klipper_config/moonraker.conf" ]; then
    CONF_PATH="$HOME/klipper_config/moonraker.conf"
else
    echo -e "\nCould not find moonraker.conf. Please add the update manager manually."
    exit 0 # Exit cleanly without failing the rest of the install
fi

# Check if the block already exists to prevent duplicate entries on re-installs
if grep -q "\[update_manager bdwidth\]" "$CONF_PATH"; then
    echo -e "\nbdwidth update manager entry already exists in $CONF_PATH"
else
    echo -e "\nAdding bdwidth to Moonraker update manager..."
    # Append the configuration to the end of the file
    cat << EOF >> "$CONF_PATH"

[update_manager bdwidth]
type: git_repo
path: ~/bdwidth
origin: https://github.com/MJeffares/bdwidth.git
primary_branch: main
managed_services: klipper
EOF
    echo -e "Update manager block added successfully!"
fi

echo ""
echo "Install bdwidth sensor successful "
echo ""
echo "happy printing!"
