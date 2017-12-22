## Summary

There are three areas that have changed enough from 0.0.x to 0.1.x to cause trouble:

1. The command line scripts are a little different.

   The command line script `cfn_nag` is now called `cfn_nag_scan`.  This script works the way it used to,
   accepting a commnad line argument for the file to scan,  or a directory to scan for templates.

   The new `cfn_nag` script accepts stdin or an explicit list of files to process.

2. The API to invoke cfn-nag directly is a little different.

   In particular, the CfnNag object is slightly different:

   * The constructor takes the rule directory as well as the profile now
   * The call to `audit_template` should be replaced by a call to `audit`, and there is no longer
     a reference to the rule directory at the point of auditing
   * All the code has been moved under the `cfn-nag` directory, and a call to `require cfn-nag` should
     replace any calls to `require cfn_nag` (beware the hyphen vs. the underscore)

3. The rule writing is drastically different

   * The recommended approach for writing rules is to write them in Ruby, using the new cfn-model as the basis
     for analysis.  There should be no/minimal need to write any "Parser" objects as in 0.0.x or to supplement
     the model.
   * cfn-nag no longer recognizes rules written in jq.  It will allow writing rules in jmespath, but it is recommended
     to write the rules in Ruby.  It is far simpler to debug and employ typical software development practices (TDD).

## Crash Course in (New) Rule Development

1. Create a class that ends with the name Rule.  This is a convention that must be observed in order for cfn-nag to load
   the rule.  Additionally, derive this class from BaseRule:

        require 'cfn-nag/violation'
        require_relative 'base'

        class IamManagedPolicyNotActionRule < BaseRule

2. Define methods that describe some of the bookkeeping for the rule, like whether it is a WARNING_VIOLATION/FAILING_VIOLATION, its
   unique identifier among rules, and error text shown when it matches:

        def rule_text
          'IAM managed policy should not allow Allow+NotAction'
        end

        def rule_type
          Violation::WARNING_VIOLATION
        end

        def rule_id
          'W17'
        end

3. Define the `audit_impl` method to do the actual work of the analysis.  This method should return an array of
   logical resource identifiers from the CloudFormation template:

        def audit_impl(cfn_model)
          violating_policies = cfn_model.resources_by_type('AWS::IAM::ManagedPolicy').select do |policy|
            !policy.policy_document.allows_not_action.empty?
          end

          violating_policies.map { |policy| policy.logical_resource_id }
        end

4. The cfn_model object passed into the `audit_impl` method is where a majority of the improvement lies.  When
   a CloudFormation document is parsed, it is mapped into a collection of objects that mirror the resource types.
   The call to `resources_by_type` will return objects for each resource with that type (http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html).

   There are a few important details to mapping:
   * Any top-level attribute in the Properties block of a Resource will be an attribute of the returned object.
<<<<<<< HEAD
     * Attributes/properties are returned in camelCase.
=======
     * Attributes are returned in camel case.
>>>>>>> 7ac44b6d5a183b17bd34b434cab1c96eba562ac6
     * For example, if dealing with an object type of 'AWS::RDS:;DBCluster', and needing to write logic against the 'StorageEncrypted' property, then an example `audit_impl` might look like this:
     * `def audit_impl(cfn_model)
       violating_rdscluster = cfn_model.resources_by_type('AWS::RDS::DBCluster').select do |cluster|
         cluster.storageEncrypted.nil? || cluster.storageEncrypted.to_s.downcase == 'false'
       end`
   * cfn-model provides special handling for a subset of objects whereby properties may be transformed into something
     simpler and/or objects may be linked together.  
   * If an object doesn't have special handling (consult cfn-model for the list of objects with special handling) then
     _only_ the top-level attributes in Properties are mapped to object properties.  This means that any second-level
     objects are accessible as Hash.  For example, in `AWS::WAF::WebACL`, the DefaultAction property is mapped to a Hash
     with the key `Type`
   * The raw underlying CloudFormation template is available as a Hash from cfn_model for any special processing
     that mapping would interfere with.

   A developer can write pretty much any rule against the mapped objects or even the raw objects, but the purpose
   of cfn-model's special handling of certain objects is to simplify rule writing.  In CloudFormation there are a number
   of places where fields can be Array or Hash (like ingress).  cfn-model typically collapses fields like this into
   Arrays so that enumerators can be used.  Two other examples of note are:

   * linking SecurityGroup with related SecurityGroupIngress and SecurityGroupEgress
   * policyDocument fields are fairly complex, so they are mapped to a PolicyDocument with some query and
     convenience methods rules can use versus having to implement themselves (potentially in multiple places)

   For a "synthetic" field like this, one computed by cfn-model versus being mapped from the underlying document,
   the original mapped field still holds its original content, while a new field is added with the computed
   value.

<<<<<<< HEAD
## Where to Place Rule Files

There are two general methods for placing custom rules:

1. Placement into the `custom_rules` directory that is installed with the cfn-nag gem
 * Choosing this method requires the least amount of changes to your code relative to the examples seen on this page.
 * If you need to know where the directory is on your filesystem, you can run `gem contents cfn-nag | grep custom_rules`.
 * Rules will automatically be included in subsequent executions of `cfn_nag_scan`.  This can be verified by running `cfn_nag_rules`.
2. Placement into a custom directory of your choice
 * Choosing this method gives you slightly more flexiblity around saving rules wherever you'd like them to be, but requires a couple small tweaks to normal execution:
   * You'll need to modify the import of the BaseRule class ***from*** `require_relative 'base'` ***to*** `require 'cfn-nag/custom_rules/base'`.
   * When executing the scan of a template, you'll need to use the `-r` or `--rules-directory` switch to specify your own custom rules directory.
   * An example execution might look like this: `cfn_nag_scan -r ./example_rules my-cfn-template.yaml`

## Contributing Rules to the Community

For any generic rules you want to share with the community, submit a PR of the rule to `lib/custom_rules`.  Please be sure to use a unique `rule_id` and write the rule according section 1 of the above "Where to Place Rule Files" area.
=======

>>>>>>> 7ac44b6d5a183b17bd34b434cab1c96eba562ac6
