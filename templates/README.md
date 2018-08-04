# Local installation

Under `nodes`, create a file whose name is the computer's
hostname + '.json'

Check what will change:

```
$ berks vendor cookbooks
$ sudo chef-client --why-run --local-mode --json-attributes nodes/$HOSTNAME.json
```

Deploy:

```
$ berks vendor cookbooks
$ sudo chef-client --local-mode --json-attributes nodes/$HOSTNAME.json
```

# Remote

```
$ knife solo cook --no-chef-check root@$HOSTNAME
```
