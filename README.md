# Zee

Zee is a shell extension for defining shortcuts for quicker file system navigation.

**Why Zee?**

Similar tools exist that offer a smarter `cd` command by setting up shortcuts based on the directories you most frequently use. However, when dealing with multiple directories that start with the same letter, these shortcuts can inadvertently change their paths, leading to unwanted destination changes. In contrast, Zee takes a simplified approach by only utilizing explicit user-defined shortcuts.

## Installation

### Install the Binary

To install Zee, run the following command:

```console
curl -sSL https://raw.githubusercontent.com/dnsv/zee/main/install.sh | bash
```

### Configure Zee for Your Shell

After installation, add the following command to your shell config file. Zee will then be available through the `z` command.

_After updating your shell configuration file, remember to run `source <your_shell_config_file>` or restart your terminal to apply the changes._

#### For Bash (`~/.bashrc`) or Zsh (`~/.zshrc`)

```console
eval "$(zee init bash)"
```

#### For Fish (`~/.config/fish/config.fish`)

```console
zee init fish | source
```

## Usage

```console
# Add a shortcut
$ z add d ~/Downloads

# List all shortcuts
$ z list
d  →  ~/Downloads

# cd to ~/Downloads
$ z d

# Remove a shortcut
$ z remove d
```
