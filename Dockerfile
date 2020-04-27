FROM ruby:2.5-alpine3.9@sha256:f33782620b363575ad95d19d0f0f07f7d197e9ccfee51f20df39dd33d408cdb4

LABEL org.opencontainers.image.authors="eric.kascic@stelligent.com"

# an explicitly blank version appears to grab latest
# override here for a real build process
ARG version=''

RUN gem install cfn-nag --version "$version"

ENTRYPOINT ["cfn_nag"]
CMD ["--help"]
