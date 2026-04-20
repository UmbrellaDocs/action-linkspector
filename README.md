[![GitHub Marketplace](https://img.shields.io/badge/GitHub%20Marketplace-action%20linkspector-brightgreen?style=for-the-badge)](https://github.com/marketplace/actions/run-linkspector-with-reviewdog)
![GitHub Release](https://img.shields.io/github/v/release/UmbrellaDocs/action-linkspector?style=for-the-badge)
[![NPM](https://img.shields.io/npm/v/@umbrelladocs/linkspector?style=for-the-badge)](https://www.npmjs.com/package/@umbrelladocs/linkspector)
[![MCP](https://img.shields.io/badge/MCP%20Server-Linkspector_MCP-brightgreen?logo=modelcontextprotocol&style=for-the-badge)](https://github.com/UmbrellaDocs/linkspector-mcp)
<a href="https://liberapay.com/gaurav-nelson/donate"><img alt="Donate using Liberapay" src="https://liberapay.com/assets/widgets/donate.svg"></a>

# GitHub action: Run 💀Linkspector with 🐶Reviewdog

This action runs [Linkspector](https://github.com/UmbrellaDocs/linkspector) with [Reviewdog](https://github.com/reviewdog/reviewdog) on pull requests to improve the quality of your content.

## Used by

<table>
<tr>
<td align="center" width="150">
<a href="https://github.com/dotnet/source-build/blob/main/.github/workflows/check-markdown-links.yml">
<img src="https://github.com/dotnet.png" width="50" height="50" alt="dotnet" /><br />
<b>.NET</b><br />
<sub>source-build</sub>
</a>
</td>
<td align="center" width="150">
<a href="https://github.com/SAP/abap-file-formats/blob/main/.github/workflows/markdown-link-check.yml">
<img src="https://github.com/SAP.png" width="50" height="50" alt="SAP" /><br />
<b>SAP</b><br />
<sub>abap-file-formats</sub>
</a>
</td>
<td align="center" width="150">
<a href="https://github.com/open-telemetry/opentelemetry-ruby/blob/main/.github/workflows/ci-markdown-link.yml">
<img src="https://github.com/open-telemetry.png" width="50" height="50" alt="OpenTelemetry" /><br />
<b>OpenTelemetry</b><br />
<sub>opentelemetry-ruby</sub>
</a>
</td>
<td align="center" width="150">
<a href="https://github.com/finos/spring-bot/blob/spring-bot-master/.github/workflows/checklinks.yml">
<img src="https://github.com/finos.png" width="50" height="50" alt="FINOS" /><br />
<b>FINOS</b><br />
<sub>spring-bot</sub>
</a>
</td>
<td align="center" width="150">
<a href="https://github.com/dotnet/dotnet-docker/blob/main/.github/workflows/check-markdown-links.yml">
<img src="https://github.com/dotnet.png" width="50" height="50" alt="dotnet" /><br />
<b>.NET</b><br />
<sub>dotnet-docker</sub>
</a>
</td>
</tr>
<tr>
<td align="center" width="150">
<a href="https://github.com/Azure-Samples/azure-spring-boot-samples/blob/main/.github/workflows/markdown-link-check.yml">
<img src="https://github.com/Azure-Samples.png" width="50" height="50" alt="Azure" /><br />
<b>Azure</b><br />
<sub>spring-boot-samples</sub>
</a>
</td>
<td align="center" width="150">
<a href="https://github.com/solarwinds/apm-ruby/blob/main/.github/workflows/ci-markdown-link.yml">
<img src="https://github.com/solarwinds.png" width="50" height="50" alt="SolarWinds" /><br />
<b>SolarWinds</b><br />
<sub>apm-ruby</sub>
</a>
</td>
<td align="center" width="150">
<a href="https://github.com/jenkinsci/autograding-plugin/blob/main/.github/workflows/check-md-links.yml">
<img src="https://github.com/jenkinsci.png" width="50" height="50" alt="Jenkins" /><br />
<b>Jenkins</b><br />
<sub>autograding-plugin</sub>
</a>
</td>
<td align="center" width="150">
<a href="https://github.com/riscv/learn/blob/main/.github/workflows/linkcheck.yml">
<img src="https://github.com/riscv.png" width="50" height="50" alt="RISC-V" /><br />
<b>RISC-V</b><br />
<sub>learn</sub>
</a>
</td>
<td align="center" width="150">
<a href="https://github.com/vllm-project/llm-compressor/blob/main/.github/workflows/linkcheck.yml">
<img src="https://github.com/vllm-project.png" width="50" height="50" alt="vLLM" /><br />
<b>vLLM</b><br />
<sub>llm-compressor</sub>
</a>
</td>
</tr>
<tr>
<td align="center" colspan="5">
<a href="https://github.com/search?q=uses%3A+umbrelladocs%2Faction-linkspector%40v1&type=code">
<b>and many more...</b>
</a>
</td>
</tr>
</table>

If you are using this on production, consider [buying me a coffee](https://liberapay.com/gaurav-nelson/) ☕.

## How to use

1. Create a new file in your repository `.github/workflows/action.yml`.
1. Copy-paste the following workflow in your `action.yml` file:

   ```yaml
   name: Linkspector
   on: [pull_request]
   jobs:
     check-links:
       name: runner / linkspector
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v5
         - name: Run linkspector
           uses: umbrelladocs/action-linkspector@v1
           with:
             github_token: ${{ secrets.github_token }}
             reporter: github-pr-review
             fail_level: any
   ```

## Action inputs

### `github_token`

(Optional) `${{ github.token }}` is used by default.

### `level`

(Optional) Report level for reviewdog [info,warning,error].
It's same as `-level` flag of reviewdog. Linkspector only reports errors, so if you change this value, you will not see any output.

### `reporter`

Reporter of reviewdog command [github-pr-check,github-pr-review,github-check].
Default is `github-pr-check`.
`github-pr-review` can use Markdown and add a link to rule page in reviewdog reports.

For more details, see [Reporters](https://github.com/reviewdog/reviewdog?tab=readme-ov-file#reporters).

### `filter_mode`

(Optional) Filtering mode for the reviewdog command [added,diff_context,file,nofilter], the default value is `added`.
- `added`: Show errors only in the added lines (with the `+` prefix).
- `diff_context`: Show errors in the diff context, that is changed lines +-N lines (N=3 for example).
- `file`: Show errors for added and modified files even if the results are not in actual diff.
- `nofilter`: Show all errors across all files.

For more details, please see [Filter mode support table](https://github.com/reviewdog/reviewdog?tab=readme-ov-file#filter-mode-support-table).

### `fail_level`

(Optional)  Exit code for reviewdog when errors are found with severity greater than or equal to the given level [none,any,info,warning,error].
Default is `none`.

### `fail_on_error`

(Optional, deprecated) Exit code for reviewdog when errors are found [true,false]. This option is ignored if `fail_level` is used.
Default is `false`.

### `reviewdog_flags`

(Optional) Additional reviewdog flags.

### `config_file`

(Optional) Path to your linkspector configuration file `.linkspector.yml`.
For more details, see [Linkspector configuration](https://github.com/UmbrellaDocs/linkspector?tab=readme-ov-file#configuration).

### `show_stats`

(Optional) Show statistics about the checked links [true,false].
Default is `false`.

**Note:** Enabling the `show_stats` option causes Linkspector to run twice: once for reporting and again to collect statistics. Using this will increase the total run time of the action.

## Self-hosted and `arm64` runners

This action automatically detects `arm64` runners and self-hosted runners where Puppeteer's bundled Chromium may not work. In these cases, it installs system Chromium using the appropriate package manager (`apt`, `dnf`, `yum`, `apk`, `zypper`, or `pacman`).

If your runner already has Chrome or Chromium installed, the action detects it and skips installation.

If you need to point to a specific Chromium/Chrome binary, set the `PUPPETEER_EXECUTABLE_PATH` environment variable in your workflow to skip all automatic Chromium setup:

```yaml
- name: Run linkspector
  uses: umbrelladocs/action-linkspector@v1
  env:
    PUPPETEER_EXECUTABLE_PATH: /usr/bin/chromium
  with:
    github_token: ${{ secrets.github_token }}
    reporter: github-pr-review
```
