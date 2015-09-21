FROM fedora:latest

RUN dnf -y install @development-tools fedora-packager rpmdevtools sudo \
    dnf-plugins-core atool

RUN useradd -m -g users -G wheel,mock rpmaker
RUN mkdir /home/rpmaker/rpmbuild
WORKDIR /home/rpmaker/rpmbuild

COPY packagectl.sh /packagectl.sh
