
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tab2xml <a href="https://josesamos.github.io/tab2xml/"><img src="man/figures/logo.png" align="right" height="139" alt="tab2xml website" /></a>

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/tab2xml)](https://CRAN.R-project.org/package=tab2xml)
[![R-CMD-check](https://github.com/josesamos/tab2xml/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/josesamos/tab2xml/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/josesamos/tab2xml/graph/badge.svg)](https://app.codecov.io/gh/josesamos/tab2xml)
[![CRAN
Downloads](http://cranlogs.r-pkg.org/badges/grand-total/tab2xml)](https://cran.r-project.org/package=tab2xml)
<!-- badges: end -->

The goal of `tab2xml` is to convert spreadsheet files (.xlsx or .ods)
into structured XML documents using a predefined template. The package
processes the spreadsheet data, replacing template tokens with
corresponding values, and manages foreign key relationships
automatically.

## Installation

You can install the released version of `tab2xml` from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("tab2xml")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("josesamos/tab2xml")
```

## Example

This example demonstrates how to use `tab2xml` to convert an Excel or
ODS file into an XML file, based on a schema example from the [Mondrian
Documentation](https://mondrian.pentaho.com/documentation/schema.php).

``` r
library(tab2xml)

# Define file paths
source_xml <- system.file("extdata", "schema_template.xml", package = "tab2xml")
source_xlsx <- system.file("extdata", "schema.xlsx", package = "tab2xml")
temp_file <- tempfile(fileext = ".xml")
```

### Show spreadsheet contents

``` r
sheet_names <- readxl::excel_sheets(source_xlsx)
for (sheet in sheet_names) {
  cat("\n#### Sheet:", sheet)
  data <- readxl::read_excel(source_xlsx, sheet = sheet)
  print(knitr::kable(data))
}
```

#### Sheet: Cube

| cube_pk | name  | table_fk |
|--------:|:------|---------:|
|       1 | Sales |        1 |

#### Sheet: Table

| table_pk | name            |
|---------:|:----------------|
|        1 | sales_fact_1997 |
|        2 | customer        |
|        3 | time_by_day     |

#### Sheet: Dimension

| dimension_pk | name   | foreignKey  | cube_fk |
|-------------:|:-------|:------------|--------:|
|            1 | Gender | customer_id |       1 |
|            2 | Time   | time_id     |       1 |

#### Sheet: Hierarchy

| hierarchy_pk | name | hasAll | allMemberName | primaryKey | dimension_fk | table_fk |
|---:|:---|:---|:---|:---|---:|---:|
| 1 | Gender | true | allMemberName=“All Genders” | customer_id | 1 | 2 |
| 2 | Time | false | NA | time_id | 2 | 3 |

#### Sheet: Level

| name    | column        | type    | uniqueMembers | hierarchy_fk |
|:--------|:--------------|:--------|:--------------|-------------:|
| Gender  | gender        | String  | true          |            1 |
| Year    | the_year      | Numeric | true          |            2 |
| Quarter | quarter       | Numeric | false         |            2 |
| Month   | month_of_year | Numeric | false         |            2 |

#### Sheet: Measure

| name        | column      | aggregator | formatString | cube_fk |
|:------------|:------------|:-----------|:-------------|--------:|
| Unit Sales  | unit_sales  | sum        | \#,###       |       1 |
| Store Sales | store_sales | sum        | \#,###.##    |       1 |
| Store Cost  | store_cost  | sum        | \#,###.00    |       1 |

#### Sheet: CalculatedMember

| calculatedmember_pk | name | dimension | formula | cube_fk |
|---:|:---|:---|:---|---:|
| 1 | Profit | Measures | \[Measures\].\[Store Sales\] - \[Measures\].\[Store Cost\] | 1 |

#### Sheet: CalculatedMemberProperty

| name          | value      | calculatedmember_fk |
|:--------------|:-----------|--------------------:|
| FORMAT_STRING | \$#,##0.00 |                   1 |

### Convert spreadsheet to XML

``` r
file <- sheet2xml(source_xlsx, source_xml, temp_file)
```

### Check output

``` r
library(xml2)

xml_content <- readLines(file, warn = FALSE)

cat("```xml\n", paste(xml_content, collapse = "\n"), "\n```", sep = "")
```

``` xml
<Schema>
    <Cube name="Sales">
                <Table name="sales_fact_1997" />
        <Dimension name="Gender" foreignKey="customer_id">
            <Hierarchy name="Gender" hasAll="true" allMemberName="All Genders" primaryKey="customer_id">
                <Table name="customer" />
                <Level name="Gender" column="gender" type="String" uniqueMembers="true" />
            </Hierarchy>
        </Dimension>
        <Dimension name="Time" foreignKey="time_id">
            <Hierarchy name="Time" hasAll="false"  primaryKey="time_id">
                <Table name="time_by_day" />
                <Level name="Year" column="the_year" type="Numeric" uniqueMembers="true" />
                <Level name="Quarter" column="quarter" type="Numeric" uniqueMembers="false" />
                <Level name="Month" column="month_of_year" type="Numeric" uniqueMembers="false" />
            </Hierarchy>
        </Dimension>
        <Measure name="Unit Sales" column="unit_sales" aggregator="sum" formatString="#,###" />
        <Measure name="Store Sales" column="store_sales" aggregator="sum" formatString="#,###.##" />
        <Measure name="Store Cost" column="store_cost" aggregator="sum" formatString="#,###.00" />
        <CalculatedMember name="Profit" dimension="Measures" formula="[Measures].[Store Sales] - [Measures].[Store Cost]">
            <CalculatedMemberProperty name="FORMAT_STRING" value="$#,##0.00" />
            
        </CalculatedMember>
    </Cube>
</Schema>
```

In this way, we can organize and work with the data in tabular form and
generate XML documents directly using the provided templates.
