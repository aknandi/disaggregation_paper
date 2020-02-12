


For instance, both packages sp and raster have a "disaggregate" method,
package "tempdisagg" has temporal disaggregation methods, and package
"sf" has a method "st_interpolate_aw", for area-weighted interpolation,
which has disaggregation as a special case. These are largely methods
not based on statistical models, but worth relating to in the main text.

sp::disaggregate is doing something totally different (not sure what).
I've mentioned raster::rasterize which is more appropriate than raster::disaggregate. 
Maybe I should mentioned raster::disaggregate explicitely... but it doens't really make sense.