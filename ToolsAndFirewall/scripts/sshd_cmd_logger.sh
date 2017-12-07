#!/bin/sh
# shellcheck disable=SC2006
##############################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2017.  All Rights Reserved.
##############################################################################
# sshd_cmd_logger.sh:
#   Author: Doug Barlett  
#   This script is used in the prefix of a public key record to set up a shell
#   history file that is specific to the session and individual to maintain
#   individual accocuntability via shell logging.
#
# Inputs: the standard ssh label string per http://ibm.biz/Compliant_SSH_keys
# Outputs: a shell history file inside a standard directory structure
# There is no return code checking because the script execs to a new command 
# when running normally.
##[  Notes  ]#################################################################
##
## ACTION Required: place this file at the location specified in the
##                  "command=" parm on your public key.
## ACTION Required: set the permissions on this file to 750.
##                  If your version of sh does not support ~/.profile expansion,
##                  see note at bottom.
## FINAL ACTION Required: after installing your key and this script,
##                  you MUST test the key via a remote SSH using the new key,
##                  and verify that the log file was created in the HISTFILE
##                  directory set below contains the session info.
##
##############################################################################
VER=2.4
##[  Change History  ]########################################################
##
## Release          xx  Details
## ---------------- --  -----------------------------------------------------
## 2.4   2017-03-18 JV  Adjusted script headers and change history.
##                      Fixed indentation: 1 tab => 4 spaces, only spaces.
##                      Ran against shellcheck and fixed all warnings.
##                      Re-introduced the #!/bin/sh shebang, the default
##                      behavior defaults to /bin/sh when no shebang is found.
##                      Make the "${BASH}" check actually look for bash rather
##                      than assuming the variable may come up uninitialized.
##                      Use printf properly with "%b" as format string.
##                      Attempt to spawn a "login shell" rather than just an
##                      "interactive" shell.
## 2.3.1 2017-03-17 JV  Add code to support method introduced in v2.2 for
##                      other Operating Systems: SunOS & HP/UX.
## 2.3   2017-03-17 JV  March 2017: Sanitize $IDENTITY to account for
##                      URT 'Intermediate codes' having an asterisk '*' in
##                      their serial numbers.
## 2.2   2017-02-02 AD  Obtain shell based on OS for accounts that use LDAP.
## 2.1   2016-08-30 DB  Significant improvements, thanks to input from:
##                      Viet Hoang and Chris High.
##                      Added quotes to remote cmd test.
##                      Changed code to handle missing HIST_DIR to do temp log,
##                      not exit.
##                      Added test for syslog facility to use, reduced logger
##                      cmds to one rather than 2 per event.
##                      Changed logger syntax to avoid problems with stacked.
##                      cmds in SSH_ORIGINAL_COMMAND.
##                      Implemented simpler way to determine if HISTFILE is
##                      treated like bash or not.
##                      Adjusted code so bash always uses .bash_history.
##                      Sometimes $BASH is not set in bash, added backup check
##                      for bash via $SHELL.
##                      Removed dot from start of HISTFILE when its placed in
##                      dedicated logging dir under /var/log/hist.
## 2.0   2016-08-25 DB  Simplified logger calls to just do both auth.info and
##                      authpriv.info.
##                      Enhanced remote cmd logging to handle multiple cmds.
##                      Fixed remote cmd logging so it wouldnt log bash id
##                      commands to .sh_history.
## 2016.6  20160819 DB  Removed the shebang. Resequenced the ksh histlog header,
##                      removed ENV stuff. 
## 2016.5               Fixed auth.info test and added identity variable to ENV
##                      variable passed to execd shell.
##                      Removed call to .profile, since we are going to exec to
##                      new shell after that.
##                      Added check to prevent issuing ksh or bash cmds if we
##                      are not really in ksh or bash yet.
##                      Changed dir check from -d to -w.
## 2016.4               Changes to support std label string as input to cmd
##                      logger, (as well as colon-delimited string).
##                      Interactive session now invokes userid's login shell,
##                      not just ksh.
##                      Added command_prompt to force history update on bash.
##                      Added recursive call to format ksh history
##                      (this may not be needed!).
##                      Added SSH_CONNECTION info to logging messages.
##                      Added option to use authpriv as well as auth for syslog.
##                      Added code to create logdir if not there.
## 2016.2  20160502 DB  Change print to printf, added msgs, code to remove
##                      spaces from $1.
## 2016.1  20160316 DB  First Release.
##----------------- --  -----------------------------------------------------
## DB=Doug Barlett; JV=Javier Villavicencio; AD=Alex Dukat;
##############################################################################

PS4='line $LINENO:  ' ; export PS4
LOG_DIR="/var/log/hist"
HISTFILE_NAME=".sh_history" #Set up a default value
IDENTITY="NoParameterProvided" #Set up a default value
PARM="$*"
OS=`uname`
DATESTAMP=`/bin/date '+%Y%m%d_%H%M%S'`
TZDATESTR=`date '+%m-%d-%Y@%T'`
THISTTY=`tty`
# Determine which syslog facility to use.
[ "${OS}" = "Linux" ] && TARGET_FACILITY="authpriv" || TARGET_FACILITY="auth"
# Make the identity string !-free and space-free and *-free and colon delimited
# so we can handle the standard ssh label format
PARM=`echo "$PARM" | \
    sed -e 's/[!]//g' -e 's/ /\./g' -e 's/[/]/:/g' -e 's/[^a-zA-Z0-9:.]/+/g'`

if [ "${PARM}x" = "x" ]; then
    # To prevent business impact, we issue msgs but continue.
    IDENTITY="NoParameterProvided"
    printf "%b" "Logging Failure: ${LOGNAME} authenticated using pubkey " \
        "but required logging was not set up correctly. " \
        "See  http://ibm.biz/Compliant_SSH_keys  " \
        "${SSH_CONNECTION}, (${THISTTY}) V:${VER} msg#1"
    echo "Failed: ${LOGNAME} authenticated using pubkey but logging was " \
        "not set up correctly. See  http://ibm.biz/Compliant_SSH_keys  "\
        "$SSH_CONNECTION, (${THISTTY}) V:${VER}  msg#1" | \
            logger -p "${TARGET_FACILITY}.info"
else
    IDENTITY="${PARM}"
fi

if [ "${LOGNAME}x" != "x" ]; then
    TARGET_ID="${LOGNAME}"
else
    if  [ -x /usr/ucb/whoami ] ; then
        TARGET_ID=`/usr/ucb/whoami | awk '{ print $1 }'`
    else
        TARGET_ID=`whoami | awk '{ print $1 }'`
    fi
fi

# Obtain user's shell.  Cannot just look in /etc/passwd in case LDAP is being
# used.
if [ "${OS}" = "AIX" ]; then
    MY_LOGIN_SHELL=`lsuser -a shell "${TARGET_ID}" | cut -f2 -d=`
elif [ "${OS}" = "Linux" ] || [ "${OS}" = "SunOS" ]; then
    MY_LOGIN_SHELL=`getent passwd "${TARGET_ID}" | cut -f7 -d:`
elif [ "${OS}" = "HP-UX" ]; then
    MY_LOGIN_SHELL=`pwget -n "${TARGET_ID}" | cut -f7 -d:`
else
    MY_LOGIN_SHELL=`egrep "^${TARGET_ID}:" /etc/passwd | cut -f7 -d:`
fi

if [ "${MY_LOGIN_SHELL}x" = "x" ]; then
  MY_LOGIN_SHELL="/bin/false"
fi

# If this is bash, adjust histfile name of last resort.
if echo "${BASH}" | grep 'bash$' >/dev/null 2>&1; then
    HISTFILE_NAME=".bash_history"
fi

# Case 1: this is just a remote command
if [ "${SSH_ORIGINAL_COMMAND}x" != "x" ]; then
    SSH_CMD_TO_LOG="$SSH_ORIGINAL_COMMAND" 

    if  [ "${MY_LOGIN_SHELL}" = "/bin/false" ] ; then
        # adjust msg if cmd will not execute
        SSH_CMD_TO_LOG="WAS_NOT_EXECUTED--${SSH_CMD_TO_LOG}"
    fi
    echo "${TARGET_ID} authenticated using key from ${IDENTITY},${SSH_CONNECTION}, " \
        "cmd=${SSH_CMD_TO_LOG} issued via ${MY_LOGIN_SHELL} msg#2" | \
            logger -p "${TARGET_FACILITY}.info"
    printf "%b" "\n# ${DATESTAMP}: id:${TARGET_ID} " \
        "by:${IDENTITY},${SSH_CONNECTION}, remote_cmd:${SSH_CMD_TO_LOG} " \
        "issued via ${MY_LOGIN_SHELL} msg#2\n\0\0" >> "${HOME}/${HISTFILE_NAME}"
    if  [ -x "${MY_LOGIN_SHELL}" ]; then
        # exec means we exit the script right here so the loop should never finish
        exec "${MY_LOGIN_SHELL}" -c "${SSH_ORIGINAL_COMMAND}"
    else
        echo "ERROR: No login shell available to launch command, " \
            "See  http://ibm.biz/Compliant_SSH_keys  V:${VER} msg#3"
    fi
# Case 2: this is an interactive login so we must set up an inidividual histfile
else
    if [ -w "${LOG_DIR}" ]; then
        HIST_DIR="${LOG_DIR}/${TARGET_ID}.ssh_history"
        if [ ! -d "${HIST_DIR}" ]; then
            mkdir -p "${HIST_DIR}"
            chmod 700 "${HIST_DIR}"
        fi
        # For usability, remove dot from front of HISTFILE_NAME
        HISTFILE_NAME=`echo "${HISTFILE_NAME}" | sed -e 's/^[.]//'`

        HISTFILE="${HIST_DIR}/${HISTFILE_NAME}.${TARGET_ID}.${IDENTITY}.${DATESTAMP}"
        if [ ! -r "${HISTFILE}" ]; then
           /bin/touch "${HISTFILE}"
        fi
        /bin/chmod 0600 "${HISTFILE}"
    else
        echo "ERROR: your SA must create a '${LOG_DIR}' with permissions " \
            "'drwxrwxrwt' (1777) before this logging script will work! msg#4"
        ls -lt "${LOG_DIR}"
        echo "ERROR: Contact your SA. See  http://ibm.biz/Compliant_SSH_keys " \
            "for information on setting up logging. V:${VER}  msg#4"
        HISTFILE="${HOME}/${HISTFILE_NAME}"
        echo "Warning: ${LOGNAME} authenticated using pubkey, temporary " \
            "logging at ${HISTFILE} used because ${LOG_DIR} was not set up " \
            "correctly. See  http://ibm.biz/Compliant_SSH_keys  " \
            "${SSH_CONNECTION}, (${THISTTY}) V:${VER}  msg#4" | \
                logger -p "${TARGET_FACILITY}.info"
        echo "WARNING:  Temporary logging going to ${HISTFILE}. msg#5"
    fi
    export HISTFILE

    # Sometimes $BASH is not set by shell, 
    # so look at $SHELL as a backup to detect bash.
    # This is actually looking for a symlink, not a glob pattern, disable SC2010.
    # shellcheck disable=SC2010
    CURRENT_IS_BASH=`ls -l "${SHELL}" | grep 'bash' 2>/dev/null`

    if echo "${BASH}" | grep 'bash$' >/dev/null 2>&1 || [ "${CURRENT_IS_BASH}x" != "x" ]; then
        # bash
        HISTTIMEFORMAT="%F %T # " 
        export HISTTIMEFORMAT
        # This would be 'bash', not 'Posix', disable SC2039.
        # shellcheck disable=SC2039
        shopt -s histappend
        unset HISTCONTROL HISTIGNORE
        # Force the write to history every command.
        PROMPT_COMMAND="history -a; history -c; history -r;${PROMPT_COMMAND}"
        export PROMPT_COMMAND
        # Try to write to the histfile before anything else does
        printf "%b" "#  ${TARGET_ID} authenticated using key from $IDENTITY, " \
            "${SSH_CONNECTION}, (${THISTTY}) on ${TZDATESTR}  ${MY_LOGIN_SHELL} " \
            "${HISTFILE} msg#6\n" >> "${HISTFILE}"
        echo "${LOGNAME} authenticated using key from ${IDENTITY}, " \
            "${SSH_CONNECTION}, (${THISTTY}), interactive login,  " \
            "${MY_LOGIN_SHELL}  HISTFILE=${HISTFILE} msg#6" | \
                logger -p "${TARGET_FACILITY}.info"
    else 
        EXTENDED_HISTORY=ON
        export EXTENDED_HISTORY
        HISTDATEFMT="%m-%d-%Y %H:%M:%S"
        export HISTDATEFMT
        # *Properly* initialize HISTFILE, otherwise ksh overwrites our header.
        printf "%b" "\0201\01" > "${HISTFILE}"
        printf "%b" "#  ${TARGET_ID} authenticated using key from ${IDENTITY}, " \
            "${SSH_CONNECTION}, (${THISTTY}) on ${TZDATESTR}  " \
            "${MY_LOGIN_SHELL} ${HISTFILE} msg#7 \n" \
            "\0\0" "\0\0" >> "${HISTFILE}"
        echo "${LOGNAME} authenticated using key from ${IDENTITY}, " \
            "${SSH_CONNECTION}, (${THISTTY}) , interactive login,  " \
            "${MY_LOGIN_SHELL}  HISTFILE=${HISTFILE} msg#7" | \
                logger -p "${TARGET_FACILITY}.info"
    fi

    if  [ -x "${MY_LOGIN_SHELL}" ]; then
        # And we will leave the script at this point.
        # If there's perl available we can start a proper "login shell"
        PERL=`which perl`
        if [ -x "${PERL}" ]; then
            SHNAME=`basename ${MY_LOGIN_SHELL}`
            # This hack changes argv[0] from the executable path to '-shell'
            # triggering the POSIX behavior of launching a login shell.
            exec "${PERL}" -e "exec { '${MY_LOGIN_SHELL}' } '-${SHNAME}'"
        else
            exec $MY_LOGIN_SHELL -l -
        fi
    else
        printf "%b" "# Interactive session for  ${TARGET_ID} exited. " \
            "Login shell: ${MY_LOGIN_SHELL} Info: ${IDENTITY}, " \
            "${SSH_CONNECTION} (${THISTTY}) on ${TZDATESTR} " \
            "${HISTFILE} msg#8 \n" >> "${HISTFILE}"
        echo " Interactive session for ${LOGNAME} exited. Login shell: " \
            "${MY_LOGIN_SHELL} Info: ${IDENTITY}, ${SSH_CONNECTION} " \
            "(${THISTTY}) , interactive login failed,  HISTFILE=${HISTFILE} " \
            "V;${VER} msg#8" | logger -p "${TARGET_FACILITY}.info"
    fi # end of if login shell is executable
fi  # end of remote command vs interactive login
