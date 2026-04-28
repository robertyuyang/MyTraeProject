
from PIL import Image
import os
import shutil

# 输入图标
selected_icon = '/Users/bytedance/Documents/src/mydemo/MyTraeProject/icon_options/icon2_backpack.png'
app_icon_dir = '/Users/bytedance/Documents/src/mydemo/MyTraeProject/MyTraeProject/Assets.xcassets/AppIcon.appiconset'

# 先清理旧图标
print("Cleaning old icons...")
for filename in os.listdir(app_icon_dir):
    if filename != 'Contents.json':
        file_path = os.path.join(app_icon_dir, filename)
        try:
            if os.path.isfile(file_path):
                os.unlink(file_path)
        except Exception as e:
            print(f"Error deleting {file_path}: {e}")

# 打开选中的图标
img = Image.open(selected_icon)

# iOS需要的图标尺寸和配置
icon_sizes = [
    {'size': 20, 'scales': [1, 2, 3], 'idiom': 'iphone'},
    {'size': 20, 'scales': [1, 2], 'idiom': 'ipad'},
    {'size': 29, 'scales': [1, 2, 3], 'idiom': 'iphone'},
    {'size': 29, 'scales': [1, 2], 'idiom': 'ipad'},
    {'size': 40, 'scales': [1, 2, 3], 'idiom': 'iphone'},
    {'size': 40, 'scales': [1, 2], 'idiom': 'ipad'},
    {'size': 60, 'scales': [2, 3], 'idiom': 'iphone'},
    {'size': 76, 'scales': [1, 2], 'idiom': 'ipad'},
    {'size': 83.5, 'scales': [2], 'idiom': 'ipad'},
    {'size': 1024, 'scales': [1], 'idiom': 'universal', 'platform': 'ios'}
]

images_config = []

print("Generating icons...")
for config in icon_sizes:
    base_size = config['size']
    for scale in config['scales']:
        actual_size = int(base_size * scale)
        filename = f"{actual_size}x{actual_size}.png"
        
        # 调整大小
        resized = img.resize((actual_size, actual_size), Image.Resampling.LANCZOS)
        resized.save(os.path.join(app_icon_dir, filename))
        
        # 添加到配置
        icon_config = {
            'filename': filename,
            'idiom': config['idiom'],
            'scale': f"{scale}x",
            'size': f"{base_size}x{base_size}"
        }
        if 'platform' in config:
            icon_config['platform'] = config['platform']
            del icon_config['scale']
        images_config.append(icon_config)

# 生成 Contents.json
import json
contents = {
    'images': images_config,
    'info': {
        'author': 'xcode',
        'version': 1
    }
}

with open(os.path.join(app_icon_dir, 'Contents.json'), 'w') as f:
    json.dump(contents, f, indent=2)

print("Done! Backpack icon has been applied successfully!")
