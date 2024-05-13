# GitHub action: Run Linkspector with Reviewdog

This action runs [Linkspector](https://github.com/UmbrellaDocs/linkspector) with [Reviewdog](https://github.com/reviewdog/reviewdog) on pull requests to improve the quality of your content.

## Inputs

### `github_token`

(Optional) `${{ github.token }}` is used by default.

### `level`

(Optional) Report level for reviewdog [info,warning,error].
It's same as `-level` flag of reviewdog.

### `reporter`

Reporter of reviewdog command [github-pr-check,github-pr-review,github-check].
Default is `github-pr-check`.
`github-pr-review` can use Markdown and add a link to rule page in reviewdog reports.

### `filter_mode`

(Optional) Filtering mode for the reviewdog command [added,diff_context,file,nofilter], the default value is `file`.

### `fail_on_error`

(Optional)  Exit code for reviewdog when errors are found [true,false]
Default is `false`.

### `reviewdog_flags`

(Optional) Additional reviewdog flags.

### `config_file`

(Optional) Path to your linkspector configuration file `.linkspector.yml`.

## Example usage

```yaml
name: Linkspector
on: [pull_request]
jobs:
  linkspector:
    name: runner / linkspector
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: linkspector
        uses: reviewdog/action-linkspector@v1
        with:
          github_token: ${{ secrets.github_token }}
          reporter: github-pr-review # Change reporter.
```


