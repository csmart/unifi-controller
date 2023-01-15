# Unifi Controller

Build a Debian based container to run the Ubiquiti Unifi Controller from
official repositories.

It is designed to run as a rootless container with `podman`, meaning it's run
as an unprivileged user on the host but as `root` inside the container.

This uses `systemd` inside the container to manage the MongoDB database service
as well as the controller itself.

The Unifi Controller is hard-coded to depend on MongoDB version `4`, however
this is no-longer supported on Debian. Version `5` does seem to run fine, so
this container includes a packaging hack to remove the dependency.

## Build container

Use `podman` to build the container from inside this repo.

```bash
cd unifi-controller
podman build -t unifi .
```

## Create volume for data

Create a volume to store the controller data and MongoDB database.

```bash
podman volume create unifi-data
```

You can inspect this volume, which will show information such as the path
(should you need it).

```bash
podman volume inspect unifi-data
```

## Running container

Run the container in detached mode, passing in the volume we created above and
using host networking (so that the controller can find devices).

```bash
podman run \
  --detach \
  --network=host \
  --volume unifi-data:/var/lib/unifi:z \
  --name unifi \
  localhost/unifi
```

### Set up controller

This should run a TLS web server on your machine, listening on `*:8443`. Open
this URL in a browser (e.g. https://localhost:8443) in a web browser and
follow the instructions.

If you have a backup from a previous controller, restore it when prompted.

Otherwise, set up a new configuration.

You can choose not to connect it to the cloud by using Advanced configuration.
In this case, create a local account and rely on local backups and the
container data for persistency.

## Stopping the container

You can stop the container and start it again at any time.

```bash
podman stop unifi
podman start unifi
```

As the container runs MongoDB and the Unifi Controller as services inside the
container, you can also interact with them directly, if you want to.

```bash
podman exec unifi systemctl status unifi
podman exec unifi systemctl status mongod
```

## Deleting the container

You can delete the container at any time (data will not be lost).

```bash
podman rm --force unifi
```

If you delete the container, you'll need to run it again using [the commands
above](#running-container).

Remember, your data is stored in the `unifi-data` volume. If you run the
container again, all of your data should still be there and you can log in with
your existing credentials.

