#import "../template.typ": *

= Results
<results>

This chapter details the measurements done associated with different design decisions. Every section in this chapter is associated with one of the sections in the methodology.

== Tests on DelftBlue
Major benefits in terms of allocation of resources f
=== small area
CPU: JOB START: 2026-04-08T13:36:34+02:00, JOB END:   2026-04-08T14:20:56+02:00\
job id: slurm-9558042.out
```
#SBATCH --job-name="solweig_on_CPU"
#SBATCH --partition=compute
#SBATCH --account=education-abe-msc-g 
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=2GB
```
- wall/aspect calc: 39 secs (parallel across 4 CPU cores with 2GB ram each)
- total time for full job: 44 minutes and 22 seconds

GPU: JOB START: 2026-04-08T13:41:41+02:00, 2026-04-08T13:49:16+02:00
```
#SBATCH --job-name="solweig_on_GPU_small"
#SBATCH --partition=gpu-a100-small
#SBATCH --account=education-abe-msc-g 
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --gpus-per-task=1
#SBATCH --mem-per-cpu=3GB 
```
- wall/aspect calc: 21 secs (parallel across 2 CPU cores with 3GB of ram each)
- total time for full job: 7 minutes and 21 seconds

=== medium area
For script & pythonfile calling the function: only change folder/job job-name.
GPU: JOB START: 2026-04-08T15:55:29+02:00, JOB END:   2026-04-08T16:14:38+02:00
slurm id: 9559473
```
#SBATCH --job-name="solweig_on_GPU_medium"
#SBATCH --partition=gpu-a100-small
#SBATCH --account=education-abe-msc-g 
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --gpus-per-task=1
#SBATCH --mem-per-cpu=3GB
```
- wall/aspect calc: 57 secs (parallel across 2 CPU cores with 3GB of ram each)
- total time for full job: 1.149 seconds 19 minutes and 9 seconds.

=== large area
change names to large and time to 2 hours (probs too big but to be sure). possibility of running out of CPU memory.\
slurm id: 9559539
```
#SBATCH --job-name="solweig_on_GPU_large"
#SBATCH --partition=gpu-a100-small
#SBATCH --account=education-abe-msc-g 
#SBATCH --time=02:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --gpus-per-task=1
#SBATCH --mem-per-cpu=3GB
```
- wall/aspect calc: 57 secs (parallel across 2 CPU cores with 3GB of ram each)
- total time for full job: 2.277 seconds 37 minutes 57 seconds