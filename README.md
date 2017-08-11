<img src="https://github.com/stelligent/cfn_nag/raw/master/logo.png" width="150">
<br/>

Background
==========
The cfn-nag tool looks for patterns in CloudFormation templates that may indicate insecure infrastructure.
Roughly speaking it will look for:

* IAM rules that are too permissive (wildcards)
* Security group rules that are too permissive (wildcards)
* Access logs that aren't enabled
* Encryption that isn't enabled

For more background on the tool, please see:  

[Finding Security Problems Early in the Development Process of a CloudFormation Template with "cfn-nag"](https://stelligent.com/2016/04/07/finding-security-problems-early-in-the-development-process-of-a-cloudformation-template-with-cfn-nag/)

Installation
============
Presuming Ruby 2.2.x is installed, installation is just a matter of:

    gem install cfn-nag

Usage
=====
Pretty simple to execute:

    cfn_nag_scan --input-path <path to cloudformation json>

The path can be a directory or a particular template.  If it is a directory, all \*.json, \*.template, \*.yml and \*.yaml files underneath
there recursively will be processed.

The default output format is free-form text, but json output can be selected with the `--output-format json` flag.    

Optionally, a `--debug` flag will dump information about the internals of rule loading.

To see a list of all the rules the cfn-nag currently supports, there is a command-line utility that will dump them to stdout:

    cfn_nag_rules

Results
-------
* The results are dumped to stdout
* A failing violation will return a non-zero exit code.
* A warning will return a zero/success exit code.
* A fatal violation stops analysis (per file) because the template is malformed in some severe way

Development
===========
work in progress - just did some major re-work on the internals
