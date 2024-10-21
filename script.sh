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
# Based on the recommendation from https://pptr.dev/troubleshooting#recommended-enable-user-namespace-cloning
if [ "$(lsb_release -rs)" = "24.04" ]; then
  sudo sysctl -w kernel.unprivileged_userns_clone=1
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
