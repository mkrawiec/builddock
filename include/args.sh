#%% Before *


#%% Private
_args_parse_positional()
{
    # Count positional arguments
    local pos_count=0
    for arg in $@; do
        if [[ $arg == -* ]]; then break; fi
        ((++pos_count))
    done

    case $pos_count in
        1) ARG_ACTION=$1 ;;
        2) ARG_ACTION=$1; ARG_SIG=$2 ;;
    esac
} >/dev/null

_args_parse_flags()
{
    # Shift all positional args preceding flags
    for arg in $@; do
        if [[ $arg == -* ]]; then break; fi
        shift
    done

    while getopts 't:' flag; do
        ARG_FLAGS[$flag]=$OPTARG
    done
} >/dev/null


#%% Public
args_init()
{
    declare -g ARG_ACTION=''
    declare -g ARG_SIG=''
    declare -gA ARG_FLAGS

    _args_parse_positional $@
    _args_parse_flags $@

    declare -gr PKG_PROJECT=${ARG_SIG##/*}
    declare -gr PKG_NAME=${ARG_SIG##*/}
    declare -gr PKG_DIR=${ROOT}/projects/${ARG_SIG}
} >/dev/null

