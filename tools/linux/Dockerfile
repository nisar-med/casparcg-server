FROM docker.io/buildpack-deps:jammy as build-casparcg
	ADD tools/linux/install-dependencies /

	RUN apt-get update && /install-dependencies

  ENV SRT_COMMIT 1.5.3
  RUN wget https://github.com/Haivision/srt/archive/v${SRT_COMMIT}.tar.gz && \
    tar zxf v${SRT_COMMIT}.tar.gz
  WORKDIR /srt-${SRT_COMMIT}/build
  RUN cmake .. -DCMAKE_INSTALL_PREFIX="/usr/local"
  RUN make && make install
  WORKDIR /
	
  RUN mkdir /source && mkdir /build && mkdir /install

	COPY ./src /source


	ARG CC
	ARG CXX
	ARG GIT_HASH

	RUN wget https://github.com/nisar-med/casparcg-dependencies/releases/download/ffmpeg/ffmpeg-n5.1.3_jammy.tar.gz
  RUN tar -xzvf /ffmpeg-n5.1.3_jammy.tar.gz -C /tmp && \
      cp -a -n /tmp/opt/ffmpeg/* /usr/local/ && \
      ln -s /usr/local/lib/libsrt.so.1.5.3 /usr/lib/x86_64-linux-gnu/libsrt.so.1.5

	WORKDIR /build
  RUN cmake -GNinja -DUSE_SYSTEM_FFMPEG=ON /source
	# ensure ffmpeg dependencies are installed
	RUN apt-get update && /usr/local/install-ffmpeg-dependencies

	RUN ninja

  RUN wget https://github.com/nisar-med/casparcg-media-scanner/releases/download/v1.3.4/scanner.tar.gz
  RUN tar --strip-components=1 -xzvf scanner.tar.gz -C ./staging/bin/
	
  RUN wget https://github.com/nisar-med/casparcg-dependencies/releases/download/ndi/libndi.so.5.6.1.tar.gz
  RUN tar -xzvf libndi.so.5.6.1.tar.gz && \
      cp ./libndi.so.5.6.1 /usr/local/lib/
  # Find a better way to copy deps
	RUN ln -s /build/staging /staging && \
		/source/shell/copy_deps.sh /staging/bin/casparcg /staging/lib

FROM docker.io/nvidia/opengl:1.2-glvnd-devel-ubuntu22.04 as run-casparcg
	COPY --from=build-casparcg /staging /opt/casparcg

	RUN set -ex; \
			apt-get update; \
			DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
            tzdata \
			libc++1 \
			libnss3 \
			fontconfig \
			libavahi-client3 \
			xvfb \
      ffmpeg \
      wget \
			; \
			rm -rf /var/lib/apt/lists/*

	WORKDIR /opt/casparcg
	#COPY libs/libndi.so.5.6.1 ./lib/libndi.so.5
	ADD tools/linux/run_docker_xvfb.sh ./
	RUN chmod +x ./run_docker_xvfb.sh
	CMD ["./run_docker_xvfb.sh"]
