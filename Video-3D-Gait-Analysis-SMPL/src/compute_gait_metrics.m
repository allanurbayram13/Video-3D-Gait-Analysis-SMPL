function metrics = compute_gait_metrics(joints, Th, events, fps)
% COMPUTE_GAIT_METRICS  Compute clinical spatiotemporal gait parameters
%
%   metrics = compute_gait_metrics(joints, Th, events, fps)
%
%   Computed parameters (with Winter 1991 normal ranges):
%     cadence         — steps per minute          normal: 100-130
%     stride_length   — meters per stride         normal: 1.30-1.60 m
%     walking_speed   — meters per second         normal: 1.20-1.60 m/s
%     step_width      — lateral foot separation   normal: 0.06-0.12 m
%     stance_pct      — % of cycle in stance      normal: ~60%
%     swing_pct       — % of cycle in swing       normal: ~40%
%     symmetry_index  — L vs R asymmetry (%)      normal: <10%

    hs_R = events.heel_strike_R;
    hs_L = events.heel_strike_L;
    to_R = events.toe_off_R;
    to_L = events.toe_off_L;

    N_frames     = size(joints, 1);
    duration_sec = N_frames / fps;

    % ── Cadence ───────────────────────────────────────────────────────────
    n_steps = length(hs_R) + length(hs_L);
    metrics.cadence = n_steps / duration_sec * 60;   % steps/min

    % ── Stride length ─────────────────────────────────────────────────────
    % Distance between consecutive heel strikes of the SAME foot
    % Using pelvis (Th) displacement as proxy for body progression
    sl_R = zeros(1, max(0, length(hs_R)-1));
    for i = 1:length(hs_R)-1
        sl_R(i) = norm(Th(hs_R(i+1),:) - Th(hs_R(i),:));
    end

    sl_L = zeros(1, max(0, length(hs_L)-1));
    for i = 1:length(hs_L)-1
        sl_L(i) = norm(Th(hs_L(i+1),:) - Th(hs_L(i),:));
    end

    metrics.stride_length_R = mean(sl_R);
    metrics.stride_length_L = mean(sl_L);
    metrics.stride_length   = mean([sl_R, sl_L]);

    % ── Walking speed ─────────────────────────────────────────────────────
    % Total pelvis displacement over total duration
    total_dist = norm(Th(end,:) - Th(1,:));
    metrics.walking_speed = total_dist / duration_sec;   % m/s

    % ── Step width ────────────────────────────────────────────────────────
    % Lateral (Z) distance between ankles at heel strike events
    % 12=R_Ankle, 16=L_Ankle
    n_pairs = min(length(hs_R), length(hs_L));
    sw = zeros(1, n_pairs);
    for i = 1:n_pairs
        z_R = joints(hs_R(i), 12, 3);   % R_Ankle Z at R heel strike (lateral)
        z_L = joints(hs_L(i), 16, 3);   % L_Ankle Z at L heel strike (lateral)
        sw(i) = abs(z_R - z_L);
    end
    metrics.step_width = mean(sw);

    % ── Stance / Swing phase ──────────────────────────────────────────────
    % Right side
    stance_pcts_R = [];
    for i = 1:length(hs_R)-1
        cycle_dur = hs_R(i+1) - hs_R(i);
        to_in = to_R(to_R > hs_R(i) & to_R <= hs_R(i+1));
        if ~isempty(to_in)
            stance_dur = to_in(1) - hs_R(i);
            stance_pct = (stance_dur / cycle_dur) * 100;
            if stance_pct >= 40 && stance_pct <= 75
                stance_pcts_R(end+1) = stance_pct;
            end
        end
    end
    
    % Left side
    stance_pcts_L = [];
    for i = 1:length(hs_L)-1
        cycle_dur = hs_L(i+1) - hs_L(i);
        to_in = to_L(to_L > hs_L(i) & to_L <= hs_L(i+1));
        if ~isempty(to_in)
            stance_dur = to_in(1) - hs_L(i);
            stance_pct = (stance_dur / cycle_dur) * 100;
            if stance_pct >= 40 && stance_pct <= 75
                stance_pcts_L(end+1) = stance_pct;
            end
        end
    end
    
    all_stance_pcts = [stance_pcts_R, stance_pcts_L];
    
    if ~isempty(all_stance_pcts)
        metrics.stance_pct = mean(all_stance_pcts);
        metrics.swing_pct = 100 - metrics.stance_pct;
    else
        metrics.stance_pct = NaN;
        metrics.swing_pct  = NaN;
    end

    % SI = |L - R| / (0.5*(L+R)) * 100   (0% = perfect symmetry)
    L = metrics.stride_length_L;
    R = metrics.stride_length_R;
    if (L + R) > 0
        metrics.symmetry_index = abs(L - R) / (0.5*(L+R)) * 100;
    else
        metrics.symmetry_index = NaN;
    end

    fprintf('[4] Clinical Gait Metrics:\n');
    fprintf('     %-20s %7.1f  steps/min   (normal: 100-130)\n', 'Cadence:', metrics.cadence);
    fprintf('     %-20s %7.3f  m           (normal: 1.30-1.60)\n', 'Stride length:', metrics.stride_length);
    fprintf('     %-20s %7.3f  m/s         (normal: 1.20-1.60)\n', 'Walking speed:', metrics.walking_speed);
    fprintf('     %-20s %7.3f  m           (normal: 0.06-0.12)\n', 'Step width:', metrics.step_width);
    if ~isnan(metrics.stance_pct)
        fprintf('     %-20s %7.1f  %%           (normal: ~60%%)\n', 'Stance phase:', metrics.stance_pct);
        fprintf('     %-20s %7.1f  %%           (normal: ~40%%)\n', 'Swing phase:', metrics.swing_pct);
    end
    fprintf('     %-20s %7.1f  %%           (normal: <10%%)\n', 'Symmetry index:', metrics.symmetry_index);
end