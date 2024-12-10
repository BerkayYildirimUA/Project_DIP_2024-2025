import deeplabcut

deeplabcut.create_new_project(
    'MetalOscillationProject',
    'testing',
    ['Imports/Ballenwerper_sync_380fps_006.npy_output_video.mp4'],
    copy_videos=True
)
