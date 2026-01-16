# Human Islet Immunofluorescence Analysis Pipeline

This repository contains the complete image analysis and statistical pipeline for quantifying intracellular protein expression in single human pancreatic islet cells using multiplex immunofluorescence, semantic segmentation, and linear mixed modeling (LMM). The approach is optimised to assess differences in protein intensity (e.g., NOX5) across endocrine cell types (insulin+, glucagon+) within human donor tissue.

## Overview

The workflow is structured as follows:

1. **Image Preprocessing and Channel Separation** using an ImageJ macro.
2. **Semantic Segmentation** of tissue and islet regions using Ilastik.
3. **Nuclear Segmentation and Cell Classification** using StarDist and CellProfiler.
4. **Extraction of Per-Cell Measurements** for protein intensity and hormone marker status.
5. **Statistical Modeling** using R to evaluate marker expression across cell types and experimental groups.

## Repository Contents

### `GMMacro.ijm` and `exocrinemacro.ijm`

* Custom ImageJ macro developed for batch image preprocessing. Functions include:

  * Conversion of `.lif` to multi-channel `.tif`
  * Channel separation and recombination
  * Preparation of input images for Ilastik and StarDist
  * Subtraction of non-nuclear background
  * Saving composite files and probability-ready inputs

### `20241104_AG_V2.ilp`

* Ilastik pixel classification project file for identifying tissue and islet compartments.
* Input: multi-channel RGB composite immunofluorescence images
* Output: tissue probability maps used for islet segmentation

### `CellProfiler_Pipeline.cppipe`

* CellProfiler pipeline for:

  * Importing probability maps and DAPI-stained images
  * Segmenting nuclei using StarDist
  * Identifying cytoplasm boundaries
  * Quantifying intensity of protein and hormone markers at the single-cell level
  * Exporting measurements to `.csv` for downstream statistical analysis

### `analysis_script.Rmd`

* Annotated RMarkdown script for:

  * Cleaning CellProfiler output
  * Assigning hormone identity to each cell (insulin+, glucagon+)
  * Normalising fluorescence intensities
  * Fitting linear mixed-effects models to compare protein levels between cell types and donor groups
  * Visualising cell-level and group-level effects (plots not included in this repository)

## Experimental Design Summary

* **Tissue Source**: Human pancreas tissue obtained from the **Quality in Organ Donation (QUOD) biobank**.
* **Experimental Groups**: Samples selected across defined experimental criteria (e.g., donor age, sex, or clinical status), grouped for statistical comparison. Specific group details are defined in metadata (not included in this repository).
* **Staining Panel**: Multiplex immunofluorescence for NOX5, insulin, glucagon, and nuclear marker DAPI.
* **Imaging**: High-resolution fluorescence microscopy performed under identical settings across all samples to ensure quantitative comparability.
* **Segmentation Strategy**: Combined workflow using Ilastik (tissue segmentation), StarDist (nuclear segmentation), and CellProfiler (cell identification and marker quantification).
* **Statistical Modeling**: LMMs control for donor-level variability and repeated measures across sections, allowing robust comparison of protein expression across endocrine cell types.

## How to Use

1. **Run the ImageJ macro** on raw `.lif` files to generate preprocessed `.tif` images suitable for Ilastik.
2. **Train or apply Ilastik** to produce probability maps distinguishing islet from exocrine tissue.
3. **Use the macro's StarDist-prep step** to generate input files for nuclear segmentation.
4. **Run CellProfiler** using the included pipeline to extract per-cell marker intensities.
5. **Load the data into R** and run the provided analysis script to perform statistical comparisons.

## Credits

* **Staining and Image Acquisition**: Alisha Gibbs, Newcastle University
* **ImageJ Macro Development**: George Merces, Newcastle University
* **Data Processing and Statistical Analysis**: Alana Mullins
* **Tissue Provided by**: Quality in Organ Donation (QUOD) biobank
* **Analysis Supervised by**: Catherine Arden


