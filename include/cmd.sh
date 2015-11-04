#%% After args.sh
#%% Before validator.sh


#%% Private


#%% Public
cmd_info()
{
    local msg=$1; shift

    printf "%$(tput cols)s\n"|tr ' ' '-'
    echo $msg
    printf "%$(tput cols)s\n"|tr ' ' '-'
}

cmd_error()
{
    local msg=$1; shift
    cmd_info "ERROR: $msg" >&2
    exit 1
}

cmd_display_help()
{
    echo 'HALP!'
}

cmd_open_editor()
{
    vi $1
}

cmd_init_package()
{
    cmd_info "Generating files for new package in ${PKG_DIR}"

    mkdir -p ${PKG_DIR}
    touch ${PKG_DIR}/service.sh
    touch ${PKG_DIR}/${PKG_NAME}.spec
}

