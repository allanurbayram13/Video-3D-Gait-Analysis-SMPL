function normalized = normalize_gait_cycle(angles, events)
% NORMALIZE_GAIT_CYCLE  Normalize each gait cycle to 101 points (0-100%)
%
%   normalized = normalize_gait_cycle(angles, events)
%
%   Each cycle runs from one heel strike to the next heel strike
%   of the same foot. Interpolated to 101 points using pchip.
%
%   Output struct fields:
%     .knee_R,  .knee_L   — matrix (n_cycles x 101)
%     .hip_R,   .hip_L
%     .ankle_R, .ankle_L
%     .mean_knee_R  etc.  — mean across cycles (1 x 101)
%     .std_knee_R   etc.  — std  across cycles (1 x 101)

    hs_R = events.heel_strike_R;
    hs_L = events.heel_strike_L;

    normalized.knee_R  = norm_cycles(angles.knee_R,  hs_R);
    normalized.knee_L  = norm_cycles(angles.knee_L,  hs_L);
    normalized.hip_R   = norm_cycles(angles.hip_R,   hs_R);
    normalized.hip_L   = norm_cycles(angles.hip_L,   hs_L);
    normalized.ankle_R = norm_cycles(angles.ankle_R, hs_R);
    normalized.ankle_L = norm_cycles(angles.ankle_L, hs_L);

    % Compute mean and std for each angle
    fields = {'knee_R','knee_L','hip_R','hip_L','ankle_R','ankle_L'};
    for k = 1:numel(fields)
        fn = fields{k};
        mat = normalized.(fn);
        if ~isempty(mat)
            normalized.(['mean_' fn]) = mean(mat, 1);
            normalized.(['std_'  fn]) = std(mat,  0, 1);
        else
            normalized.(['mean_' fn]) = nan(1,101);
            normalized.(['std_'  fn]) = nan(1,101);
        end
    end

    n_R = size(normalized.knee_R, 1);
    n_L = size(normalized.knee_L, 1);
    fprintf('[5] Normalized gait cycles: %d right, %d left\n', n_R, n_L);
end


function mat = norm_cycles(signal, heel_strikes)
% Segment signal by heel strikes and normalize each segment to 101 points
    mat = [];
    for i = 1:length(heel_strikes)-1
        i1  = heel_strikes(i);
        i2  = heel_strikes(i+1);
        seg = signal(i1:i2);
        if length(seg) < 4
            continue;
        end
        x_orig = linspace(0, 100, length(seg));
        x_new  = 0:100;
        row    = interp1(x_orig, seg, x_new, 'pchip');
        mat    = [mat; row]; %#ok<AGROW>
    end
end
