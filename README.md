## To Build:
```
# For CUDA
DEVICE=cuda ./build.sh

# For ROCm
DEVICE=rocm ./build.sh
```

## To Compile A Model:
```
# For CUDA
docker run --gpus all -v /path/to/models:/models -v /path/to/output:/dist \
    -e DEVICE=cuda mlc-llm-compiler:latest-cuda

# For ROCm
docker run --gpus all -v /path/to/models:/models -v /path/to/output:/dist \
    -e DEVICE=rocm mlc-llm-compiler:latest-rocm
```

## Example Model Compile:
```
docker run --gpus all -v /home/mike/models:/models -v /home/mike/dist:/dist -e DEVICE=cuda -e MODEL_NAME=Hermes-3-Llama-3.1-70B -e CONV_TEMPLATE=hermes3_llamau mlc-llm-compiler:latest-cuda
```