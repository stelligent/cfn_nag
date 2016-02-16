Installation
============
For now, you can build and deploy the gem locally with the following convenience script:

    ./deploy_local.sh

Usage
=====
Pretty simple to execute:

    cfn_nag --input-json <path to cloudformation json>

Optionally, a `--debug` flag will dump all the "jq" query command lines to stdout

Results
-------
* Explanations of failures are dumped to stdout
* A fatal violation or violation will return a non-zero exit code.
* A warning will return a zero/success exit code.
* A fatal violation stops analysis because the template is malformed in some severe way

Development
===========

Adding JSON Rules
-----------------
To add a JSON rule, add a call to `warning`, `violation` or `fatal_violation` in a file under
`lib/json_rules`.  Any file in that directory will be evaluated, so you can add new files as desired
or update existing files if the rule applies to an existing rough category.

For more information on the jq query language, see: https://stedolan.github.io/jq/manual/

Custom Rules
------------
The jq query language is convenient, but can get out of hand pretty quickly.  For some rules that require
"joining" up different pieces of a Cloudformation template to make a decision, it can be too difficult if not
impossible.

In this case, there are two basic steps to creating a custom rule:

1. The `CfnModel` will likely need to be updated to parse the template and return objects with the necessary information
   to make a decision
2. A rule object should be added under `lib/custom_rules` that can analyse the CfnModel object as needed.  Then the
   list of custom rules needs to be updated in `CfnNag::custom_rules`
       
Other
-----
* Generally speaking - be sure to drive any changes with tests.  i.e. before making a code change, add a test under
  spec that fails, and then develop the code to make it succeed.
* The simplecov gem is hooked up, so when running `rspec`, inspect `coverage/index.html` to make sure your change is covered by a test.
* the script `run-end-to-end-random-test.sh` runs AWS sample templates against cfn_nag.  It doesn't measure outcomes, it
  just throws the kitchen sink at it and it's up to you to spot check or look for strange results.

