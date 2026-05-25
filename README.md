# Automated Anthropometric Measurement using Deep Learning

[![arXiv](https://img.shields.io/badge/arXiv-2512.06434-b31b1b.svg)](https://arxiv.org/abs/2512.06434)
[![License: CC BY-NC 4.0](https://img.shields.io/badge/License-CC_BY--NC_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc/4.0/)

This project implements a deep learning pipeline to automatically estimate human anthropometric measurements from 2D images, with applications in preparticipation cardiovascular screening (PPCE).
The approach leverages transfer learning with state-of-the-art CNN architectures to provide accurate, scalable, and non-invasive measurements.

## Papers

1. [Automated Deep Learning Estimation of Anthropometric Measurements for Preparticipation Cardiovascular Screening](https://arxiv.org/abs/2512.06434)
2. **ADD ARGENCON**

## Overview

Traditional anthropometric measurements (e.g., waist circumference, limb length) are: Time-consuming, Operator-dependent & Hard to scale
This project proposes an automated alternative using deep learning models trained on synthetic human body data.
### Aplications


This system can be used for:


### Models

We evaluate and compare three well-known convolutional neural networks:

- VGG19
- ResNet50
- DenseNet121

All models use:

- Transfer learning (pretrained on ImageNet)
- Frozen convolutional base
- Fully connected regression head


## Target Measurements

**TBD**

## Training Details

**TBD**

## Results

**TBD**

## How to Run

**TBD**

## Contributions

Feel free to open issues or submit pull requests.

## License

This work is licensed under CC BY-NC 4.0.
You must give appropriate credit and may not use it for commercial purposes.
