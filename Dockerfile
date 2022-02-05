# syntax = docker/dockerfile:1.2

FROM archlinux

# use faster mirror to speed up the image build
RUN echo 'Server = https://mirror.pkgbuild.com/$repo/os/$arch' > /etc/pacman.d/mirrorlist

# install packages
RUN --mount=type=cache,sharing=locked,target=/var/cache/pacman \
    pacman -Suy --noconfirm --needed \
        base base-devel \
        zsh openssh git vim


# configure nvidia container runtime
# https://github.com/NVIDIA/nvidia-container-runtime#environment-variables-oci-spec
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

# Create user
RUN useradd -ms /bin/zsh dev
RUN passwd -d dev
RUN echo 'dev ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/dev

USER dev
WORKDIR /home/dev

RUN mkdir -p /home/dev/.gnupg && \
    echo 'standard-resolver' > /home/dev/.gnupg/dirmngr.conf

# Setup paru
RUN git clone --depth 1 https://aur.archlinux.org/paru.git && \
    cd paru && \
    makepkg --noconfirm -si && \
    cd .. && \
    rm -rf paru

# Setup zsh
RUN paru --noconfirm -S oh-my-zsh-git
RUN mkdir -p .config/zsh-config
ADD zsh-config .config/zsh-config
RUN sudo chown -R dev:dev .config/zsh-config
RUN echo "source ~/.config/zsh-config/zshrc" > .zshrc

# Setup git
ADD gitconfig .gitconfig
RUN sudo chown dev:dev .gitconfig

# Setup .ssh
ADD ssh .ssh
RUN sudo chown -R dev:dev .ssh

CMD zsh

