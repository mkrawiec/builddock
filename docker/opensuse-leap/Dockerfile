FROM opensuse:leap


# Target-specific variables used in mkpackage
ENV TARGET_NAME 'opensuse-leap'
ENV TARGET_BDEP '/usr/local/bin/zypper-deps'

# Install basic stuff required to build every package
RUN zypper in -y sudo
RUN zypper in -y -t pattern devel_basis devel_C_C++ devel_rpm_build

# Allow group wheel for sudo without password
RUN echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Add user to run commands as
RUN groupadd -f $GROUP; \
    useradd -m -g $GROUP -G wheel $USER

# Copy helper scripts
COPY ./rpm.sh /usr/local/bin/mkpackage
COPY ./zypper-deps.sh /usr/local/bin/zypper-deps
