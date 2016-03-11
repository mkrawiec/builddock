#%% After cmd.sh
#%% Before service.sh


#%% Private
_validator_arg_sig() { [ ! -z ${ARG_SIG} ] || cmd_error 'Missing argument'; }

_validator_pkg_dir() { [ -d ${PKG_DIR} ] || cmd_error "Package ${ARG_SIG} does not exist"; }

_validator_npkg_dir() { [ ! -d ${PKG_DIR} ] || cmd_error "Package ${ARG_SIG} already exists"; }

_validator_target_flag() { [ ${ARG_FLAGS[t]+1} ] || cmd_error 'Missing target flag'; }


#%% Public
validator_apply()
{
    for validator in "$@"; do
        eval "_validator_$validator"
    done
}
