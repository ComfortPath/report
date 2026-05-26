#import "../template.typ": *

= Related Work
<chap:related-work>
This chapter situates this thesis into the broader research by delving into two topics. First, it discusses research on how people unconsciously move through cities and how the urban environment can influence that. Secondly, papers are discussed that use differing 'environmental factors' to support citizens in making these decisions consciously through environmental informed routing. There are three main elements to these tools: the input environmental data, the pedestrian network, and the routing algorithm. 

== Mobility patterns
Human mobility patterns are recurring regularities in movement on a population scale. The fact that these routes can identified indicates that some routes are generally preferred over others. These patterns in mobility follow from a multidisciplinary set of forces, including _"socioeconomic conditions, technological advancements, policy interventions, and environmental changes"_ @du_review_2025. Increased availability of GPS data has helped develop this area of research by providing precise route information. Analysing these common routes, and their reasons for deviating from the shortest path, can support more informed routing decisions at both the individual and collective levels @pappalardo_future_mobility_2023. For example, by routing both car traffic and pedestrians in such a way that pedestrian exposure to air pollution is minimized @aliyev2_vehicle-pedestrian_2025.

== Unconscious route choice
Routing choices in urban areas are not solely dependent on the distance in meters; factors like facade complexity, nearness to greenery, or other urban features can also play a role @pappalardo_future_mobility_2023. This mismatch between actual and perceived distance is described by the concept _cognitive distance_, the distance humans _think_ a route will be, illustrated by @fig:cog_dist @manley_cognitive_2021. Approaching this concept practically, Salazar Miranda et al. (2021) used GPS data from mobile devices to investigate what makes people deviate from the shortest path. They found that urban greenery is the most common feature on these deviating routes @salazar_miranda_desirable_2021. Many of these routing choices are not done consciously @foshag_how_2024. However, studies show that thermal conditions also influence route choice. With Basu et al. (2024) showing that, when given the option, pedestrians tend to pick routes that avoid heat stress @basu_hot_2024. 
#figure(
  image("../figs/Manley_cognitive_dist.png", width: 70%),
  caption: [
    _"Plots of indicative cognitdive distance (red points) and Euclidean (blue points) distances from a single origin point, in Delhi (left) and Berlin (right)."_ (Manley et al. 2021)
    #cite(<manley_cognitive_2021>).
  ],
) <fig:cog_dist>
== Environmentally informed routing tools
=== Input data
Planning routing to reduce exposure to environmental factors, like heat stress or pollution, can provide statistically different paths to the shortest path. However, which environmental input data is used and in what form differs largely between papers. With some papers using static maps containing the environmental variable(s) @aliyev1_exploiting_2025 @mora-navarro_optimising_2018 @novack_system_2018. Rußig & Bruns (2017) used data collected by a thermal scanner flight adjusted with hourly data from a local weather station @rusig_reducing_2017. Some of the most extensive data collection was done by Foshag et al. (2024), who used a collection of multidisciplinary methods to investigate heat-sensitive routing with a special focus on vulnerable groups. By using a combination of surveys, interviews, shade maps, and modelling using ENVI-net they built a route planner that avoids heat stress @foshag_how_2024. This gives a very detailed implementation for one area that can help policy makers, but is cost-intensive to replicate on a large scale. Lastly, Novack et al. (2018) built their pleasant route planner based entirely on open street map (OSM) data. This supports openness and reproducibility, but they only base their routes on noisiness, closeness to greenery, and social places @novack_system_2018. 
#todo[include ma street and machine learning to generate heat maps]
=== Routing algorithms
#todo[include ma et al. (twice)]
In existing literature, pedestrian networks are typically generated using OpenStreetMap (OSM) data, creating a topologically connected network of all paths in a city. Routing is commonly performed using weighted shortest-path algorithms such as Dijkstra @aliyev1_exploiting_2025 @wen_walking_smart_2025 @rusig_reducing_2017 or A\* @mora-navarro_optimising_2018, although in some studies the specific algorithm is not explicitly stated @novack_system_2018 @foshag_how_2024. Before application of the routing algorithm weights need to be assigned to the edges in the network. The methods used to compute these weights differ substantially between studies.

// static approach
The most straightforward approach is to assign each network edge a static cost based on a weighted combination of relevant factors, such as thermal conditions, distance or greenery @mora-navarro_optimising_2018 @novack_system_2018 @foshag_how_2024. In this approach, all edge weights are calculated before the routing algorithm is applied and remain fixed during route generation. This gives a formula for the weight of an edge $W$ with $f_i$ being the factors you wish to consider (e.g., distance, shade, greenery) and $w_i$ being the weights assigned to each of these factors.

#set align(center)
$ W = sum_{i=1}^{n} w_i f_i$
#set align(left)

// dynamic
Several studies extend static edge weighting to better account for the dynamic character of thermal comfort during walking. A pedestrian’s thermal experience is influenced not only by the current edge conditions, but also by their physiological state and recent exposure history. As walking continues, physical exertion can increase the demand for cooler edges, as the body heats up @wen_walking_smart_2025 @rusig_reducing_2017 @ma_active_2025. Similarly, whole-trip thermal comfort research shows that current thermal sensation is influenced by recent previous thermal experiences, so the perceived cost of an edge may depend on the thermal conditions encountered immediately before it @zhao_impact_2024. This suggests that routing approaches should allow edge weights to dynamically change during route generation, rather than being fixed in advance.

To achieve this Wen et al. (2025) adjusted the generated route using a sigmoid function, deduced from a pedestrian movement dataset, to find an optimal balance between actual distance and sun exposure @wen_walking_smart_2025. While Rußig & Bruns (2017) use a time-dependent multi-layered raster as the input to account for this effect. Aliyev & Nanni (2025-6) applied a different technique to find an optimum between distance and exposure, though they wanted to avoid pollution. They generated a set of routes with different weights, to use a statistical method to find the optimum between distance and exposure for every trip @aliyev1_exploiting_2025. This was later extended to dynamically adjust the weights as pollution moves trough the city @aliyev2_vehicle-pedestrian_2025. Although demonstrated for pollution avoidance, this approach allows weights to be adjusted automatically and to vary between individual trips. These approaches in routing algorithm are summarized in @table:lit-algorithms. Descriptions
- *Static* the previously visited edges do not have an impact on the rest of the route.
- *Dynamic* the previously visited edges can change on the weight of the next edge.
- *Predefined* weights for factors (e.g. distance, shade) are pre-emptively assigned to edges by the researchers.
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
