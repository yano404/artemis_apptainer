# Artemis Apptainer

[Apptainer](https://apptainer.org/) container environment for running [Artemis](https://github.com/artemis-dev/artemis).

## Software versions

- ROOT: 6.34.00 (Ubuntu 24.04)
- Artemis: master branch
- yaml-cpp: 0.7.0

## Building the image

```bash
apptainer build --fakeroot artemis.sif artemis.def
```

The build takes several tens of minutes.

## Usage

### Interactive shell

```bash
apptainer shell artemis.sif
```

### Mount your analysis directory

```bash
apptainer shell --bind /path/to/analysis artemis.sif
```

Then start artemis inside the container as usual.

```
artemis
```

### Run a macro directly

```bash
apptainer exec artemis.sif artemis -b -q your_macro.C
```

### With X11 forwarding (SSH -X / VNC)

```bash
apptainer shell --bind /tmp/.X11-unix artemis.sif
```

## Environment variables

The following are set automatically inside the container.

| Variable | Value |
|---|---|
| `ARTEMIS_HOME` | `/opt/artemis` |
| `ROOTSYS` | `/opt/root` (from base image) |
| `PATH` | includes `$ARTEMIS_HOME/bin` |
| `LD_LIBRARY_PATH` | includes `/usr/local/lib` and `$ARTEMIS_HOME/lib` |

## User configuration files

Artemis behaviour is controlled by the following files. Prepare them outside the container and mount them with `--bind`.

| File | Purpose |
|---|---|
| `artemislogon.C` | Macro executed automatically at startup |
| `.rootrc` | ROOT/Artemis settings (e.g. `Art.MassTable`) |

Example:

```bash
apptainer shell --bind /path/to/analysis:/work artemis.sif
# inside the container
cd /work
artemis
```
