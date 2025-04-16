
library(cranlogs)
library(knitr)
library(stringr)
library(tools)
library(gh)
library(dplyr)
library(purrr)
library(base64enc)
library(commonmark)
library(rlang)

dir.create("tables", showWarnings = FALSE)

# in rlang or make ourselves
# `%||%` <- function(x, y) if (!is.null(x)) x else y

# Helper function to fetch README snippet + check for DOI
get_readme_snippet <- function(owner, repo, url) {
  readme <- tryCatch(
    gh("GET /repos/{owner}/{repo}/readme", owner = owner, repo = repo),
    error = function(e) NULL
  )
  if (is.null(readme)) {
    return(list(snippet = NA_character_, doi = NA_character_))
  }
  
  # Decode from base64
  decoded <- rawToChar(base64decode(readme$content))
  # Convert Markdown to plain text (keeps punctuation, strips markup)
  plain_text <- markdown_text(decoded)
  
  # Grab the first 240 characters as a snippet
  lines <- strsplit(plain_text, "\r?\n")[[1]]
  full_readme <- paste(lines, collapse = " ")
  snippet_chars <- substr(full_readme, 1, min(240, nchar(full_readme)))
  snippet <- paste0(snippet_chars, "<a href='", url, "'>...</a>")
  
  # Attempt to find a DOI in the plain text
  doi_match <- str_extract(plain_text, "10\\.\\d{4,9}/\\S+")
  
  if (!is.na(doi_match)) {
    # Remove any trailing period
    doi_match <- str_replace(doi_match, "\\.$", "")
    # Make it clickable
    doi_link <- paste0("<a href='https://doi.org/", doi_match, "'>", doi_match, "</a>")
  } else {
    doi_link <- NA_character_
  }
  
  list(snippet = snippet, doi = doi_link)
}

# Tag categories
tag_categories <- list(
  Type = c(
    "tutorial", "analysis", "simulation", "shiny-app", "dataset", "package"
    ),
  Area = c(
    "air-pollution","heat-waves" ,"temperature","mortality","infectious-disease",
    "small-area-analysis","health-impact-projection","urban-health", 
    "health-impact-assessment","mcc"
           ),
  Methods = c(
    "distributed-lag-models", "exposure-linkage","time-series","meta-analysis",
    "bayesian","linear-mixed-effects","interrupted-time-series","case-time-series",
    "study-design","penalized-regression","multi-stage-analysis","machine-learning", 
    "risk-attribution"
    )
)

# Function to categorize tags
categorize_tags <- function(tags) {
  tags_list <- str_split(tags, "; ")[[1]] # Split tags string into a list
  
  type_tag <- intersect(tags_list, tag_categories$Type)
  area_tag <- intersect(tags_list, tag_categories$Area)
  methods_tag <- intersect(tags_list, tag_categories$Methods)
  
  return(data.frame(Type = ifelse(length(type_tag) > 0, paste(type_tag,collapse = "; "), NA), # Return NA if no match
                    Area = ifelse(length(area_tag) > 0, paste(area_tag,collapse = "; "), NA),
                    Methods = ifelse(length(methods_tag) > 0, paste(methods_tag,collapse = "; "), NA)))
}


# Creating Repo Tables

username <- "ehm-lab"

repos <- gh("GET /users/{username}/repos", username = username, .limit = Inf)

# retrieve and process metadata from github repo by repo
repo_list <- map(repos, function(r) {
  readme_info <- get_readme_snippet(username, r$name, r$html_url)
  
  data.frame(
    Repository  = paste0("<a href='", r$html_url, "'>", r$name, "</a>"),
    About       = ifelse(is.null(r$description), "", r$description),
    Tags        = paste(r$topics, collapse = "; ") %||% "",
    `Last Push` = as.Date(r$pushed_at),
    DOI         = readme_info$doi,
    # Stars       = r$stargazers_count,
    Forks       = r$forks
  )
  
})

repo_df <- bind_rows(repo_list)

# split all tags into four columns, make factors and reorder columns
repo_df <- cbind(repo_df, do.call(rbind, lapply(repo_df$Tags, categorize_tags)))
# repo_df[c("Tags", "Type", "Area", "Methods")] <- lapply(repo_df[c("Tags", "Type", "Area", "Methods")], factor)
repo_df <- select(repo_df, 
                  Repository,About,Tags,Type,Area,Methods,DOI,Last.Push#,Stars,Forks
                  )

all_repos <- subset(repo_df, select = -Tags)
print("about to save first table")
saveRDS(all_repos,"tables/all_repos.RDS")

# split into repo-type tables
analysis <- subset(repo_df, grepl("analysis", Type), select = -Tags)
tutorial <- subset(repo_df, grepl("tutorial", Type), select = -Tags)
simulation <- subset(repo_df, grepl("simulation", Type), select = -Tags)
dataset <- subset(repo_df, grepl("dataset", Type), select = -Tags)
package <- subset(repo_df, grepl("package", Type), select = -Tags)
shiny_app <- subset(repo_df, grepl("shiny-app", Type), select = -Tags)

saveRDS(analysis,"tables/analysis.RDS")
saveRDS(tutorial,"tables/tutorial.RDS")
saveRDS(simulation,"tables/simulation.RDS")
saveRDS(dataset,"tables/dataset.RDS")
saveRDS(package, "tables/package.RDS")
saveRDS(shiny_app, "tables/shiny_app.RDS")

# split into repo-research-area tables
unique(repo_df$Area)
# temperature (inc. of heat-waves), air-pollution, other

temperature <- subset(repo_df, grepl("temperature|heat-waves", Area), select = -Tags)
air_pollution <- subset(repo_df, grepl("air-pollution", Area), select = -Tags)
other <- subset(repo_df, !grepl("temperature|heat-waves|air-pollution", Area), select = -Tags)

saveRDS(temperature,"tables/temperature.RDS")
saveRDS(air_pollution, "tables/air_pollution.RDS")
saveRDS(other, "tables/other.RDS")

# PACKAGES TABLE
ehm_pkgs <- c("dlnm","mixmeta","mvmeta","cirls","cgaim")

dlcounts <- cran_downloads(when = "last-month", packages = ehm_pkgs) |>
  aggregate(x=count~package, FUN=sum)
names(dlcounts) <- c("Package","Downloads (last month)")

ehm_pkgdf <- tools::CRAN_package_db() |> 
  subset(x=_, Package%in%ehm_pkgs, select=c("Package","Title","Maintainer","Description","URL","DOI")) |>
  merge(x=_,y=dlcounts)
rownames(ehm_pkgdf) <- NULL

ehm_pkgdf$Description <- str_remove_all(ehm_pkgdf$Description, "\n")
ehm_pkgdf$DOI <- paste0("<a href='https://doi.org/",ehm_pkgdf$DOI," '>", ehm_pkgdf$DOI , "</a>")

saveRDS(ehm_pkgdf,"tables/ehm_pkgdf.RDS")
