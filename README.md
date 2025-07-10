# Tunnels and bridges in Venice

![Venice city network](image-poster.png)

Repo for the [StatPhys'29](https://statphys29.org) poster *Over the
bridge, under the gate: analyzingthe role of bridges and underpasses
in thecomplex network of Venetian streets*, by JJ Merelo and Uri
Hershberg, focused on network analysis of tunnels and
bridges.

Check out the full text by [downloading the
abstract](https://github.com/JJ/venice-tunnels-bridges/releases/download/v0.9/abstract-venice-tunnels-bridges.pdf)
or  [the technical report that goes with it](https://digibug.ugr.es/handle/10481/105168).

What can we learn by analyzing the city network of Venice about its
history or self-organizing nature? Find out by reading [the paper](https://digibug.ugr.es/handle/10481/105168)

If you're using the code, or referencing [the paper](https://digibug.ugr.es/handle/10481/105168), use this:

```bibtex
@misc{10481/105168,
year = {2025},
month = {7},
url = {https://hdl.handle.net/10481/105168},
abstract = {Venice, renowned for its water channels, is a largely pedestrianized city that has barely changed its configuration in the last 500 years. Several hundred bridges link the islands of Venice represent also one of the few significant changes to the city's network over time, highlighting their crucial role in its urban configuration. Notably, Venice's unique character stems from the largely unplanned and self-organizing nature of its development, which makes it an intriguing subject for study.
Sotoportegos (covered walkways) are another prominent urban feature. Here we will focus on the role these two urban features have in the complex network of Venice streets, what is their status, and which specific type of elements have the highest centrality, trying to explain via historical and statistical research why that is so.},
organization = {Ministerio español de Economía y Competitividad PID2023-147409NB-C21},
keywords = {Venice},
keywords = {Complex network analysis},
keywords = {Urban networks},
title = {Over the bridge, under the gate: analyzing the role of bridges and underpasses in the complex network of Venetian streets},
author = {Merelo Guervós, Juan Julián and Hershberg, Uri},
}
```


## Data

Data for the paper is in [`venice.graph.undirected.Rdata`](venice.graph.undirected.Rdata), obviously in Rdata format.

## Code and paper source

The code is [embedded in the paper using
`knitr`](abstract-venice-tunnel-bridges.Rnw).

A report that support the poster can be found [here, including
code](venice-tunnel-bridges.Rnw]. You will need Rstudio to compile it
easily. The [PDF of the paper is included in one of tehe
releases](https://github.com/JJ/venice-tunnels-bridges/releases/download/v0.999/venice-tunnels-bridges.pdf).

## LICENSE

The content of this repository is released under a free [LICENSE](LICENSE) GPL v3.0
