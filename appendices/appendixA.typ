
#set page(
  paper: "a4",
  flipped: true,
)
= Appendix A
<appendix-A>

Table only has insights from the emergent design process. If the first methodological approach did not encounter any major bottlenecks, it is not noted here but only in the methodology @chap:methodology. Because the methodology was primarily informed by previous work, several emergent insights for one topic indicate aspects of the workflow that appear to have received less detailed attention in the literature consulted for this thesis.

== Table emergent process
#text(size: 7.5pt)[
#table(
  columns: (0.9cm, 2.8cm, 4.4cm, 5.2cm, 5.0cm, 5.4cm),
  inset: 4pt,
  align: horizon + left,

  table.header(
    [*Insight*],
    [*Component*],
    [*Initial approach*],
    [*Bottleneck or observation*],
    [*Revised approach or implication*],
    [*Broader lesson*],
  ),

  [I1],
  [*Data preparation*],
  [Use the SOLFD pipeline @monahan_cool_2025.],
  [The pipeline was difficult to use because of how the code was distributed.],
  [Distribute the SOLFD pipeline as a PyPI package.],
  [A scalable pipeline must not only be technically functional, but also easy to install, run, and reproduce.],

  [I2],
  [*Pedestrian network*],
  [Retrieve the pedestrian network from OpenStreetMap.],
  [The resulting network consists mainly of centreline geometries, which assumes that pedestrians move along the centre of each mapped edge.],
  [Treat this as a limitation.],
  [Pedestrian network preparation is not a neutral input step, though it is currently the best we have. The geometric abstraction can introduce inaccuracies into the final routing results.],

  [I3],
  [*Pedestrian network*],
  [Use existing automatic OSM filtering through abstraction tools such as OSMnx.],
  [Automatic filtering can remove tags with sidewalk and footway information.],
  [Load all available OSM information and apply project-specific filtering.],
  [Software automations can introduce unnoticed data loss; the choice of data collection tool can affect the final result.],

  [I4],
  [*Network representation*],
  [Use the standard OSMnx representation, where bidirectional movement is represented through duplicate directed edges.],
  [Bidirectional pedestrian connections increased storage demand.],
  [Use an undirected internal network representation.],
  [Standard network representations should be questioned when their assumptions do not match the workflow.],

  [I5],
  [*SOLWEIG / UMEP execution*],
  [Run SOLWEIG on demand for only the area directly needed by the route.],
  [Input data collection from tiles and CHM generation were too slow for interactive, on-demand routing.],
  [Run SOLWEIG pre-emptively and integrate the environmental outputs into the pedestrian network.],
  [On-demand environmental simulation is only feasible when input-data retrieval and preprocessing are fast enough for interactive use.],

  [I6],
  [*SOLWEIG / UMEP execution*],
  [Run SOLWEIG on external compute infrastructure when available.],
  [SOLWEIG\_GPU performance depends strongly on available GPU memory, tile size, and shared hardware conditions.],
  [Test SOLWEIG\_GPU on the available hardware.],
  [SOLWEIG performance is highly hardware-dependent, so scalability should be evaluated in relation to the specific computing environment.],

  [I7],
  [*SOLWEIG / UMEP execution & network annotation*],
  [Merge tiled SOLWEIG outputs into a multidimensional GeoTIFF.],
  [The resulting files were large, and multidimensional lookup was inefficient during pedestrian-network annotation.],
  [Store tiled environmental outputs in a Zarr structure.],
  [File format choices should match the needs of the computation.],

  [I8],
  [*Network annotation & routing prototype*],
  [Use the OSMnx / NetworkX graph representation directly in routing.],
  [Implementation is dependent OSMNX graph representation which couples the routing and network allocation by file format. Introduces performance bottlenecks for routing.],
  [Use a shared data schema between components, while allowing the internal representation to change between use-cases.],
  [Dependencies on static network representations can reduce performance, flexibility, and reusability.],

  [I9],
  [*Routing prototype & application*],
  [Let the application also calculate routes.],
  [Coupling the application and routing logic reduced reusability, and client-side route calculation can introduce performance constraints at scale.],
  [Separate the routing engine from the application and communicate between them through an API.],
  [The application should primarily visualize, while the routing logic is done in the back-end.],

  // [I10],
  // [*Performance*],
  // [Evaluate the performance of the full workflow.],
  // [Network annotation and routing were relatively fast compared with SOLWEIG execution. Annotation took approximately 10 seconds per tile, and generating 300 OD-pair routes using the optimized representation took approximately 2 seconds.],
  // [Prioritize optimization of environmental simulation, tiling, and workflow automation rather than route calculation itself.],
  // [The main scalability bottleneck is environmental simulation and data preparation, not network annotation or route generation.]
)
]

#set page(
  paper: "a4",
  flipped: false,
)