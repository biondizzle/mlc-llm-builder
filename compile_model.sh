#!/bin/bash

set -e

# Set the local vars from the environment
INPUT_DIR=${INPUT_DIR:-"/models"}
OUTPUT_DIR=${OUTPUT_DIR:-"/dist"}
DEVICE=${DEVICE:-"cuda"}
MODEL_NAME=${MODEL_NAME:-"Hermes-3-Llama-3.2-3B"}
QUANTIZATION=${QUANTIZATION:-"q4f16_1"}
CONV_TEMPLATE=${CONV_TEMPLATE:-"hermes3_llama"}
TENSOR_PARALLEL_SHARDS=${TENSOR_PARALLEL_SHARDS:-"1"}
EXTRA_CONVERT_WEIGHT=${EXTRA_CONVERT_WEIGHT:-""}
EXTRA_GEN_CONFIG=${EXTRA_GEN_CONFIG:-""}
EXTRA_COMPILE=${EXTRA_COMPILE:-""}

# Activate the appropriate virtual environment based on device
if [ "$DEVICE" = "cuda" ]; then
    cd /mlc-llm/cuda && source venv/bin/activate
elif [ "$DEVICE" = "rocm" ]; then
    cd /mlc-llm/rocm && source venv/bin/activate
else
    echo "Error: Unsupported device type: $DEVICE"
    exit 1
fi

# Check if the compiled model already exists
if [ -f "$OUTPUT_DIR/libs/$MODEL_NAME-$QUANTIZATION-$DEVICE.so" ]; then
    echo "Compiled model already exists, skipping compilation."
    exit 0
fi

# Ensure the models directory is accessible
if [ ! -d "$INPUT_DIR/$MODEL_NAME" ]; then
  echo "Error: Models directory '$INPUT_DIR/$MODEL_NAME' not found!"
  exit 1
fi

# Convert the weights
python -m mlc_llm convert_weight "$INPUT_DIR/$MODEL_NAME/" \
    --quantization $QUANTIZATION \
    --device $DEVICE \
    -o "$OUTPUT_DIR/$MODEL_NAME-$QUANTIZATION-MLC" $EXTRA_CONVERT_WEIGHT

# Generate the config
python -m mlc_llm gen_config "$INPUT_DIR/$MODEL_NAME/" \
    --quantization $QUANTIZATION \
    --device $DEVICE \
    --conv-template $CONV_TEMPLATE \
    --tensor-parallel-shards $TENSOR_PARALLEL_SHARDS \
    -o "$OUTPUT_DIR/$MODEL_NAME-$QUANTIZATION-MLC/" $EXTRA_GEN_CONFIG

# Compile the model
python -m mlc_llm compile "$OUTPUT_DIR/$MODEL_NAME-$QUANTIZATION-MLC/mlc-chat-config.json" \
    --device $DEVICE \
    --overrides "tensor_parallel_shards=$TENSOR_PARALLEL_SHARDS" \
    -o "$OUTPUT_DIR/libs/$MODEL_NAME-$QUANTIZATION-$DEVICE.so" $EXTRA_COMPILE

echo "Model compilation completed!"