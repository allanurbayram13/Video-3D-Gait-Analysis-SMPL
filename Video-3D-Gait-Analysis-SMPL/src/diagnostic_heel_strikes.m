% diagnostic_joints.m
clear; close all;

load('smpl_gait_data.mat');

% Plot all 25 joints in a single frame to visualize the body
frame = 130;
joints_frame = squeeze(joints_xyz(frame, :, :));

figure('Position', [100 100 1000 800]);

% 3D plot of all joints
plot3(joints_frame(:,1), joints_frame(:,2), joints_frame(:,3), 'b.', 'MarkerSize', 15);
hold on;

% Label each joint
joint_names = {
    '0:Nose', '1:Neck', '2:RShoulder', '3:RElbow', '4:RWrist', ...
    '5:LShoulder', '6:LElbow', '7:LWrist', '8:MidHip', ...
    '9:RHip', '10:RKnee', '11:RAnkle', '12:RBigToe', '13:RHeelSmall', ...
    '14:LHip', '15:LKnee', '16:LAnkle', '17:LBigToe', '18:LHeelSmall', ...
    '19:Neck', '20:Head', '21:LeftEye', '22:RightEye', '23:LeftEar', '24:RightEar'
};

for i = 1:25
    text(joints_frame(i,1), joints_frame(i,2), joints_frame(i,3), ...
         sprintf('%d:%s', i-1, joint_names{i}), 'FontSize', 8);
end

xlabel('X'); ylabel('Y'); zlabel('Z');
title(sprintf('Body25 Joints - Frame %d (Body25 indices shown)', frame));
grid on; axis equal;
view(45, 30);

% Also plot just the leg joints
figure;
leg_indices = [9, 10, 11, 12, 13, 14, 15, 16, 17, 18];  % R and L legs
plot3(joints_frame(leg_indices,1), joints_frame(leg_indices,2), joints_frame(leg_indices,3), 'ro-', 'LineWidth', 2, 'MarkerSize', 8);
hold on;

for i = leg_indices
    text(joints_frame(i,1), joints_frame(i,2), joints_frame(i,3), ...
         sprintf('%d', i-1), 'FontSize', 10, 'FontWeight', 'bold');
end

xlabel('X'); ylabel('Y'); zlabel('Z');
title('Leg Joints Only (Body25 0-indexed)');
grid on; axis equal;
legend('Leg skeleton');
view(45, 30);