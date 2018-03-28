
# failure(id: 'F8888',
#         jmespath:
#         "Resources.*|[?Type == 'AWS::EC2::Volume' && " \
#         "(Properties.Encrypted == `false` || " \
#         "Properties.Encrypted == `null`)].id",
#         message: 'Found a naughty EBS volume')
