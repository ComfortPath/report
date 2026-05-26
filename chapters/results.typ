#import "../template.typ": *

= Results and analysis
<chap:results>
This chapter presents the main results of the developed workflow and analyses what they reveal about thermally conscious pedestrian routing. It first reflects on insights that emerged during the development process, before evaluating the implemented tool through its performance and routing outcomes. The detailed emergent design process is summarized in the Appendix: @appendix-A.

== Generalizable insights from the emergent process
This section synthesizes the main lessons from the emergent development process. Rather than repeating each design decision from the methodology chapter, it focuses on what the implementation revealed about the conditions under which a thermally conscious pedestrian routing tool can be scalable, reusable, and computationally feasible.

=== Scalability through ease of use
During input-data preparation it became visible that scalability (in part) depends on the reusability and ease of use of the supporting workflow. Since reducing manual steps and standardizing execution were necessary before the SOLFD @monahan_cool_2025 workflow could be reused reliably. Publishing the data-preparation pipeline as the pip package #link("https://pypi.org/project/umepio/")[UMEPIO] therefore contributed to scalable transformation of SOLWEIG input data by making the preceding environmental-data workflow easier to reproduce, automate, and apply in other contexts.

=== Pedestrian network assumptions
The preparation of the pedestrian network showed that network extraction and representations are not neutral steps in the process. The environmental data is ultimately linked to the geometries of the pedestrian network, but these geometries are themselves abstractions. In this thesis, the network is based on OpenStreetMap geometries, which often represent movement through centre lines. Which is appropriate for car travel, but these centre lines do not necessarily correspond to actual walking paths, especially in areas where pedestrians would move on sidewalks or squares.

This matters because the thermal conditions assigned to a network edge depend on where that edge is geometrically located. If the geometry does not represent the actual pedestrian position, the sampled environmental conditions may also differ from the conditions pedestrians experience in reality. This does not make the network unusable, but it does mean that pedestrian network preparation should be treated as a methodological decision rather than as a purely technical input step. @fig:pedestrian_inf shows which parts of the network have tags that are related specifically to pedestrian use. 

#figure(
  grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: alignment.horizon,
    image("../figs/results/netw_dedic_peds.png", width: 120%),
    image("../figs/results/sid_pres.png", width: 100%)
  ),
  caption: "(Left) Green edges represent edges that have tags denoting them as dedicated pedestrian infrastructure. (Right) the blue edges represent segments that have explicit sidewalk tags.  "
)<fig:pedestrian_inf>

The development process also showed that automatic filtering of OpenStreetMap data can introduce unnoticed data loss. Existing download tools (like OSMnx @osmnx_geoff_2025) simplify network collection, but they may remove sidewalk and footway information. Losing information is not necessarily problematic when it is intentional and documented. However, since the filtering is hidden inside an abstraction layer, the final user may not know which information has been removed or why. This means that the choice of software used for data collection can influence the final routing result in ways that are not immediately visible.

Another practical insight concerns the representation of directionality. The standard NetworkX representation stores bidirectional movement using duplicate directed edges, one edge $u -> v$ and one $v -> u$. Pedestrian movement can be treated as undirected, so this representation creates redundant information. It doubles storage demand and processing time during annotation, because all connections are considered double. This shows that standard network representations should be questioned when their assumptions do not match the use case. A representation that is useful for general network analysis is not necessarily the most efficient data structure for scalable pedestrian routing.

=== SOLWEIG computation
Running SOLWEIG on demand is not feasible for interactive routing using the current workflow. Initially, running SOLWEIG only for the area directly required by a route seemed attractive, because it would avoid generating environmental data for unused areas. In practice, however, this approach was bottlenecked by input data collection process. Downloading and merging the required tiled input data for all data sources introduced too much latency for route-time computation. AAs a result, SOLWEIG outputs need to be precomputed and transformed before routing, rather than generated during route calculation.

This workflow is well suited to external compute infrastructure. However, the performance of SOLWEIG_GPU depends strongly on the specific computing environment, including available GPU memory, tile size, and shared workload conditions. For example, runs on an A100 GPU with 80 GB of available memory took approximately 19 minutes, while runs with 10 GB of available GPU memory took approximately 37 minutes. In practice, each implementation should test SOLWEIG_GPU on the available hardware before drawing conclusions about the computation time needed to run SOLWEIG_GPU for a large area. 

#figure(
  image("../figs/methods/UTCI_15.png", width: 100%),
  caption: [The UTCI of the study area at 15:00. ]
) <fig:utci-15>

=== SOLWEIG integration in the pedestrian network
Integrating environmental information into the pedestrian network showed that file format choices can have a large effect on performance. This was especially visible when comparing multidimensional GeoTIFF storage with a Zarr-based structure. While a GeoTIFF can store spatial data, it was less suited to the repeated spatial and temporal lookup required during network annotation. Zarr better matched this access pattern and therefore improved network sampling performance on the study area from 5 minutes to 10 seconds. 

This illustrates a broader point: file formats should be chosen based on how the data will be used, not only on whether they can store the required information. In this workflow, the environmental data are not visualized as maps; they are repeatedly queried to annotate many network edges. This is especially relevant for geodata, where the location of each value is part of its meaning and data access is often spatially organized. A format that supports repeated spatial and temporal lookup can therefore provide substantial performance gains.

The same principle applies to the storage of the pedestrian network. Using an explicit column-based format such as Parquet improved clarity because it required the network to be stored as a structured data table rather than as a fixed graph object. This separation between persistent storage and internal routing representation made the workflow more modular. Each component could transform the shared data into the structure best suited to its own computation.

This would have been more difficult with a more static network format such as GML, where the graph representation is embedded in the file structure and additional preprocessing would be needed before the data could be used in array-based routing. This shows that the chosen file formats can either support or constrain flexibility and performance when integrating SOLWEIG outputs in the pedestrian network.

=== Routing implementation
A routing-specific internal representation based on simplified NumPy arrays was used. In this representation, a single thermally conscious route took approximately 0.0364 seconds on average to compute. This suggests that, once the environmental data have been prepared and incorporated into the network, the routing calculation itself is not the main computational bottleneck.

The separation between the routing backend and the application was important because they serve different functions. The backend handles data access, route calculation, and thermal comfort costs, while the application focuses on interaction and visualization. Keeping these responsibilities separate improved the cohesion of the system. The communication between these two using an API supports reusability since the routing backend can be accessed by different interfaces without changing the underlying routing logic.

The development process also showed that the research value of the front-end was more limited than initially expected. For this thesis, the front-end mainly needed to demonstrate that the routing algorithm could be used interactively and that the results could be visualized. 

== Evaluation of the tool
=== Performance of the implemented workflows
#todo[put a part of this in methodology]
The runtime tests in @res:scalability should not be interpreted as a structured benchmark, but as an indicative comparison of the relative computational cost of the different workflow components on the available hardware. SOLWEIG was executed on DelftBlue using an A100 GPU with 10 GB of available GPU memory, while the remaining steps were executed locally on a MacBook Air with an M2 chip. The purpose of these tests was therefore not to establish general performance values, but to show where the main computational bottlenecks occur within this implementation and how changes in spatial resolution affect each step of the workflow.

The results show that the preparation and simulation of the UMEP/SOLWEIG data are the most computationally demanding parts of the workflow. In particular, SOLWEIG execution time decreases substantially when the spatial resolution is reduced. This is expected, because a coarser resolution reduces the number of raster cells that need to be processed during the simulation. For the study area, increasing the resolution from 0.5 m to 1 m reduced the SOLWEIG runtime from 39.17 minutes to 8.50 minutes, while a resolution of 1.5 m further reduced the runtime to 4.97 minutes. Network annotation was comparatively fast in all cases, taking only a few seconds once the environmental outputs had been generated and stored in the required format.

The test on a different area was included to assess whether the workflow could be applied outside the original study area without requiring changes to the pipeline. No implementation issues were encountered: the new bounding box could be inserted into the same data preparation, SOLWEIG execution, and network annotation steps. The calculation times were slightly lower than for the original study area, which is likely related to the smaller spatial extent of the second area.

The effect of spatial resolution on the quality of the thermal outputs was not validated in this thesis. From a computational perspective, lowering the resolution clearly improves performance, especially for SOLWEIG execution. Yet a coarser resolution also reduces the spatial detail of the simulated microclimate conditions and therefore affect the accuracy of the thermal attributes assigned to the pedestrian network. Without validation against observed thermal comfort data or human thermal perception, it is not possible to determine whether the performance gains from lower-resolution simulations justify the potential loss of accuracy. 

#figure(
  table(
  columns: (auto, auto, auto, auto),
  inset: 10pt,
  align: horizon,
  table.header(
    [*Data set*], [*UMEPIO*], [*SOLWEIG execution*],[*Network annotation*],
    [Study area (resolution 0.5 meter)],[18.12 min],[39.17 min],[10 seconds],
    [Study area (resolution 1 meter)],[13.93 min],[8.50 min],[6 seconds],
    [Study area (resolution 1.5 meter)],[14.38 min],[4.97 min],[5 seconds],
    [Different area],[9.56 min],[26.59 min],[8 seconds]
  ),
    ),
  caption: [Runtimes for different resolutions ]
)<res:scalability>

=== Route validation
The route validation is done based on a generated set of stratified Origin-Destination (OD) pairs (@chap:methodology: @fig:OD_pairs). The two forms of validation are described in this section: manual and structured. The goal of the manual analysis is to circle back to the initial input data, since this was flattened into the pedestrian network to a single value per edge, even though the edges can have a high variability along themselves. The goal of the structured validation is to check the average performance of the algorithm across different route lengths. 
==== Manual 
#figure(
  grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: alignment.horizon,
    image("../figs/results/manual/pair_229_route_comparison.png", width: 100%),
    image("../figs/results/manual/pair_408_route_comparison.png", width: 70%)
  ),
  caption: "Shortest (cyan) and most thermally comfortable (magenta) path for OD pair 229 and 408,"
)<fig:man-short-comf>
For the manual analysis two routes were chosen from the stratified OD pairs (see @fig:man-short-comf). These routes were in the top 25% of routes in terms of UTCI reduction, and from those the two routes with minimal difference in distance. This represents the optimal use-case for the routing tool, mainly a case that shows the usefulness of the tool, since it shows the highest gains for the minimal effort. OD pair 229 has some shared edges, but diverges twice to use more thermally comfortable sub paths. OD pair 408 follows an entirely different path for the shortest and thermally comfortable routes, with no shared edges.

#figure(
  grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: alignment.horizon,
    image("../figs/results/manual/pair_229_utci_sampled_cells.png", width: 120%),
    image("../figs/results/manual/pair_408_utci_sampled_cells.png", width: 100%)
  ),
  caption: "Sampled UTCI cells plotted on the shortest and most thermally comfortable path for OD pair 229 and 408."
)<fig:utci-on-route>

#figure(
  grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: alignment.horizon,
    image("../figs/results/manual/pair_229_route_comparison_utci_background.png", width: 120%),
    image("../figs/results/manual/pair_408_route_comparison_utci_background.png", width: 100%)
  ),
  caption: "Shortest and most thermally comfortable path for OD pair 229 and 408, plotted on top of original UTCI map."
)<fig:route-on-utci>

The paths in @fig:utci-on-route show which raster cells were sampled along the route. As you can see cells sampled by the thermally conscious route are usually less warm along the route. Closer inspection of the original UTCI map around the route in @fig:route-on-utci #footnote[Figure legend scale capped at maximum values found sampled along the route, this is to ensure maximum contrast for analysis along the route. Since there are some disproportionally high values in the UTCI map far from the route that skew the colour scale. However, it does mean that the plot is slightly different from the full plot of ] that the thermally conscious route primarily chooses parts of the map that are filled with vegetation. This can be seen by the round shaped cools pots on the UTCI map which are trees. 

The increased presence of vegetation along the thermally more comfortable route is also visible in the satellite imagery shown in @fig:sat-roads. At the first deviation between the two routes for OD pair 229, the thermally comfortable route follows `Roerdomplaan` and `Lepelaarsingel`, rather than the shorter alternative via `Dorpsweg` and `Wielewaalstraat`. The satellite imagery indicates that `Wielewaalstraat` contains relatively little vegetation, which is consistent with the higher UTCI values assigned to this segment. In contrast, `Roerdomplaan` is characterized by a greater presence of vegetation and is therefore selected by the routing algorithm as the thermally preferable alternative.
#figure(
  image("../figs/results/manual/sat_comp.png", width: 100%), 
  caption: "Satellite images of first deviant roads OD pair 229, roads in the shortest path (left) and roads in the most comfortable path (right)."
)<fig:sat-roads>


==== Structured
This analysis aims to show the general performance of the algorithm on the study area. The evaluation was based on a set of origin-destination pairs divided into five distance categories: `max_distance`, `medium_long`, `medium`, `short_mid`, and `short`. In total there were 5 distance categories and 100 OD pairs per category, all with different orientations and positions on vertices in the investigated area @fig:OD_pairs. Each category contained 100 OD pairs with different positions and orientations across the pedestrian network. For every OD pair, the shortest route was calculated once and thermally comfortable routes were calculated for five hours: 08:00, 12:00, 15:00, 18:00, and 22:00. This resulted in 3000 route calculations in total.

The user can configure the importance of the weights. For these tests the default weights were used where the importance of the UTCI is 1: it's only based on @tab:heat_multipliers. And consecutive hot edges are punished. 

The results are evaluated using three main indicators. The first is route distance, which shows how much longer the comfortable route becomes compared with the shortest route. The second is average UTCI, which shows whether the comfortable route reduces thermal exposure. The third is route deviation, measured as the number of edges in the comfortable route that are not present in the shortest route. Together, these indicators show not only the trade-off between thermal comfort and additional walking distance, but also how different the routes are.

#figure(
  grid(
  columns: (1fr),
  gutter: 1em,
  align: alignment.horizon,
    image("../figs/results/structured/average_distance_absolute_by_category_hour.png", width: 100%),
    image("../figs/results/structured/average_distance_difference_by_category_hour.png", width: 100%)
  ),
  caption: "Absolute average distance of the routes (top), average difference in distance between shortest and most comfortable route (bottom)"
)<fig:res-dist>

The distance results in @fig:res-dist show that the comfortable routes are generally only longer than the shortest routes during the warmer hours. At 08:00 and 22:00, the average distance difference is close to zero for most categories, indicating that the comfortable route often remains identical or very similar to the shortest route. This is expected, because the algorithm is designed to penalize hot edges; if there are only a few hot edges at these times, there is little reason to select an alternative route. The largest distance increases occur at 15:00 and 18:00, especially for the longer distance categories, showing that the algorithm takes longer detours when avoiding heat becomes more relevant.

The average distance increase in the higher distance categories is about 70m which is the same as perceived distance increase caused by one extra degree in the UTCI @basu_hot_2024. The average distance increase for more comfortable routes is around 4\% across categories which is a little lower than previous work @rusig_reducing_2017 @ma_active_2025. #todo[move to discussion?]Indicating that if the user were to assign a higher importance to reducing the UTCI, the routes would still be sensible.

#figure(
  grid(
  columns: (1fr),
  gutter: 1em,
  align: alignment.horizon,
    image("../figs/results/structured/average_new_comfortable_route_edges_by_category_hour.png", width: 100%),
  ),
  caption: "Amount of new segments (edges) in the comfortable route that are not in the shortest."
)<fig:res-diff>
The number of different edges follows the same pattern as the distance increase @fig:res-diff. Comfortable routes at 15:00 and 18:00 include more edges that are not part of the shortest route, particularly for the longer OD categories. This shows that the algorithm does not only increase route length slightly, but can also select partly different paths through the network when hot edges are present. At 08:00 and 22:00, the number of newly used edges is much lower, which again suggests that the shortest route often already avoids heat exposure, if it even is there, at these times.


#figure(
  grid(
  columns: (1fr),
  gutter: 1em,
  align: alignment.horizon,
    image("../figs/results/structured/average_utci_absolute_shortest_vs_comfortable_by_category_hour.png", width: 100%),
    image("../figs/results/structured/average_utci_difference_by_category_hour.png", width: 100%)
  ),
  caption: "Absolute average UTCI of the routes both the UTCI of the shortest and the most comfortable route (top), average difference in UTCI between shortest and most comfortable route (bottom)"
)<fig:res-utci>

The UTCI results in @fig:res-utci show that the additional distance taken by the comfortable routes generally corresponds to a reduction in average UTCI. The route-level UTCI was calculated as an edge-length-weighted average, meaning that the UTCI value of each edge was weighted by its length before being averaged over the full route. As a result, longer edges have a larger influence on the route average than very short edges. The comfortable routes have a lower average UTCI than the shortest routes, especially during the warmer hours. The largest reductions occur at 15:00 and 18:00, while the differences at 08:00 and 22:00 are small or close to zero. 

The reduction in UTCI at 12:00 is lowest of the 'hot times' measurements. This could be caused by the high position of the sun, which reduces the extent to which urban geometries such as buildings and vegetation cast shade. A similar effect was observed by Wen et al. (2025) at this time @wen_walking_smart_2025. In addition, the limited number of edges classified into the highest UTCI categories, as shown by the lower average UTCI as compared to 15:00 and 18:00, may reduce the influence of the heat-penalty factors shown in @tab:heat_multipliers. As a result, the routing algorithm has fewer strongly penalized edges to avoid and is therefore less likely to select a substantially different route. The reduction in UTCI is generally larger for the longer distance categories, where more alternative edges are available.

The reductions in UTCI are slightly lower than what is achieved in previous work @rusig_reducing_2017 @ma_active_2025. This can be attributed to the lower attributed importance of avoiding heat, which leads to a lower distance as well. Additionally, the results from Ma et al. were gathered in Hong Kong which has a different climate. #todo[Should this sort of analysis be in discussion]

#figure(
  grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: alignment.horizon,
    image("../figs/results/structured/distance_difference_vs_utci_difference_category_max_distance.png", width: 100%),
    image("../figs/results/structured/distance_difference_vs_utci_difference_category_medium_long.png", width: 100%),
    image("../figs/results/structured/distance_difference_vs_utci_difference_category_medium.png", width: 100%),
    image("../figs/results/structured/distance_difference_vs_utci_difference_category_short_mid.png", width: 100%),
    image("../figs/results/structured/distance_difference_vs_utci_difference_category_short.png", width: 100%)
  ),
  caption: "Absolute average distance of the routes (top), average difference in distance between shortest and most comfortable route (bottom)"
)<fig:res-ut-di>

The scatterplots (@fig:res-ut-di) show the trade-off between additional walking distance and UTCI reduction for individual OD pairs. The x-axis shows the distance difference between the comfortable and shortest route, while the y-axis shows the UTCI difference between the comfortable and shortest route. Because the UTCI difference is calculated as comfortable minus shortest, negative values indicate that the comfortable route has a lower average UTCI. Most points are located to the right of zero and below zero, meaning that the comfortable route is usually longer but cooler than the shortest route. The points for 15:00 and 18:00 show the clearest reductions, while 08:00 and 22:00 are clustered closer to zero. This again shows that the algorithm mainly changes the route during the hot parts of the day. 

For a small number of OD pairs, the comfortable route has a higher average UTCI than the shortest route. This can occur because the algorithm strongly penalizes extremely hot edges. As a result, it may avoid one particularly hot edge by choosing a route with several slightly less hot edges. Although this behaviour reduces exposure to the most extreme heat conditions, it can increase the length-weighted average UTCI of the full route. 