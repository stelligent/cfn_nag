# cfn_nag GitHub Action

This action executes cfn_nag_scan linter against the repo for which the workflow is run.  It exposes all the options for `cfn_nag_scan` (see [extra_args](https://github.com/stelligent/cfn_nag/github-action.md#extra_args) below) and allows you to point to a specific directory containing templates to scan.

For more background on the tool, please see:

[Finding Security Problems Early in the Development Process of a CloudFormation Template with "cfn-nag"](https://stelligent.com/2016/04/07/finding-security-problems-early-in-the-development-process-of-a-cloudformation-template-with-cfn-nag/)

and:

[cfn_nag GitHub repository](https://github.com/stelligent/cfn_nag)

## Inputs

### `input_path`

The directory of the repo to search for violations. Default: `$GITHUB_WORKSPACE`

### `extra_args`

Additional arguments to pass to `cfn_nag_scan`. See the [usage for `cfn_nag_scan`](https://github.com/stelligent/cfn_nag#usage) for more options. Default: `--print-suppression`

## Example Usages

### Basic

Search the root of the GitHub runner's workspace for files to scan (not recommended, incase there are other, non-template files with matching extensions).

```
- uses: stelligent/cfn_nag@master
```

### Define path to search

In this form it will search the `templates` directory within the GitHub runner's workspace for files to scan.

```
- uses: stelligent/cfn_nag@master
  with:
    input_path: templates
```

### Define path to search and add extra arguments

In addition to pointing it to search the `templates` directory within the GitHub runner's workspace, it will also produce the output in JSON and fail if any warnings are produced (in addition to violations).

```
- uses: stelligent/cfn_nag@master
  with:
    input_path: templates
    extra_args: --fail-on-warnings -o json
```

### Define path to search and remove default extra args

Search the `templates` directory within the GitHub runner's workspace and remove the default `--print-suppression` extra argument.

```
- uses: stelligent/cfn_nag@master
  with:
    input_path: templates
    extra_args: ''
```

## Support

To report a bug or request a feature, submit an issue through the GitHub repository via: https://github.com/stelligent/cfn_nag/issues/new

Pull requests are welcome as well: https://github.com/stelligent/cfn_nag/pulls