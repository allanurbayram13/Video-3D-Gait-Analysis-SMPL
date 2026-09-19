function angles = compute_joint_angles(joints)
    N = size(joints, 1);

    angles.knee_R  = zeros(N,1);
    angles.knee_L  = zeros(N,1);
    angles.hip_R   = zeros(N,1);
    angles.hip_L   = zeros(N,1);
    angles.ankle_R = zeros(N,1);
    angles.ankle_L = zeros(N,1);

    for f = 1:N

        % ── Extract joint positions ───────────────────────────────────────
        midhip   = squeeze(joints(f,  9, :))';
        hip_R    = squeeze(joints(f, 10, :))';
        knee_R   = squeeze(joints(f, 11, :))';
        ankle_R  = squeeze(joints(f, 12, :))';
        toe_R    = squeeze(joints(f, 23, :))';

        hip_L    = squeeze(joints(f, 13, :))';
        knee_L   = squeeze(joints(f, 14, :))';
        ankle_L  = squeeze(joints(f, 15, :))';
        toe_L    = squeeze(joints(f, 20, :))';

        % Approximate trunk direction: midpoint of shoulders (joints 3 & 6)
        % Body25: 2=RShoulder→3, 5=LShoulder→6 (MATLAB)
        shoulder_R = squeeze(joints(f, 3, :))';
        shoulder_L = squeeze(joints(f, 6, :))';
        shoulder_mid = (shoulder_R + shoulder_L) / 2;

        % ── Knee flexion: Hip → Knee → Ankle ─────────────────────────────
        angles.knee_R(f) = angle_3pt(hip_R,  knee_R,  ankle_R);
        angles.knee_L(f) = angle_3pt(hip_L,  knee_L,  ankle_L);

        % ── Hip flexion: Shoulder_mid → Hip → Knee ───────────────────────
        angles.hip_R(f)  = angle_3pt(shoulder_mid, hip_R, knee_R);
        angles.hip_L(f)  = angle_3pt(shoulder_mid, hip_L, knee_L);

        % ── Ankle angle: Knee → Ankle → BigToe ───────────────────────────
        angles.ankle_R(f) = angle_3pt(knee_R, ankle_R, toe_R);
        angles.ankle_L(f) = angle_3pt(knee_L, ankle_L, toe_L);

    end

    fprintf('[2] Computed joint angles (knee, hip, ankle) — left & right\n');
    fprintf('     Knee R:  %.1f° – %.1f°  |  Knee L:  %.1f° – %.1f°\n', ...
            min(angles.knee_R), max(angles.knee_R), ...
            min(angles.knee_L), max(angles.knee_L));
    fprintf('     Hip  R:  %.1f° – %.1f°  |  Hip  L:  %.1f° – %.1f°\n', ...
            min(angles.hip_R),  max(angles.hip_R), ...
            min(angles.hip_L),  max(angles.hip_L));
    fprintf('     Ankle R: %.1f° – %.1f°  |  Ankle L: %.1f° – %.1f°\n', ...
            min(angles.ankle_R),max(angles.ankle_R), ...
            min(angles.ankle_L),max(angles.ankle_L));
end


function angle = angle_3pt(A, B, C)
% Compute interior angle (degrees) at vertex B, given points A, B, C
    v1 = A - B;
    v2 = C - B;
    n1 = norm(v1);
    n2 = norm(v2);
    if n1 < 1e-8 || n2 < 1e-8
        angle = 0;
        return;
    end
    cosTheta = dot(v1, v2) / (n1 * n2);
    cosTheta = max(-1, min(1, cosTheta));   % numerical clamp
    angle = acosd(cosTheta);
end