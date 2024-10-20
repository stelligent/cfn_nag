# syntax=docker/dockerfile:1

FROM ruby:2.7-alpine

LABEL org.opencontainers.image.authors='Stelligent'
LABEL org.opencontainers.image.licenses='MIT'
LABEL org.opencontainers.image.source='https://github.com/stelligent/cfn_nag'
LABEL org.opencontainers.image.title='cfn_nag'
LABEL org.opencontainers.image.vendor='Stelligent'

# An explicitly blank version appears to grab latest.
# Pass the required version with `--build-arg version=${YOUR_VERSION}` for a real build process.
ARG version=''

RUN gem install cfn-nag --version "$version"

ENTRYPOINT ["cfn_nag"]
CMD ["--help"]
