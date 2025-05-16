# Steps
## ipynb files.
They are complete in themselves, but you can take a look how to know how the files are created. 
We create:

- `pivot_df`: Normal run + all status "completed" + uncleaned (2 files)

- `pivot_df_uncleaned`: Normal run + all status "completed" + ucleaned (2 files)

- `pivot_df_temp0`: Run with temperature = 0 + all status "completed" +     uncleaned (2 files)

- `pivot_df_temp0_uncleaned`: Run with temperature = 0 + all status "completed" + ucleaned (2 files)

- `output_` + TASK + `_uncleaned`: pivot_df input history and etc for uncleaned data

- `output_` + TASK + `_cleaned`: pivot_df input history and etc for cleaned data

- `output_` + TASK + `_temp0_uncleaned`: pivot_df input history and etc for uncleaned data + temperature = 0

- `output_` + TASK + `_temp0_cleaned`: pivot_df input history and etc for cleaned data + temperature = 0


## Folders
Output created after running the AgentBench Benchmarks. <br>
Reference: 
- withCaching: temperature = 0.7 + uses vLLm with caching
- withCaching0: temperature = 0 + uses vLLm without caching
- shareGPT: sends 1000 PROMPTS in one go
- shareGPT10: sends 10 PROMPTS in one go <br>
... rest follows same rule

## Zip file
updated AgentBench codebase to support vLLM. Next steps should be followed inside the unzipped codebase.

## Steps to start the AgentBench on your own. 
Make sure all the dockers are stopped
1. `python -m src.start_task -a` (Dockers take a while to start, give atleast 5 to 10 minutes to start, else you might see some errors. You can start again though.)
2. Start the vLLM server (with or without)
3. `python -m src.assigner --config configs/assignments/qwenVllm.yaml`

## Visualization
Inside Outputs folder. <br>
`Visualize.ipynb`: Givese general idea about the duration of the runs per file per tasks. <br>
`Visualize_diff.ipynb`: Givese general idea about the differences of duration of the runs per file per tasks. <br>
Same as before - `clean means data is cleaned with NaN values` and `temp0 means temp = 0`