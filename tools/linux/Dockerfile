FROM docker.io/buildpack-deps:jammy as build-casparcg
	ADD tools/linux/install-dependencies /

	RUN apt-get update && /install-dependencies

	RUN mkdir /source && mkdir /build && mkdir /install

	COPY ./src /source

	WORKDIR /build

	ARG CC
	ARG CXX
	ARG GIT_HASH

	RUN cmake -GNinja -DENABLE_HTML=OFF /source

	# ensure ffmpeg dependencies are installed
	RUN apt-get update && ./_deps/ffmpeg-lib-src/ffmpeg/install-ffmpeg-dependencies

	RUN ninja

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
			; \
			rm -rf /var/lib/apt/lists/*

	WORKDIR /opt/casparcg
	COPY libs/libndi.so.5.6.1 ./lib/libndi.so.5
	COPY tools/linux/scanner ./
	ADD tools/linux/run_docker_xvfb.sh ./
	RUN chmod +x ./run_docker_xvfb.sh
	CMD ["./run_docker_xvfb.sh"]
