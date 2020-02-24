# VS Code Remote Development

You can start working on developing with this project with relative ease by using the VS Code Remote Development extension. In this project there is a folder named `.devcontainer` that allows users to open the project in a docker container using the custom built development image. This development image has all the items needed to start working on the cfn_nag project right out of the box. All you need to do is open the project in the VS Code Remote Container to get started.

- Install the VS Code [Remote Development extension pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)
- Open the repo in VS Code
- When prompted "`Folder contains a dev container configuration file. Reopen folder to develop in a container`" click the "`Reopen in Container`" button
- When opening in the future use the "`[Dev Container] cfn_nag Development`" option

## VS Code Dependencies

There are a couple of dependencies that you need to configure locally before being able to fully utizlize the Remote Developemnt environment.
- Requires `ms-vscode-remote.remote-containers` >= `0.101.0`
- [Docker](https://www.docker.com/products/docker-desktop)
  - Needs to be installed in order to use the remote development container
- [GPG](https://gpgtools.org)
  - Should to be installed in `~/.gnupg/` to be able to sign git commits with gpg
- SSH
  - Should to be installed in `~/.ssh` to be able to use your ssh config and keys.

## Container Image

### Docker Hub: stelligent/vscode-remote-cfn_nag

The main `.devcontainer/Dockerfile` points to the latest `stelligent/vscode-remote-cfn_nag` Docker Hub container image. This image is created and pushed by a separate GitHub Actions Workflow. It will tag the newly created image with the short git sha and `latest`.

### Build Dockerfile

The `stelligent/vscode-remote-cfn_nag` container image is build and controlled by the `.devcontainer/build/Dockerfile`

From within this file we are starting from the official Ruby 2.5 image and then going through and installing and configuring the necessary items for the remote build environment.

Some important items to note here:
* Installs the `docker` cli so that the `rake` tasks can still run from within the remote development container environment.
* Installs gems needed for the project and vscode extensions.
* Creates a non-root user (`cfn_nag_dev`) and provides `sudo` access so that the user can run the `rake` tasks that call the `docker` cli.
* Creates a way for the `bash` command history to be saved between container runs.
* Sets up the GPG home directory and sets the `tty` so that you can still sign git commits inside the container.

## Container Settings

The VS Code Remote Development container settings are controlled from within the `.devcontainer/devcontainer.json` file.

Some important items to note here:
* Container Mount Consistency is set to `consistent` to avoid a lag or mismatch from files that are changed during code editing from inside the remote container environment.
* `DND_PWD` Environment Variable is created to help with the `rake` tasks that are executed while inside the remote container. The mount source needs to reference the local systems path from within the docker container.
* Mounts:
  * A volume is created and mounted to store the `bash` command line history from within the container. Now when you close the connection and reopen at a later date, you can still search for previously used commands as needed.
  * The Docker socket is mounted so that you can still run `docker` commands from within the remote container environment.
  * If it exists, your local ssh directory (`~/.ssh`) is mounted so that you still access your config and sshkeys to be able to connect to github with key authentication.
  * If it exists, your local gpg items (`~/.gnupg`) are mounted so that you can still sign your commits and tags from within the remote container.
* Several vscode extensions are installed to help the user jumping right into project development. These extensions also have custom configured settings to work within the remote container environment.
* Runs `bundle install` so that everything is fully setup for the user before they get logged into the connection. The user can simply just run the `rake` commands without needing to set anything else up.
