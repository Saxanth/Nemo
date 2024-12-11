bash ${VIRTUAL_ENV}/bin/activate && \
huggingface-cli login --token=hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --add-to-git-credential && git config --global credential.helper store && \
huggingface-cli download "black-forest-labs/FLUX.1-dev" --max-workers 4 && \
huggingface-cli download "meta-llama/Llama-3.2-11B-Vision-Instruct" --exclude "./original/*" --max-workers 4 && \
fastapi run application.py --host 0.0.0.0 --port 8080 --proxy-headers