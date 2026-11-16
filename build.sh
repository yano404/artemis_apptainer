#!/usr/bin/env bash
#
# Build a version-pinned Artemis Apptainer image.
#
# Defaults are read from the %arguments section of artemis.def, so there is a
# single source of truth for the pinned versions. Override any of them with a
# flag (or an environment variable of the same name) to build a different ROOT
# or Artemis without editing the def file.
#
# The output filename and the ghcr image/git tag follow the project convention:
#   root<ROOT_VERSION>-artemis<DATE-with-dots>-<short-sha>
# e.g. root6.34.00-artemis2025.10.31-966a83f
#
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEF="${SCRIPT_DIR}/artemis.def"

usage() {
  cat <<'EOF'
Usage: build.sh [options]

Options:
  --root-tag TAG        ROOT base image tag       (default: from artemis.def)
  --root-version VER    ROOT version for labels   (default: from artemis.def)
  --yaml-cpp VER        yaml-cpp version          (default: from artemis.def)
  --artemis-ref SHA     Artemis commit to pin     (default: from artemis.def)
  --artemis-date DATE   Artemis commit date       (default: from artemis.def)
  -o, --output FILE     Output .sif path          (default: artemis-<tag>.sif)
      --force           Overwrite an existing .sif
      --print-tag       Print the derived tag and exit (no build)
  -n, --dry-run         Print resolved values + build command, do not build
  -h, --help            Show this help

Each version option may also be set via an environment variable of the same
name, e.g. ARTEMIS_REF=<sha> build.sh
EOF
}

# Read a KEY=VALUE default from the %arguments block of the def file.
def_default() {
  awk -v key="$1" '
    /^%arguments/ { inblk=1; next }
    /^%/ && inblk { inblk=0 }
    inblk {
      sub(/^[[:space:]]+/, "")
      if ($0 ~ "^" key "=") { sub("^" key "=", ""); print; exit }
    }' "$DEF"
}

# Defaults: environment variable, else the def's %arguments value.
ROOT_TAG="${ROOT_TAG:-$(def_default ROOT_TAG)}"
ROOT_VERSION="${ROOT_VERSION:-$(def_default ROOT_VERSION)}"
YAML_CPP_VERSION="${YAML_CPP_VERSION:-$(def_default YAML_CPP_VERSION)}"
ARTEMIS_REF="${ARTEMIS_REF:-$(def_default ARTEMIS_REF)}"
ARTEMIS_DATE="${ARTEMIS_DATE:-$(def_default ARTEMIS_DATE)}"

OUTPUT=""
FORCE=0
DRY_RUN=0
PRINT_TAG=0

while [ $# -gt 0 ]; do
  case "$1" in
    --root-tag)      ROOT_TAG="$2"; shift 2 ;;
    --root-version)  ROOT_VERSION="$2"; shift 2 ;;
    --yaml-cpp)      YAML_CPP_VERSION="$2"; shift 2 ;;
    --artemis-ref)   ARTEMIS_REF="$2"; shift 2 ;;
    --artemis-date)  ARTEMIS_DATE="$2"; shift 2 ;;
    -o|--output)     OUTPUT="$2"; shift 2 ;;
    --force)         FORCE=1; shift ;;
    --print-tag)     PRINT_TAG=1; shift ;;
    -n|--dry-run)    DRY_RUN=1; shift ;;
    -h|--help)       usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

# Derive the project tag: root<ver>-artemis<date-with-dots>-<short-sha>
SHORT_SHA="${ARTEMIS_REF:0:7}"
TAG="root${ROOT_VERSION}-artemis${ARTEMIS_DATE//-/.}-${SHORT_SHA}"

if [ "$PRINT_TAG" -eq 1 ]; then
  echo "$TAG"
  exit 0
fi

OUTPUT="${OUTPUT:-${SCRIPT_DIR}/artemis-${TAG}.sif}"

BUILD_FLAGS=(--fakeroot)
[ "$FORCE" -eq 1 ] && BUILD_FLAGS+=(--force)

cat <<EOF
Building Artemis image
  ROOT_TAG          = ${ROOT_TAG}
  ROOT_VERSION      = ${ROOT_VERSION}
  YAML_CPP_VERSION  = ${YAML_CPP_VERSION}
  ARTEMIS_REF       = ${ARTEMIS_REF}
  ARTEMIS_DATE      = ${ARTEMIS_DATE}
  tag               = ${TAG}
  output            = ${OUTPUT}
EOF

CMD=(apptainer build "${BUILD_FLAGS[@]}"
  --build-arg "ROOT_TAG=${ROOT_TAG}"
  --build-arg "ROOT_VERSION=${ROOT_VERSION}"
  --build-arg "YAML_CPP_VERSION=${YAML_CPP_VERSION}"
  --build-arg "ARTEMIS_REF=${ARTEMIS_REF}"
  --build-arg "ARTEMIS_DATE=${ARTEMIS_DATE}"
  "${OUTPUT}" "${DEF}")

if [ "$DRY_RUN" -eq 1 ]; then
  printf '\nDry run, would execute:\n'
  printf '  %q' "${CMD[@]}"
  printf '\n'
  exit 0
fi

echo
"${CMD[@]}"
echo
echo "Built ${OUTPUT}"
echo "To publish this exact pin, tag the repo and push:"
echo "  git tag ${TAG} && git push origin ${TAG}"
