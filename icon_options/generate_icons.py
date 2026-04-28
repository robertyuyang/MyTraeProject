
from PIL import Image, ImageDraw
import os

output_dir = '/Users/bytedance/Documents/src/mydemo/MyTraeProject/icon_options'
os.makedirs(output_dir, exist_ok=True)

# 图标1: 简约清单风格
def create_icon1(size=1024):
    img = Image.new('RGB', (size, size), color='#ff6b6b')
    draw = ImageDraw.Draw(img)
    
    # 粉色渐变背景
    for y in range(size):
        r = int(255 - y * 0.05)
        g = int(107 + y * 0.03)
        b = int(107 + y * 0.02)
        draw.line([(0, y), (size, y)], fill=(r, g, b))
    
    # 白色清单板
    margin = size // 4
    width = size // 2
    height = size // 2
    x = (size - width) // 2
    y = (size - height) // 2
    
    draw.rounded_rectangle([(x, y), (x + width, y + height)], radius=40, fill='#ffffff')
    
    # 清单行
    line_height = height // 5
    for i in range(3):
        line_y = y + line_height * (i + 1)
        # 勾选框
        check_size = 30
        check_x = x + 50
        check_y = line_y - check_size // 2
        draw.rectangle([(check_x, check_y), (check_x + check_size, check_y + check_size)], 
                      outline='#4a4a4a', width=3)
        # 对勾
        if i < 2:
            points = [(check_x + 5, check_y + check_size // 2), 
                     (check_x + check_size // 2, check_y + check_size - 5),
                     (check_x + check_size - 5, check_y + 5)]
            draw.line(points, fill='#2ecc71', width=5, joint='round')
        # 横线
        draw.rectangle([(check_x + check_size + 30, line_y - 5), (x + width - 50, line_y + 5)], 
                      fill='#e0e0e0')
    
    img.save(f'{output_dir}/icon1_checklist.png')

# 图标2: 背包风格
def create_icon2(size=1024):
    img = Image.new('RGB', (size, size), color='#4ecdc4')
    draw = ImageDraw.Draw(img)
    
    # 青绿色渐变背景
    for y in range(size):
        r = int(78 + y * 0.05)
        g = int(205 - y * 0.03)
        b = int(196 + y * 0.02)
        draw.line([(0, y), (size, y)], fill=(r, g, b))
    
    # 背包主体
    margin = size // 4
    width = size // 2
    height = size // 2
    x = (size - width) // 2
    y = (size - height) // 2
    
    # 背包形状
    draw.rounded_rectangle([(x, y + 80), (x + width, y + height)], radius=30, fill='#2d3436')
    draw.rounded_rectangle([(x + 30, y + 100), (x + width - 30, y + height - 30)], 
                          radius=20, fill='#636e72')
    
    # 背包顶部
    draw.rounded_rectangle([(x + 50, y), (x + width - 50, y + 100)], radius=50, fill='#2d3436')
    
    # 背包肩带
    draw.rectangle([(x + 60, y + 50), (x + 120, y + height)], fill='#2d3436')
    draw.rectangle([(x + width - 120, y + 50), (x + width - 60, y + height)], fill='#2d3436')
    
    img.save(f'{output_dir}/icon2_backpack.png')

# 图标3: 地图指南针风格
def create_icon3(size=1024):
    img = Image.new('RGB', (size, size), color='#ffeaa7')
    draw = ImageDraw.Draw(img)
    
    # 黄色渐变背景
    for y in range(size):
        r = int(255 - y * 0.02)
        g = int(234 - y * 0.05)
        b = int(167 + y * 0.03)
        draw.line([(0, y), (size, y)], fill=(r, g, b))
    
    # 指南针
    center = size // 2
    radius = size // 3
    
    # 外圈
    draw.ellipse([(center - radius, center - radius), 
                 (center + radius, center + radius)], 
                fill='#ffffff', outline='#2d3436', width=8)
    
    # 指针
    # 北指针 (红色)
    draw.polygon([(center, center - radius + 30), 
                 (center - 40, center + 20), 
                 (center, center),
                 (center + 40, center + 20)], 
                fill='#e74c3c')
    
    # 南指针 (白色)
    draw.polygon([(center, center + radius - 30), 
                 (center - 40, center - 20), 
                 (center, center),
                 (center + 40, center - 20)], 
                fill='#ecf0f1')
    
    # 中心点
    draw.ellipse([(center - 20, center - 20), 
                 (center + 20, center + 20)], 
                fill='#2d3436')
    
    img.save(f'{output_dir}/icon3_compass.png')

# 图标4: 相机风景风格
def create_icon4(size=1024):
    img = Image.new('RGB', (size, size), color='#a29bfe')
    draw = ImageDraw.Draw(img)
    
    # 紫色渐变背景
    for y in range(size):
        r = int(162 + y * 0.02)
        g = int(155 + y * 0.03)
        b = int(254 - y * 0.05)
        draw.line([(0, y), (size, y)], fill=(r, g, b))
    
    # 相机主体
    center = size // 2
    width = size // 2
    height = size // 3
    x = center - width // 2
    y = center - height // 2
    
    # 相机
    draw.rounded_rectangle([(x, y + 30), (x + width, y + height)], radius=30, fill='#2d3436')
    
    # 镜头
    lens_radius = height // 2 - 20
    lens_center_x = center
    lens_center_y = center + 30
    draw.ellipse([(lens_center_x - lens_radius, lens_center_y - lens_radius),
                 (lens_center_x + lens_radius, lens_center_y + lens_radius)],
                fill='#636e72', outline='#2d3436', width=8)
    draw.ellipse([(lens_center_x - lens_radius // 2, lens_center_y - lens_radius // 2),
                 (lens_center_x + lens_radius // 2, lens_center_y + lens_radius // 2)],
                fill='#0984e3')
    
    # 闪光灯
    draw.rectangle([(x + width - 80, y + 50), (x + width - 30, y + 100)], 
                  fill='#fdcb6e', outline='#e17055', width=3)
    
    img.save(f'{output_dir}/icon4_camera.png')

# 图标5: 票根风格
def create_icon5(size=1024):
    img = Image.new('RGB', (size, size), color='#fd79a8')
    draw = ImageDraw.Draw(img)
    
    # 粉色渐变背景
    for y in range(size):
        r = int(253 - y * 0.05)
        g = int(121 + y * 0.03)
        b = int(168 - y * 0.02)
        draw.line([(0, y), (size, y)], fill=(r, g, b))
    
    # 票根
    width = size // 2
    height = size // 2
    x = (size - width) // 2
    y = (size - height) // 2
    
    # 白色票根
    draw.rounded_rectangle([(x, y), (x + width, y + height)], radius=20, fill='#ffffff')
    
    # 锯齿边缘
    tooth_size = 20
    for i in range(int(width / tooth_size / 2)):
        tx = x + tooth_size + i * tooth_size * 2
        draw.ellipse([(tx - tooth_size // 2, y - tooth_size // 2),
                     (tx + tooth_size // 2, y + tooth_size // 2)],
                    fill='#fd79a8')
        draw.ellipse([(tx - tooth_size // 2, y + height - tooth_size // 2),
                     (tx + tooth_size // 2, y + height + tooth_size // 2)],
                    fill='#fd79a8')
    
    # 飞机图标
    plane_x = x + width // 2
    plane_y = y + height // 2
    # 简单的飞机形状
    draw.polygon([(plane_x, plane_y - 60),
                 (plane_x + 30, plane_y),
                 (plane_x, plane_y + 20),
                 (plane_x - 30, plane_y)],
                fill='#2d3436')
    draw.rectangle([(plane_x - 80, plane_y - 10), (plane_x + 80, plane_y + 10)], 
                  fill='#2d3436')
    
    img.save(f'{output_dir}/icon5_ticket.png')

# 生成所有图标
print("Generating icons...")
create_icon1()
create_icon2()
create_icon3()
create_icon4()
create_icon5()
print("All icons generated successfully!")
print("\nAvailable icons in /Users/bytedance/Documents/src/mydemo/MyTraeProject/icon_options/:")
print("- icon1_checklist.png (简约清单风格)")
print("- icon2_backpack.png (背包风格)")
print("- icon3_compass.png (地图指南针风格)")
print("- icon4_camera.png (相机风景风格)")
print("- icon5_ticket.png (票根风格)")
