#%% After *


#%% Private
_docker_render_dockerfile()
{
    local user=$(whoami)
    local group=$(id -gn $user)
    sed -i.bak "s/\$GROUP/$group/g; s/\$USER/$user/g" Dockerfile
} >/dev/null

_docker_clear_dockerfile()
{
    mv Dockerfile.bak Dockerfile
} >/dev/null

_docker_build()
{
    local target=${ARG_FLAGS[t]}

    pushd ${ROOT}/docker/$target
    _docker_render_dockerfile
    docker build -t builddock/$target .
    _docker_clear_dockerfile
    popd
} >/dev/null


#%% Public
docker_run()
{
    local cmd=$1; shift
    local target=${ARG_FLAGS[t]}
    local user=$(whoami)
    local group=$(id -gn $user)

    cmd_info "Docker container for $target does not exist yet. Building..."
    _docker_build

    docker run \
        --volume ${PKG_DIR}:/home/$user/_project \
        --net=host \
        --user=$user:$group \
        --rm \
        -it builddock/$target \
        $cmd
}

docker_mkpackage()
{
    cmd_info "Starting build for ${ARG_SIG}"

    # Package building process can fail for any reason
    docker_run mkpackage || true
}

