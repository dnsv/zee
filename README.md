# Zee

Zee is a shell extension for defining shortcuts for quicker file system navigation.

Similar tools exist that offer a smarter `cd` command by setting up shortcuts based on the directories you most frequently use. However, when dealing with multiple directories that start with the same letter, these shortcuts can inadvertently change their paths, leading to unwanted destination changes. In contrast, Zee takes a simplified approach by only utilizing explicit user-defined shortcuts.

## Installation

```console
curl -sSL https://raw.githubusercontent.com/dnsv/zee/main/install.sh | bash
```

## Usage

```shell
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
