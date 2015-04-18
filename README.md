This code implements the algorithm introduced in 

Yannick Hold-Geoffroy, Jinsong Zhang, Paulo F. U. Gotardo, and Jean-François Lalonde, What Is a Good Day for Outdoor Photometric Stereo?, International Conference on Computational Photography (ICCP), 2015. 

which calculate and show the confidence intervals from a set of HDR environment maps captured throughout a day. 

Project webpage: http://vision.gel.ulaval.ca/~̃jflalonde/projects/outdoorPS/ 

Getting started
===============

Run the 'main.m' script in 'mycode'.

Make sure you have the environments maps and set the 'datebasePath` flag to where the images located.

Running the code on your own images:

All you have to do is to specify 'datebasePath' and 'dateValue' it will automatic calculate the confidence intervals for your data. 

Dataset
===========

See our project webpage.

Requirements
============

Requires some of my software packages (available on github):

* My [utils](http://www.github.com/jflalonde/utils) package;

Requires the following 3rd-party functions (included):

* [Suite of functions to perform uniform sampling of a sphere](http://www.mathworks.com/matlabcentral/fileexchange/37004-suite-of-functions-to-perform-uniform-sampling-of-a-sphere), included in `3rd_party/Uniform_Sampling_of_S2`;


