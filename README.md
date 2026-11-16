# Artemis Apptainer

[![English](https://img.shields.io/badge/lang-English-blue.svg)](README.md)
[![日本語](https://img.shields.io/badge/lang-日本語-lightgrey.svg)](README.ja.md)
[![ghcr.io](https://img.shields.io/badge/ghcr.io-artemis__apptainer-2496ED?logo=github)](https://github.com/yano404/artemis_apptainer/pkgs/container/artemis_apptainer)

[Apptainer](https://apptainer.org/) container environment for running [Artemis](https://github.com/artemis-dev/artemis).

## Software versions

- ROOT: 6.34.00 (Ubuntu 24.04)
- Artemis: commit [`966a83f`](https://github.com/artemis-dev/artemis/commit/966a83f93869254a17263b1db64186d55b15f048) (2025-10-31)
- yaml-cpp: 0.7.0

The exact pinned versions are also recorded as image labels (`apptainer inspect artemis.sif`).

## Pull the pre-built image

Pre-built images are published to the GitHub Container Registry:

```bash
apptainer pull oras://ghcr.io/yano404/artemis_apptainer:latest
```

| Tag | Meaning |
|---|---|
| `latest` | Newest build |
| `root6.34.00` | Newest build on the ROOT 6.34.00 line |
| `root6.34.00-artemis2025.10.31-966a83f` | Immutable, fully pinned build |

## Building the image

If you prefer to build it yourself instead of pulling:

```bash
apptainer build --fakeroot artemis.sif artemis.def
```

The build takes several tens of minutes. The defaults in the `%arguments`
section of `artemis.def` reproduce the pinned image.

To build another ROOT or Artemis version without editing `artemis.def`, use
`build.sh`. It reads its defaults from `artemis.def`, names the output after
the project tag (`artemis-root<ROOT>-artemis<date>-<short-sha>.sif`), and
prints the `git tag` command to publish that exact pin:

```bash
./build.sh                                   # pinned defaults
./build.sh --root-tag 6.36.00-ubuntu24.04 --root-version 6.36.00 \
           --artemis-ref <sha> --artemis-date <yyyy-mm-dd>
./build.sh --dry-run                         # show the resolved values only
```

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
