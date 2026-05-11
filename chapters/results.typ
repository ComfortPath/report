#import "../template.typ": *

= Results
<results>

This chapter details the measurements done associated with different design decisions. Every section in this chapter is associated with one of the sections in the methodology.

== Generalizable insights
=== full tool
- modularity/ component based design as a core design element to support scalability, extensibility and reusability of the route planner.
=== data preperation
- Ease of use as an important componenet in how useful 
- Running SOLWEIG on demand bottlenecked by input data download latency and method (merge for CHM)

- Unnoticed loss of detail by using automatic filtering in the OSM collection. Nothing wrong with losing information but abstracting these steps means that the final user might lose information without knowing why. -> which software you choose can thus have an unnoticed effect on the final result. 

=== running SOLWEIG
- Running SOLWEIG on (fast) external machine, indipendent process, so very well suited. especially in a research context there is usually university wide compute available.

- SOLWEIG\_GPU benchmarks completely dependent on hardware availability so while information is usefull, this thesis does not proved a complete benchmarking on different amounts of avaialable GPU RAM. General recommendation would be to do performance tests on your own devices to see the speed. 

a100 80GB of RAM: 19 min (could probably be faster with tile size optimized for this large amount of RAM) around 60 secs for 1000x1000 tile.
a100 10GB of RAM: 37 min
=== Integration within the pedestrian network
- pedestrian network not discussed in detail in current papers
- small size allows for the incorportaion of a large amount of input variables.
- resolution of input data?
- sampling different values for thermal comfort 
  - difference in routes?
  - conceptual difference: what are we measuring?
=== routing prototype
- Combining step of all abstractions of the previous components of the route planner. 
- Implementation type of least-cost algorithm is entirely use-case dependent, an algorithm is only as good as it's input data.
- While what the algorithm is doing can be computed, to a degree: black-box. 
- Application not as important as previously expected.
- input should be dynamic, most exiting use case could be for avoiding heat. but also possibility for 
- many options for how to translate temperature to thermal comfort -> many ways to rome, but value in acknowleding these variantions.
== Tests on DelftBlue
On only 10GB of Ram (available via delftblue) these are the results.
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