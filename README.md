# Video-Based 3D Gait Analysis Using SMPL Body Model & MATLAB

[![UNIST](https://img.shields.io/badge/UNIST-Biomedical%20Engineering-blue)](https://www.unist.ac.kr/)
[![Language](https://img.shields.io/badge/MATLAB-R2023b%2B-orange)](https://www.mathworks.com/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

An end-to-end computational pipeline that extracts clinical-grade 3D gait kinematics and diagnostic reports from monocular walking videos without expensive motion-capture sensor arrays.

---

## 📌 Motivation & Clinical Impact

* **The Problem:** Traditional clinical gait analysis relies on optical motion-capture labs ($50,000+), while state-of-the-art video methods (e.g., Stenum et al., 2024) rely on 2D keypoints restricted to sagittal plane approximations.
* **Our Solution:** By leveraging the **SMPL parametric 3D human body model** ($N=6,890$ vertices), this pipeline constructs true 3D joint trajectories ($N \times 25 \times 3$) and computes full spatio-temporal kinematic parameters entirely in MATLAB.

---

## ⚙️ System Architecture

```text
 Walking Video (5-10s)
         │
         ▼
 ┌───────────────────────────┐
 │ Python (EasyMocap / 3DGS) │  --> SMPL Mesh & World Joint Extraction (N x 25 x 3)
 └─────────────┬─────────────┘
               │
               ▼
 ┌───────────────────────────┐
 │ MATLAB Processing Engine  │
 ├───────────────────────────┤
 │  1. load_and_filter       │  --> 4th-order Zero-Phase Butterworth LPF (6 Hz)
 │  2. detect_gait_events    │  --> Heel-Strike (Max Y) & Toe-Off (Min Y)
 │  3. compute_joint_angles  │  --> 3-Point Spatial Vector Angle (Knee, Hip, Ankle)
 │  4. normalize_gait_cycle  │  --> PCHIP Time-Normalization (0-100% Gait Cycle)
 │  5. compute_gait_metrics  │  --> Cadence, Stride Length, Speed, Stance %, Symmetry Index
 │  6. plot_results          │  --> Time Series & Normative Winter (1991) Bands
 └─────────────┬─────────────┘
               │
               ▼
 📊 Clinical Gait Kinematics Report (.txt / .csv)
