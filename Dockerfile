FROM swift:4.1
RUN apt-get update

RUN swift package update
RUN swift build --product main --configuration release
CMD .build/release/Dev