#!/bin/sh
set -e

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

# If the user has already set PUPPETEER_EXECUTABLE_PATH, respect it and skip
# all Chromium setup.
if [ -n "${PUPPETEER_EXECUTABLE_PATH}" ]; then
  echo "Using user-provided Chromium at ${PUPPETEER_EXECUTABLE_PATH}"
else

USE_SYSTEM_CHROMIUM=false

# Puppeteer's bundled Chromium does not support arm64 Linux.
if [ "$(uname -m)" = "aarch64" ]; then
  USE_SYSTEM_CHROMIUM=true
fi

# On Ubuntu 24.04, AppArmor restricts unprivileged user namespaces which
# Chromium's sandbox requires. Try to disable the restriction; if we can't
# (e.g. self-hosted runners without the sysctl), fall back to system Chromium
# which ships with proper AppArmor profiles.
# Reference: https://chromium.googlesource.com/chromium/src/+/main/docs/security/apparmor-userns-restrictions.md
if [ "${USE_SYSTEM_CHROMIUM}" = "false" ] && command -v lsb_release >/dev/null 2>&1 && [ "$(lsb_release -rs)" = "24.04" ]; then
  if [ -f /proc/sys/kernel/apparmor_restrict_unprivileged_userns ]; then
    echo '::group::🔗💀 Setting up Chrome Linux Sandbox'
    echo 0 | sudo tee /proc/sys/kernel/apparmor_restrict_unprivileged_userns
    echo 'Done'
    echo '::endgroup::'
  else
    USE_SYSTEM_CHROMIUM=true
  fi
fi

if [ "${USE_SYSTEM_CHROMIUM}" = "true" ]; then
  echo '::group::🔗💀 Installing system Chromium'
  echo "Reason: $(uname -m) runner or missing AppArmor sysctl"

  # Check if Chromium is already installed
  EXISTING_CHROMIUM=""
  for bin in chromium-browser chromium google-chrome-stable google-chrome; do
    if command -v "${bin}" >/dev/null 2>&1; then
      EXISTING_CHROMIUM="$(which "${bin}")"
      break
    fi
  done

  if [ -n "${EXISTING_CHROMIUM}" ]; then
    echo "System Chromium already installed at ${EXISTING_CHROMIUM} — skipping installation"
  elif command -v apt-get >/dev/null 2>&1; then
    # Debian, Ubuntu
    sudo apt-get update -qq
    sudo apt-get install -y -qq chromium-browser || sudo apt-get install -y -qq chromium
  elif command -v dnf >/dev/null 2>&1; then
    # Fedora, RHEL 8+, CentOS Stream
    sudo dnf install -y chromium
  elif command -v yum >/dev/null 2>&1; then
    # RHEL 7, older CentOS
    sudo yum install -y chromium
  elif command -v apk >/dev/null 2>&1; then
    # Alpine
    sudo apk add --no-cache chromium
  elif command -v zypper >/dev/null 2>&1; then
    # openSUSE, SLES
    sudo zypper install -y chromium
  elif command -v pacman >/dev/null 2>&1; then
    # Arch
    sudo pacman -S --noconfirm chromium
  else
    echo '::error::Could not detect package manager. Please install Chromium manually and set PUPPETEER_EXECUTABLE_PATH.'
    exit 1
  fi

  export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
  # Find the Chromium binary — name varies by distro
  for bin in chromium-browser chromium google-chrome-stable google-chrome; do
    if command -v "${bin}" >/dev/null 2>&1; then
      PUPPETEER_EXECUTABLE_PATH="$(which "${bin}")"
      break
    fi
  done
  export PUPPETEER_EXECUTABLE_PATH

  if [ -z "${PUPPETEER_EXECUTABLE_PATH}" ]; then
    echo '::error::Chromium was installed but the binary was not found in PATH.'
    exit 1
  fi

  echo "Using system Chromium at ${PUPPETEER_EXECUTABLE_PATH}"
  echo '::endgroup::'
fi

fi # end PUPPETEER_EXECUTABLE_PATH check

echo '::group::🔗💀 Installing linkspector ... https://github.com/UmbrellaDocs/linkspector'
npm install -g @umbrelladocs/linkspector@0.5.2
echo '🔗💀 linkspector version:'
linkspector --version
echo '::endgroup::'

echo '::group:: Running linkspector with reviewdog 🐶 ...'
linkspector check -c "${INPUT_CONFIG_FILE}" -j |
  reviewdog -f=rdjson \
    -name="${INPUT_TOOL_NAME}" \
    -reporter="${INPUT_REPORTER}" \
    -filter-mode="${INPUT_FILTER_MODE}" \
    -fail-level="${INPUT_FAIL_LEVEL}" \
    -level="${INPUT_LEVEL}" \
    "${INPUT_REVIEWDOG_FLAGS}"
exit_code=$?
echo '::endgroup::'

if [ "${INPUT_SHOW_STATS}" = "true" ]; then
  echo '::group:: Running linkspector stats ...'
  linkspector check -c "${INPUT_CONFIG_FILE}" -s || true
  echo '::endgroup::'
fi

exit $exit_code
