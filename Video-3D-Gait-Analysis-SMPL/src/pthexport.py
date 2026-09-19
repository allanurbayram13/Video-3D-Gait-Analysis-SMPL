import json
import numpy as np
from pathlib import Path
import scipy.io as sio

# ── CONFIG ───────────────────────────────────────────────────────────────────
kp_dir    = Path("EasyMocap/output/sv1p/keypoints3d")
smpl_dir  = Path("data/subject10/smpl")
fps       = 30

# ── SUBJECT CALIBRATION (MODIFY THIS!) ─────────────────────────────────────
SUBJECT_HEIGHT_REAL = 1.75  # ← CHANGE TO ACTUAL SUBJECT HEIGHT IN METERS

# ── COLLECT FILES ─────────────────────────────────────────────────────────────
kp_files   = sorted(kp_dir.glob("*.json"),   key=lambda p: int(p.stem))
smpl_files = sorted(smpl_dir.glob("*.json"), key=lambda p: int(p.stem))

kp_indices   = {int(p.stem): p for p in kp_files}
smpl_indices = {int(p.stem): p for p in smpl_files}
common_frames = sorted(set(kp_indices.keys()) & set(smpl_indices.keys()))
N = len(common_frames)
print(f"Total matched frames: {N}")

# ── ALLOCATE ARRAYS ───────────────────────────────────────────────────────────
joints_xyz = np.zeros((N, 25, 3), dtype=np.float64)
Rh_all     = np.zeros((N, 3),     dtype=np.float64)
Th_all     = np.zeros((N, 3),     dtype=np.float64)
poses_all  = np.zeros((N, 69),    dtype=np.float64)
shapes_all = np.zeros((N, 10),    dtype=np.float64)

# ── LOAD ──────────────────────────────────────────────────────────────────────
for i, fidx in enumerate(common_frames):
    with open(kp_indices[fidx]) as f:
        kp_data = json.load(f)
    joints_xyz[i] = np.array(kp_data[0]["keypoints3d"])

    with open(smpl_indices[fidx]) as f:
        sm_data = json.load(f)
    person = sm_data[0]
    Rh_all[i]     = np.array(person["Rh"]).flatten()
    Th_all[i]     = np.array(person["Th"]).flatten()
    poses_all[i]  = np.array(person["poses"]).flatten()
    shapes_all[i] = np.array(person["shapes"]).flatten()

    if i % 50 == 0:
        print(f"  Frame {fidx:04d} | joints sample (R_Knee): {joints_xyz[i, 10]}")

# ── SANITY CHECK ──────────────────────────────────────────────────────────────
print(f"\njoints_xyz shape : {joints_xyz.shape}")
print(f"Th (pelvis) shape: {Th_all.shape}")
print(f"Value range xyz  : [{joints_xyz.min():.3f}, {joints_xyz.max():.3f}]")

# ── HEIGHT CALIBRATION (CRITICAL!) ────────────────────────────────────────────
body_height_measured = np.max(joints_xyz[:, :, 1]) - np.min(joints_xyz[:, :, 1])
print(f"\n📏 Measured body height from joints: {body_height_measured:.3f} m")
print(f"📏 Subject ACTUAL height (input):   {SUBJECT_HEIGHT_REAL:.3f} m")

scale_factor = SUBJECT_HEIGHT_REAL / body_height_measured
print(f"📐 Calculated scale factor: {scale_factor:.3f}x")

# Apply scaling to all joint positions
joints_xyz = joints_xyz * scale_factor
Th_all = Th_all * scale_factor

# Verify scaling
new_height = np.max(joints_xyz[:, :, 1]) - np.min(joints_xyz[:, :, 1])
print(f"\n✓ AFTER SCALING:")
print(f"   New body height: {new_height:.3f} m")
print(f"   Expected stride: ~{0.7 * SUBJECT_HEIGHT_REAL:.3f} m")

# ── SAVE ──────────────────────────────────────────────────────────────────────
sio.savemat("smpl_gait_data.mat", {
    "joints_xyz":    joints_xyz,
    "Th":            Th_all,
    "Rh":            Rh_all,
    "poses":         poses_all,
    "shapes":        shapes_all,
    "fps":           float(fps),
    "n_frames":      float(N),
    "frame_indices": np.array(common_frames, dtype=np.float64),
    "scale_factor":  float(scale_factor),
})

print(f"\n✓ Saved → smpl_gait_data.mat")
print(f"  joints_xyz : {joints_xyz.shape}  (scaled to real-world)")
print(f"  Th (pelvis): {Th_all.shape}")
print(f"  Scale factor: {scale_factor:.3f}x")