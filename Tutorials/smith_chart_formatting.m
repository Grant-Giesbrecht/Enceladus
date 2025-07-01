% figure(1);
% subplot(1, 2, 1);
% smithplot([1, i*2, -1], 'GridType', 'Z');
% subplot(1, 2, 2);
% smithplot([1, -i*2, -1], 'GridType', 'Y');

figure(1);
subplot(1, 2, 1);
smithplot([1, i*2, -1], 'GridValue', [30.0 5.0 2.0 1.0 0.5 0.2; Inf 30.0 5.0 5.0 2.0 1.0], 'ClipData', 1, 'TitleTopOffset', 0);
subplot(1, 2, 2);
smithplot([1, -i*2, -1], 'GridValue', [30.0 15 5.0 2.5 2.0 1.0 .75 0.5 .35 0.2 .1; Inf 30.0 15 7.5 5.0 5.0 2.8 2.8 2.0 2.0 1.0]);