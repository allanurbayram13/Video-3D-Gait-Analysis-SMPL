# Video-Based 3D Gait Analysis Using SMPL Body Model & MATLAB

[![UNIST](https://img.shields.io/badge/UNIST-CSE%20%26%20Biomedical%20Engineering-blue)](https://www.unist.ac.kr/)
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
```

---

## 📐 Kinematic & Mathematical Foundation

### 1. Zero-Phase Butterworth Filtering
Noise in 3D joint extraction is mitigated using a 4th-order zero-phase Butterworth Low-Pass Filter ($f_c = 6\text{ Hz}$, $f_s = 30\text{ Hz}$) via double-filtering (`filtfilt`):

$$\vert{}H_{\text{eff}}\vert{} = \vert{}H(j\omega)\vert{}^2, \quad f_c = 6\text{ Hz}$$

### 2. 3D Joint Angle Calculation
Interior angles at joint vertices $B$ (e.g., Knee = Hip-Knee-Ankle) are computed via 3D vector dot products:

$$\theta = \arccos\left(\frac{\vec{v}_1 \cdot \vec{v}_2}{\Vert{}\vec{v}_1\Vert{} \Vert{}\vec{v}_2\Vert{}}\right), \quad \vec{v}_1 = A - B, \; \vec{v}_2 = C - B$$

### 3. Clinical Symmetry Index (SI)
$$SI = \frac{\vert{}X_L - X_R\vert{}}{0.5(X_L + X_R)} \times 100\%$$
*(Where $SI = 0\%$ indicates perfect symmetry and $SI > 10\%$ denotes atypical/pathological gait).*

---

## 📊 Results: Normal vs. Atypical Gait Analysis

The pipeline was validated against benchmark normative data (Winter, 1991) across normal walking and atypical (simulated post-stroke stiff-knee) gait patterns:

| Clinical Parameter | Normal Gait | Atypical Gait | Normative Range | Unit |
| :--- | :---: | :---: | :---: | :---: |
| **Cadence** | **115.3** | **90.7** | $100 - 130$ | $\text{steps/min}$ |
| **Stride Length** | **0.59** | **0.37** | $1.30 - 1.60$ | $\text{m}$ |
| **Walking Speed** | **0.51** | **0.25** | $1.20 - 1.60$ | $\text{m/s}$ |
| **Stance Phase** | **58.9%** | **57.9%** | $\approx 60\%$ | $\%$ |
| **Swing Phase** | **41.1%** | **42.1%** | $\approx 40\%$ | $\%$ |
| **Knee Range of Motion (ROM)** | **55.8°** | **31.8°** *(43% ↓)* | $60° - 70°$ | $\text{deg}$ |
| **Symmetry Index (SI)** | **19.7%** | **11.4%** | $< 10\%$ | $\%$ |

### Visual Comparisons

| Normal Joint Angle Waveforms | Atypical Joint Angle Waveforms |
| :---: | :---: |
| ![Normal Gait](assets/normal_fig1.png) | ![Atypical Gait](assets/atypical_fig1.png) |

---

## 🚀 Quick Start & Usage

### Prerequisites
* MATLAB R2021b or higher
* Signal Processing Toolbox

### Execution
1. Clone the repository:
   ```bash
   git clone [https://github.com/YOUR_USERNAME/Video-3D-Gait-Analysis-SMPL.git](https://github.com/YOUR_USERNAME/Video-3D-Gait-Analysis-SMPL.git)
   cd Video-3D-Gait-Analysis-SMPL
   ```
2. Run the main processing driver in MATLAB:
   ```matlab
   % Run main processing script inside src/
   cd src/
   main_gait_analysis.m
   ```

---

## 📄 Documentation & Slides
For complete project slides and theoretical background, check out [`docs/Video_Based_3D_Gait_Analysis_Slides.pdf`](docs/Video_Based_3D_Gait_Analysis_Slides.pdf).

---

## 👤 Author
**Allanur Bayramgeldiyev**  
* Department of Computer Science & Engineering & Biomedical Engineering  
* Ulsan National Institute of Science and Technology (UNIST)  
* Email: [allanurbayram13@unist.ac.kr](mailto:allanurbayram13@unist.ac.kr)
