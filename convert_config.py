import json
import yaml
import argparse
import sys

def convert_config(json_data):
    '''
    Converts configuration from mlc_config.json format to .linkspector.yml format.
    '''
    linkspector_config = {}
    warnings = []

    if 'aliveStatusCodes' in json_data:
        linkspector_config['aliveStatusCodes'] = json_data['aliveStatusCodes']

    if 'ignorePatterns' in json_data:
        linkspector_config['ignorePatterns'] = []
        for item in json_data['ignorePatterns']:
            if isinstance(item, str):
                linkspector_config['ignorePatterns'].append({'pattern': item})
            elif isinstance(item, dict) and 'pattern' in item:
                linkspector_config['ignorePatterns'].append({'pattern': item['pattern']})
            else:
                warnings.append(f"Skipping unrecognized item in 'ignorePatterns': {item}")

    if 'replacementPatterns' in json_data:
        linkspector_config['replacementPatterns'] = []
        for item in json_data['replacementPatterns']:
            if isinstance(item, dict) and 'pattern' in item and 'replacement' in item:
                linkspector_config['replacementPatterns'].append({
                    'pattern': item['pattern'],
                    'replacement': item['replacement']
                })
            else:
                warnings.append(f"Skipping unrecognized item in 'replacementPatterns': {item}")

    if 'httpHeaders' in json_data:
        linkspector_config['httpHeaders'] = []
        for header_group in json_data['httpHeaders']:
            new_header_group = {}
            # Handle both 'urls' (old) and 'url' (new, or if user partially migrated)
            source_url_key = None
            if 'urls' in header_group and isinstance(header_group['urls'], list):
                source_url_key = 'urls'
            elif 'url' in header_group and isinstance(header_group['url'], list):
                 source_url_key = 'url'

            if source_url_key:
                new_header_group['url'] = header_group[source_url_key] # Correct key for Linkspector is 'url'
            else:
                warnings.append(f"Skipping httpHeader group due to missing/invalid 'urls' or 'url' key: {header_group}")
                continue

            if 'headers' in header_group and isinstance(header_group['headers'], dict):
                new_header_group['headers'] = header_group['headers']
                warnings.append(
                    "Migrated an 'httpHeaders' entry. IMPORTANT: Review for sensitive data (e.g., API tokens). "
                    "Replace these with environment variable placeholders (e.g., '${MY_TOKEN}') "
                    "in '.linkspector.yml' and store actual values in GitHub Secrets."
                )
            else:
                warnings.append(f"Skipping httpHeader group due to missing or invalid 'headers' key: {header_group}")
                continue

            linkspector_config['httpHeaders'].append(new_header_group)

        if not linkspector_config.get('httpHeaders'):
             if 'httpHeaders' in linkspector_config:
                 del linkspector_config['httpHeaders']

    # Default settings for Linkspector if not mapped
    if 'dirs' not in linkspector_config and 'files' not in linkspector_config:
        if 'folder-path' in json_data: # Non-standard in mlc_config.json, but attempt conversion
            path_data = json_data['folder-path']
            if isinstance(path_data, str):
                linkspector_config['dirs'] = [p.strip() for p in path_data.split(',')]
                warnings.append("Used 'folder-path' from JSON for 'dirs'. Review for correctness.")
            elif isinstance(path_data, list):
                linkspector_config['dirs'] = path_data
                warnings.append("Used 'folder-path' (list) from JSON for 'dirs'. Review for correctness.")
            else:
                linkspector_config['dirs'] = ['.']
                warnings.append("Added default 'dirs: [.]'. 'folder-path' in JSON was invalid.")
        else:
            linkspector_config['dirs'] = ['.']
            warnings.append("Added default 'dirs: [.]' as no 'dirs', 'files', or 'folder-path' found.")

    if 'useGitIgnore' not in linkspector_config:
        linkspector_config['useGitIgnore'] = True
        # warnings.append("Added 'useGitIgnore: true' (Linkspector default).") # Less critical warning

    warnings.append(
        "MANUAL REVIEW REQUIRED: "
        "1. HTML comment ignores (e.g., <!-- markdown-link-check-disable -->) are NOT automatically converted. Add them as 'ignorePatterns' in the YAML. "
        "2. Workflow inputs like 'check-modified-files-only', 'file-path', 'max-depth' need manual translation to '.linkspector.yml' fields (e.g., 'modifiedFilesOnly', 'files') or to the new GitHub Action's inputs."
    )

    return linkspector_config, warnings

def main():
    parser = argparse.ArgumentParser(
        description='Convert mlc_config.json to .linkspector.yml format.',
        epilog="Example: python convert_config.py mlc_config.json > .linkspector.yml"
    )
    parser.add_argument(
        'input_file',
        help='Path to the input mlc_config.json file.'
    )
    args = parser.parse_args()

    try:
        with open(args.input_file, 'r') as f:
            json_data = json.load(f)
    except FileNotFoundError:
        sys.stderr.write(f"Error: Input file '{args.input_file}' not found.\n")
        sys.exit(1)
    except json.JSONDecodeError as e:
        sys.stderr.write(f"Error: Could not decode JSON from '{args.input_file}'. Details: {e}\n")
        sys.exit(1)

    linkspector_config, warnings = convert_config(json_data)

    if warnings:
        sys.stderr.write("--- Conversion Warnings and Suggestions ---\n")
        for warning in warnings:
            sys.stderr.write(f"- {warning}\n")
        sys.stderr.write("------------------------------------------\n")
        sys.stderr.write("YAML output (review carefully):\n\n")

    yaml.dump(linkspector_config, sys.stdout, sort_keys=False, indent=2, default_flow_style=False)

if __name__ == '__main__':
    main()
