fprintf('==============================================\n');
fprintf('   3D GAIT ANALYSIS — Production Version\n');
fprintf('==============================================\n\n');

% Setup logging
log_file = setup_logging();

MAT_FILE = 'smpl_atpical_gait_data.mat';

try
    % 1. Load & validate
    [joints, Th, fps, N] = load_and_filter(MAT_FILE);
    if isempty(joints)
        error('Failed to load data');
    end

    % 2. Compute angles
    angles = compute_joint_angles(joints);

    % 3. Detect events
    events = detect_gait_events(joints, fps);

    % 4. Compute metrics
    metrics = compute_gait_metrics(joints, Th, events, fps);

    % 5. Assess quality
    quality = assess_data_quality(joints, events, metrics);

    % 6. Normalize cycles
    normalized = normalize_gait_cycle(angles, events);

    % 7. Plot results
    plot_results(angles, normalized, events, metrics, fps, N);

    % 8. Export data
    export_results(metrics, normalized, events, N, fps, MAT_FILE);
    generate_report(metrics, quality, MAT_FILE);

    % 9. Animate
    fprintf('\nStarting skeleton animation (close window to finish)...\n');
    animate_skeleton(joints, fps);

    fprintf('\n✓ Analysis complete!\n');
    
catch ME
    fprintf('\nERROR: %s\n', ME.message);
    fprintf('Stack trace:\n');
    disp(ME.stack);
end

diary off;
fprintf('Log saved to: %s\n', log_file);