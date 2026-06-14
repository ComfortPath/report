#import "template.typ": *
#import "@preview/abbr:0.3.1"

#show: abbr.show-rule
#abbr.config(style: it => text(fill: black, it))
#abbr.make(
  ("API", "Application Programming Interface"),
  ("CBA", "Component-Based Architecture"),
  ("CHM", "Canopy Height Model"),
  ("CPU", "Central Processing Unit"),
  ("CRS", "Coordinate Reference System"),
  ("DEM", "Digital Elevation Model"),
  ("DHPC", "Delft High Performance Computing Centre"),
  ("DSM", "Digital Surface Model"),
  ("DSR", "Design Science Research"),
  ("DTM", "Digital Terrain Model"),
  ("ERA5", "ECMWF Reanalysis v5"),
  ("IPCC", "Intergovernmental Panel on Climate Change"),
  ("KNMI", "Koninklijk Nederlands Meteorologisch Instituut"),
  ("OD", "Origin-Destination"),
  ("OSM", "OpenStreetMap"),
  ("OTC", "Outdoor Thermal Comfort"),
  ("PDOK", "Publieke Dienstverlening Op de Kaart"),
  ("PET", "Physiological Equivalent Temperature"),
  ("PyPI", "Python Package Index"),
  ("SOLWEIG", "Solar and LongWave Environmental Irradiance Geometry"),
  ("UMC", "Urban Micro Climate"),
  ("UMEP", "Urban Multi-scale Environmental Predictor"),
  ("UTCI", "Universal Thermal Climate Index"),
)

#let mysettings = toml("settings.toml")
#show: doc => msc-geomatics-tudelft(
  title: mysettings.title,
  author: mysettings.author,
  graduation-year: mysettings.graduation-year,
  graduation-month: mysettings.graduation-month,
  supervisor1: mysettings.supervisor1,
  supervisor2: mysettings.supervisor2,
  supervisor3: mysettings.supervisor3,
  coreader   : mysettings.coreader,
  graduation-group: mysettings.graduation-group,
  doc,
)

//-- front-matter
#set page(
  numbering: "i",
  footer: context {
    if calc.even(here().page()) {
      align(left, counter(page).display("i"));
    } else {
      align(right, counter(page).display("i"));
    }
  }
)
#counter(page).update(1)

#include "front/abstract.typ"
#include "front/acknowledgement.typ"
#[
  #show outline.entry.where(
    level: 1
  ): it => {
    v(12pt, weak: true)
    strong(it)
  }
  #outline(depth: 2, indent: auto)
]

#{
  show outline: it => {
    [#in-outline.update(true)]
    it
    [#in-outline.update(false)]
  }
  outline(title: [List of figures], target: figure.where(kind: image))
}

#outline(
  title: [List of tables],
  target: figure.where(kind: table),
)

#abbr.list(title: "List of Abbreviations", columns: 1)

// page counter anchor
#metadata(()) <front-matter>
#pagebreak()

//-- main-matter
#set page(
  numbering: "1",
  header: context {
    if calc.odd(here().page()) {
      align(right, emph(hydra(1)))
    } else {
      align(left, emph(hydra(2)))
    }
    // line(length: 100%)
  },
  footer: context {
    if calc.even(here().page()) {
      align(left, counter(page).display("1"));
    } else {
      align(right, counter(page).display("1"));
    }
  }
)
#counter(page).update(1)
#set heading(numbering: "1.")

#include "chapters/introduction.typ"
#include "chapters/background.typ"
#include "chapters/relatedwork.typ"
#include "chapters/methodology.typ"
#include "chapters/implementation.typ"
#include "chapters/results.typ"
#include "chapters/discussion.typ"

//-- back-matter
// must take page breaks into account, may need to be offset by +1 or -1
// #context counter(page).update(counter(page).at(<front-matter>).first())
#set heading(numbering: "A.1")
#counter(heading).update(0)
#let sub-figure-numbering = (super, sub) => numbering("A.1a", counter(heading).get().first(), super, sub)
#let figure-numbering = super => numbering("A.1", counter(heading).get().first(), super)
#show figure.where(kind: image): set figure(numbering: figure-numbering)

#include "appendices/appendixA.typ"
#include "appendices/useofai.typ"
#include "appendices/reproducibility.typ"

//-- references
#bibliography("./refs/refs.bib", style: "./refs/ieee-alphabetical.csl")
