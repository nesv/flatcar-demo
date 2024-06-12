# flatcar-demo

Prepared demo for the [Flatcar Office Hours on Wednesday, June 12 2024][1].

## Setup

Install [devbox][devbox] &mdash; this will provide all of the tooling required
to run the _Steps_ outlined below.
After devbox is installed, run

```sh
devbox shell
```

to start a new shell with an updated `$PATH` that puts the devbox-installed
tools before anything provided by your system.

> [!NOTE]
> If you would prefer to not use devbox, you will need to install the following:
>  
> - [**linode-cli**][linode-cli] for interacting with the Linode API from the comfort of your own terminal;
> - [**GNU make**][gnu-make] for running the canned instructions to get a running Flatcar Linode;
> - [**curl**][curl] for retrieving the specially-patched OS image;
> - [**jq**][jq] for extracting information from the Linode API responses;
> - The [**butane**][butane-cli] configuration transpiler for converting `butane.yaml` into an `ignition.json` file for configuring your Flatcar Linode at first boot.

Once you have the Linode CLI installed, you will need to configure it.
This will perform a web-based flow that will log you in through your web
browser, and provision a personal access token:

```sh
linode-cli configure
```

Create an SSH key that can be used to log in to your Flatcar Linode, once it is
up and running:

```sh
ssh-keygen -t ed25519 -f id_ed25519
```

Now open `butane.yaml` in your preferred text editor, and add the _public SSH
key_ to the `ssh_authorized_keys` list for the `core` user:

```yaml
passwd:
  users:
    - name: core
      ssh_authorized_keys:
        - "ssh-ed25519 ..."
```

then save the file, and exit the text editor.

At this point you are ready to go on to launch your first Linode running Flatcar
Container Linux!

## Steps

1. `make upload-image` &mdash; will retrieve the custom OS image built and
   provided by Flatcar, containing (now-upstreamed) patches to Ignition and
   Afterburn, that allow it to boot on Akamai/Linode.
1. `make instance` &mdash; creates a Linode instance that _is not booted_.
1. `make instance-disk` &mdash; creates the boot disk for the Linode instance,
   from the Flatcar image that was uploaded in step 1.
1. `make instance-config` &mdash; creates an instance configuration to associate
   the boot disk with the instance.
1. `linode linodes boot "$(make instance-id)"` &mdash; boots the Linode
   instance!

At this point, you can either use the Linode CLI or the [Cloud
Manager](https://cloud.linode.com/) to retrieve the public IP address for your
new `flatcar-demo` instance.
If you go to that IP address into your web browser, you will be greeted with a
very basic web page displaying the name ("label") of your Linode instance.

## Cleaning up

When you are done with this Linode instance, run

```sh
make destroy
```

to stop and delete the Linode instance.

[1]: https://github.com/flatcar/Flatcar/discussions/1443
[linode-cli]: https://www.linode.com/docs/products/tools/cli/guides/install/
[gnu-make]: https://www.gnu.org/software/make/
[curl]: https://curl.se/
[jq]: https://jqlang.github.io/jq/
[butane-cli]: https://www.flatcar.org/docs/latest/provisioning/config-transpiler/
[devbox]: https://www.jetify.com/devbox
