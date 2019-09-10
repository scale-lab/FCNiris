
## Iris Recognition Flow
This repository contains the MATLAB-version of the iris recognition flow used in our paper "A Resource-Efficient Embedded Iris Recognition System using Fully Convolutional Networks." The processing pipeline consists of:

1. Input Iris Images
Datasets explored in this project include CASIA Iris Interval V4 (CASIA4I) and IITD.

2. FCN-based iris segmentation
2.a FCN models produce mask identifying pixels belonging to the iris region.
2.b Pupil/iris and iris/sclera boundary information as well as pupil and iris center points are then extracted using a boundary fitting routine. Currently, the boundaries are assumed to be circular.

3. Iris Normalization and Encoding
The information from the previous step is then used to perform normalization and encoding. The algorithms used here is based on the work by Daugman [1]. The code used in this MATLAB implementation is obtained from Masek et al. [2].

[1]. Daugman, J. (2009). How iris recognition works. In The essential guide to image processing (pp. 715-739). Academic Press.
[2]. Masek, L., Kovesi, P. (2003). MATLAB Source Code for a Biometric Identification System Based on Iris Patterns. School of Computer Science and Software Engineering. University of Western Australia, Perth, Australia. 

### How to run the flow
- Download the normalization and encoding code by Masek et al. from [here](https://www.peterkovesi.com/studentprojects/libor/sourcecode.html) and place them in the `[home]/normalize_encoding` folder. Only 3 files are necessary: `normalizeiris.m`, `encode.m`, and `gaborconvolve.m`.
 
- Change current working directory to `[home]` and add `[home]/tools` and `[home]/normalize_encoding` folders to the paths before executing toplevel files. In addition to the flow, the `tools` folder contains useful code to compute Equal Error Rates and other metrics. A trained FCN model is needed in `[home]/FCN_models`. Some sample trained weights are provided for CASIA4I and IITD.

Three toplevel files are provided, `toplevel_single.m`, `toplevel_dataset.m` and `toplevel_groundtruth.m`. Each of these file is for a different purpose.

- `toplevel_single.m`: this is for processing a single iris image. The output results include an iris encoding and a mask. Simply replace the image path inside this toplevel file before running the code.

For the next two files, we need a whole dataset to be present. For information on how to download dataset, see the README file in [home]/data.

- `toplevel_dataset.m`: this file processes a whole dataset. It computes the EER as output.

- `toplevel_groundtruth.m`: this file processes a whole dataset. However, the iris segmentation is not performed. Instead, groundtruth segmentation mask is used. It computes the EER as output. The purpose is to evaluate what the best possible EER is without the FCN segmentation inaccuracies.

### License and Citation:
Unless specified in file header, the code in this repository is released under the [BSD 3-Clause License](https://github.com/scale-lab/FCNiris/blob/master/LICENSE).

Please use the following citation if this repository helps your research:

@article{tann2019a,
  Author = {Tann, Hokchhay and Zhao, Heng and Reda, Sherief},
  Journal = {arXiv preprint arXiv:1909.03385},
  Title = {A Resource-Efficient Embedded Iris Recognition System using Fully Convolutional Networks},
  Year = {2019}
}
