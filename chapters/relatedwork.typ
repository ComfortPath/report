#import "../template.typ": *

== Background info & relevance <background-info>
=== Health outcomes & heat
In the same weather conditions, the form and material characteristics of the urban environment can amplify thermal discomfort for people living in cities when compared to rural areas @Oke_Mills_Christen_Voogt_2017. Especially heat stress, which becomes more relevant as extreme weather events become more likely with climate change @ipcc2022_policy, is an area of concern. Extreme (or even moderate) heat goes hand in hand with an increase in mortality @Oke_Mills_Christen_Voogt_2017 and negative health outcomes @zendeli_heatwaves_2025 @aghamolaei_comprehensive_2023. To assess human thermal stress in outdoor urban environments, the related concepts of outdoor thermal comfort (OTC) and Physiologically Equivalent Temperature (PET) can be used. These will be explained first to give the necessary background to understand the rest of this text. 

=== OTC
A state of thermal comfort is described as when the body doesn't have to do anything to manage its temperature. In outdoor settings, a wide range of factors influence thermal comfort, which can broadly be grouped into two categories:
- Environment-based: weather and climate conditions (e.g., temperature, wind, humidity), but also the secondary physical characteristics (e.g., morphology, geometry, material properties). 
- Human-based: physiological characteristics (e.g., gender, age, clothing), but also psychological and cultural factors can play a role. @aghamolaei_comprehensive_2023
The environmental factors create the local microclimate conditions that pedestrians find themselves in. While the human factors help explain how people subjectively perceive and adapt to these environmental conditions. In general these parameters help explain why thermal comfort preferences vary between population groups and climates.

=== PET
To describe the effect of outdoor temperature on the human body in a single index, the PET was developed, which is based on the human energy balance _"which is a complete description of the biophysical processes that underpin the thermal state of the body."_@Oke_Mills_Christen_Voogt_2017. The index translates complex outdoor environmental conditions into an equivalent indoor air temperature at which the human body would experience the same thermal strain. PET also allows the specification of 'human-based' characteristics, which can provide more accurate representations of vulnerable population groups.

=== UMEP
UMEP incorporates these concepts by modelling the key environmental variables that govern the human energy balance in outdoor urban environments. SOLWEIG estimates mean radiant temperature by accounting for urban geometry and surface properties. URock simulates pedestrian-level wind conditions influenced by urban geometry. Combined with air temperature and humidity data derived from meteorological input datasets, these model outputs can be used to compute PET values, given the human-based characteristics. This allows for a detailed assessment of thermal stress in the urban environment.

== Why routing?
=== Mobility patterns
Human mobility patterns are recurring regularities in movement on a population scale, indicating that some routes are generally preferred over others. These patterns in mobility follow from a multidisciplinary set of forces, including "socioeconomic conditions, technological advancements, policy interventions, and environmental changes" @du_review_2025. Increased availability of GPS data has helped develop this area of research by providing precise route information. Analyzing these common routes can support more informed routing decisions at both the individual and collective levels @pappalardo_future_mobility_2023. For example, by routing both car traffic and pedestrians in such a way that pedestrian exposure to air pollution is minimized @aliyev2_vehicle-pedestrian_2025.
=== Unconscious route choice
Routing choices in urban areas are not solely dependent on the distance in meters; factors like facade complexity, nearness to greenery, or other urban features can also play a role @pappalardo_future_mobility_2023. This mismatch between actual and perceived distance is described by the concept _cognitive distance_, the distance humans _think_ a route will be, illustrated in @fig:cog_dist @manley_cognitive_2021. Approaching this concept practically, Salazar Miranda et al. (2021) used GPS data from mobile devices to investigate what makes people deviate from the shortest path. They found that urban greenery is the most common feature on these routes that deviate @salazar_miranda_desirable_2021. Many of these routing choices are not done consciously @foshag_how_2024. However, studies show that thermal conditions also influence route choice. With Basu et al. (2024) showing that, when they have the option, pedestrians tend to pick routes that avoid heat stress @basu_hot_2024. 
#figure(
  image("../figs/Manley_cognitive_dist.png", width: 80%),
  caption: [
    _"Plots of indicative cognitdive distance (red points) and Euclidean (blue points) distances from a single origin point, in Delhi (left) and Berlin (right)."_ (Manley et al. 2021)
    #cite(<manley_cognitive_2021>).
  ],
) <fig:cog_dist>

== Routing based on environment <rout-env>
Building a routing tool to improve the adaptive capacity of urban communities to environmental factors has already been the subject of academic attention. There are three main elements: the input environmental data, the routing algorithm, and the pedestrian network. 
=== Routing & input data
Planning routing to reduce exposure to environmental factors, like heat stress or pollution, can provide statistically different paths to the shortest path. However, which environmental input data is used and in what form differs largely between papers. With some papers using static maps containing the environmental variable(s) @aliyev1_exploiting_2025 @mora-navarro_optimising_2018 @novack_system_2018. Rußig & Bruns (2017) used data collected by a thermal scanner flight adjusted with hourly data from a local weather station @rusig_reducing_2017. Some of the most extensive data collection was done by Foshag et al. (2024), who used a collection of multidisciplinary methods to investigate heat-sensitive routing with a special focus on vulnerable groups. By using a combination of surveys, interviews, shade maps, and modeling using ENVI-net they built a route planner that avoids heat stress @foshag_how_2024. This gives a very detailed implementation for one area that can help policy makers, but is cost-intensive to replicate on a large scale. Lastly, Novack et al. (2018) built their pleasant route planner based entirely on open street map (OSM) data. This supports openness and reproducibility, but they only base their routes on noisiness, closeness to greenery, and social places. 

=== Pedestrian network
The pedestrian network can be generated using OpenStreetMap (OSM) data, creating a topologically connected network of all paths in a city. This is the approach used in most existing literature, due to the quality and open nature of the dataset. However, this also means that 

=== Routing & algorithms
In existing literature, pedestrian networks are typically generated using OpenStreetMap (OSM) data, creating a topologically connected network of all paths in a city. Routing is commonly performed using weighted shortest-path algorithms such as Dijkstra @aliyev1_exploiting_2025 @wen_walking_smart_2025 @rusig_reducing_2017 or A\* @mora-navarro_optimising_2018, although in some studies the specific algorithm is not explicitly stated @novack_system_2018 @foshag_how_2024. Before application of the routing algorithm weights need to be assigned to the edges in the network. The methods used to compute these weights differ substantially between studies.

The first, and most simple to implement, approach is to assign a single score to stretches in the network based on a set of factors @mora-navarro_optimising_2018 @novack_system_2018 @foshag_how_2024. This gives a formula for the weight of an edge $W$ with $f_i$ being the factors you wish to consider (e.g., length, shade, greenery) and $w_i$ being the weights assigned to each of these factors.

$ W = sum_{i=1}^{n} w_i f_i$

Several studies extend this approach to better represent heat-related discomfort. By adjusting the edge weights as the route is being generated to favor shadier routes, taking into account the increasing desire for shade as pedestrians spend a longer time in the heat @wen_walking_smart_2025 @rusig_reducing_2017. Wen et al. (2025) adjusted the generated route using a sigmoid function, deduced from a pedestrian movement dataset, to find an optimal balance between actual distance and sun exposure @wen_walking_smart_2025. While Rußig & Bruns (2017) use a time-dependent multi-layered raster as the input to account for this effect. Aliyev & Nanni (2025-06) applied a different technique to find an optimum between distance and exposure, though they wanted to avoid pollution. They generated a set of routes with different weights, to use a statistical method to find the optimum between distance and exposure for every trip @aliyev1_exploiting_2025. This was later extended to dynamically adjust the weights as pollution moves trough the city. @aliyev2_vehicle-pedestrian_2025 Although demonstrated for pollution avoidance, this approach allows weights to be adjusted automatically and to vary between individual trips. These approaches in routing algorithm are summarized in @table:lit-algorithms. Descriptions
- *Static* the previously visited edges do not have an impact on the rest of the route.
- *Dynamic* the previously visited edges can change on the weight of the next edge.
- *Predefined* weights for factors (e.g. distance, shade) are preemptively assigned to edges by the researchers.
- *User defined* weights for factors (e.g. distance, shade) are defined by the user of the system.
- *Automatically derived* weights for the factors are automatically derived by an optimization problem for every trip.

#figure(
  table(
  columns: (1fr, auto, auto),
  inset: 10pt,
  align: horizon,
  table.header(
    [], [*Edge weights*], [*Algorithm*],
  ),
  [Mora-navarro et al. (2018)],
  [Static, predefined],
  [A\*],
  [Novack et. al (2018)],
  [Static, defined by user],
  [Unspecified],
  [Foshag et al. (2024)],
  [Static, predefined],
  [Unspecified],
  [Rußig & Bruns (2017)],
  [Dynamic, predefined],
  [Dijkstra],
  [Wen et al. (2025)],
  [Dynamic, predefined],
  [Dijkstra],
  [Aliyev & Nanni (2025-06)],
  [Static, automatically derived],
  [Dijkstra],
  [Aliyev & Nanni (2025-10)],
  [Dynamic, automatically derived],
  [Dijkstra],
  ),
  caption: [Algorithm descriptions papers]
)<table:lit-algorithms>

The differences between the algorithmic approaches even in recent papers show that this remains an open methodological problem rather than a settled solution.
