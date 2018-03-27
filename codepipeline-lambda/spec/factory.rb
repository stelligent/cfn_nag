def no_violations_cfn_templates
  [
    {
      name:
      'spec/test_templates/json/ec2_volume/ebs_volume_with_encryption.json',
      contents: <<END
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
END
    }
  ]
end

def json_templates_zip_file_contents
  [
    {
      name:
      'spec/test_templates/json/ec2_volume/ebs_volume_with_encryption.json',
      contents: <<END
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
END
    },
    {
      name:
      'spec/test_templates/json/ec2_volume/' \
      'ebs_volume_without_encryption_string.json',
      contents: <<END
{
  "Resources": {
    "NewVolumeA": {
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
END
    },
    {
      name:
      'spec/test_templates/json/ec2_volume/' \
      'two_ebs_volumes_with_no_encryption.json',
      contents: <<END
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
END
    }
  ].map do |entry|
    {
      name: entry[:name],
      contents: entry[:contents].chomp
    }
  end
end
