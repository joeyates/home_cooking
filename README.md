# `personal_kitchen`

Use [chef][chef] to configure your accounts on various computers.

You can manage your local computer, or a desktop or server over a network.

[chef]: https://www.chef.io/

# Overview

## One Root Key

The key to the whole `personal_kitchen` system is the data bag key (see below).
You'll need to keep it in a safe place.

## Two Repos

You'll need to create two Git repos: one for your personal kitchen and one for
your passwords, as is explained below.

When you set up a computer, you need to be able to access the repo of your
personal kitchen. You either do this by pushing the deploy from another
computer over the network, or, if you're starting from scratch you'll need
to clone the repo and deploy to the computer itself.

## Three Modules

There are three independent modules:

* system - manages system services,
* shell - manages shell configuration and command line programs,
* desktop - manages the desktop and GUI programs.

For each, you can specify programs to install and configurations to set.

## Secrets

Every computer user should have a password manager for Internet passwords,
SSH private keys, access tokens and the like.

`personal_kitchen` installs, and relies heavily on, [`pass`][pass]
"the standard unix password manager".

Please also use `pass` as your personal password manager - that way you'll have
everything in the same place!

[pass]: https://www.passwordstore.org/

# Install

```shell
$ gem install personal_kitchen
```

# Preparation

## Create a Git Repository for your Personal Kitchen

Create a private Git repository (i.e. on GitLab or BitBucket), where you can
keep your personal kitchen.

## Create a Git Repository for your `pass` Store

Your `pass` store needs to be backed up on a remote Git repostiory. So, before
bootstrapping your personal kitchen, you'll need to set up a private
Git repository for it.

# Create your Personal Kitchen

```shell
$ personal_kitchen init my-kitchen
```

This creates a directory `my-kitchen` with all the necessary initial setup.
Obviously, you can call it whatever you like.

During bootstrap, a new SSH key for access to your `pass` repo will be
generated.
You should set up this key as a deployment key (e.g. under "Settings" ->
"Access keys" for BitBucket repos).

`pass` uses a GPG key to encrypt passwords. By default, `personal_kitchen`
creates a new GPG key specifically for `pass`.

### Warning for Users with Existing GPG Keyrings

If you already have GPG set up, you'll probably be intending to save your
keyring in your `pass` store. Unfortunately, this creates a chicken-and-egg
situation: bootstrapping your kitchen requires the GPG key to be available
right from the start.

To get around this problem, you'll need to do the following:

* choose an existing GPG secret key in your keyring, or add a new one specially
  for `pass`,
* export an ASCII armored file with the key:

```shell
$ TODO
```

* Pass the key to `init`:

```shell
$ personal_kitchen init my-kitchen --gpg-key mykey
```

# Set Some Defaults

```shell
$ personal-kitchen defaults
```

This command allows you to set up default values to be used across all nodes.

Defaults are stored in your `pass` repository under `personal_kitchen/user`.

Defaults are:

* `user/name`
* `user/group` - on Linux systems, defaults to the same value as `user/name`,
  on macOS, defaults to `wheel`,
* `user/shell` - defaults to `/bin/bash`,
* `user/locales` - defaults to `[]`.

# Add a Node

## Preparation

You'll need to specify the host name.

If the node is the computer you're using, you can use hostname + ".local",
e.g. 'joes-computer.local'.

If you want to manage a remote computer, you'll need it's fully-qualified name,
e.g. `joes-computer.example.com` or, failing that, its IP address.

## Create the Base Configuration

```shell
$ personal-kitchen add-node {{hostname}}
```

You will be asked for the user name, group, etc.

# Configuration

As much as possible, configuration should be kept in your personal kitchen's
attributes. These are the configurations that are shared between all of the
computers you use.

Everything that is host ("node") specific, should go in the node configuration
file (under `nodes`).

Everything that is secret or sensitive, should go in your `pass` store.

## Default/Global

TODO

## Node Specific

TODO

# Updating

## What's Changed

Even if you never manaually change you're computer's configuration, some
configurations can change for other reasons: i.e. you log in to a remote
system and a local file records your access token.

So, before you deploy, it's always a good idea to check what will change
and, update your `pass` repo, if necessary to avoid overwriting stuff.

### Local Mode

```shell
$ sudo chef-client --why-run --local-mode --json-attributes nodes/$HOSTNAME.json
```

### Remote Mode

```shell
$ knife solo cook --why-run root@$HOSTNAME
```

## Deploying

### Local Mode

```shell
$ sudo chef-client --local-mode --json-attributes nodes/$HOSTNAME.json
```

### Remote Mode

```shell
$ knife solo cook root@$HOSTNAME
```

# How It Works

## Secrets

There are three levels of secrets:

* a data bag key, '/data_bag_key' that must be managed separately and is the
  key to the whole system,
* the kitchen's data bag,
* a `pass` store.

### The Data Bag Key

When your personal kitchen is bootstrapped, a random data bag key is generated.
You should copy this key to a safe place.

Store this key on two (or more) USB thumb drives, and keep them in two safe,
separate, locations.

### The Data Bag

Initially, the kitchen contains a single data bag
`data_bags/personal_kitchen/bootstrap` with the minimum bootstrap secrets:

* the URL of your `pass` store repository,
* the GPG key used to encrypt data in the store,
* the SSH key used to access the repository.

### The `pass` Store

Use `pass` as your password store, and commit and push changes to your remote
repo.
That said, please don't touch the keys under `personal_kitchen` as they are
needed to make `personal_kitchen` work!

# Contributing

Bug reports and pull requests are welcome on GitHub at
https://gitlab.com/joeyates/personal_kitchen.

# License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
