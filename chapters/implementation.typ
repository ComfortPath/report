#import "../template.typ": *

= Implementation
<implementation>
This chapter will go into the technical detail on how the tool is implemented and why certain technical choices were made. In @fig:implementation the connection between the separate compontents is represented in a graphical manner. The research process was iterative, as is illutstrated by the changing priorities or design direction indicated in @chap:methodology: Methodology. The goal of this chapter is to describe the final product, not the intermediate steps. The insights generated from the intermediate steps are part of the results and presented there. First, the chapter will present the implementation rationale for the entire tool and how it embodies the final technical requirements. Then it wil go into technical detail for all the components. For the sake of continuity the same conceptual separation as presentend in @chap:methodology: Methodology will be used to give structure to the chapter. However, in a technical sense this seperation can come across as unnatural; e.g. the pedestrian network and input data collection fall under the same 'data preperation' umbrella, but are completely seperate in terms of implementation. Or for example the 'running solweig' section did not require much implementation, so the section is quite short, but did produce a lot of insights in terms of the iterative development. 

#figure(
  image("../figs/implementation/implementation.png", width: 80%),
  caption: [
    Graphical representation of the connection between the componenets.
  ],
) <fig:implementation>
== Full tool

- scalability
  - extendibillity
  - performance
- openness
- reproducibility 
  - minimal input data
- became less important: user facing application.
- modularity
- reusability
- component based architecture


== data preperation
=== umepio
this requirement was realized as a pip package with these components...
- package architecture
- modules and functions
- CLI or API design
- input/output structure
dependency management
how it connects to the existing pipeline
how it supports reproducibility and reuse in practice
  - why and 
=== pedestrian network
- network: builder.py 

OSMnx graph representation necessitates two edges to indicate bidirectionality. This is a good choice when building a routeplanner centered around cars, but pedestrians can (ususally) walk wherever they want. So by choosing to represent bidirectionality as two seperate roads, you're primarily introducing bulk and adding complexity to the routing stage. So while OSMnx is a good choice downloading and the final geospatial displays, it's not quite suited for the steps in between. When saving the network the representation is saved to two dataframes nodes and edges. Where the edges get all the edge attributes assigned at the annotation stage. 
-

== Running solweig
- SOLWEIG GPU
- DelftBlue
- merging tif to Zarr. -> how it's merged

== Annotating the network
<sec:annotation>
- Sampling on a Zarr file. why it's faster
- point-based sampling (or maybe somthing else?)
- which variables to attatch to the edges
- how to go over the edges
- this section is still using networkX because that keeps the logic for this part seperate from the routing and prevents datatranslations while the network is still present in runtime. -> how big can a single networkX graph be loaded in runtime.

-- then we are saving anyway so better do that in a way that manages the scale. 

SOLWEIG_GPU returns tiles in speperate folders with the given tile size and overlap, which are then merged. Shared overlap area is split evenly between adjacent tiles. After which the tile is written to it's georeferened location in the Zarr file, by splitting the overlap the tiles align exactly. Zarr is a cloud optimized format for 

== Routing prototype
NetworkSchema
    ↓
original node IDs mapped to dense integer node indices
    ↓
edges converted to NumPy arrays
    ↓
adjacency list describes connectivity
    ↓
Dijkstra uses edge weights to find a route
    ↓
result maps back to original node IDs and edge table rows

Utilizes 
=== data schema
To perform routing in a way that is scalable, we must lose the networkX representation
- distance always part of the equation?

=== Application
The internal datastructure lists of nodes and edges need to be transformed to a shape that the UI understands.


#table(
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

)