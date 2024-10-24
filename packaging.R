#=============================================================================
# Put together the package
#=============================================================================

# WORKFLOW: UPDATE EXISTING PACKAGE
# 1) Modify package content and documentation.
# 2) Increase package number in "use_description" below.
# 3) Go through this script and carefully answer "no" if a "use_*" function
#    asks to overwrite the existing files. Don't skip that function call.
# devtools::load_all()

library(usethis)

# Sketch of description file
use_description(
  fields = list(
    Title = "Marginal Plots",
    Version = "0.0.1",
    Description = "Provides tools to create high-quality plots for model analysis.
    The main function 'marginal()' calculates average observed values of the model
    response, average predicted values, partial dependence, and exposure for each
    feature and (possibly binned) feature value.
    Visualization can be done via 'ggplot2' or 'plotly'.
    Optimized for speed and convenience, the package supports models with numeric
    predictions, including regression and probabilistic binary classification.
    It is compatible with many models out-of-the-box, also those wrapped with
    'DALEX' explainers or 'Tidymodels'.",
    `Authors@R` = "person('Michael', 'Mayer', email = 'mayermichael79@gmail.com', role = c('aut', 'cre'))",
    Depends = "R (>= 4.1.0)",
    LazyData = NULL
  ),
  roxygen = TRUE
)

use_package("ggplot2", "Imports")
use_package("grDevices", "Imports")
use_package("patchwork", "Imports")
use_package("plotly", "Imports")
use_package("stats", "Imports")

use_gpl_license(2)

# Your files that do not belong to the package itself (others are added by "use_* function")
use_build_ignore(c("^packaging.R$", "[.]Rproj$", "^logo.png$",
                   "^docu$", "^backlog$"), escape = FALSE)

# Add short docu in Markdown (without running R code)
use_readme_md()

# If you want to add unit tests
use_testthat()


# On top of NEWS.md, describe changes made to the package
use_news_md()

# Add logo
use_logo("logo.png")

# If package goes to CRAN: infos (check results etc.) for CRAN
use_cran_comments()

use_github_links() # use this if this project is on github

# Github actions
# use_github_action("check-standard")
# use_github_action("test-coverage")
# use_github_action("pkgdown")

#=============================================================================
# Finish package building (can use fresh session)
#=============================================================================

library(devtools)

document()
# test()
check(manual = TRUE, cran = TRUE)
build()
# build(binary = TRUE)
install(upgrade = FALSE)

# Run only if package is public(!) and should go to CRAN
if (FALSE) {
  check_win_devel()
  check_rhub()

  # Wait until above checks are passed without relevant notes/warnings
  # then submit to CRAN
  release()
}
