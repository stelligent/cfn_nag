FROM ruby:2.5

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Update package tool
RUN apt-get update

# Install apt-utils and suppress package configuration warning
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1

# Install build tools
RUN apt-get install -y --no-install-recommends build-essential \
    git

# Install Docker CE CLI
RUN apt-get install -y apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    lsb-release \
    && curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | apt-key add - 2>/dev/null \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y docker-ce-cli

# Install gems
RUN gem install bundler
RUN gem install rubocop
RUN gem install solargraph

# Install cfn-lint via pip
RUN apt-get install -y python3-pip
RUN pip3 install cfn-lint

# Create a non-root user and provide sudo rights
ARG USERNAME=cfn_nag_dev
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd --uid $USER_UID --gid $USER_GID --shell /bin/bash -m $USERNAME \
  && apt-get install -y sudo \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME

# Persist bash history between runs
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && mkdir /commandhistory \
    && touch /commandhistory/.bash_history \
    && chown -R $USERNAME /commandhistory \
    && echo $SNIPPET >> "/home/$USERNAME/.bashrc"

# Prompt gpg window inside container for signing commits & setup folder permissions for non-root user
RUN echo 'export GPG_TTY="$(tty)"' >> /home/$USERNAME/.bashrc \
  && mkdir /home/$USERNAME/.gnupg \
  && chown -R $USERNAME /home/$USERNAME/.gnupg

# Add non-root user to gems and bundle
RUN chown -R $USERNAME /usr/local/lib/ruby/gems/2.5.0 \
  && chown -R $USERNAME /usr/local/bundle

# Enter container as non-root user
USER $USERNAME
