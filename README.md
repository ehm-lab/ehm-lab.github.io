# ehmquarto

To update site: 
0. clone this repo and set as working directory
1. run/source utils_ehm_site.R (requires setting up a github API connection)
  this updates all the tables by calling the github API with e.g if a DOI has been added to a README
2. open Terminal tab in RStudio (it's next to the console tab) and run: "quarto render"
3. site is built in the docs/ directory
4. open the github repo for ehm-lab.github.io (not the site)
5. click add files and drag docs/ to it, after files have loaded commit-push, done
6. site should reflect updates after a few minutes

To run locally: follow 0 to 3 above, then open index.html found in docs/ directory.


Suggested structure for ehm-lab repos

-   **About:** Short, single-sentence description.
-   **Topics:** Prefer pre-selected tags (see topics below).
-   **README:** Title matches "About" section. First DOI to appear will be extracted.

Changes are still possible after forking and can be synced.

|   | tags/topics |
|-------------------------------------------|-----------------------------|
| Type | tutorial; analysis; simulation; shiny-app; dataset; package |
| Area | air-pollution; heat-waves; temperature; mortality; infectious-disease; small-area-analysis; health-impact-projection; urban-health; health-impact-assessment; mcc |
| Methods | distributed-lag-models; exposure-linkage; time-series; meta-analysis; bayesian; linear-mixed-effects; interrupted-time-series; case-time-series; study-design; penalized-regression; multi-stage-analysis; machine-learning; risk-attribution |
