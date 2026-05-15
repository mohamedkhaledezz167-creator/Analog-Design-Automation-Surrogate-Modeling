# Analog-Design-Automation-Surrogate-Modeling
Neural Network models for automating design parameters of CS amplifiers &amp; 5T-OTAs. Includes automated SPICE data generation and model validation
This repository showcases the implementation of Neural Network (NN) surrogate models designed to automate and optimize analog IC parameters. By training models on SPICE-generated datasets, this workflow achieves significant speedups in the design cycle for common analog blocks.

🚀 Key Features
Automated Data Generation: Python-based integration with SPICE/LTspice for automated circuit simulation and dataset creation.

High-Performance Models: Implementation of Deep Learning architectures using TensorFlow to predict circuit performance (Gain, Phase, Power).

Hybrid Workflow: Comparison of implementations across Python and MATLAB environments.

Target Circuits: Optimized for Common-Source (CS) Amplifiers and 5T-Operational Transconductance Amplifiers (OTAs).

📂 Repository Structure
Python_TensorFlow_Implementation/: Contains the core machine learning models, training scripts, and model validation notebooks.

MATLAB_Implementation/: Mathematical modeling and alternative algorithmic implementations.

📊 Technical Highlights
Accuracy: Reached high correlation between NN predictions and SPICE "Golden" data for 5T-OTA parameters.

Speed: Massive reduction in design iteration time compared to traditional manual simulation.

⚠️ Intellectual Property Notice
© 2026 Mohamed Khaled Ezzeldin. All Rights Reserved.
This repository is for portfolio demonstration only. The source code, datasets, and architectural designs provided here in are the private property of the author. Permission is NOT granted to download, modify, or distribute this code for any purpose without explicit written consent.
