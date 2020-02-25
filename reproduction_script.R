# disaggregation: An R Package for Bayesian Spatial Disaggregation 
# Modelling
#
# This replication script runs all code needed to reproduce results
# in the paper above
#
# If you want to re-run the MCMC time comparison for full replicability, 
# please set the variable (run_mcmc) below to TRUE.
# NOTE: running the MCMC will take a long time even on high
# performance systems.

run_mcmc <- FALSE

#######
# Example predicting malaria in Madagascar
#######

library(disaggregation)
library(raster)
library(tmbstan)

shapes <- shapefile('data/shapes/mdg_shapes.shp')
population_raster <- raster('data/population.tif')
covariate_stack <- getCovariateRasters('data/covariates', 
                                       shape = population_raster)

dis_data <- prepare_data(polygon_shapefile = shapes, 
                         covariate_rasters = covariate_stack, 
                         aggregation_raster = population_raster, 
                         mesh.args = list(max.edge = c(0.7, 8), 
                                          cut = 0.05, 
                                          offset = c(1, 2)),
                         id_var = 'ID_2',
                         response_var = 'inc',
                         na.action = TRUE,
                         ncores = 8)

summary(dis_data)

plot(dis_data)

fitted_model <- disag_model(data = dis_data,
                            iterations = 1000,
                            family = 'poisson',
                            link = 'log')


summary(fitted_model)

plot(fitted_model)

model_prediction <- predict(fitted_model)

plot(model_prediction)


##########
# Comparison with MCMC
##########

if(run_mcmc) {
  
  message('Runnning the MCMC algorithm. This takes a long time')
  
  model_object <- make_model_object(data = dis_data,
                                    family = 'poisson',
                                    link = 'log')
  
  start <- Sys.time()
  mcmc_out <- tmbstan(model_object, chains = 4, iter = 8000, warmup = 2000,
                      cores = getOption('mc.cores', 4))
  end <- Sys.time()
  print(end - start)
  
  # Plot the trace of the parameter values
  stan_trace(mcmc_out,
             pars = c('intercept',
                      'slope[1]', 'slope[2]', 'slope[3]',
                      'iideffect_log_tau', 'log_sigma', 'log_rho'))
  
  # Print the summary results 
  summary(mcmc_out)$summary[c('intercept',
                              'slope[1]', 'slope[2]', 'slope[3]',
                              'iideffect_log_tau', 'log_sigma', 'log_rho'), ]
  
} 

