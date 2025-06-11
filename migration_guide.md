# Migration Guide: `gaurav-nelson/github-action-markdown-link-check` to `UmbrellaDocs/action-linkspector`

This guide will help you migrate your GitHub Actions workflow from the deprecated `gaurav-nelson/github-action-markdown-link-check` to the recommended `UmbrellaDocs/action-linkspector`.

## Why Migrate?

The `gaurav-nelson/github-action-markdown-link-check` action is no longer actively maintained. `UmbrellaDocs/action-linkspector` offers several advantages:

*   **Active Maintenance:** Regularly updated and supported.
*   **Improved Accuracy:** Uses Linkspector, which leverages Puppeteer (headless Chrome) for checking links, leading to fewer false positives.
*   **Enhanced Reporting:** Integrates with `reviewdog` to provide annotations directly in your pull requests.
*   **Modern Underpinnings:** Built to address limitations of the older action and incorporate user-requested features.

## Core Workflow Changes

The primary change involves updating the action used in your workflow file (e.g., `.github/workflows/links.yml`).

### Before: `gaurav-nelson/github-action-markdown-link-check`

A typical workflow using the old action might look like this:

```yaml
name: Check Markdown links

on: [push]

jobs:
  markdown-link-check:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3 # Or your preferred version
    - uses: gaurav-nelson/github-action-markdown-link-check@v1
      # Optional: with other parameters like config-file
      # with:
      #   config-file: 'mlc_config.json'
```

### After: `UmbrellaDocs/action-linkspector`

Here's how you would update it to use `UmbrellaDocs/action-linkspector`:

```yaml
name: Check Markdown links

on: [pull_request] # Recommended to run on pull_request for reviewdog integration

jobs:
  markdown-link-check:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4 # Or your preferred version
    - name: Run Linkspector
      uses: UmbrellaDocs/action-linkspector@v1 # Or latest version
      with:
        # Essential for reviewdog to comment on PRs
        github_token: ${{ secrets.GITHUB_TOKEN }}

        # Reporter: github-pr-review posts findings as PR review comments.
        # Other options: github-pr-check (posts as PR check annotations)
        reporter: github-pr-review

        # fail_level: Determines the exit code of the action.
        # 'any' means it will fail if Linkspector finds any broken links.
        # Other options: 'none', 'info', 'warning', 'error'.
        fail_level: any

        # filter_mode: Controls which files reviewdog reports on.
        # 'added' = only new files in the PR.
        # 'diff_context' = lines in the diff.
        # 'file' = all changed files.
        # 'nofilter' = all files.
        filter_mode: diff_context # Or your preferred mode, 'file' is also common

        # Optional: Path to your Linkspector config file
        # config_file: '.linkspector.yml'

        # Optional: Show statistics about checked links
        # show_stats: 'true'
```

### Key Workflow Parameter Explanations:

*   **`uses: UmbrellaDocs/action-linkspector@v1`**: This line changes to the new action. Always check the [Marketplace page](https://github.com/marketplace/actions/run-linkspector-with-reviewdog) for the latest version.
*   **`on: [pull_request]`**: While the old action often ran `on: [push]`, `action-linkspector` is best utilized `on: [pull_request]` to leverage `reviewdog`'s PR commenting features.
*   **`github_token: ${{ secrets.GITHUB_TOKEN }}`**: This is required for `reviewdog` to post comments and checks to your pull request.
*   **`reporter`**: Controls how `reviewdog` reports findings. `github-pr-review` is very user-friendly as it adds comments to the PR.
*   **`fail_level`**: Determines if the workflow step should fail based on the severity of links found. `any` is a common setting to catch all broken links.
*   **`filter_mode`**: Useful for focusing reports on the changes made in a pull request.
*   **`config_file`**: (Optional) If you use a Linkspector configuration file (recommended), specify its path here. The default is `.linkspector.yml`.

## Configuration File Migration: `mlc_config.json` to `.linkspector.yml`

The old `gaurav-nelson/github-action-markdown-link-check` action used a JSON file (often `mlc_config.json` or specified by `config-file` in the workflow) for detailed configuration. `UmbrellaDocs/action-linkspector` uses a YAML file, by default named `.linkspector.yml` (this can be changed with the `config_file` input in your workflow).

While we provide a [conversion script](#automating-the-conversion) to help with this, it's important to understand how the options map.

### Option Mapping Overview

| `gaurav-nelson` (`mlc_config.json`) | `UmbrellaDocs/linkspector` (`.linkspector.yml`) | Notes                                                                                                                               |
|-------------------------------------|---------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------|
| `folder-path` (workflow input)      | `dirs` (YAML list)                                | List directories to scan.                                                                                                           |
| `file-path` (workflow input)        | `files` (YAML list)                               | List specific files to scan.                                                                                                        |
| `max-depth` (workflow input)        | (Not directly available)                          | Manage scan depth by carefully defining `dirs` and `excludedDirs`.                                                                  |
| `file-extension` (workflow input)   | (Automatic)                                       | Linkspector automatically recognizes common markup files (Markdown, AsciiDoc).                                                      |
| `check-modified-files-only` (workflow input) | `modifiedFilesOnly` (YAML boolean)           | Set to `true` to check only git-modified files. Works in conjunction with `filter_mode` in the action workflow for reporting. |
| `base-branch` (workflow input)      | (Handled by CI/`actions/checkout`)                | The context for `modifiedFilesOnly` is typically determined by your `actions/checkout` setup and PR base.                         |
| `use-quiet-mode` (workflow input)   | (N/A - Linkspector is generally quiet)            | Linkspector provides concise output. `reviewdog` handles reporting verbosity.                                                       |
| `use-verbose-mode` (workflow input) | `show_stats: 'true'` (workflow input)             | Use `show_stats` in the workflow for a summary. Detailed error reports are standard.                                                |
| `ignorePatterns` (JSON array)       | `ignorePatterns` (YAML list of objects)           | See details below.                                                                                                                  |
| `replacementPatterns` (JSON array)  | `replacementPatterns` (YAML list of objects)      | See details below.                                                                                                                  |
| `aliveStatusCodes` (JSON array)     | `aliveStatusCodes` (YAML list)                    | List of HTTP status codes considered 'alive'.                                                                                       |
| `httpHeaders` (JSON array)          | `httpHeaders` (YAML list of objects)              | Define custom HTTP headers, now with better support for secrets using environment variables.                                        |
| (N/A - HTML comments)               | `ignorePatterns` (YAML)                           | HTML comments for disabling checks are **not supported**. Use `ignorePatterns`.                                                     |
| (N/A)                               | `excludedFiles` (YAML list)                       | New option to explicitly exclude specific files.                                                                                    |
| (N/A)                               | `excludedDirs` (YAML list)                        | New option to explicitly exclude specific directories.                                                                              |
| (N/A)                               | `useGitIgnore` (YAML boolean, default `true`)     | Tells Linkspector to respect your `.gitignore` file.                                                                                |
| (N/A)                               | `baseUrl` (YAML string)                           | Set a base URL for resolving relative links.                                                                                        |
| (N/A)                               | `followRedirects` (YAML boolean, default `true`)  | Controls whether Linkspector should follow HTTP redirects.                                                                          |

### Detailed Configuration Translation:

#### 1. `ignorePatterns`

*   **Old (`mlc_config.json`):**
    ```json
    {
      "ignorePatterns": [
        { "pattern": "^http://localhost" },
        { "pattern": "https://example.com/ignored-path" }
      ]
    }
    ```
*   **New (`.linkspector.yml`):** Each pattern needs to be an object with a `pattern` key.
    ```yaml
    ignorePatterns:
      - pattern: '^http://localhost'
      - pattern: 'https://example.com/ignored-path'
    ```

#### 2. `replacementPatterns`

*   **Old (`mlc_config.json`):**
    ```json
    {
      "replacementPatterns": [
        {
          "pattern": "^http://old-domain.com",
          "replacement": "https://new-domain.com"
        }
      ]
    }
    ```
*   **New (`.linkspector.yml`):**
    ```yaml
    replacementPatterns:
      - pattern: '^http://old-domain.com'
        replacement: 'https://new-domain.com'
    ```

#### 3. `aliveStatusCodes`

*   **Old (`mlc_config.json`):**
    ```json
    {
      "aliveStatusCodes": [200, 204, 429]
    }
    ```
*   **New (`.linkspector.yml`):**
    ```yaml
    aliveStatusCodes:
      - 200
      - 204
      - 429 # Example: Treating 'Too Many Requests' as alive temporarily
    ```

#### 4. `httpHeaders`

*   **Old (`mlc_config.json`):**
    ```json
    {
      "httpHeaders": [
        {
          "urls": ["https://api.example.com"],
          "headers": { "Authorization": "Bearer YOUR_TOKEN" }
        }
      ]
    }
    ```
*   **New (`.linkspector.yml`):** Linkspector allows embedding environment variables, which is more secure for tokens.
    ```yaml
    # In your .env file (or GitHub secrets for actions)
    # API_EXAMPLE_COM_TOKEN="Bearer YOUR_TOKEN"

    httpHeaders:
      - urls: # Note: 'urls' not 'url' as in Linkspector v0.4.x docs, but action might adapt or Linkspector docs vary.
              # The core Linkspector CLI docs show 'url:' with a list. Check current Linkspector docs if issues arise.
          - 'https://api.example.com'
        headers:
          Authorization: '${API_EXAMPLE_COM_TOKEN}' # Use env variable
          User-Agent: 'MyLinkCheckerClient/1.0'
    ```
    **Important for `httpHeaders`**:
    *   The structure within Linkspector's YAML for `httpHeaders` involves a list of objects, where each object has a `url` (list of URL strings/patterns) and `headers` (key-value map).
    *   It's highly recommended to use environment variables (e.g., `${MY_TOKEN}`) for sensitive header values like authentication tokens and define these in your CI/CD environment (e.g., GitHub Secrets).

Remember to create a `.linkspector.yml` file in your repository root (or the path specified by `config_file` in your workflow) with these new configurations.

## Handling Link Ignoring/Skipping

A significant change from `gaurav-nelson/github-action-markdown-link-check` is how links are ignored or skipped.

**The old method of using HTML comments like `<!-- markdown-link-check-disable -->`, `<!-- markdown-link-check-disable-next-line -->`, or `<!-- markdown-link-check-disable-line -->` is NO LONGER SUPPORTED by Linkspector.**

All link ignoring must now be configured within your `.linkspector.yml` file using `ignorePatterns`.

### Examples of Migrating HTML Comment Ignores to `ignorePatterns`:

Let's say you had the following in your Markdown:

```markdown
<!-- markdown-link-check-disable -->
This link will be ignored: [Broken Link 1](http://example.com/this-is-broken)
And this one too: [Another Broken Link](http://another.example.com/very-broken)
<!-- markdown-link-check-enable -->

This link is checked.

<!-- markdown-link-check-disable-next-line -->
[Specific Broken Link](http://specific.example.com/broken-for-sure)

[Link on this line is ignored](http://inline.example.com/broken-too) <!-- markdown-link-check-disable-line -->
```

You would translate these into `ignorePatterns` in your `.linkspector.yml`:

```yaml
ignorePatterns:
  # To ignore specific individual links:
  - pattern: 'http://example.com/this-is-broken'
  - pattern: 'http://another.example.com/very-broken'
  - pattern: 'http://specific.example.com/broken-for-sure'
  - pattern: 'http://inline.example.com/broken-too'

  # Alternatively, to ignore all links to a domain (if that was the intent):
  # - pattern: '^http://example\.com' # Ignores all links starting with http://example.com
  # - pattern: '^https://another\.example\.com'

  # Or to ignore links within a certain path:
  # - pattern: 'https://example.com/ignored-path/'
```

**Key Takeaways for Ignoring Links:**

*   **Centralize Ignores:** All ignore rules are now in `.linkspector.yml`. This provides a clearer overview of what's being skipped.
*   **Use Regular Expressions:** `ignorePatterns` use regular expressions, offering powerful and flexible ways to define what to skip. Make sure to escape special characters in your regex if needed (e.g., `.` becomes `\.`).
*   **No More Inline Disabling:** You can no longer disable link checking for just a section or a single line directly within the Markdown file. You must add a pattern to `.linkspector.yml`.
*   **Be Specific or Broad:** You can create patterns that are very specific to a single URL or broad enough to cover entire domains or URL paths.

This change requires a shift in how you manage skipped links, but it leads to a more maintainable and centrally configured setup. The [conversion script](#automating-the-conversion) will not be able to automatically convert HTML comments, so this part will require manual attention.

## Automating the Conversion with `convert_config.py`

To help migrate your old `mlc_config.json` to the new `.linkspector.yml` format, a Python conversion script (`convert_config.py`) is provided in this repository.

### How to Use the Script

1.  **Save the Script:** Make sure you have the `convert_config.py` script from this repository.
2.  **Locate Your Old Config:** Find your existing `mlc_config.json` file.
3.  **Run the Script:** Execute the script from your terminal, providing the path to your old JSON config file as an argument. It's recommended to redirect the output to your new `.linkspector.yml` file.

    ```bash
    python convert_config.py /path/to/your/mlc_config.json > .linkspector.yml
    ```
    For example, if `mlc_config.json` is in the current directory:
    ```bash
    python convert_config.py mlc_config.json > .linkspector.yml
    ```
4.  **Review Output:** The script will print the converted YAML to your terminal (or the output file). It will also print any warnings or suggestions to the terminal's standard error output. **Carefully review these warnings and the generated `.linkspector.yml` file.**

### What the Script Does:

*   Converts `aliveStatusCodes`.
*   Converts `ignorePatterns` (note: simple string patterns in the old JSON will be wrapped as `{'pattern': 'your_string'}`).
*   Converts `replacementPatterns`.
*   Converts `httpHeaders`, changing the `urls` key to `url`. It will also issue a warning to remind you to move any sensitive tokens to environment variables.
*   Adds sensible defaults like `dirs: ['.']` (if no directory/file configuration is found) and `useGitIgnore: true`.

### Important Limitations & Manual Steps:

*   **HTML Comment Ignores:** The script **CANNOT** automatically convert link ignores that were done using HTML comments (e.g., `<!-- markdown-link-check-disable -->`) in your Markdown files. You **MUST** manually identify these and add corresponding `ignorePatterns` to your `.linkspector.yml`.
*   **Workflow Parameters:** The script primarily converts the *content* of `mlc_config.json`. Old workflow parameters like `folder-path`, `file-path`, `check-modified-files-only`, `max-depth`, etc., need to be manually translated:
    *   `folder-path` and `file-path` can often be mapped to `dirs` and `files` in `.linkspector.yml`. The script makes a basic attempt if it finds `folder-path` in the JSON, but complex setups require manual mapping.
    *   `check-modified-files-only: 'yes'` maps to `modifiedFilesOnly: true` in `.linkspector.yml` AND you should configure the `filter_mode` (e.g., `added` or `diff_context`) in your GitHub Actions workflow for `action-linkspector`.
*   **HTTP Header Secrets:** While `httpHeaders` are converted, if you had tokens or other secrets directly in your `mlc_config.json`, you should replace these with environment variable placeholders (e.g., `Authorization: '${MY_API_TOKEN}'`) in `.linkspector.yml` and store the actual secrets securely (e.g., in GitHub Secrets).
*   **Review is Crucial:** Always review the generated `.linkspector.yml` for correctness and completeness before relying on it.

This script aims to handle the bulk of the tedious conversion, but manual verification and adjustments are essential for a successful migration.

## Example `.linkspector.yml`

Here's an example of what a `.linkspector.yml` file might look like after migration, incorporating common configurations. You would tailor this to your specific needs.

```yaml
# Directories to scan for markdown files
dirs:
  - 'docs/'
  - 'src/content/'
  # - '.' # Uncomment to scan the whole repository from the root

# Specific files to include (optional, if dirs isn't specific enough)
# files:
#   - 'README.md'
#   - 'CONTRIBUTING.md'

# Directories to exclude from scanning
excludedDirs:
  - 'docs/archive/'
  - 'node_modules/' # Always good to exclude

# Specific files to exclude
# excludedFiles:
#   - 'docs/draft-notes.md'

# Use .gitignore rules to exclude files and directories
useGitIgnore: true

# Check only files modified in the last git commit (useful for PR checks)
# Ensure your GitHub Action workflow also uses an appropriate 'filter_mode' for reviewdog
modifiedFilesOnly: false # Set to true for PR checks usually

# Base URL for resolving relative links, if necessary
# baseUrl: 'https://my-documentation-site.com'

# Patterns for URLs to ignore (regular expressions)
ignorePatterns:
  - pattern: '^http://localhost' # Ignore all localhost links
  - pattern: 'https://github.com/.*/issues/\d+$' # Ignore links to GitHub issues
  - pattern: 'https://twitter.com/' # Ignore all twitter links (often problematic for checks)
  - pattern: 'https://example.com/do-not-check-this-specific-link.html'
  - pattern: '/api/private/' # Ignore relative links to a private API path

# Patterns to replace parts of URLs before checking (e.g., for staging domains)
# replacementPatterns:
#   - pattern: 'https://docs.example.com'
#     replacement: 'http://localhost:3000' # Test local links instead of prod

# HTTP status codes to consider as 'alive' or valid
aliveStatusCodes:
  - 200 # OK
  - 204 # No Content
  # - 403 # Forbidden - sometimes sites return 403 to bots, might treat as alive if known
  # - 429 # Too Many Requests - consider if you hit rate limits often

# Custom HTTP headers for specific URLs (use environment variables for secrets)
# Ensure these environment variables (e.g., MY_API_TOKEN) are set in your CI environment
# httpHeaders:
#   - url:
#       - 'https://api.specific.com/data'
#     headers:
#       Authorization: '${MY_API_TOKEN}'
#       X-Custom-Header: 'MyCheckerValue'
#   - url:
#       - 'https://another.service.com'
#     headers:
#       User-Agent: 'LinkspectorLinkCheck/1.0'

# Whether to follow HTTP redirects (301, 302, etc.)
# Defaults to true if not specified. Setting to false means redirects are reported as errors.
followRedirects: true
```

This example provides a starting point. You should adjust the paths, patterns, and other settings based on your project's structure and requirements. Remember to consult the [official Linkspector documentation](https://github.com/UmbrellaDocs/linkspector) for the most up-to-date list of configuration options and their usage.
