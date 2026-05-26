#import "../template.typ": *

= Implementation
<chap:implementation>
This chapter will go into the technical detail on how the tool is implemented. Discussing the data structures and functions used in the code as well as the structure of the entire tool. @fig:implementation shows the connection between the separate components in a graphical manner. 

First, the chapter will present the implementation rationale for the entire tool. Then it wil go into technical detail for all the components. The structure of the chapter is based on the structure of the code, which differs in some aspects from the conceptual separation used in @chap:methodology. For example, the configuration of the pedestrian network is not included in the data preparation section since it is happening in a different section of the code. The goal of this chapter is for a developer to be capable of re-building the tool.

== Full tool

#figure(
  image("../figs/implementation/implementation.png", width: 80%),
  caption: [
    Graphical representation of the connection between the components.
  ],
) <fig:implementation>

The pedestrian routing tool uses a component based architecture (CBA), which emphasizes modularity and is associated with a better reusability @khalid_software_2025. This is technically enforced through the active separation of code according to @fig:modularity.
#figure(
  image("../figs/implementation/modularity.png", width: 70%),
  caption: [
    Code structure to ensure modularity.
  ],
) <fig:modularity>

== Data preparation
#figure(
  image("../figs/implementation/data_prep.png", width: 70%),
  caption: [
    Structure of the data preparation code.
  ],
) <fig:data_prep>
=== UMEPIO
<imp:umepio>
UMEPIO, like SOLFD @solfd_githum, is organised around four internal classes: buildings, DEMs, CHM, and landcover. With the classes reflecting the main input categories required by SOLWEIG.  The building class retrieves and stores building geometries for the study area. The DEM class generates aligned terrain and surface rasters, using the building geometries where needed to represent urban form. The CHM class derives vegetation height information from LiDAR data and converts this into a raster layer. The land-cover class classifies and rasterises surface types so that they match the spatial grid of the other inputs. More detailed descriptions on the processing steps can be found in and Monahan (2025) @monahan_cool_2025.

Access to the functionality is organised through a user-facing API module, which uses the internal classes and exposes their use through simple callable functions (@fig:umepio). Users can either run separate steps, such as only generating buildings or land cover, or call one high-level function that runs the complete input-generation workflow. This keeps the original processing logic modular while making it easier to (re)use.

Lastly, due to a bug in SOLWEIG\_GPU where it is unable to consider negative values all the negative values of the generated DEMs are set to 0. Note that this is to account for a bug and not desired behaviour which is why it is not implemented in UMEPIO directly.

#figure(
  image("../figs/implementation/umepio_struct.png", width: 70%),
  caption: [
    Structure of UMEPIO package.
  ],
) <fig:umepio>


== Running SOLWEIG
<imp:running-solweig>
#figure(
  image("../figs/implementation/running_solweig.png", width: 70%),
  caption: [
    Structure of collection of scripts used for runnign SOLWEIG
  ],
) <fig:running-solweig>
SOLWEIG-GPU was run on DelftBlue, the TU Delft high-performance computing cluster shared with the entire university. DelftBlue provides CPU, high-memory, and GPU nodes, including GPU partitions with NVIDIA V100 and A100 GPUs, making it suitable for computationally intensive raster-based modelling tasks @DHPC2024. The model was executed through the SOLWEIG\_GPU package @kamath_solweig-gpu_2026 @solweig_gpu_git, using a single function call to run the simulation after the required input rasters and meteorological files had been prepared.

Running on DelftBlue required some adaptation compared with running the model locally. Since only the login nodes have a direct internet connection, the generation and downloading of input data was performed locally before transferring the prepared files to DelftBlue. On DelftBlue, SOLWEIG\_GPU was loaded in a Python virtual environment and executed through an `sbatch` script, which submits the job to the `Slurm` queue until the requested resources become available. Although GPU nodes with higher RAM achieve faster runtimes, the small GPU partition with 10GB of RAM was often more practical because there was no queue. As a result, the total time between submitting the job and obtaining the output could be shorter, even when the runtime itself was slower. SOLWEIG_GPU automatically tiles the input data before processing based on a user-defined tile size; since the documentation states that the optimal tile size depends on available GPU memory @solweig_gpu_git, tiles of 1000 × 1000 cells were used.

== Network annotation
#figure(
  image("../figs/implementation/network_anno.png", width: 80%),
  caption: [
    Structure of network annotation code
  ],
) <fig:network-anno>

=== Network builder
The network is retrieved from OSM @OpenStreetMap OSMnx @osmnx_geoff_2025. A custom filtering step is then applied in Python to select the relevant edges.

The filtering keeps only edges that are usable for pedestrians. In practice, an edge is excluded when it is clearly unsuitable according to the OSM documentation, for example `highway=motorway` or `access=private`. Edges are included when they are suitable for pedestrians, such as `highway=footway`. Roads that are not explicitly pedestrian-only, such as `highway=residential`, are also included. Since explicit pedestrian information is relatively rare, edges with such information are given an additional custom tag, `ped_infra_type=dedicated`, to reflect this. When sidewalk information is available for certain roads, it is also added through the tags `sidewalk_present` and `sidewalk_side`. 

=== Network annotation
<imp:zarr>
For every edge in the network, the UTCI raster is sampled along the edge geometry. The SOLWEIG output is stored as a multiband Zarr raster, where the spatial data are chunked and each chunk contains all 24 hourly bands (@fig:zarr). In this implementation, the chunk structure is `256x256x24`, which means that the original multiband GeoTIFF is reorganised into chunks of 256 by 256 cells, while all 24 hourly UTCI bands are stored on top of each other within each chunk. The conversion to Zarr therefore does not change the raster values, resolution, or spatial extent, but changes how the data are stored and accessed.

Because network edges are spatially clustered, annotating nearby edges is likely to access the same or adjacent Zarr chunks, limiting the amount of data that needs to be loaded into memory. Furthermore, since all 24 hourly bands are stored within each spatial chunk, the complete daily UTCI profile for a raster cell can be retrieved in a single read operation. This enables each edge to be assigned a 24-value thermal attribute without repeatedly accessing separate raster files or individual bands.

All these values are collected and aggregated into two attributes: `utci_median`, which stores the median UTCI value per raster band, and `utci_category`, which stores the corresponding thermal-stress category. Lastly, the names of the added environmental attributes are stored in the network metadata.

#figure(
  image("../figs/implementation/zarr_structure.png", width: 40%),
  caption: [
    Chunked access to the zarr cube adjusted from Trujillo et al. (2026)@Trujillo_zarr_img_2026
  ],
)<fig:zarr>

=== Network storage
During processing the network is kept in the NetworkX representation used by OSMnx, namely `nx.MultiGraph` combined with custom metadata. Using the combination of both the network can be visualized and loaded/saved from/to persistent storage #footnote[In the case of this thesis, persistent storage just means that the network is saved to a file (geoparquet). However, depending on the implementation, other forms of persistent storage, such as a database, could also be used.]. The data schema simply defines which columns need to be kept so the network can be converted reliably between different network representations. From the runtime representation to persistent storage the network is written to two GeoParquet files and one metadata file:

- `nodes.parquet`: contains the original OSM node id and the geometry `point(x, y)` of its location.
- `edges.parquet`: contains the origin and destination node, the OSMnx key, all annotated attributes, and any remaining attributes preserved after filtering.
- `metadata.json`: contains the metadata assigned throughout the annotation process, such as the CRS and the names of the annotated attributes.

== Routing prototype
#figure(
  image("../figs/implementation/routing_pro.png", width: 60%),
  caption: [
    Structure oft the routing prototype
  ],
)<fig:routing-pro>

== Routing prototype
The routing prototype connects the prepared pedestrian network, the routing algorithm, an API layer, and an interactive web interface. The prepared network is loaded from the persisted schema folder containing the node table, edge table, and metadata. At startup, this network is converted into the routing representation used by the algorithm and is also transformed into a GeoJSON payload that can be displayed in the browser. This means that the same underlying network is used both for visualisation and for route calculation, avoiding a separation between what the user sees and what the algorithm uses.

=== Adjacency list
For efficient access during routing, the network topology is represented through an adjacency list. This structure stores for each node, the neighbouring nodes that can be reached from it. Each neighbour entry also stores the corresponding edge. This is important because the neighbour relation itself only describes connectivity, while the edge position provides access to the attributes needed for environmental cost calculation. The adjacency list is created when the network is initialized for routing. So during routing all connections from a single node can be retrieved with a single query. Because the pedestrian network is undirected, this initialization step also inserts each edge in both directions, allowing all movement between connected nodes.

#figure(
  image("../figs/implementation/adjacency_list.png", width: 60%),
  caption: [
    Adjacency list representation of an undirected graph. Adjusted from GeeksforGeeks @geeksforgeeks_adjacency_list_2025.
  ],
)<fig:adjacency-list>

=== Modified Dijkstra
Standard Dijkstra is explained in @chap:background. This implementation follows the same principle, but tracks the least-cost path for each combination of node and route state rather than for each node alone. This is necessary because future edge costs depend on both the current location and the accumulated heat exposure at that point.

The algorithm uses a priority queue to always expand the currently cheapest partial route. Each queue entry contains the current accumulated cost, the current node, and the current route state. When an entry is selected from the queue, the algorithm checks all neighbouring nodes. For each possible next edge, it calculates the weighted edge cost and the updated route state. The new total cost is then compared with the best known cost for the resulting node-state combination.

If the new combination of (node, state) has not been reached before, or if it has now been reached with a lower cost, it is added to the queue. The algorithm also stores the predecessor of each accepted node-state combination. This is required because the final route must be reconstructed after the target has been found. The search stops when the target node is reached. At that point, the algorithm has found the best route under the implemented cost structure, including both distance and dynamic thermal penalties.

The final route is then transformed back to it's original OSMnx id's. This allows the retracing of the route in the front-end, since the internal network representation for routing is not used by the front-end.

=== Application
The application is structured as a local client-server prototype, with the backend API and Shiny interface served separately. This keeps the routing logic outside the interface code: the Shiny application handles map interaction and visualisation, while the API manages the network, route requests, algorithm execution, and response formatting.

Routes are generated through direct map interaction using MapLibreGL. The first click sets the origin and the second click sets the destination. These coordinates, together with the selected hour, are sent to the API, which snaps them to the nearest network nodes, calculates the route, reconstructs the traversed edge geometries, and returns the result as GeoJSON for visualisation in the interface.