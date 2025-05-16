#!/bin/bash

# Define variables for the benchmark
BACKEND="vllm"
MODEL_NAME="deepseek-ai/DeepSeek-R1-Distill-Qwen-7B"
DATASET_NAME="hf"
NUM_PROMPTS=100
RESULTS_DIR="/home/ubuntu/gabriel/results"
SLEEP_SECONDS=30  # Number of seconds to sleep between tests

# Create an array of dataset paths
DATASET_PATHS=(
    # "agent-leaderboard/data/BFCL_v3_irrelevance"
    "agent-leaderboard/data/BFCL_v3_multi_turn_base_multi_func_call"
    "agent-leaderboard/data/BFCL_v3_multi_turn_base_single_func_call"
    "agent-leaderboard/data/BFCL_v3_multi_turn_composite"
    "agent-leaderboard/data/BFCL_v3_multi_turn_long_context"
    "agent-leaderboard/data/BFCL_v3_multi_turn_miss_func"
    "agent-leaderboard/data/BFCL_v3_multi_turn_miss_param"
    # "agent-leaderboard/data/tau_long_context"
    # "agent-leaderboard/data/toolace_single_func_call_1"
    # "agent-leaderboard/data/toolace_single_func_call_2"
    # "agent-leaderboard/data/xlam_multiple_tool_multiple_call"
    # "agent-leaderboard/data/xlam_multiple_tool_single_call"
    # "agent-leaderboard/data/xlam_single_tool_multiple_call"
    # "agent-leaderboard/data/xlam_single_tool_single_call"
    # "agent-leaderboard/data/xlam_tool_miss"
)

# Loop through each dataset path
for DATASET_PATH in "${DATASET_PATHS[@]}"; do
    echo "=========================================================="
    echo "Running benchmark with dataset: ${DATASET_PATH}"
    echo "=========================================================="
    
    # Create base filename from arguments
    BASE_FILENAME="${BACKEND}_${MODEL_NAME//\//-}_${DATASET_NAME}_${NUM_PROMPTS}"
    LOG_FILENAME="/home/ubuntu/gabriel/logs-agent-p1/${DATASET_PATH:23}.log"
    
    # Run the benchmark with unbuffered output to ensure all output is displayed
    stdbuf -oL python3 -u vllm/benchmarks/benchmark_serving.py \
      --backend ${BACKEND} \
      --model ${MODEL_NAME} \
      --endpoint /v1/completions \
      --dataset-name ${DATASET_NAME} \
      --dataset-path ${DATASET_PATH} \
      --num-prompts ${NUM_PROMPTS} \
      --save-result \
      --priority 1 \
      --multi-turn true \
      --result-dir ${RESULTS_DIR} \
      | stdbuf -oL tee "${LOG_FILENAME}"

    echo "Console output saved to ${LOG_FILENAME}"
    echo "=========================================================="
    
    # Sleep between tests unless this is the last dataset
    if [ ! "$DATASET_PATH" = "${DATASET_PATHS[-1]}" ]; then
        echo "Sleeping for ${SLEEP_SECONDS} seconds before the next test..."
        sleep ${SLEEP_SECONDS}
        echo "Resuming tests..."
    fi
done

echo "All benchmarks completed successfully!"
