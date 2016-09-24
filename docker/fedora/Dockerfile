FROM fedora:24

# Target-specific variables used in mkpackage
ENV TARGET_NAME 'fedora'
ENV TARGET_BDEP 'dnf -y builddep'

# Install basic stuff required to build every package
RUN dnf -y install @development-tools @c-development fedora-packager \
    rpmdevtools sudo which dnf-plugins-core

# Allow group wheel for sudo without password
RUN echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Add user to run commands as
RUN groupadd -f $GROUP; \
    useradd -m -g $GROUP -G wheel $USER

# Copy helper scripts
COPY ./rpm.sh /usr/local/bin/mkpackage

