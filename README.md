# personal_kitchen

Use [chef][chef] to configure your users on various computers.

You can manage nodes locally or over a network.

[chef]: https://www.chef.io/

# Overview

There are three independent modules:

* system - manages system services,
* shell - manages shell configuration and command line programs,
* desktop - manages the desktop and GUI programs.

# Getting Started

## Create a `pass` store repository

`personal_kitchen` relies heavily on [`pass`][pass-site] the "the standard
unix password manager".

Your `pass` store needs to be backed up un a remote git repostiory. So, before
bootstrapping your personal kitchen, you'll need to set up a private
git repository, e.g. on GitLab or Bitbucket.

## Install

```shell
$ gem install personal_kitchen
```

## Bootstrap the kitchen

```shell
$ personal_kitchen bootstrap my-kitchen
```

This creates a directory `my-kitchen` with all the necessary initial setup.
Obviuosly, you can call it whatever you like.

During bootstrap, a new ssh key for access to your pass repo will be generated.
You should set up this key as a deployment key (e.g. under "Settings" ->
"Access keys" for BitBucket repos).

You will also asked for a few defaults, such as the username you normally use.

## Create a Repository for your Personal Kitchen

Create a private repository, add all the repo's changes and push.

# Add a node

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


## Node Specific

# Updating

## What's Changed

Even if you never manaually change you're computer's configuration, some
configurations can change for other reasons: i.e. you log in to a remote
system and a local file records your access token.

So, before you deploy, it's always a good idea to check what will change
and, update your pass repo, if necessary to avoid overwriting stuff.

### Local node

```shell
$ sudo chef-client --why-run --local-mode --json-attributes nodes/$HOSTNAME.json
```

### Remote mode

```shell
$ knife solo cook --why-run root@$HOSTNAME
```

## Deploying

# How It Works

## Secrets

A user's computer configuration requires handling of a number of secrets, such
as SSH private keys and access tokens.

There are three levels of secrets:

* a data bag key that must be managed separately and is the key to the whole
system,
* the kitchen's data bag,
* a `pass` store.

### Data bag key

When your personal kitchen is bootstrapped, a random data bag key is generated.
You should copy this key to a safe place.

Store this key on two (or more) USB thumb drives, and keep them in two or
more safe, separate, locations.

### The data bag

The kitchen contains a single data bag `data_bags/personal_kitchen/bootstrap`
with the minimum bootstrap secrets:

* the URL of your pass store repository,
* the GPG key used to access the store,
* the ssh key used to access the repository.

### The pass store

You can use the pass store as your day-to-day password manager, but a couple
of keys under `personal_kitchen` are required.

* personal_kitchen/user

# Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/joeyates/personal_kitchen.

# License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).

