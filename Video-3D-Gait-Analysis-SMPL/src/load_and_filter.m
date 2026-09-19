function [joints, Th, fps, N] = load_and_filter(mat_file)
% LOAD_AND_FILTER  Load SMPL joint data and apply Butterworth low-pass filter
%
%   [joints, Th, fps, N] = load_and_filter('smpl_gait_data.mat')
%
%   Inputs:
%     mat_file  - path to smpl_gait_data.mat
%   Outputs:
%     joints    - filtered 3D joint positions  (N x 25 x 3)
%     Th        - pelvis world translation     (N x 3)
%     fps       - frame rate (scalar)
%     N         - number of frames (scalar)
%
%   Filtering: 4th-order zero-phase Butterworth, 6 Hz cutoff
%   (6 Hz is the standard cutoff used in clinical gait analysis labs)

    % ── Load ──────────────────────────────────────────────────────────────
    data = load(mat_file);

    joints_raw = data.joints_xyz;          % (N x 25 x 3)
    Th         = data.Th;                  % (N x 3)  pelvis translation
    fps        = double(data.fps);
    N          = size(joints_raw, 1);

    fprintf('[1] Loaded %d frames at %.0f fps (%.1f sec)\n', ...
            N, fps, N/fps);

    % ── Butterworth low-pass filter ───────────────────────────────────────
    fc  = 6;                               % cutoff freq (Hz)
    ord = 4;                               % filter order
    Wn  = fc / (fps / 2);                  % normalized cutoff
    [b, a] = butter(ord, Wn, 'low');

    joints = zeros(size(joints_raw));
    for j = 1:25
        for ax = 1:3
            sig = squeeze(joints_raw(:, j, ax));
            joints(:, j, ax) = filtfilt(b, a, sig);  % zero-phase
        end
    end

    % Also filter Th (pelvis trajectory)
    for ax = 1:3
        Th(:, ax) = filtfilt(b, a, Th(:, ax));
    end

    fprintf('     Applied 4th-order Butterworth low-pass (fc = %d Hz)\n', fc);
end
