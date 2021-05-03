#!/bin/bash

# get basic system information
# these are the same set of infos the WebGUI dialog/controler has
source /home/admin/raspiblitz.info

# SETUPFILE
# this key/value file contains the state during the setup process
SETUPFILE="/var/cache/raspiblitz/raspiblitz.setup"

# init SETUPFILE
rm $SETUPFILE 2>/dev/null
echo "# RASPIBLITZ SETUP STATE" > $SETUPFILE

############################################
# Basic Setup (Blockchain & Lightning Impl)
# (skip if migration was auto-detected)

if [ "${migrationOS}" == "" ]; then

  echo "# Starting basic setup dialog ..."
  /home/admin/setup.scripts/dialogBasicSetup.sh

  # on cancel - let user exit to terminal
  if [ "$?" != "0" ]; then
    echo "# you selected cancel - exited to terminal"
    echo "# to re-start setup use command --> setup"
    exit 1
  fi

fi

if [ "${migrationOS}" != "" ]; then

  ###############################################
  # MIGRATION 
  # other fullnodesOS or RaspiBlitz migration file

  echo "# Starting migration dialog ..."
  /home/admin/setup.scripts/dialogMigration.sh

  # on cancel - let user exit to terminal
  if [ "$?" != "0" ]; then
    echo "# you selected cancel - exited to terminal"
    echo "# to re-start setup use command --> setup"
    exit 1
  fi

else

  ###############################################
  # FRESH SETUP

  ############################################
  # Setting Name for Node

  echo "# Starting basic setup dialog ..."
  /home/admin/setup.scripts/dialogPasswords.sh

  ############################################
  # Lightning Wallet (new or restore) do this before passwords
  # because password C not needed if LND rescue file is uploaded

  lightningWalletDone=0
  while [ "${lightningWalletDone}" == "0" ]
  do

    echo "# Starting lightning wallet dialog ..."
    /home/admin/setup.scripts/dialogLightningWallet.sh

    # only if dialog exited clean end loop
    if [ "$?" == "0" ]; then
      lightningWalletDone=1
    fi

  done

fi

############################################
# Enter Passwords
# for fresh setup & migration

echo "# Starting passwords dialog ..."
/home/admin/setup.scripts/dialogPasswords.sh

############################################
# PROCESS SETUP CHOICES
# TODO: move this part later outside of dialog controller and combine with data from WebUI

if [ "${migrationOS}" == "" ]; then

  ############################################
  # Normal Setup

  echo "# CREATING raspiblitz.conf from your setup choices"

  # prepare the config file (what will later become the raspiblitz.config)
  source /home/admin/_version.info

  CONFIGFILE="/mnt/hdd/raspiblitz.config"
  rm $CONFIGFILE 2>/dev/null
  echo "# RASPIBLITZ CONFIG FILE" > $CONFIGFILE
  echo "raspiBlitzVersion='${codeVersion}'" >> $CONFIGFILE
  echo "lcdrotate=1" >> $CONFIGFILE
  echo "lightning=${lightning}" >> $CONFIGFILE
  echo "network=${network}" >> $CONFIGFILE
  echo "chain=main" >> $CONFIGFILE
  echo "runBehindTor=on" >> $CONFIGFILE

else

  ############################################
  # Process Migration
  # TODO: move this part later outside of dialog controller and combine with data from WebUI

  echo "TODO: Process Migration"
  exit 1

fi

clear
echo "# setup dialog done - results in:"
echo "# $SETUPFILE"
echo "# $CONFIGFILE"