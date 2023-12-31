# `home_cooking`

Configure your environment on various computers.

You create a [chef][chef] project or "kitchen" to manage your user setup on
various computers.

You can manage your local computer, or a desktop or server over a network.

# Why?

Setting up a computer is a pain - you have to install various programs,
maybe clone your dot-files repo and copy a whole load of secrets.

This project aims to unify all of those activities.

# Why the corny name?

I couldn't resist.

# Overview

## One Root Key

The key to the whole `home_cooking` system is the data bag key (see below).
You'll need to keep it in a safe place.

## A Repo

You'll need to create a Git repo for your personal kitchen.

When you set up a computer, you need to be able to access the repo of your
personal kitchen. You either do this by pushing the deploy from another
computer over the network, or, if you're starting from scratch you'll need
to clone the repo and deploy to the computer itself.

## Three Modules

There are three independent cookbooks:

* system - manages system services,
* shell - manages shell configuration and command line programs,
* desktop - manages the desktop and GUI programs.

For each, you can specify programs to install and configurations to set.

# Install

```shell
$ gem install home_cooking
```

# How It Works

# Create your Personal Kitchen

### Create a Git Repository for your Personal Kitchen

Create a private Git repository (i.e. on GitLab or BitBucket), where you can
keep your personal kitchen.

## Creation

```shell
$ home_cooking init --path my-kitchen
```

This creates a directory `my-kitchen` with all the necessary initial setup.
Obviously, you can call it whatever you like.

# Set Some Defaults

```shell
$ home_cooking defaults
```

This command allows you to set up default values to be used across all nodes.

Defaults are stored in your data bags under `personal/user`.

Defaults are:

* `user/name`
* `user/group` - on Linux systems, defaults to the same value as `user/name`,
  on macOS, defaults to `wheel`,
* `user/shell` - defaults to `/bin/bash`,
* `user/locales` - defaults to `[]`.

# Manage Secret Files

Use the provided `home_cooking` program to list, add, remove and dump
files to be installed.

# Add a Node

## Preparation

You'll need to specify the host name.

If the node is the computer you're using, you can use hostname + ".local",
e.g. 'joes-computer.local'.

If you want to manage a remote computer, you'll need it's fully-qualified name,
e.g. `joes-computer.example.com` or, failing that, its IP address.

## Create the Base Configuration

```shell
$ home_cooking add-node {{hostname}}
```

You will be asked for the user name, group, etc.

# Configuration

As much as possible, configuration should be kept in your personal kitchen's
attributes. These are the configurations that are shared between all of the
computers you use.

Everything that is host ("node") specific, should go in the node configuration
file (under `nodes`).

# Associated Software

* pass

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

A [chef][chef] kitchen is generated with basic setup.

[chef]: https://www.chef.io/

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

### The `pass` Store

Use `pass` as your password store, and commit and push changes to your remote
repo.

# Similar Software

* https://github.com/boxen
* https://github.com/Microsoft/macos-cookbook

# Contributing

Bug reports and pull requests are welcome on GitHub at
https://gitlab.com/joeyates/home_cooking.

# License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
