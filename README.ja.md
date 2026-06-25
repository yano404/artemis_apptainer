# Artemis Apptainer

[![English](https://img.shields.io/badge/lang-English-lightgrey.svg)](README.md)
[![日本語](https://img.shields.io/badge/lang-日本語-blue.svg)](README.ja.md)
[![ghcr.io](https://img.shields.io/badge/ghcr.io-artemis__apptainer-2496ED?logo=github)](https://github.com/yano404/artemis_apptainer/pkgs/container/artemis_apptainer)

[Artemis](https://github.com/artemis-dev/artemis) を動かすための [Apptainer](https://apptainer.org/) コンテナ環境。

## ソフトウェアバージョン

- ROOT: 6.34.00 (Ubuntu 24.04)
- Artemis: commit [`966a83f`](https://github.com/artemis-dev/artemis/commit/966a83f93869254a17263b1db64186d55b15f048) (2025-10-31)
- yaml-cpp: 0.7.0

固定した正確なバージョンはイメージのラベルにも記録されています（`apptainer inspect artemis.sif`）。

## ビルド済みイメージの取得

ビルド済みイメージを GitHub Container Registry で配布しています。

```bash
apptainer pull oras://ghcr.io/yano404/artemis_apptainer:latest
```

| タグ | 意味 |
|---|---|
| `latest` | 全体の最新ビルド |
| `root6.34.00` | ROOT 6.34.00 系列の最新ビルド |
| `root6.34.00-artemis2025.10.31-966a83f` | 完全固定の不変ビルド（再現用） |

## イメージのビルド

自分でビルドする場合は以下のとおりです。

```bash
apptainer build --fakeroot artemis.sif artemis.def
```

ビルドには数十分かかります。

## 使い方

### インタラクティブシェル

```bash
apptainer shell artemis.sif
```

### 解析ディレクトリをマウントして使う

```bash
apptainer shell --bind /path/to/analysis artemis.sif
```

コンテナ内で通常通り artemis を起動します。

```
artemis
```

### マクロを直接実行

```bash
apptainer exec artemis.sif artemis -b -q your_macro.C
```

### X11 フォワーディングあり（SSH -X / VNC 環境）

```bash
apptainer shell --bind /tmp/.X11-unix artemis.sif
```

## 環境変数

コンテナ内では以下が自動で設定されます。

| 変数 | 値 |
|---|---|
| `ARTEMIS_HOME` | `/opt/artemis` |
| `ROOTSYS` | `/opt/root` (base image より) |
| `PATH` | `$ARTEMIS_HOME/bin` を含む |
| `LD_LIBRARY_PATH` | `/usr/local/lib`, `$ARTEMIS_HOME/lib` を含む |

## ユーザー設定ファイル

Artemis の動作は以下のファイルで制御します（コンテナ外で用意し、`--bind` でマウントしてください）。

| ファイル | 用途 |
|---|---|
| `artemislogon.C` | 起動時に自動実行されるマクロ |
| `.rootrc` | ROOT/Artemis の設定（`Art.MassTable` など） |

例：

```bash
apptainer shell --bind /path/to/analysis:/work artemis.sif
# コンテナ内
cd /work
artemis
```
