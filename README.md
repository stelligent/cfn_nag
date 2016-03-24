Installation
============
Presuming Ruby 2.2.x is installed, installation is just a matter of:

    gem install cfn-nag

To install the gem locally with version 0.0.0 to do end-to-end testing, there is a convenience script:

    ./deploy-local.sh
    
Usage
=====
Pretty simple to execute:

    cfn_nag --input-json-path <path to cloudformation json>
    
The path can be a directory or a particular template.  If it is a directory, all \*.json and \*.template files underneath
there recursively will be processed.

The default output format is free-form text, but json output can be selected with the `--output-format json` flag.    

Optionally, a `--debug` flag will dump all the "jq" query command lines to stdout

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

Adding JSON Rules
-----------------
To add a JSON rule, add a call to `warning`, `violation` or `fatal_violation` in a file under
`lib/json_rules`.  Any file in that directory will be evaluated, so you can add new files as desired
or update existing files if the rule applies to an existing rough category.

For more information on the jq query language, see: https://stedolan.github.io/jq/manual/

There are two kinds of queries you can throw at `jq`:

* The typical query to `jq` should return just a JSON array of logical resource ids.  The `Rule` module
  will expect this and use this to format result messages properly.  If a query can't be written
  to return just an array of resource ids, then a "raw" query is probably needed.
* A "raw" query can have free-form results.  If anything is found/not found per assertion/violation
  then that determines success/failure and the stdout of jq is emitted as part of the result to the user.
  This is intended for testing special cases - structural correctness.  Instead of calling `violation`, call
  `raw_violation`
  
Custom Rules
------------
The jq query language is convenient, but can get out of hand pretty quickly.  For some rules that require
"joining" up different pieces of a Cloudformation template to make a decision, it can be too difficult if not
impossible.  Some of the existing "basic" jq rules might even deserve a rewrite as a custom rule given how
complex they turned out to be.

In this case, there are two basic steps to creating a custom rule:

1. The `CfnModel` will likely need to be updated to parse the template and return objects with the necessary information
   to make a decision
2. A rule object should be added under `lib/custom_rules` that can analyse the CfnModel object as needed.  Then the
   list of custom rules needs to be updated in `CfnNag::custom_rules`
3. The rule object should return a violation count per resource, but only one message.
       
Other
-----
* Generally speaking - be sure to drive any changes with tests.  i.e. before making a code change, add a test under
  spec that fails, and then develop the code to make it succeed.
* The simplecov gem is hooked up, so when running `rspec`, inspect `coverage/index.html` to make sure your change is covered by a test.
* the script `run-end-to-end-random-test.sh` runs AWS sample templates against cfn_nag.  It doesn't measure outcomes, it
  just throws the kitchen sink at it and it's up to you to spot check or look for strange results.

