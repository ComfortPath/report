#import "../template.typ": *

= Methodology
<methodology>

#todo(position: "inline")[*This chap should answer: what did I do as a research process, and how did I evaluate it*]

== Research approach (contextualize study method)
The goal of this thesis is to investigate how urban microclimate (UMC) outputs can be integrated into pedestrian routing tools in a way that is open-source, scalable, and reusable. To do this this thesis applies a Design Science Methodology (DSM), with which knowledge is derived from the development of an artifact @runeson_design_2020 @wohlin_design_2021. This pedestrian routing tool thus serves as both a result of the research and as a way to investigate generalizable strategies for integrating urban microclimate data into web-based routing applications.

DSM lends itself to this problem because this type of routeplanner is a complex system depending on multiple interconnected components, each whith its own technical challenges and constraints. For each of these components the design logic is applied by defining: problem conceptualisation, solution design and evaluation @wohlin_design_2021.  This thesis systamatically examines the seperate components, identifying practical bottlenecks, trade-offs and implementation choices that shape the final tool. These insights can then be used in further research which employs UMEP outputs or builds a similar routing tool. 

== Describe the study (document the research process)
<research-steps>
Existing research has shown the possibility and usefulness of themally informed routing, but paid less attention to the technical foundantions. This thesis adresses this gap by considering the full pipline of the components which make up a route planner. Building the full system allows for evaluation of the final tool, but also generates insights for technical limitations and opportunities found during development. 

=== research steps
#todo(position: "inline")[step 2 is by far the biggest, change to match at the end]
In broad steps these are the stages the research went through:
1. A literature review is conducted to identify the functional requirements of the routing tool. This review informs the core components of the application, the role of SOLWEIG in the workflow, and the desired routing logic.

2. The route planner is developed iteratively by treating its main stages as separate but connected design components. This allows each component to be designed, analysed, and refined before being integrated into the complete system.

3. The resulting route planner is evaluated with regard to its correctness and practical usability.

4. The development process is reflected upon to identify key challenges, trade-offs, and effective implementation choices. These reflections are used to derive broader insights and practical recommendations for future UMC-informed routing applications.

=== Data & tools
For testing a bounding box was chosen of a neighbourhood in Rotterdam with varying urban features: green & blue corridors, parks and different types of roads. As displayed in @fig:bbox the bounding box spans about 2.5 kilometers north and 2 kilometers east to west. This is to limit the calculation time for SOLWEIG and data download. An area of this size allows for in depth testing without great demands on runtime. 

#figure(
  image("../figs/methods/testing_area.png", width: 80%),
  caption: [
    Red bounding box area for testing
  ],
) <fig:bbox>
#table(
  columns: (1fr, auto, auto),
  inset: 10pt,
  align: horizon,
  table.header(
    [], [*left lower corner*], [*right top corner*],
  ),
  [WSG84 (lat/long)],
  [51°52'46.75"/4°27'39.74"],
  [51°53'48.48"/4°28'59.42"],
  [RDNEW],
  [(91229,432752)],
  [(92777,434641)]
)
- using data preparation from solfd
  - what does the input data look like and what datasources are used for it
- using SOLWEIG_GPU
- using DelftBlue
- OSM
- UMEP
== Development of the routeplanner 
#todo(position: "inline")[Relate to RQ's. Currently this is too seperate from them.]
// reason being: the sub RQ's as they are now are maybe a little too oriented on  the routeplanner as an outcome than the development of concrete recommendations.
To ensure the insights gathered in this thesis are as broadly applicable as possible, the components are developed and evaluated seperately. In existing research there is a wide variety of methodologies, suggesting that there are multiple valid ways of building a tool like this. By separating the research into component-level design elements, the findings associated with each part can be applied flexibly across different methodological contexts.

Each component is framed as a specific problem–solution pair, where the problem statements are derived from approaches in existing literature and evaluating them against the desired software property of scalability. The proposed solutions are informed both by existing literature and by insights gained in earlier development stages.#todo[At the end: is this what I've acutally done?] The validation of these individual design elements is described in @validation.

=== Data preperation
- existing literature: loads of different sources of input data -> environmental information gathered through a variety of sources, some of which are not accessible. -> difficult to scale.  
- solution: use minimal open input data and UMEP 
- how: Use SOLFD data preperation framwork developed by Monohan @monahan_cool_2025 that automatically generates 
- ease of access
-> standardizes (for the dutch context )
==== pip package
- problem: usability of code reduces by the way it is distributed, only having this framwork available as sections of code in a github repository greatly limits the reusability
- Solution: publish the code as a public pip package, especially since the automatic collection of this data could be used for more analyses than just running SOLWEIG.
- How: implement what is described above...

==== OSM to pedestrian network representation
*Not really discussed in existing research*
- problem: there are general limitations to using the OSM -> describe them here?
- solution: mitigation of the consequencces by clearly documenting the (lack of)availability of certain tags & going into detail on the test area
- special case since the 'true fix' does not exist, there is no prefect input data. 

=== UMEP execution
- Problem: UMEP's SOLWEIG takes forever to run and the ouputs are gigantic.
- test two solutions: general & specific
how:
- general: test runtimes for collecting data using UMEPIO -> invesitgate feasibility of runnign UMEP on demand when having a GPU speed-up and pedestrian lenght route (not likely longer than 2km)
- specialization: offload runtime to fast external machine, compute available at university. Deal with the gigantic size by folding information into pedestrian network (context specific possibility).
- Using SOLWEIG_GPU and ERA5 on an external machine -> DelftBlue
- what outputs are useful for routing

=== Integration within the pedestrian network
* not really discussed in research*
- Problem: how can attach weights to the edges that summerize the UMEP outputs to the edges. In technical sense, raster needs to fit into memory for lookup. Context: the rastercells are flattened into one value for a single edge (what's the best way). 
- Solution: implement it?? Sampling should be described. 
- sampling technique
- environmental factors as weights/cost
=== Routing algorithm design
problem: algorithm should be dynamic -> as a pedestrian walks the length of being in heat is increasingly bothersome.  Algorithm should not just have researcher defined weights, since the situation can change for different user preferences. 
- Using weighted dijkstra?
- User defined 'importance' metrics -> 'do you wanna walk in the sun?'
- combining all components
=== Application
*Not done or discussed in most research papers*
- Prototype using Shiny
- Why API between routing and GUI

== Validation and evaluation of the routeplanner (analyzing the data)
<validation>
Runeson et al. note that insights from design-based research are inherently context based @runeson_design_2020. 
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