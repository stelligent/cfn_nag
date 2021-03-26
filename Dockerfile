FROM ruby:2.7-alpine

# an explicitly blank version appears to grab latest
# override here for a real build process
ARG version=''

RUN gem install cfn-nag --version "$version"

ENTRYPOINT ["cfn_nag"]
CMD ["--help"]
