#!/bin/bash

# Define variables for the benchmark
BACKEND="vllm"
MODEL_NAME="deepseek-ai/DeepSeek-R1-Distill-Qwen-7B"

DATASET_NAME="sharegpt"
DATASET_PATH="/home/ubuntu/gabriel/ShareGPT_V3_unfiltered_cleaned_split.json"

NUM_PROMPTS=100

# Create base filename from arguments
BASE_FILENAME="${BACKEND}_${MODEL_NAME//\//-}_${DATASET_NAME}_${NUM_PROMPTS}"
LOG_FILENAME="/home/ubuntu/gabriel/logs-loop/${BASE_FILENAME}.log"
RESULTS_DIR="/home/ubuntu/gabriel/results"

# Run the benchmark with result saving enabled and capture console output
python3 vllm/benchmarks/benchmark_serving.py \
  --backend ${BACKEND} \
  --model ${MODEL_NAME} \
  --endpoint /v1/completions \
  --dataset-name ${DATASET_NAME} \
  --dataset-path ${DATASET_PATH} \
  --num-prompts ${NUM_PROMPTS} \
  --save-result \
  --num-runs 1000 \
  --result-dir ${RESULTS_DIR} \
  | tee "${LOG_FILENAME}"

echo "Console output saved to ${LOG_FILENAME}"
