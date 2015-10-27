
ICCP15
------

This code implements the algorithm introduced in:

* Yannick Hold-Geoffroy, Jinsong Zhang, Paulo F. U. Gotardo, and Jean-François Lalonde, What Is a Good Day for Outdoor Photometric Stereo?, International Conference on Computational Photography (ICCP), 2015.

This implementation calculates and displays the confidence intervals from a set of HDR environment maps captured throughout a day. 

For more details, please see our project webpage: http://vision.gel.ulaval.ca/~jflalonde/projects/outdoorPS.

*Important*: if you use this code, please cite the paper above!

3DV15
-----

This code implements the algorithm introduced in:

* Yannick Hold-Geoffroy, Jinsong Zhang, Paulo F. U. Gotardo, and Jean-François Lalonde, x-hour Outdoor Photometric Stereo, International Conference on 3-D Vision (3DV), 2015.

This implementation computes and displays the maximum uncertainty over all the possible intervals from a set of HDR environment maps captured throughout a day.

For more details, please see our project webpage: http://vision.gel.ulaval.ca/~jflalonde/projects/xHourPS.

*Important*: if you use this code, please cite the paper above!

Getting started
===============

1. Organize a sequence of environment maps in this folder hierarchy: YYYYMMDD/HHmmSS/envmap.exr . Ready-to-use examples are available on [hdrdb.com](http://hdrdb.com).
2. Modify the `databasePath` and `dateValue` variables at the beginning of `main.m` to point respectively to the 
3. Run the `main.m` script.


Dataset
=======

HDR captures of full days are available on [hdrdb.com](http://hdrdb.com).


Requirements
============

Requires the following software package (available on github):

* [utils](http://www.github.com/jflalonde/utils);
* [hdrutils](http://www.github.com/lvsn/hdrutils);
* [envMapConversions](http://www.github.com/lvsn/envMapConversions);

Also requires the following 3rd-party functions (included in 3dr_party):

* [Suite of functions to perform uniform sampling of a sphere](http://www.mathworks.com/matlabcentral/fileexchange/37004-suite-of-functions-to-perform-uniform-sampling-of-a-sphere), included in `3rd_party/Uniform_Sampling_of_S2`;


