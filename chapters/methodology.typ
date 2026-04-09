#import "../template.typ": *

= Methodology
<methodology>

#todo(position: "inline")[*This chap should answer: what did I do as a research process, and how did I evaluate it*]

== Research approach (contextualize study method)
This thesis is working towards a reusable framework that can help researchers and developers make informed decisions when integrating UMC outputs into pedestrian routing tools. 
To achieve this this thesis has a design-based research approach, in which new insights will be generated through iterative design, implementation, and consequent evaluation of the functionalities. The final tool serves both as a result of the research and as a way to investigate generalizable strategies for integrating urban microclimate data into web-based routing applications.
- design-based research approach why:
  - A routeplanner is a geosystem that has many components, all of which have their own challenges and impose limitations on the final result. Current research usually only delves into one of the elements, but rarely gives a complete overview of all implementation choices. This endangers the reusability and therefore scalability of the systems. This thesis aims to shine light on these technical foundations and identify in a very practical way which elements of development face which issues.  
  - research gap was present in the technical implementation -> previous work was focussed on showing a tool like this is useful, this work focusses on how you can build the technical foundatations to make the tool scalable and extendible. Focussing on the entire pipeline from data collection to the web ui, by actually building the full system every element of development is considered.
- The tool serves as a research artifact that is a result of the research and is evaluated on correctness. But also serves as a way to generate more generalizable stratagies for integrating UMC data in web-based routing applications. 

The goal of this thesis is to expose the underlying sytems on which a routeplanner is built. To identify limitations and opportunities of all the separate elements and make concrete recommendations and give measurements that enable the scalability of this tool. 
== Describe the study (document the research process)
Why is the development of a environmental routeplanner useful, why does the tool answer the research question. 
=== research steps
1. Use a literature review to identify functional requirements for this routing tool. -> what should the algorithm look like, how do we run SOLWEIG effectively and what elements should the routeplanner have.

2. Develop the tool? 

3. Evaluate/reflect the routeplanner on correctness and usability.
4. Reflect on the development process to gain generalizable insights. 
=== data & tools
- research area.
- using data preparation from solfd
  - what does the input data look like and what datasources are used for it
- using SOLWEIG_GPU
- using DelftBlue
- osm
-
== Development of the routeplanner (describe in step-by-step)
=== Data preperation
==== pip package
- developing pip package
==== OSM to pedestrian network representation.
- changing OSM to a pedestrian network.
=== UMEP execution
- Using SOLWEIG_GPU and ERA5 on an external machine -> DelftBlue
- what outputs are useful for routing
=== Integration within the pedestrian network
- sampling technique
- environmental factors as weights/cost
=== Routing algorithm design
- Using weighted dijkstra?
- User defined 'importance' metrics -> 'do you wanna walk in the sun?'
- combining all components
=== Application
- Prototype using Shiny
- Why API between routing and GUI

== Validation and evaluation of the routeplanner
- functional validation: are outputs consitent, does it make sense in a pedestrian context. (this balance between level of detail etc) (evaluate routes/inputs)
- intended purpose evaluation: are the routes significantly different, does it scale, is it easy to use and extend. (evaluate as a tool)
- reflection on implementation choices: How do i come to recommendations

== Limitations of this study design
- No dataset to compare my routes to, no questionares to people that use them. 
- many assumptions on how the world behaves
- validation stratagy is limited and assumes that a lower temperature on the roads limits heat stress. 
- any recommendations flowing from this are generalized as much as possible but stay in the realm of a route planner based on urban microclimate modelling.


/*
Q's this chapter should answer in the end:
Why was a design-oriented approach chosen?
What role does the tool play in answering the research question?
What were the stages of development?
What data, inputs, and assumptions were used?
How was the tool tested or validated?
How were lessons drawn from the design process?

*/
/*
== Research design 
The methodology is structured around four main phases, which are shown in @fig:overview_method.
#figure(
  image("../figs/research_steps.png", width: 100%),
  caption: [
    The 4 phases of this research
  ],
) <fig:overview_method>

Explain the stages of the study, for example:
analyze SOLWEIG outputs and routing requirements
design a data transformation pipeline
implement the routing prototype
test and evaluate functionality, scalability, and usefulness
derive generalizable recommendations/framework
3.3 Data and case study
Describe:
study area
SOLWEIG outputs used
street network data
any demographic, meteorological, or comfort threshold data
software stack

3.4 Methods for transformation and integration
This is still methodology, not implementation in full technical detail.
Here you explain conceptually:
how microclimate rasters or grids are converted into routing cost information
how costs are linked to pedestrian network segments
how routing logic incorporates thermal comfort
what assumptions you make
3.5 Evaluation strategy
Very important. Explain how you assess whether your approach works.
For example:
technical feasibility
computational scalability
quality of routing outputs
interpretability or applicability of results
usefulness of the framework for others
== design rationale
=== umepio (standardisation of data preperation)
a modular, reproducible preprocessing component was required
- the existing pipeline was fragmented, hard to reproduce, or difficult to scale
-preparing SOLWEIG input data required multiple preprocessing steps that needed standardization
- a modular package was needed to support openness, repeatability, and later integration into the routing workflow
- packaging the pipeline was part of answering the research question, because data transformation is a necessary step between raw microclimate inputs and tertiary application outputs

=== running solweig (SOLWEIG_GPU)


This thesis has a design-based research approach, in which new insights will be generated through iterative design, implementation, and consequent evaluation of the functionalities. The final tool serves both as a result of the research and as a way to investigate strategies for integrating urban microclimate data into web-based routing applications.



== Data preparation <data-preparation>
#figure(
  image("../figs/data_prep_methods.png", width: 100%),
  caption: [
    The necessary input datasets per tool that will be used in this research, the pink colored data still needs to be implemented.
  ],
) <fig:data_prep>
The first step of this research is the collection and preparation of all datasets required to run SOLWEIG and URock. This is partially supported by SOLFD @solfd_githum, which provides an automated data collection pipeline for the Netherlands tailored to SOLWEIG. URock, however, requires additional specialized input data that is not currently supported by SOLFD. As part of this thesis, the existing SOLFD pipeline will therefore be extended to also collect and prepare the necessary inputs for URock. Also, the pedestrian network is prepared for integration with environmental attributes.

== Operationalization <operationalization>
The goal of this phase is to address RQ1 through iterative code development.
#quote[_What design strategies and data structures enable the effective use of UMEP outputs  in scalable web-based applications?_]
This approach is adopted because limited prior research exists on how to operationalize UMEP outputs for scalable, web-based applications. The central design requirement is scalability, meaning that the system should be easily extendable to larger spatial extents (e.g., additional cities).
Two primary challenges are identified:
- *Space:* UMEP outputs consist of large raster datasets (.tif) containing hourly values that depend on meteorological conditions.
- *Time:* The computational cost of running UMEP simulations is substantial.
#figure(
  image("../figs/oper_methods.png", width: 50%),
  caption: [
    Workflow iterative code development: operationalizing UMEP outputs
  ],
) <fig:oper_methods>
Using the workflow shown in Figure @fig:oper_methods, two approaches are investigated for feasibility, with the aim of identifying techniques and bottlenecks when deploying UMEP-based workflows in web-based services:
- *Generalist:* Running UMEP (partially) on demand reduces storage requirements, as only model inputs need to be retained. In this case, computation time becomes the primary bottleneck.
- *Specialist:* Reducing storage requirements in a use-case–specific manner by synthesizing UMEP outputs into the pedestrian network prior to publication. This approach trades generality for efficiency.
To support these approaches, SOLWEIG-GPU is used, as it can operate outside the QGIS environment and enables GPU-based acceleration where possible. URock will be adapted in this thesis to also run independently of QGIS. This improves extensibility, for example, when deploying on a Linux server, since QGIS is no longer needed. Based on these outputs, PET is calculated and used as an input for routing. The PET values can be evaluated against measurements done in Rotterdam. 

== Routing <routing>
This phase will answering RQ2 trough iterative code development and literature review.
#quote[How can established multi-objective routing algorithms incorporate UMEP outputs and be implemented and adapted to automatically generate heat aware pedestrian routes?]
In contrast to the operationalization (@operationalization) phase, a substantial body of literature exists on “pleasant” or heat-aware routing. Therefore, the workflow for addressing RQ2 begins with a synthesis of existing research rather than exploratory experimentation. 
#figure(
  image("../figs/routing_methods.png", width: 50%),
  caption: [
    Workflow iterative code development: routing
  ],
) <fig:routing_methods>
From the literature, two key requirements for the routing strategy are derived:
1. The algorithm should account for route length as a contributor to heat exposure, as demonstrated by Wen et al. and Rußig & Bruns @wen_walking_smart_2025 @rusig_reducing_2017.
2. The algorithm should avoid reliance on researcher-defined weights, as used in approaches such as Aliyev et al. @aliyev1_exploiting_2025 @aliyev2_vehicle-pedestrian_2025.

The first requirement reflects the fact that both the duration and intensity of pedestrian activity influence experienced heat stress. The second requirement is motivated by scalability and extensibility: calculating trade-offs statistically on a route-by-route basis reduces subjectivity and enables the routing problem to be formulated as an optimization problem. This formulation of the algorithm also allows the inclusion of additional environmental factors beyond heat in future extensions.

== Application <application>
In this phase the actual implementation will be created, in doing so the RQ3 will be answered.
#quote[What does scalability mean for a pedestrian routing tool particularly regarding its potential for spatial and functional extension?]
The insights obtained from data preparation, operationalization, and routing are integrated into a web-based pedestrian routing tool. This application serves as a demonstration of the proposed framework, enabling evaluation of data processing, routing behavior, and system performance. The interface is used to reflect on the feasibility, extensibility, and clarity of presenting UMEP microclimate information within a user-facing routing tool. The tool will be built on top of the existing open-source infrastructure of the OpenRouteService #footnote[https://openrouteservice.org].
#pagebreak()
= Preliminary results
<preliminary-results>
== Data preparation
Steps have been made to start the collection of input data automatically, using SOLFD @solfd_githum and SOLWEIG_GPU @solweig_gpu_git. SOLFD outputs the Landcover, CHM, DTM and DSM which are displayed in @fig:solfd-output. SOLWEIG_GPU outputs the TMRT map which is displayed in @fig:solweig-gpu-output.

#figure(
  image("../figs/solfd_outputs.png", width: 100%),
  caption: [
    Input datasets needed for SOLWEIG generated by SOLFD @solfd_githum.
  ],
) <fig:solfd-output>
#figure(
  image("../figs/SOLWEIG_GPU_output.png", width: 50%),
  caption: [
    TMRT output map from SOLWEIG_GPU at band 0. @solweig_gpu_git
  ],
) <fig:solweig-gpu-output>
== Literature review
Existing literature has been evaluated to determine the best algorithm to be implemented for the routing problem. Leading to the expectations described in the methods section (@routing)



#set page(
  paper: "a4",
  flipped: true,
)

= Time planning
<time-planning>
#figure(
  image("../figs/timeplanning.png", width: 100%),
  caption: [Time planning with coding tasks per week],
)

#set page(
  paper: "a4",
  flipped: false,
)

= Tools and datasets used
<tools-and-datasets-used>
== Data preparation
- SOLFD @solfd_githum generates:
  - DTM (digital terrain model (includes buildings & vegetation)), DSM (digital surface model (only the ground)), CHM (only vegetation), Landcover (based on bgt (basisregistratie grootschalige topografie)), building polygons
- Use the DTM, DSM, CHM, and building polygons to generate the input data for URock -> building polygons with height values and vegetation polygons with height values.
- Overture maps #footnote[https://overturemaps.org] for the pedestrian network. Will be evaluated against just using Open Street Map data.

== Operationalization
- UMEP
  - SOLWEIG_GPU @solweig_gpu_git, stand alone python package that implements a sped-up version of SOLWEIG.
  - URock @bernard_urock_2023, currently implemented in UMEP-processing.
  - PET @lindberg_urban_2017 generator currently implemented in UMEP, uses outputs from SOLWEIG and URock.
== Routing
For routing, a tool like graphHopper or the OpenRouteService can be explored, since both implement an API to generate routes between cities. This is probably not necessary for the tool now, since it's only in one city.
== Application
OpenRouteService #footnote[https://openrouteservice.org]: open-source route planning tool implementing both a front-end and back-end. This was already used for pleasant routing by Foshag et al. (2024) and Novack et al. (2018) @foshag_how_2024 @novack_system_2018. GraphHopper also has an associated front-end, so this can also be explored.
*/