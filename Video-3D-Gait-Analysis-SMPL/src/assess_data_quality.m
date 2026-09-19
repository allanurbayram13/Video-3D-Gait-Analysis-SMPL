function quality = assess_data_quality(joints, events, metrics)
% Assess if data quality is sufficient for clinical use

    quality.warnings = {};
    quality.score = 100;  % Start at 100, deduct for issues

    % Check for missing/NaN joints
    nan_count = sum(isnan(joints(:)));
    if nan_count > 0
        quality.warnings{end+1} = sprintf('Found %d NaN values in joint data', nan_count);
        quality.score = quality.score - 10;
    end

    % Check gait event balance
    r_hs = length(events.heel_strike_R);
    l_hs = length(events.heel_strike_L);
    balance = abs(r_hs - l_hs) / max(r_hs, l_hs);
    if balance > 0.25  % >25% imbalance
        quality.warnings{end+1} = sprintf('High R/L imbalance: R=%d, L=%d', r_hs, l_hs);
        quality.score = quality.score - 15;
    end

    % Check stride length
    if isnan(metrics.stride_length)
        quality.warnings{end+1} = 'Invalid stride length (NaN)';
        quality.score = quality.score - 20;
    elseif metrics.stride_length < 0.3 || metrics.stride_length > 2.5
        quality.warnings{end+1} = sprintf('Unusual stride length: %.3f m', metrics.stride_length);
        quality.score = quality.score - 10;
    end

    % Check walking speed
    if metrics.walking_speed < 0.1 || metrics.walking_speed > 2.5
        quality.warnings{end+1} = sprintf('Unusual walking speed: %.3f m/s', metrics.walking_speed);
        quality.score = quality.score - 10;
    end

    quality.score = max(0, quality.score);
    
    fprintf('\n[QC] Data Quality Assessment: %.0f%%\n', quality.score);
    if ~isempty(quality.warnings)
        fprintf('     Warnings:\n');
        for i = 1:length(quality.warnings)
            fprintf('     - %s\n', quality.warnings{i});
        end
    else
        fprintf('     No quality issues detected ✓\n');
    end
end