[![GitHub Marketplace](https://img.shields.io/badge/GitHub%20Marketplace-action%20linkspector-brightgreen?style=for-the-badge)](https://github.com/marketplace/actions/run-linkspector-with-reviewdog)
![GitHub Release](https://img.shields.io/github/v/release/UmbrellaDocs/action-linkspector?style=for-the-badge)

<a href="https://liberapay.com/gaurav-nelson/donate"><img alt="Donate using Liberapay" src="https://liberapay.com/assets/widgets/donate.svg"></a>

# GitHub action: Run 💀Linkspector with 🐶Reviewdog

This action runs [Linkspector](https://github.com/UmbrellaDocs/linkspector) with [Reviewdog](https://github.com/reviewdog/reviewdog) on pull requests to improve the quality of your content.

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
         - uses: actions/checkout@v4
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
