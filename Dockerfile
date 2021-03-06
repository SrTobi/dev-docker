# syntax = docker/dockerfile:1.2

FROM archlinux

# use faster mirror to speed up the image build
RUN echo 'Server = https://mirror.pkgbuild.com/$repo/os/$arch' > /etc/pacman.d/mirrorlist

# install packages
#RUN --mount=type=cache,sharing=locked,target=/var/cache/pacman \
RUN pacman -Suy --noconfirm --needed \
        base base-devel \
        zsh openssh git vim


# configure nvidia container runtime
# https://github.com/NVIDIA/nvidia-container-runtime#environment-variables-oci-spec
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

# Create user
RUN useradd -ms /bin/zsh ddev
RUN passwd -d ddev
RUN echo "ddev ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ddev

USER ddev
WORKDIR /home/ddev

RUN mkdir -p /home/ddev/.gnupg && \
    echo 'standard-resolver' > /home/ddev/.gnupg/dirmngr.conf

# Setup paru
RUN git clone --depth 1 https://aur.archlinux.org/paru-bin.git paru
#RUN --mount=type=cache,sharing=locked,target=/var/cache/pacman \
RUN cd paru && \
    makepkg --noconfirm -si && \
    cd ..
RUN rm -rf paru

# Install oh-my-zsh and additional stuff
#RUN --mount=type=cache,sharing=locked,target=/var/cache/pacman \
RUN paru --noconfirm -S \
        oh-my-zsh-git kitty-terminfo

# Setup zsh
RUN mkdir -p .config/zsh-config
ADD content/zsh-config .config/zsh-config
RUN sudo chown -R ddev:ddev .config/zsh-config
RUN echo "source ~/.config/zsh-config/zshrc" > .zshrc

# Setup git
ADD content/gitconfig .gitconfig
RUN sudo chown ddev:ddev .gitconfig

# Setup ssh
RUN sudo sh -c "echo 'PermitEmptyPasswords yes' >> /etc/ssh/sshd_config"
ADD content/ssh-entrypoint.sh /run/entrypoint.sh

ENTRYPOINT ["/run/entrypoint.sh"]
CMD [ "zsh" ]

