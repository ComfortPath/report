#import "../template.typ": *

#heading(outlined: false)[Abstract]

This thesis investigated how SOLWEIG-derived urban microclimate data can be transformed and integrated into a fully open-source, scalable pedestrian routing tool that supports thermally conscious mobility decisions. Scalability is treated as a central design requirement because such a tool can only contribute to climate-adaptive urban mobility if it can be reproduced and extended to different areas without being limited by manual processing or computational bottlenecks.

The modular workflow prepares SOLWEIG input data, runs SOLWEIG_GPU to generate hourly UTCI outputs, samples these outputs onto an OpenStreetMap-derived pedestrian network as edge-level thermal-comfort attributes, and uses these in a modified, state-aware weighted Dijkstra algorithm with user-defined preferences. Interaction with the route planner is implemented using a locally deployable web interface. Evaluation with stratified origin-destination pairs shows that thermally conscious routes can reduce modelled UTCI exposure compared with the shortest path, particularly during hotter hours, while requiring only limited additional walking distance. The development process further shows that scalability depends not only on the routing algorithm, but also on data structures, file formats, network representation, and modular software design. 

