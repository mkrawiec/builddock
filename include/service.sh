#%% After arg.sh
#%% Before package.sh


#%% Private
_service_set_version()
{
    sed -i "s/Version:.*/Version: ${PKG_VERSION}/g" ${PKG_NAME}.spec
} >/dev/null

_service_download_url()
{
    # Return if file exists or download url not set
    [ -v PKG_DOWNLOAD_URL ] || return 1
    [ -f ${PKG_NAME}-${PKG_VERSION}.tar.gz ] && return 1

    # Download the file and store curl output
    local curl_output=$(curl -JLO ${PKG_DOWNLOAD_URL})

    # Extract download filename from curl output
    local filename=$(grep -o -P "(?<=filename ').*(?=')" <<< "$curl_output")

    # Prefix download filename with tmp_vendor_
    mv {,tmp_vendor_}$filename
} >/dev/null

_service_unpack()
{
    local from_file=$(ls tmp_vendor_* | head -1)
    local to_dir="tmp_vendor_dir/"

    mkdir -p $to_dir
    case $from_file in
        *.tar.bz2)   tar xjf $from_file -C $to_dir ;;
        *.tar.gz)    tar xzf $from_file -C $to_dir ;;
        *.tar.xz)    tar xJf $from_file -C $to_dir ;;
        *.tar)       tar xf $from_file -C $to_dir ;;
        *.tbz2)      tar xjf $from_file -C $to_dir ;;
        *.tgz)       tar xzf $from_file -C $to_dir ;;
        *.zip)       unzip $from_file -d $to_dir ;;
        *.7z)        7z x $to_dir        ;;
        *.bz2)       bunzip2 $to_dir     ;;
        *.gz)        gunzip $to_dir      ;;
        *.xz)        unxz $to_dir        ;;
        *)           cmd_error "unknown download file format" ;;
    esac
} >/dev/null

_service_repack()
{
    local from_dir="tmp_vendor_dir"
    local to_file="${PKG_NAME}-${PKG_VERSION}.tar.gz"

    # Rename the inner dir
    if [ ! -d $from_dir/${PKG_NAME}-${PKG_VERSION} ]; then
    mv $from_dir/*/ $from_dir/${PKG_NAME}-${PKG_VERSION}
    fi

    tar -C $from_dir -czf $to_file .
} >/dev/null

_service_run_hook()
{
    local hook_name=$1; shift
    if [ "$(type -t $hook_name)" = 'function' ]; then
        eval $hook_name
    fi
}

_service_delete_tmpfiles()
{
    rm -fr tmp_*
} >/dev/null


#%% Public
service_setup()
{
    pushd $PKG_DIR >/dev/null

    source service.sh
    _service_set_version
    _service_download_url && (_service_unpack; _service_repack)
    _service_run_hook 'pkg_service_hook'

    popd >/dev/null
}

service_cleanup()
{
    pushd $PKG_DIR >/dev/null

    _service_run_hook 'pkg_cleanup_hook'
    _service_delete_tmpfiles

    popd >/dev/null
}

