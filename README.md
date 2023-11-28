# Taylor Swift's Impact on NFL Viewership Analysis

This project explores the rumored influence of Taylor Swift's presence at Kansas City Chiefs games on NFL viewership figures. The analysis spans the 2021-2023 NFL seasons, utilizing viewership data alongside game dates and opponents to assess variations and trends.

## Project Structure:
- **Data Preparation:** Leveraging `KC_viewership.csv` for data on game viewership, adding a `Game_Num` sequence for identification, and removing incomplete records.
- **Statistical Summary & Visualization:** Generating a statistical summary of viewership data, creating a variety of plots (histograms, boxplots, quantile plots) to visualize distribution characteristics and identify typical viewership ranges.
- **Transformation & Regression Analysis:** Executing a power transformation for data normalization and applying simple linear regression to model the relationship between game number and viewership. Further analysis involves measuring individual games' influence on the regression model and comparing models with and without the games Swift attended.
- **Robust Regression Modeling:** Incorporating robust regression techniques to account for outliers, specifically using Tukey's Bisquare objective function for a more resilient model fitting.

## Insights:
The project aims to quantify Taylor Swift's impact on NFL viewership by evaluating changes in the viewership pattern before and after her attendance at games, considering both direct and indirect influences on the regression model outcomes.

## Implementation Details:
The analysis is conducted in R, with extensive use of data manipulation, visualization libraries, and regression modeling techniques. The repository includes R scripts detailing the data cleaning process, statistical analysis, modeling, and visualization steps undertaken throughout the project.

## Usage:
The included R scripts can be run in an R environment after setting the working directory to the location of the `KC_viewership.csv` file. The scripts are commented to guide the user through the analysis process.

## Conclusion:
Findings from the project reveal nuanced insights into how celebrity presence could potentially affect sports viewership, providing a data-driven perspective on the relationship between media, entertainment, and sports industries.
