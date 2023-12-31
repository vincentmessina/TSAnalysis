setwd("~/Library/Mobile Documents/com~apple~CloudDocs/Waterloo/Coop Files/F23 Resumes/Resumes/Data Science/V3.1/Projects/TS")

# Read data
views <- read.csv("KC_viewership.csv")

# Add a column to views called Game_Num.
views$Game_Num <- 40:1

# Remove the rows of the data frame containing NAs.
views <- na.omit(views)

# Use summary() function Viewers col
print(summary(views$Viewers))

# Calculate mean viewership by Opponent.
mean_viewers_by_opponent <- aggregate(Viewers ~ Opponent, views, mean)
print(mean_viewers_by_opponent)

# Identify the most and least exciting match-ups
most_exciting <- mean_viewers_by_opponent[which.max(mean_viewers_by_opponent$Viewers), "Opponent"]
least_exciting <- mean_viewers_by_opponent[which.min(mean_viewers_by_opponent$Viewers), "Opponent"]
cat(paste("The match-up against", 
          most_exciting, "appears to be the most exciting as it had the highest average viewership \n", 
          "while the match-up against", 
          least_exciting, "appears to be the least exciting based on the viewership data."))

### line searching could be done as a simple grid search
gridLineSearch <- function(theta, rhoFn, d,lambdaStepsize = 0.01, lambdaMax = 1) {
  ## grid of lambda values to search
  lambdas <- seq(from = 0, by = lambdaStepsize,  to = lambdaMax)
  ## line search
  rhoVals <- sapply(lambdas, function(lambda) {rhoFn(theta - lambda * d)})
  ## Return the lambda that gave the minimum
  lambdas[which.min(rhoVals)]
}

gradientDescent <- function(theta = 0,
                            rhoFn, gradientFn, lineSearchFn, testConvergenceFn,
                            maxIterations = 100,
                            tolerance = 1E-6, relative = FALSE,
                            lambdaStepsize = 0.01, lambdaMax = 0.5 ) {
  
  converged <- FALSE
  i <- 0
  
  while (!converged & i <= maxIterations) {
    g <- gradientFn(theta) ## gradient
    glength <-  sqrt(sum(g^2)) ## gradient direction
    if (glength > 0) d <- g /glength
    
    lambda <- lineSearchFn(theta, rhoFn, d,
                           lambdaStepsize = lambdaStepsize, lambdaMax = lambdaMax)
    
    thetaNew <- theta - lambda * d
    converged <- testConvergenceFn(thetaNew, theta,
                                   tolerance = tolerance,
                                   relative = relative)
    theta <- thetaNew
    i <- i + 1
  }
  
  ## Return last value and whether converged or not
  list(theta = theta, converged = converged, iteration = i, fnValue = rhoFn(theta))
}

### Where testCovergence might be (relative or absolute)
testConvergence <- function(thetaNew, thetaOld, tolerance = 1E-10, relative=FALSE) {
  sum(abs(thetaNew - thetaOld)) < if (relative) tolerance * sum(abs(thetaOld)) else tolerance
}

y <- views$Viewers
x <- views$Game_Num
# Load necessary library
library(MASS)



## Setting up the plotting area
par(mfrow=c(1,3))

## Histogram with Sturges' rule
hist(views$Viewers, breaks="Sturges", main="KC Viewership", xlab="Viewers", ylab="Frequency")

## Boxplot
boxplot(views$Viewers, horizontal=TRUE, main="KC Viewership", xlab="Viewers")

## Quantile-plot
n <- length(views$Viewers)
sorted_viewers <- sort(views$Viewers)
proportions <- (1:n)/n

plot(proportions, sorted_viewers, pch=19, col=adjustcolor("grey", alpha=0.5), 
     xlab="Proportion p", ylab="Viewers", main="KC Viewership")


# Histogram:
#   The distribution of viewers appears somewhat right-skewed, meaning there are 
# a few weeks with exceptionally high viewership numbers compared to the rest. 
# Most weeks fall within the 15 to 25 million viewers range, with a peak around 20 million.
# 
# Boxplot:
#   The median viewership seems to be around 18 million.
# The interquartile range suggests that 50% of the weeks have viewership numbers 
# between approximately 15 million and 23 million.There are several outliers on 
# the higher end, which aligns with the right-skew observed in the histogram.
# 
# Quantile Plot:
#   The points deviate from the straight line, especially on the right end. This 
#   suggests that the viewership distribution doesn't strictly follow a normal 
#   distribution. The rightward bend at the high end of the Quantile-plot further 
#   confirms the right-skew observed in the histogram.
# 
# Based on the above observations:
# The "typical" range for weekly viewership might be considered around 15 million 
# to 23 million. Weeks with viewership outside this range are atypical. Likely 
# when Taylor Swift attends.


Viewers <- views$Viewers
##given course notes
powerfun <- function(y, alpha) {
  if(sum(y <= 0) > 0) stop("y must be positive")
  if (alpha == 0)
    log(y)
  else if (alpha > 0) {
    y^alpha
  } else -y^alpha
}



## loss function based on skewness
loss_function <- function(alpha) {
  transformed <- Viewers^alpha
  skewness <- sum((transformed - mean(transformed))^3) /  
                ((length(Viewers) - 1) * sd(transformed)^3)
  return(abs(skewness))
}

## find minimizing value
result <- optim(par=1, fn=loss_function, method="Brent", lower=-10, upper=10)

## Output the optimal alpha value
optimal_alpha <- result$par
print(optimal_alpha)



transformed_viewers <- powerfun(Viewers, optimal_alpha)

##plotting
# Setting up the plotting area
par(mfrow=c(1,3))

# Histogram with Sturges' rule
hist(transformed_viewers, breaks="Sturges", main="Transformed KC Viewership", 
     xlab="Transformed Viewers", ylab="Frequency")

# Boxplot
boxplot(transformed_viewers, horizontal=TRUE, main="Transformed KC Viewership", 
        xlab="Transformed Viewers")

## Quantile-plot
n <- length(transformed_viewers)
sorted_viewers <- sort(transformed_viewers)
proportions <- (1:n)/n

plot(proportions, sorted_viewers, pch=19, col=adjustcolor("grey", alpha=0.5), 
     xlab="Proportion p", ylab="Viewers", main="Transformed KC Viewership")


# The data appears to have slight left skewness. The bump rule from class could
# be preferable because we could fine tune the value to the given data.




# Scatter plot with regression line
model <- lm(Viewers ~ Game_Num, data=views)
plot(views$Game_Num, views$Viewers, main="Scatter Plot of Viewers vs Game_Num", 
     xlab="Game Number", ylab="Number of Viewers", pch=16)
abline(model, col="red")



## initializing 3 empty vectors
Delta_alpha <- numeric()
Delta_beta <- numeric()
Delta_theta <- numeric()

## fit reg model excluding game
for (u in 1:nrow(views)) {
  temp_model <- lm(Viewers ~ Game_Num, data = views[-u, ])
  Delta_alpha <- c(Delta_alpha, abs(coef(model)[1] - coef(temp_model)[1]))
  Delta_beta <- c(Delta_beta, abs(coef(model)[2] - coef(temp_model)[2]))
  Delta_theta <- c(Delta_theta, sqrt(Delta_alpha[u]^2 + Delta_beta[u]^2))
}

## Scatter plot for Delta_alpha
plot(views$Game_Num, Delta_alpha, xlab = "Game Number", ylab = "Delta Alpha", 
     main = "Influence Plot for Alpha", pch=16, col="blue")

## Scatter plot for Delta_beta
plot(views$Game_Num, Delta_beta, xlab = "Game Number", ylab = "Delta Beta", 
     main = "Influence Plot for Beta", pch=16, col="green")

## Scatter plot for Delta_theta
plot(views$Game_Num, Delta_theta, xlab = "Game Number", ylab = "Delta Theta", 
     main = "Influence Plot for Theta", pch=16, col="purple")

## Determine four games with largest influence
top_4_games <- order(Delta_theta, decreasing = TRUE)[1:4]
cat("Top 4 influential games:", top_4_games)



model <- lm(Viewers ~ Game_Num, data=views)
plot(views$Game_Num, views$Viewers, main="Scatter Plot of Viewers vs Game_Num", 
     xlab="Game Number", ylab="Number of Viewers", pch=16)
abline(model, col="red")

## Remove two most recent games (which Taylor Swift attended)
filtered_views <- views[views$Game_Num != 39 & views$Game_Num != 40, ]

## Fit  new regression model on data excluding two most recent games
model_without_taylor <- lm(Viewers ~ Game_Num, data=filtered_views)

## Add regression line of new model to existing plot
abline(model_without_taylor, col="blue")

## Add a legend to distinguish between lines
legend("topright", legend=c("All Games", "Excluding Taylor Swift Attended Games"), 
       col=c("red", "blue"), lty=1, cex=0.8)

# 
# Given the Tukey's bisquare (or biweight) objective function:
# \[
# \rho_k(r) = \left\{ \begin{array}{cc}
#                       \frac{r^2}{2} - \frac{r^4}{2k^2} + \frac{r^6}{6k^4}  & \mbox{for } |r| \le k \\
#                       \frac{k^2}{6}  & \mbox{for } |r| > k
# \end{array} \right.
# \]
# 
# For \( |r| \le k \):
# The derivative with respect to \( r \) is:
# \[
# \frac{\partial}{\partial r}\left(\frac{r^2}{2} - \frac{r^4}{2k^2} + \frac{r^6}{6k^4}\right) = r - \frac{2r^3}{k^2} + \frac{r^5}{k^4}
# \]
# 
# For \( |r| > k \):
# The derivative with respect to \( r \) is:
# \[
# \frac{\partial}{\partial r} \left( \frac{k^2}{6} \right) = 0
# \]
# 
# Given \( r_u = y_u - \alpha - \beta x_u \), the gradient can be calculated as:
# 
# For \( |r| \le k \):
# \[
# g_1 = \frac{\partial \rho}{\partial \alpha} = \sum_{u \in \mathcal{P}} \left( -1 \times \left( r - \frac{2r^3}{k^2} + \frac{r^5}{k^4} \right) \right)
# \]
# \[
# g_2 = \frac{\partial \rho}{\partial \beta} = \sum_{u \in \mathcal{P}} \left( -x_u \times \left( r - \frac{2r^3}{k^2} + \frac{r^5}{k^4} \right) \right)
# \]
# 
# For \( |r| > k \):
# \[
# g_1 = g_2 = 0
# \]
# 
# Thus, the gradient vector for \( |r| \le k \) is:
# \[
# \boldsymbol{g} =  \nabla\rho(\boldsymbol{\theta};\mathcal{P}) = \begin{bmatrix}
#        g_1 \\
#        g_2 \\
#      \end{bmatrix}
# \]


## provided fns
tukey.fn <- function(r, k) {
  val = (r^2)/2 - (r^4)/(2*k^2) + (r^6)/(6*k^4)
  subr = abs(r) > k
  val[ subr ] = (k^2)/6
  return(val)
}

tukey.fn.prime <- function(r, k) {
  val = r - (2*r^3)/(k^2) + (r^5)/(k^4)
  subr = abs(r) > k
  val[ subr ] = 0
  return(val)
}

createRobustTukeyRho <- function(x, y, kval) {
  xbar <- mean(x)
  function(theta) {
    alpha <- theta[1]
    beta <- theta[2]
    sum(tukey.fn(y - alpha - beta * (x  - xbar), k = kval))
  }
}

createRobustTukeyGradient <- function(x, y, kval) {
  xbar <- mean(x)
  function(theta) {
    alpha <- theta[1]
    beta <- theta[2]
    ru = y - alpha - beta * (x  - xbar)
    rhok = tukey.fn.prime(ru, k=kval)
    -1 * c(sum(rhok), sum(rhok * (x - xbar )))
  }
}



##constant value
kval <- 4.685 * 5   # Given value for k

## Ordinary Least Squares Regression to get initial values
fit_ols <- lm(Viewers ~ Game_Num, data = views)

## Extracting coefficients
alpha_init <- coef(fit_ols)[1]  # Intercept
beta_init <- coef(fit_ols)[2]   # Slope

## Setting initial params
initial_parameters <- c(alpha_init, beta_init)
rho <- createRobustTukeyRho(x, y, kval)  
gradient <- createRobustTukeyGradient(x, y, kval)

## optimization
optimized_parameters <- gradientDescent(
  initial_parameters, rho, gradient, gridLineSearch, testConvergence,
  maxIterations = 1000,
  tolerance = 0.000001)

## check with Robust Regression
fit_rlm <- rlm(Viewers ~ Game_Num, data = views)

print("Optimized parameters from gradient descent:")
print(optimized_parameters)

print("Parameters from robust regression:")
print(coef(fit_rlm))



## Reconstruct scatter plot from above
plot(views$Game_Num, views$Viewers, main="Scatter Plot of Viewers vs Game_Num", 
     xlab="Game Number", ylab="Number of Viewers", pch=16)

## Add regression line for all games (red)
abline(model, col="red")

## Remove two most recent games (which Taylor Swift attended)
filtered_views <- views[views$Game_Num != 39 & views$Game_Num != 40, ]

## Fit new regression model on data excluding two most recent games
model_without_taylor <- lm(Viewers ~ Game_Num, data=filtered_views)

## Add regression line excluding Taylor Swift attended games (blue)
abline(model_without_taylor, col="blue")

# Add Tukey Bisquare regression line from gradient descent (green)
abline(optimized_parameters$theta[1], optimized_parameters$theta[2], col="green")

## Add legend to distinguish between lines
legend("topright", legend=c("All Games", "Excluding Taylor Swift Attended Games", "Tukey Bisquare Regression"), 
       col=c("red", "blue", "green"), lty=1, cex=0.8)


# The Tukey seems to do the best job, it seems to be the most centred and capture 
# everything the best. However there isn't a very big difference. You could see 
# the blue line is the most flat. The viewership hasnt really changed across the 
# season. You notice that when you include Taylor (the red line) there is actually 
# an increase in the number of viewers as the season go by, so with only 2 games 
# affected, she certainly had a noticeable influence.
