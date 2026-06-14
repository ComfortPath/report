#import "../template.typ": *

= Background <chap:background>
This section introduces the theoretical background needed to understand the main concepts used throughout the thesis.

== Health outcomes & heat
In the same weather conditions, the form and material characteristics of the urban environment can amplify thermal discomfort for people living in cities when compared to rural areas @Oke_Mills_Christen_Voogt_2017. Especially heat stress, which becomes more relevant as extreme weather events become more likely with climate change @ipcc2022_policy, is an area of concern. Extreme (or even moderate) heat goes hand in hand with an increase in mortality @Oke_Mills_Christen_Voogt_2017 and negative health outcomes @zendeli_heatwaves_2025 @aghamolaei_comprehensive_2023. To assess human thermal stress in outdoor urban environments, the following sections first introduce the broader concept of outdoor thermal comfort (@OTC) and then discuss the Universal Thermal Climate Index (@UTCI) as a metric for quantifying thermal stress.

=== OTC
A state of thermal comfort occurs when the body is in thermal balance with its environment and does not need to actively compensate for heat gain or heat loss.
In outdoor settings, a wide range of factors influence thermal comfort, which can broadly be grouped into two categories:
- Environment-based: weather and climate conditions (e.g., temperature, wind, humidity), but also the secondary physical characteristics (e.g., morphology, geometry, material properties). 
- Human-based: physiological characteristics (e.g., gender, age, clothing), but also psychological and cultural factors can play a role. @aghamolaei_comprehensive_2023
The environmental factors create the local microclimate conditions that pedestrians find themselves in. While the human factors help explain how people subjectively perceive and adapt to these environmental conditions. In general these parameters help explain why thermal comfort preferences vary between population groups and climates.

=== UTCI
The interaction between outdoor thermal conditions and the human body can be understood through the human energy balance, _“... which is a complete description of the biophysical processes that underpin the thermal state of the body”_@Oke_Mills_Christen_Voogt_2017. Building on this principle, the @UTCI combines a thermophysiological model with a clothing model and a predefined reference condition of a person (e.g. walking at 4 km/h). This results in a one-dimensional temperature-scale index that represents the heat stress experienced by the human body @utci_Blazejczyk_2013.
#figure(
  image("../figs/background/UTCI.png", width: 40%),
  caption: [
    Concept of the Universal Thermal Climate Index (UTCI). Reproduced from Błażejczyk et al. (2013) @utci_Blazejczyk_2013
  ],
) <fig:utci-expl>

=== Urban Microclimate Modelling 
Urban Microclimate (@UMC) modelling tools operationalise these concepts by simulating the environmental variables that govern the human energy balance in outdoor urban environments. In this thesis, the @UMEP is used to model these conditions, because it is an open-source tool @lindberg_urban_2017. From @UMEP, the @SOLWEIG (SOlar and LongWave Environmental Irradiance Geometry model) model is used to estimate mean radiant temperature by modelling spatial variations in shortwave and longwave radiation fluxes in complex urban settings @lindberg_urban_2017. Which is used as input for the @UTCI calculation together with ERA5 weather data.

== Dijkstra's least cost algorithm
<bkg:dijkstra>
Dijkstra’s algorithm is a well-known greedy algorithm for finding shortest paths in a weighted network with non-negative edge weights @Dijkstra1959. It was introduced by Dijkstra in 1959 and remains a common basis for routing applications.

The algorithm works by maintaining a tentative distance for each node. At the start, the distance to the source node is set to zero, while all other nodes are assigned an infinite distance because no path to them has yet been found. The algorithm then repeatedly selects the unvisited node with the lowest tentative distance, which is kept at the top of the priority queue. This greedy choice is safe because, with non-negative edge weights, no later path can reduce the distance to that node once it has been selected. From this node, the algorithm evaluates all outgoing edges and updates the tentative distances of neighbouring nodes when a shorter path is found. The process continues until all reachable nodes have been visited, or until the destination node has been reached. The full algorithm in pseudo-code is presented in @dijkstra-alg.


#figure(
  text(size: 10pt)[
  ```
function Dijkstra(Graph, source, target):

    dist[source] ← 0
    prev ← empty dict
    processed ← empty set

    Q ← priority queue
    Q.push(0, source)

    WHILE Q IS NOT empty:

        current_cost, u ← Q.pop() 

        IF u is in processed:
            continue

        processed.add(u)

        IF u = target:
            break

        FOR EACH neighbour v of u:
            edge_cost ← weight(u, v)
            new_cost ← current_cost + edge_cost

            IF v NOT IN dist OR new_cost < dist[v]:
                dist[v] ← new_cost
                prev[v] ← u
                Q.push(new_cost, v)

    RETURN (dist, path)
```
  ],
caption: "Dijkstra's algorithm in pseudocode"
)<dijkstra-alg>
