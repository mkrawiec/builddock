FROM fedora:latest

RUN dnf -y install @development-tools fedora-packager rpmdevtools sudo \
    which dnf-plugins-core

RUN useradd -m -g users -G wheel,mock rpmaker
RUN echo 'Defaults:rpmaker !authenticate' >> /etc/sudoers

RUN su -c "rpmdev-setuptree" rpmaker
WORKDIR /home/rpmaker/rpmbuild

COPY build-package /usr/local/bin/build-package
