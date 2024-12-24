%% Reading and loading the video data
clear 
close all 
clc

folderPath = 'C:\Users\samee\Desktop\Semester 5 part 2\Digital image processing\Frames\';

frame0 = load(folderPath + "Ballenwerper_sync_380fps_006.npychunk_0.mat");
frame1 = load(folderPath + "Ballenwerper_sync_380fps_006.npychunk_1.mat");
frame2 = load(folderPath + "Ballenwerper_sync_380fps_006.npychunk_2.mat");
frame3 = load(folderPath + "Ballenwerper_sync_380fps_006.npychunk_3.mat");
frame4 = load(folderPath + "Ballenwerper_sync_380fps_006.npychunk_4.mat");
frame5 = load(folderPath + "Ballenwerper_sync_380fps_006.npychunk_5.mat");
frame6 = load(folderPath + "Ballenwerper_sync_380fps_006.npychunk_6.mat");
frame7 = load(folderPath + "Ballenwerper_sync_380fps_006.npychunk_7.mat");
frame8 = load(folderPath + "Ballenwerper_sync_380fps_006.npychunk_8.mat");
frame9 = load(folderPath + "Ballenwerper_sync_380fps_006.npychunk_9.mat");

frames = cat(1, frame0.video_data, frame1.video_data, frame2.video_data, ...
     frame3.video_data, frame4.video_data, frame5.video_data, ...
     frame6.video_data, frame7.video_data, frame8.video_data, ...
     frame9.video_data);

%%

folderPath = 'C:\Users\samee\Desktop\Semester 5 part 2\Digital image processing\Frames\';

frame0 = load(folderPath + "output_Ballenwerper_sync_380fps_002_chunk_0.mat");
frame1 = load(folderPath + "output_Ballenwerper_sync_380fps_002_chunk_1.mat");
frame2 = load(folderPath + "output_Ballenwerper_sync_380fps_002_chunk_2.mat");
frame3 = load(folderPath + "output_Ballenwerper_sync_380fps_002_chunk_3.mat");
frame4 = load(folderPath + "output_Ballenwerper_sync_380fps_002_chunk_4.mat");
frame5 = load(folderPath + "output_Ballenwerper_sync_380fps_002_chunk_5.mat");
frame6 = load(folderPath + "output_Ballenwerper_sync_380fps_002_chunk_6.mat");
frame7 = load(folderPath + "output_Ballenwerper_sync_380fps_002_chunk_7.mat");
frame8 = load(folderPath + "output_Ballenwerper_sync_380fps_002_chunk_8.mat");
frame9 = load(folderPath + "output_Ballenwerper_sync_380fps_002_chunk_9.mat");

frames2 = cat(1, frame0.Ballenwerper_sync_380fps_002, frame1.Ballenwerper_sync_380fps_002, ...
    frame2.Ballenwerper_sync_380fps_002, frame3.Ballenwerper_sync_380fps_002, ...
    frame4.Ballenwerper_sync_380fps_002, frame5.Ballenwerper_sync_380fps_002, ...
     frame6.Ballenwerper_sync_380fps_002, frame7.Ballenwerper_sync_380fps_002, ...
     frame8.Ballenwerper_sync_380fps_002, frame9.Ballenwerper_sync_380fps_002);

%%

folderPath = 'C:\Users\samee\Desktop\Semester 5 part 2\Digital image processing\Frames\';

frame0 = load(folderPath + "output_Ballenwerper_sync_380fps_003_chunk_0.mat");
frame1 = load(folderPath + "output_Ballenwerper_sync_380fps_003_chunk_1.mat");
frame2 = load(folderPath + "output_Ballenwerper_sync_380fps_003_chunk_2.mat");
frame3 = load(folderPath + "output_Ballenwerper_sync_380fps_003_chunk_3.mat");
frame4 = load(folderPath + "output_Ballenwerper_sync_380fps_003_chunk_4.mat");
frame5 = load(folderPath + "output_Ballenwerper_sync_380fps_003_chunk_5.mat");
frame6 = load(folderPath + "output_Ballenwerper_sync_380fps_003_chunk_6.mat");
frame7 = load(folderPath + "output_Ballenwerper_sync_380fps_003_chunk_7.mat");
frame8 = load(folderPath + "output_Ballenwerper_sync_380fps_003_chunk_8.mat");
frame9 = load(folderPath + "output_Ballenwerper_sync_380fps_003_chunk_9.mat");

frames3 = cat(1, frame0.Ballenwerper_sync_380fps_003, frame1.Ballenwerper_sync_380fps_003, ...
    frame2.Ballenwerper_sync_380fps_003, frame3.Ballenwerper_sync_380fps_003, ...
    frame4.Ballenwerper_sync_380fps_003, frame5.Ballenwerper_sync_380fps_003, ...
     frame6.Ballenwerper_sync_380fps_003, frame7.Ballenwerper_sync_380fps_003, ...
     frame8.Ballenwerper_sync_380fps_003, frame9.Ballenwerper_sync_380fps_003);

%%

folderPath = 'C:\Users\samee\Desktop\Semester 5 part 2\Digital image processing\Frames\';

frame0 = load(folderPath + "output_Ballenwerper_sync_380fps_004_chunk_0.mat");
frame1 = load(folderPath + "output_Ballenwerper_sync_380fps_004_chunk_1.mat");
frame2 = load(folderPath + "output_Ballenwerper_sync_380fps_004_chunk_2.mat");
frame3 = load(folderPath + "output_Ballenwerper_sync_380fps_004_chunk_3.mat");
frame4 = load(folderPath + "output_Ballenwerper_sync_380fps_004_chunk_4.mat");
frame5 = load(folderPath + "output_Ballenwerper_sync_380fps_004_chunk_5.mat");
frame6 = load(folderPath + "output_Ballenwerper_sync_380fps_004_chunk_6.mat");
frame7 = load(folderPath + "output_Ballenwerper_sync_380fps_004_chunk_7.mat");
frame8 = load(folderPath + "output_Ballenwerper_sync_380fps_004_chunk_8.mat");
frame9 = load(folderPath + "output_Ballenwerper_sync_380fps_004_chunk_9.mat");

frames4 = cat(1, frame0.Ballenwerper_sync_380fps_004, frame1.Ballenwerper_sync_380fps_004, ...
    frame2.Ballenwerper_sync_380fps_004, frame3.Ballenwerper_sync_380fps_004, ...
    frame4.Ballenwerper_sync_380fps_004, frame5.Ballenwerper_sync_380fps_004, ...
     frame6.Ballenwerper_sync_380fps_004, frame7.Ballenwerper_sync_380fps_004, ...
     frame8.Ballenwerper_sync_380fps_004, frame9.Ballenwerper_sync_380fps_004);

