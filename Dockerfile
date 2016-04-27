FROM dockerfile/ubuntu

# Install Ruby
RUN apt-add-repository ppa:brightbox/ruby-ng && apt-get update && apt-get install -y ruby2.2

WORKDIR /workspace

RUN gem install nexus

ADD ./Gemfile Gemfile
ADD ./lib lib
ADD ./cucumber_testrail.gemspec cucumber_testrail.gemspec
ADD ./deploy.sh deploy.sh

ENTRYPOINT ["./deploy.sh"]
CMD ["--help"]
