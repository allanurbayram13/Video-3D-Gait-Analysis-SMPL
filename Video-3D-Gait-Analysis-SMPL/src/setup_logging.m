function log_file = setup_logging()
    timestamp = datetime('now', 'Format', 'yyyy-MM-dd_HHmmss');
    log_file = sprintf('gait_analysis_%s.log', timestamp);
    
    diary(log_file);
    fprintf('=== GAIT ANALYSIS LOG ===\n');
    fprintf('Started: %s\n\n', datetime('now'));
end