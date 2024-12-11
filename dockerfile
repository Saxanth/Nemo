# attempting to build a container for my 'nemo' image generating app
FROM nvidia/cuda:12.6.2-base-ubuntu24.04 AS builder

ENV HF_HUB_DOWNLOAD_TIMEOUT=60
ENV HF_HUB_ENABLE_HF_TRANSFER=1

ENV NEMO_ROOT=/nemo
ENV NEMO_SRC=/opt/apps/nemo
ENV VIRTUAL_ENV=/opt/venv/nemo
ENV HUG_ROOT=/root/.cache/huggingface

ENV PATH="$VIRTUAL_ENV/bin:$NEMO_SRC:$HUG_ROOT:$PATH"

ARG DEBIAN_FRONTEND=noninteractive
RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
        apt update && apt-get install -y git python3-venv python3-pip build-essential

RUN mkdir -p ${NEMO_ROOT} && chown -R ${CONTAINER_UID:-1000}:${CONTAINER_GID:-1000} ${NEMO_ROOT} && \
    mkdir -p ${HUG_ROOT}  && chown -R ${CONTAINER_UID:-1000}:${CONTAINER_GID:-1000} ${HUG_ROOT}

WORKDIR ${HUG_ROOT}

RUN --mount=type=cache,target=/root/.cache/pip \
    python3 -m venv ${VIRTUAL_ENV} && bash ${VIRTUAL_ENV}/bin/activate && \
    pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 && \
    pip install pytorch-lightning lightning-sdk litserve "litgpt[all]" && \
    pip install "fastapi[standard]"  "uvicorn[standard]" pydantic "pydantic[email,timezone]" && \
    pip install "huggingface_hub[cli]" diffusers[torch] -U

WORKDIR ${NEMO_ROOT}/app
ADD ./app/. .
COPY ./startup.sh ../
SHELL [ "/bin/bash", "-c" ]
CMD ["/bin/bash", "../startup.sh"]