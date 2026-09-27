# Rain-aware flood detection with MS-MRF

This MATLAB package detects flood-related changes from a pair of co-registered,
dual-polarization SAR covariance images. It contains the detection pipeline:
configuration loading, covariance input, difference-map generation, superpixel
construction, binary segmentation, and result export.

## Method

The pipeline computes a symmetric HLT difference measure between the two dates,
clips extreme values, and normalizes the result. The `HLT_rain` option subtracts
a normalized post-event VV/VH-derived correction from the difference map and
normalizes it again. This implementation expects VH in C11 and VV in C22.

The default `polsar` superpixel generator combines averaged covariance
features, log-span information, spatial proximity, directional edge contrast,
and local equivalent number of looks (ENL). Connected regions form the nodes
of a superpixel adjacency graph. MS-MRF starts from an Otsu initialization,
estimates binary Gaussian class models, and classifies the region graph using
a Potts energy and graph cuts. It then refines pixels in a narrow band around
the coarse classification boundaries, keeping the remaining pixels fixed.

## Requirements

- MATLAB with Image Processing Toolbox. MATLAB R2025a is the reference
  development environment.
- MATLAB built-in `digraph` and `maxflow` provide graph-cut optimization.
- All project-specific functions and the flat YAML reader are included here.
  No external YAML or graph-cut package is needed.

## Input data

Prepare two co-registered, consistently calibrated and preprocessed covariance
rasters in linear units. Both dates must have the same pixel grid and dimensions.
The package reads prepared rasters; it does not perform registration or SAR
calibration.

Each input directory contains the following files, directly or in a `C2/`
subdirectory:

| File | Component |
| --- | --- |
| `C11.bin` | VH power |
| `C12_real.bin` | Real part of the cross-covariance |
| `C12_imag.bin` | Imaginary part of the cross-covariance |
| `C22.bin` | VV power |

Files are headerless, row-major, little-endian float32 rasters. The reader
constructs the complex C12 component from its real and imaginary files.
Set `lines` and `samples` to the actual raster height and width. The dimensions
and paths in `Config.yaml` are illustrative; input data are not distributed.

## Quick start

1. Open this folder in MATLAB.
2. Edit `Config.yaml`: set the two input paths, raster dimensions, and output
   directory. Relative paths are resolved against the configuration directory.
3. Run:

```matlab
[result, cfg, timing] = Main;
```

To use a separate configuration:

```matlab
[result, cfg, timing] = Main('path/to/experiment.yaml');
```

All MATLAB files should remain together. Main temporarily adds its own folder
to the MATLAB path and restores the previous path on return.

## Configuration

The example selects `HLT_rain`, `polsar`, and `MS-MRF` with superpixel scale
500 pixels, lambda 1.2, eta 0.4, and boundary radius 2 pixels.

| Setting | Meaning |
| --- | --- |
| `diffMethod` | `HLT_rain` for rain correction, or `HLT` for the baseline |
| `segmentationMethod` | `MS-MRF`, `Superpixel-SS-MRF`, `Pixel-SS-MRF`, or `Otsu` |
| `superpixelMethod` | `polsar`, or `reference` for MATLAB superpixels |
| `superpixelScale` | Target mean superpixel area, in pixels |
| `superpixelBeta` | Spatial compactness weight in PolSAR clustering |
| `superpixelChangeWeight` | Optional difference-feature weight; default 0 |
| `mrfLambda` | Superpixel graph regularization weight |
| `mrfPixelLambda` | Pixel graph regularization weight |
| `mrfEta` | Contrast bandwidth used in boundary refinement |
| `mrfBoundaryRadius` | Refinement band radius in pixels |
| `mrfMaxIter` | Maximum classification iterations |

The configuration contains English explanations for the remaining controls.
`reference` generates regions from the difference map using MATLAB defaults;
PolSAR-specific edge, ENL, and clustering settings apply only to `polsar`.
Otsu and Pixel-SS-MRF skip superpixel construction. Superpixel-SS-MRF performs
only the region classification stage. MS-MRF adds boundary refinement.

## Outputs

The configured output directory receives:

- `detection.png`: binary detection image, white for detected change and black
  for no detected change.
- `detection.mat`: logical `result` array (1 = detected change/flood candidate,
  0 = no detected change), resolved configuration `cfg`, and `timing` structure.

The output array has shape `[lines, samples]` and retains the input pixel grid.
PNG does not carry geographic metadata. Reusing the same output directory
replaces its detection files.

The returned timing fields measure difference generation and difference-map
segmentation separately. They exclude input reading, superpixel generation,
and output writing.

## Code organization

`Main.m` is the linear entry point. `readFloodConfig.m` loads parameters;
`readC2.m` reads the covariance pair; `cacDiffGraph.m` constructs the difference
map; `generateSuperPixel.m` creates labels; and `segmentDifferenceImage.m`
dispatches the selected segmentation method. Their supporting functions are
included in the same directory. Accuracy assessment, reference labels,
sensitivity sweeps, and study-area-specific plotting are outside this package.
