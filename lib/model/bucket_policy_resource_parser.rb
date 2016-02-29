
#this might be made general across IAM, but not worried about that right now just naming it what it is intended for
#originally
class BucketPolicyResourceParser

  def includes_wildcard?(resource)
    not (/^arn:aws:s3:::[^\/]*\/\*$/ =~ resource).nil?
  end
end