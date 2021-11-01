
# Example of implementation for midasml package

# This is one of the potential methods that we will use for our model, along with SVM and Neural Nets. 

library(midasml)

# Cross-validation fit for sg-LASSO

x = matrix(rnorm(100 * 20), 100, 20) # Data matrix
beta = c(5,4,3,2,1, rep(0, times = 15))
y = x%*%beta + rnorm(100) # Response variable

gindex = sort(rep(1:4, times = 5)) # Indicates group membership of each covariate

cv.sglfit(x = x, y = y, gindex = gindex, gamma = 0.5,
          standardize = FALSE, intercept = FALSE)
