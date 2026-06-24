# Artemis Apptainer

[![English](https://img.shields.io/badge/lang-English-lightgrey.svg)](README.md)
[![日本語](https://img.shields.io/badge/lang-日本語-blue.svg)](README.ja.md)

[Artemis](https://github.com/artemis-dev/artemis) を動かすための [Apptainer](https://apptainer.org/) コンテナ環境。

## ソフトウェアバージョン

- ROOT: 6.34.00 (Ubuntu 24.04)
- Artemis: master ブランチ
- yaml-cpp: 0.7.0

## イメージのビルド

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
