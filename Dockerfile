FROM ruby:alpine

LABEL maintainer="steyn@oblcc.com"
LABEL name="cfn-nag"
LABEL version="0.3.4"

RUN gem install cfn-nag -v "0.3.4" && gem cleanup

CMD ["cfn_nag"]
