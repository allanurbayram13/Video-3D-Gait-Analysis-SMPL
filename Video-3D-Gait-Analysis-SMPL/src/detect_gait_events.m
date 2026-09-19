function events = detect_gait_events(joints, fps)
    % ── Extract vertical trajectories (Y = dim 2) ─────────────────────────
    heel_R_y = squeeze(joints(:, 25, 2));   % R_Heel   vertical
    heel_L_y = squeeze(joints(:, 22, 2));   % L_Heel   vertical
    toe_R_y  = squeeze(joints(:, 23, 2));   % R_BigToe vertical
    toe_L_y  = squeeze(joints(:, 20, 2));   % L_BigToe vertical

    % ── Peak detection parameters ─────────────────────────────────────────
    min_prom = 0.008;                        % 8 mm minimum prominence
    min_dist = round(fps * 0.25);            % min 0.25 s between events

    % ── Heel strikes: minima of heel Y ───────────────────────────────────
    [~, hs_R] = findpeaks(-heel_R_y, ...
        'MinPeakProminence', min_prom, ...
        'MinPeakDistance',   min_dist);

    [~, hs_L] = findpeaks(-heel_L_y, ...
        'MinPeakProminence', min_prom, ...
        'MinPeakDistance',   min_dist);

    % ── Toe-offs: maxima of toe Y ─────────────────────────────────────────
    [~, to_R] = findpeaks(toe_R_y, ...
        'MinPeakProminence', min_prom, ...
        'MinPeakDistance',   min_dist);

    [~, to_L] = findpeaks(toe_L_y, ...
        'MinPeakProminence', min_prom, ...
        'MinPeakDistance',   min_dist);

    if length(hs_R) < 2 || length(hs_L) < 2
        warning(['Few gait events detected with default params. ' ...
                 'Trying relaxed detection...']);
        min_prom2 = 0.003;
        min_dist2 = round(fps * 0.15);
        [~, hs_R] = findpeaks(-heel_R_y, 'MinPeakProminence', min_prom2, ...
                              'MinPeakDistance', min_dist2);
        [~, hs_L] = findpeaks(-heel_L_y, 'MinPeakProminence', min_prom2, ...
                              'MinPeakDistance', min_dist2);
        [~, to_R] = findpeaks(toe_R_y,  'MinPeakProminence', min_prom2, ...
                              'MinPeakDistance', min_dist2);
        [~, to_L] = findpeaks(toe_L_y,  'MinPeakProminence', min_prom2, ...
                              'MinPeakDistance', min_dist2);
    end

    events.heel_strike_R = hs_R;
    events.heel_strike_L = hs_L;
    events.toe_off_R     = to_R;
    events.toe_off_L     = to_L;

    fprintf('[3] Gait events detected:\n');
    fprintf('     R heel strikes: %2d  |  L heel strikes: %2d\n', ...
            length(hs_R), length(hs_L));
    fprintf('     R toe-offs:     %2d  |  L toe-offs:     %2d\n', ...
            length(to_R), length(to_L));
    fprintf('     Note: R > L is expected if subject started/ended on right foot\n');
end