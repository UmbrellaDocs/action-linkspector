#!/bin/sh
set -e

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

echo '::group::🔗💀 Installing linkspector ... https://github.com/UmbrellaDocs/linkspector'
npm install -g @umbrelladocs/linkspector@0.3.13
echo '🔗💀 linkspector version:'
linkspector --version
echo '::endgroup::'

echo '::group::🔗💀 Setting up Chrome Linux Sandbox'
# Based on the instructions found here: https://chromium.googlesource.com/chromium/src/+/main/docs/security/apparmor-userns-restrictions.md
if [ "$(lsb_release -rs)" = "24.04" ]; then
  echo 0 | sudo tee /proc/sys/kernel/apparmor_restrict_unprivileged_userns
  echo 'Done'
fi

echo '::endgroup::'

echo '::group:: Running linkspector with reviewdog 🐶 ...'
linkspector check -c "${INPUT_CONFIG_FILE}" -j |
  reviewdog -f=rdjson \
    -name="${INPUT_TOOL_NAME}" \
    -reporter="${INPUT_REPORTER}" \
    -filter-mode="${INPUT_FILTER_MODE}" \
    -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
    -level="${INPUT_LEVEL}" \
    "${INPUT_REVIEWDOG_FLAGS}"
exit_code=$?
echo '::endgroup::'
exit $exit_code
