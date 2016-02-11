assertion '.Resources|length > 0' do
  puts 'Must have at least 1 resource'
end


#use recurse to find all Ref and then cross-reference against .Resources|keys