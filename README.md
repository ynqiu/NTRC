# Noisy Tensor Completion via Low-Rank Tensor Ring

This repository implements a novel noisy tensor completion model for recovering incomplete high-order tensor data with noise.  

## Overview
NTRC (Noisy Tensor Ring Completion) is a tensor completion algorithm that combines tensor ring nuclear norm with least-squares estimation to effectively handle noisy and incomplete tensor data. FaNTRC (Fast NTRC) accelerates the original NTRC method by equivalently minimizing the tensor ring nuclear norm on a smaller core tensor through heterogeneous tensor decomposition, making it particularly efficient for large-scale tensor completion tasks.

## Requirements

- MATLAB R2019b or later
- [Tensor Toolbox 3.6](https://www.tensortoolbox.org/) (included in `tensor_toolbox3.6` directory)


## Key parameters:
- `sr`: Sampling rate 
- `c`: Noise level 
- `lambda`: Regularization parameter 
- `R0`: Tensor ranks for Faster NTRC

## Data Preparation

- Video data should be placed in `data/YUV/`
- Color images should be placed in `data/Images512/`
- Light field images should be placed in `data/LightField/`


## Citation

If you use this code in your research, please cite:
```

@ARTICLE{9800181,
author={Qiu, Yuning and Zhou, Guoxu and Zhao, Qibin and Xie, Shengli},
journal={IEEE Transactions on Neural Networks and Learning Systems},
title={Noisy Tensor Completion via Low-Rank Tensor Ring},
year={2024},
volume={35},
number={1},
pages={1127-1141},
doi={10.1109/TNNLS.2022.3181378}
}
```


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.