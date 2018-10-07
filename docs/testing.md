# Test your kitchen

# Setup

First, install ChefDK

# Environment

Instead of adding ChefDK config permanentyl to your shell,
you can activate it as and when you need it:

```shell
$ eval "$(chef shell-init bash)"
```

# Run Tests

```shell
$ vagrant up --provision
```

Stop vagrant:

```
$ vagrant halt
```

# Protip: Create a snapshot with just Chef installed

In libvirt, your virtual machines ("domains") will be called
directory + `_default`

1. empty out Berksfile
2. remove any `chef.add_recipe` from Vagrantfile
3. vagrant up
5. vagrant halt
4. virsh snapshot-create-as --domain <domain> --name with-chef

Use the snapshot:

1. restore Berksfile
2. restore Vagrantfile
3. virsh snapshot-revert --domain <domain> --snapshotname with-chef
4. vagrant up --provision
5. vagrant halt

...repeat 3-5 while developing
