FROM openjdk:17-slim

# Install freetype, fontconfig, and basic fonts for Java
RUN apt-get update && \
    apt-get install -y libfreetype6 fonts-dejavu-core fontconfig && \
    apt-get clean

WORKDIR /app

COPY Watermark.java .
RUN javac Watermark.java

ENTRYPOINT ["java", "Watermark"]
