def ebs_volume_with_encryption
  <<CFNRESOURCE
{
  "Resources": {
    "NewVolume": {
      "Type": "AWS::EC2::Volume",
      "Properties": {
        "Size": "100",
        "VolumeType": "io1",
        "Encrypted": "true",
        "Iops": "100",
        "AvailabilityZone": "us-east-1c"
      }
    }
  }
}
CFNRESOURCE
end

def ebs_volume_without_encryption
  <<CFNRESOURCE
{
  "Resources": {
    "NewVolume": {
      "Type": "AWS::EC2::Volume",
      "Properties": {
        "Size": "100",
        "VolumeType": "io1",
        "Encrypted": "false",
        "Iops": "100",
        "AvailabilityZone": "us-east-1c"
      }
    }
  }
}
CFNRESOURCE
end

def two_ebs_volumes_with_no_encryption
  <<CFNRESOURCE
{
  "Resources": {
    "NewVolume1": {
      "Type": "AWS::EC2::Volume",
      "Properties": {
        "Size": "100",
        "VolumeType": "io1",
        "Iops": "100",
        "AvailabilityZone": "us-east-1c"
      }
    },
    "NewVolume2": {
      "Type": "AWS::EC2::Volume",
      "Properties": {
        "Size": "100",
        "VolumeType": "io1",
        "Encrypted": false,
        "Iops": "100",
        "AvailabilityZone": "us-east-1c"
      }
    }
  }
}
CFNRESOURCE
end

def no_violations_cfn_templates
  [
    {
      name:
      'spec/test_templates/json/ec2_volume/ebs_volume_with_encryption.json',
      contents: ebs_volume_with_encryption
    }
  ]
end

def ebs_volume_with_encryption_hash
  { name:
    'spec/test_templates/json/ec2_volume/ebs_volume_with_encryption.json',
    contents: ebs_volume_with_encryption }
end

def ebs_volume_without_encryption_hash
  { name:
    'spec/test_templates/json/ec2_volume/' \
    'ebs_volume_without_encryption_string.json',
    contents: ebs_volume_without_encryption }
end

def two_ebs_volumes_with_no_encryption_hash
  { name:
    'spec/test_templates/json/ec2_volume/' \
    'two_ebs_volumes_with_no_encryption.json',
    contents: two_ebs_volumes_with_no_encryption }
end

def json_templates_zip_file_contents
  [ebs_volume_with_encryption_hash,
   ebs_volume_without_encryption_hash,
   two_ebs_volumes_with_no_encryption_hash].map do |entry|
    {
      name: entry[:name],
      contents: entry[:contents].chomp
    }
  end
end
