#import "../template.typ": *

= Implementation
<implementation>
This chapter will go into the technical detail on how the tool is implemented. Discussing the data structures and functions used in the code as well as the structure of the entire tool. @fig:implementation shows the connection between the separate components in a graphical manner. 

First, the chapter will present the implementation rationale for the entire tool. Then it wil go into technical detail for all the components. The structure of the chapter is based on the structure of the code, which differs in some aspects from the conceptual separation used in @chap:methodology. For example, the configuration of the pedestrian network is not included in the data preparation section since it is happening in a different section of the code. The goal of this chapter is for a developer to be capable of re-building the tool.

== Full tool

#figure(
  image("../figs/implementation/implementation.png", width: 80%),
  caption: [
    Graphical representation of the connection between the components.
  ],
) <fig:implementation>
The pedestrian routing tool uses a component based architecture (CBA), which emphasizes modularity and is associated with a better reusability @khalid_software_2025. Where the modularity of the components is achieved through low coupling and high cohesion @mehboob_reusability_2021. The goal of modular design is that you can change things in one component without breaking everything else. This is technically enforced through the active separation of code according to @fig:modularity.
#figure(
  image("../figs/implementation/modularity.png", width: 70%),
  caption: [
    Code structure to ensure modularity.
  ],
) <fig:modularity>

All packages used in the tool are open-source and required input data is kept minimal. The design goals are scalability for which the important elements were identified as: performance, reusability and ease of use. #todo[explain why? in methods?, currently in conclusion in answer rqs] This is to ensure that the results achieved are reproducible. #todo[maybe not here/ move above image]

== Data preparation
All SOLWEIG input data except for the weather data is gathered using UMEPIO. ERA5 is used for the weather data, which is is a global climate reanalysis dataset that provides hourly atmospheric, land, and ocean variables by combining weather model simulations with historical observations. This data is collected via the API through a simple script
#figure(
  image("../figs/implementation/data_prep.png", width: 70%),
  caption: [
    Structure of the data preparation code.
  ],
) <fig:data_prep>
=== UMEPIO
<imp:umepio>
To support reusability and ease of use, an existing pipeline for the generation of SOLWEIG inputs was published as a #link("https://pypi.org/project/umepio/")[pip package] on the public PyPi repository: UMEPIO. This pipeline (SOLFD) for automatically gathering and preparing the input datasets was developed by Monahan (2025) @monahan_cool_2025. The pip package acts as a mode of distribution for the SOLFD pipeline which is a preprocessing layer between open Dutch geodata sources and SOLWEIG.

The implementation of the package is organised around four internal classes: buildings, DEMs, CHM, and landcover. With the classes reflecting the main input categories required by SOLWEIG.  The building class retrieves and stores building geometries for the study area. The DEM class generates aligned terrain and surface rasters, using the building geometries where needed to represent urban form. The CHM class derives vegetation height information from LiDAR data and converts this into a raster layer. The land-cover class classifies and rasterises surface types so that they match the spatial grid of the other inputs. More detailed descriptions on the processing steps can be found in and Monahan (2025) @monahan_cool_2025.

Access to the functionality is organised through a user-facing API module, which uses the internal classes and exposes their use through simple callable functions (@fig:umepio). Users can either run separate steps, such as only generating buildings or land cover, or call one high-level function that runs the complete input-generation workflow. This keeps the original processing logic modular while making it easier to (re)use.

Lastly, due to a bug in SOLWEIG\_GPU where it is unable to consider negative values all the negative values of the generated DEMs are set to 0. Note that this is to account for a bug and not desired behaviour which is why it is not implemented in UMEPIO directly.

#figure(
  image("../figs/implementation/umepio_struct.png", width: 70%),
  caption: [
    Structure of UMEPIO package.
  ],
) <fig:umepio>


== Running solweig
<imp:running-solweig>
#figure(
  image("../figs/implementation/running_solweig.png", width: 70%),
  caption: [
    Structure of UMEPIO package.
  ],
) <fig:running-solweig>
SOLWEIG-GPU was run on DelftBlue, the TU Delft high-performance computing cluster shared with the entire university. DelftBlue provides CPU, high-memory, and GPU nodes, including GPU partitions with NVIDIA V100 and A100 GPUs, making it suitable for computationally intensive raster-based modelling tasks @DHPC2024. The model was executed through the SOLWEIG\_GPU package @kamath_solweig-gpu_2026 @solweig_gpu_git, using a single function call to run the simulation after the required input rasters and meteorological files had been prepared.

Running on DelftBlue required some adaptation compared with running the model locally. Since only the login nodes have a direct internet connection, the generation and downloading of input data was performed locally before transferring the prepared files to DelftBlue. On DelftBlue, SOLWEIG\_GPU was loaded in a Python virtual environment and executed through an `sbatch` script, which submits the job to the `Slurm` queue until the requested resources become available. Although GPU nodes with higher RAM achieve faster runtimes, the small GPU partition with 10GB of RAM was often more practical because there was no queue. As a result, the total time between submitting the job and obtaining the output could be shorter, even when the runtime itself was slower. SOLWEIG\_GPU automatically tiles the input data before processing, based on the user defined tile size. The documentation @solweig_gpu_git states that optimal tile size depends on the available GPU memory, so based on that 1000x1000 cell tiles were chosen. 

=== Network annotation
#figure(
  image("../figs/implementation/network_anno.png", width: 80%),
  caption: [
    Structure of network annotation code
  ],
) <fig:network-anno>

==== Network builder
The network is retrieved from OSM @OpenStreetMap OSMnx @osmnx_geoff_2025. A custom filtering step is then applied in Python to select the relevant edges, rather than relying on the filtering options implemented by OSMnx. This was done to avoid unintended data loss of tags related to pedestrians.

The filtering keeps only edges that are usable for pedestrians. In practice, an edge is excluded when it is clearly unsuitable according to the OSM documentation, for example `highway=motorway` or `access=private`. Edges are included when they are suitable for pedestrians, such as `highway=footway`. Roads that are not explicitly pedestrian-only, such as `highway=residential`, are also included. Since explicit pedestrian information is relatively rare, edges with such information are given an additional custom tag, `ped_infra_type=dedicated`, to reflect this. When sidewalk information is available for certain roads, it is also added through the tags `sidewalk_present` and `sidewalk_side`. 

==== Network annotation
The pedestrian network is annotated with the SOLWEIG output maps. It uses the existing `PedestrianNetwork` created by the builder and samples a multiband Zarr raster along each edge geometry. The sampled hourly UTCI values are then added to the graph edges as attributes.

For every edge in the network, the UTCI raster is sampled along the edge geometry. The SOLWEIG output is stored as a multiband Zarr raster, where the spatial data are chunked and each chunk contains all 24 hourly bands (@fig:zarr). In this implementation, the chunk structure is `256x256x24`, which means that the original multiband GeoTIFF is reorganised into chunks of 256 by 256 cells, while all 24 hourly UTCI bands are stored on top of each other within each chunk. The conversion to Zarr therefore does not change the raster values, resolution, or spatial extent, but changes how the data are stored and accessed

If necessary the edge geometry is first transformed to the CRS of the raster. Then it is rasterized to find the indexes of the intersecting raster cells in the Zarr file. Using these indexes the corresponding chunks are loaded into memory. Since the edges are clustered together spatially, it's likely that for most edges only one or two chunks need to be loaded into memory. For each index that corresponds to the original edge only one query is needed to get all 24 values.

All these values are collected and aggregated into two attributes: `utci_median`, which stores the median UTCI value per raster band, and `utci_category`, which stores the corresponding thermal-stress category. Lastly, the names of the added environmental attributes are stored in the network metadata.

#figure(
  image("../figs/implementation/zarr_structure.png", width: 40%),
  caption: [
    Chunked access to the zarr cube adjusted from Trujillo et al. (2026)@Trujillo_zarr_img_2026
  ],
)<fig:zarr>

==== Network storage
During processing the network is kept in the NetworkX representation used by OSMnx, namely `nx.MultiGraph` combined with custom metadata. Using the combination of both the network can be visualized and loaded/saved from/to persistent storage #footnote[In the case of this thesis, persistent storage just means that the network is saved to a file (geoparquet). However, depending on the implementation, other forms of persistent storage, such as a database, could also be used.]. The data schema simply defines which columns need to be kept so the network can be converted reliably between different network representations. From the runtime representation to persistent storage the network is written to two GeoParquet files and one metadata file:

- `nodes.parquet`: contains the original OSM node id and the geometry `point(x, y)` of its location.
- `edges.parquet`: contains the origin and destination node, the OSMnx key, all annotated attributes, and any remaining attributes preserved after filtering.
- `metadata.json`: contains the metadata assigned throughout the annotation process, such as the CRS and the names of the annotated attributes.

== Routing prototype
=== Routing representation
#todo(position: "inline")[Chatty section -> rewrite when helder & adding figures (repeats itself & methodology too much.)]
The routing prototype is implemented as a small end-to-end tool that connects the prepared pedestrian network, the routing algorithm, an API layer, and an interactive web interface. The prepared network is loaded from the persisted schema folder containing the node table, edge table, and metadata. At startup, this network is converted into the routing representation used by the algorithm and is also transformed into a GeoJSON payload that can be displayed in the browser. This means that the same underlying network is used both for visualisation and for route calculation, avoiding a separation between what the user sees and what the algorithm uses.

The API forms the connection between the routing backend and the web application. It keeps the loaded network in memory, exposes the full pedestrian network for visualisation, and receives route requests from the interface. A route request consists of two map coordinates and a selected hour. The API first snaps the clicked coordinates to the closest nodes in the pedestrian network, then passes these nodes and the selected time step to the routing algorithm. After the route has been calculated, the result is converted back into a web-compatible response containing the route geometry, distance, cost, duration when available, and the corresponding node and edge sequence.

The web interface is implemented as the user-facing part of the prototype. It communicates with the API through a small asynchronous client and provides two modes: one for inspecting the UTCI-annotated network and one for calculating routes. In the network view, the user can select an hour and inspect the spatial distribution of UTCI categories across the pedestrian network. In the route planner, the user selects an origin and destination by clicking on the map, chooses the relevant hour, and requests a route from the backend. The returned route is then drawn on top of the same network layer, while summary values such as distance and route cost are shown in the sidebar

=== Adjacency list
For efficient access during routing, the network topology is represented through an adjacency list. This structure stores, for each node, the neighbouring nodes that can be reached from it. Each neighbour entry also stores the corresponding edge position. This is important because the neighbour relation itself only describes connectivity, while the edge position provides access to the attributes needed for environmental cost calculation. The adjacency list is created when the network is initialized for routing, so all connections of a node can be retrieved with a single query. Because the pedestrian network is undirected, this initialization step also inserts each edge in both directions, allowing all movement between connected nodes.

=== Stateful routing
#todo[connect] The route is not evaluated as a sequence of independent edges. Instead, the algorithm carries a route state through the search. This state represents the accumulated heat exposure along the route thus far. The route state starts at zero and is updated after each traversed edge.

When an edge is classified as thermally stressful, the state increases. When an edge is not classified as thermally stressful, the state decreases again. This decrease represents recovery after exposure. The state is not allowed to decrease below zero, and it is also capped at an upper value of thirty. This upper bound keeps the number of possible route states finite, which is necessary because the route state becomes part of the search space.

Because of this design, the same physical node can be reached under different thermal conditions. Reaching a node after a cool route segment is not equivalent to reaching the same node after several hot route segments. The implementation therefore cannot store only one best cost per node, as a standard shortest-path implementation would do. Instead, it stores costs for combinations of node and route state. This keeps track of the the cumulative heat exposure along the route.

=== Weight configuration
The algorithm uses user defined weights to define the importance of the environmental values. #todo[does it -< if not implementing shade] #todo[Do i explain somewhere why and how this is useful for incorporating weather/other values] Which is passed to the routing algorithm via a weight configuration dictionary. At initialization the edge weights are extracted for the given time step, such that there is only one value per variable at an edge.

The edge cost is calculated from the physical edge length and an added environmental penalty. Length remains the base cost, so longer edges are still more expensive than shorter ones. The environmental part is added as a multiplicative penalty on top of this length. In practice, this means that an edge with a high thermal penalty becomes equivalent to a longer edge in the search process. The algorithm can therefore trade off distance against thermal comfort without replacing the distance-based structure of the graph.

For thermal stress, the implementation uses the UTCI category stored on the edge. Each category is translated into a penalty multiplier. With higher heat-stress categories receiving progressively larger penalties. The weighting structure then determines how strongly this penalty influences the final cost. #todo[can it be turned off?] If dynamic sensitivity is enabled, the penalty is further adjusted based on the current route state. This allows consecutive exposure to hot edges to become increasingly expensive.

The same calculation also determines how the route state should change. #todo[is this included in the configuration] If the traversed edge belongs to a high heat-stress category, the state is increased. If it does not, the state is reduced. The cost calculation therefore produces two outputs at the same time: the weighted cost of traversing the edge and the updated cumulative route state after that edge has been used.

=== Modified Dijkstra
Standard Dijkstra is explained in @background-info #todo[refer when written]. In this implementation the route search is based on Dijkstra’s algorithm, but it is adapted to account for the route state. In a standard implementation, the algorithm keeps track of the cheapest known path to each node. In this implementation, the cheapest known path is tracked for each combination of node and route state. This modification is required because the future cost of a route depends not only on the current location, but also on the accumulated heat exposure at that point.

The algorithm uses a priority queue to always expand the currently cheapest partial route. Each queue entry contains the current accumulated cost, the current node, and the current route state. When an entry is selected from the queue, the algorithm checks all neighbouring nodes. For each possible next edge, it calculates the weighted edge cost and the updated route state. The new total cost is then compared with the best known cost for the resulting node-state combination.

If the new combination has not been reached before, or if it has now been reached with a lower cost, it is added to the queue. The algorithm also stores the predecessor of each accepted node-state combination. This is required because the final route must be reconstructed after the target has been found.
The search stops when the target node is reached through the lowest-cost available node-state combination. At that point, the algorithm has found the best route under the implemented cost structure, including both distance and dynamic thermal penalties.

The final route is then transformed back to it's original OSMnx id's. This allows the retracing of the route in the front-end, since the internal network representation for routing is not used by the front-end.

=== Generally
The use of dense indices and array-based edge storage reduces unnecessary indexing overhead. The adjacency list provides a direct and efficient way to access neighbouring nodes during the search. Most importantly, the node-state formulation allows cumulative heat exposure to influence routing without requiring the original network structure to be changed. New environmental variables can be incorporated through the same weighting structure, as long as they can be reduced to one numerical value per edge for the selected routing scenario.


=== Application
The application is structured as a local client-server prototype. The backend is served separately from the user interface: the API runs on one local port and the Shiny application runs on another. This separation keeps the computational routing logic outside the interface code. The interface is therefore responsible for interaction and visualisation, while the API is responsible for serving the network, preparing route requests, calling the routing algorithm, and formatting the response.

The route planner uses map interaction to generate routes, the display map is using the MapLibreGL package. The first click sets the origin and the second click sets the destination. These clicked coordinates are sent to the API together with the selected hour. The backend then performs the spatial snapping, calculates the route, reconstructs the traversed edge geometries, and returns a GeoJSON route that can be drawn directly in the interface. This implementation makes the prototype useful both as a technical test environment for the routing algorithm and as a visual demonstrator of how heat-aware pedestrian routing could be exposed to users.#todo[Uses Shiny & MapLibre (why those.)]

#set page(
  paper: "a4",
  flipped: true,
)

#figure(
table(
  columns: 5,
  table.header[*Component*][*Initial approach*][*Bottleneck*][*Revised approach*][*Broader lesson*],
    
  [SOLWEIG_GPU output & network annotation],
  [Merge tiled outputs into a multidimensional GeoTIFF],
  [Large file size and inefficient multidimensional lookup during pedestrian-network annotation],
  [Merge tiled outputs into a Zarr structure],
  [Choosing a file format aligned with the access pattern of the computation can substantially improve performance],

  [pedestrian network],
  [get network from OSM],
  [network consistes of centerlines],
  [out of scope/future work],
  [loading the pedestrian network introduces new innaccuricies due to the assumption that pedestrians are walking on the centerline with this approach],

  [pedestrian network],
  [get network from OSM],
  [automatic filtering loses sidwalk and footway inforamtion],
  [load all information and implement personal filtering, generally a limitation],
  [Using abstraction tools built by others (osmnx) can introduce invisible data loss in unexpected ways.],

  [pedestrian network],
  [Use OSMNX],
  [Implementation is dependent OSMNX graph representation which couples the routing and network allocation by file format],
  [Use a shared data schema between the two elements of the route planner],
  [Dependency on (complex) software packages can introduce unecessary limitations to the system],

  [Network annotation],
  [Flatten environmental value as one attribute into network, map the median UTCI to categories],
  [A lot of information is lost, two road segments can have the same median but with a very different actual feel],
  [Add attributes to the network that can provide context, increases the explainability of the final results],
  [Taking extensibility as a core design requirement has the added benefit that it can increase the explainability of the software. The original pupose was for other workflows or priorities to be possible, but this came up as important as well],

),
caption: "Design steps of the emergent design p"
)<tab:emergent>
#set page(
  paper: "a4",
  flipped: false,
)