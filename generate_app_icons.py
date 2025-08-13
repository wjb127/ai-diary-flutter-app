#!/usr/bin/env python3
"""
앱 아이콘 생성 스크립트
원본 이미지를 iOS와 Android에 필요한 모든 크기로 변환합니다.
"""

from PIL import Image
import os
import json

def create_icon(source_path, size, output_path):
    """이미지를 지정된 크기로 리사이즈하고 저장"""
    img = Image.open(source_path)
    
    # RGBA를 RGB로 변환 (iOS는 알파 채널 없는 이미지 필요)
    if img.mode == 'RGBA':
        # 흰색 배경 생성
        background = Image.new('RGB', img.size, (255, 255, 255))
        background.paste(img, mask=img.split()[3] if len(img.split()) > 3 else None)
        img = background
    
    # 리사이즈
    img_resized = img.resize((size, size), Image.Resampling.LANCZOS)
    
    # 디렉토리 생성
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    # 저장
    img_resized.save(output_path, quality=100)
    print(f"✅ 생성됨: {output_path} ({size}x{size})")

def generate_ios_icons(source_path):
    """iOS용 아이콘 생성"""
    print("\n🍎 iOS 아이콘 생성 중...")
    
    ios_sizes = [
        # iPhone 아이콘
        (20, 2, "Icon-App-20x20@2x.png"),  # iPhone Notification 2x
        (20, 3, "Icon-App-20x20@3x.png"),  # iPhone Notification 3x
        (29, 2, "Icon-App-29x29@2x.png"),  # iPhone Settings 2x
        (29, 3, "Icon-App-29x29@3x.png"),  # iPhone Settings 3x
        (40, 2, "Icon-App-40x40@2x.png"),  # iPhone Spotlight 2x
        (40, 3, "Icon-App-40x40@3x.png"),  # iPhone Spotlight 3x
        (60, 2, "Icon-App-60x60@2x.png"),  # iPhone App 2x
        (60, 3, "Icon-App-60x60@3x.png"),  # iPhone App 3x
        
        # iPad 아이콘
        (20, 1, "Icon-App-20x20@1x.png"),  # iPad Notification 1x
        (29, 1, "Icon-App-29x29@1x.png"),  # iPad Settings 1x
        (40, 1, "Icon-App-40x40@1x.png"),  # iPad Spotlight 1x
        (76, 1, "Icon-App-76x76@1x.png"),  # iPad App 1x
        (76, 2, "Icon-App-76x76@2x.png"),  # iPad App 2x
        (83.5, 2, "Icon-App-83.5x83.5@2x.png"),  # iPad Pro App
        
        # App Store 아이콘
        (1024, 1, "Icon-App-1024x1024@1x.png"),  # App Store
    ]
    
    base_path = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    
    for base_size, scale, filename in ios_sizes:
        size = int(base_size * scale)
        output_path = os.path.join(base_path, filename)
        create_icon(source_path, size, output_path)
    
    # Contents.json 생성
    contents = {
        "images": [
            {"size": "20x20", "idiom": "iphone", "filename": "Icon-App-20x20@2x.png", "scale": "2x"},
            {"size": "20x20", "idiom": "iphone", "filename": "Icon-App-20x20@3x.png", "scale": "3x"},
            {"size": "29x29", "idiom": "iphone", "filename": "Icon-App-29x29@2x.png", "scale": "2x"},
            {"size": "29x29", "idiom": "iphone", "filename": "Icon-App-29x29@3x.png", "scale": "3x"},
            {"size": "40x40", "idiom": "iphone", "filename": "Icon-App-40x40@2x.png", "scale": "2x"},
            {"size": "40x40", "idiom": "iphone", "filename": "Icon-App-40x40@3x.png", "scale": "3x"},
            {"size": "60x60", "idiom": "iphone", "filename": "Icon-App-60x60@2x.png", "scale": "2x"},
            {"size": "60x60", "idiom": "iphone", "filename": "Icon-App-60x60@3x.png", "scale": "3x"},
            {"size": "20x20", "idiom": "ipad", "filename": "Icon-App-20x20@1x.png", "scale": "1x"},
            {"size": "20x20", "idiom": "ipad", "filename": "Icon-App-20x20@2x.png", "scale": "2x"},
            {"size": "29x29", "idiom": "ipad", "filename": "Icon-App-29x29@1x.png", "scale": "1x"},
            {"size": "29x29", "idiom": "ipad", "filename": "Icon-App-29x29@2x.png", "scale": "2x"},
            {"size": "40x40", "idiom": "ipad", "filename": "Icon-App-40x40@1x.png", "scale": "1x"},
            {"size": "40x40", "idiom": "ipad", "filename": "Icon-App-40x40@2x.png", "scale": "2x"},
            {"size": "76x76", "idiom": "ipad", "filename": "Icon-App-76x76@1x.png", "scale": "1x"},
            {"size": "76x76", "idiom": "ipad", "filename": "Icon-App-76x76@2x.png", "scale": "2x"},
            {"size": "83.5x83.5", "idiom": "ipad", "filename": "Icon-App-83.5x83.5@2x.png", "scale": "2x"},
            {"size": "1024x1024", "idiom": "ios-marketing", "filename": "Icon-App-1024x1024@1x.png", "scale": "1x"}
        ],
        "info": {"version": 1, "author": "xcode"}
    }
    
    contents_path = os.path.join(base_path, "Contents.json")
    with open(contents_path, 'w') as f:
        json.dump(contents, f, indent=2)
    print(f"✅ Contents.json 생성됨: {contents_path}")

def generate_android_icons(source_path):
    """Android용 아이콘 생성"""
    print("\n🤖 Android 아이콘 생성 중...")
    
    android_sizes = [
        ("mipmap-mdpi", 48),     # mdpi (1x)
        ("mipmap-hdpi", 72),     # hdpi (1.5x)
        ("mipmap-xhdpi", 96),    # xhdpi (2x)
        ("mipmap-xxhdpi", 144),  # xxhdpi (3x)
        ("mipmap-xxxhdpi", 192), # xxxhdpi (4x)
    ]
    
    base_path = "android/app/src/main/res"
    
    for folder, size in android_sizes:
        output_path = os.path.join(base_path, folder, "ic_launcher.png")
        create_icon(source_path, size, output_path)
    
    # Adaptive icon용 foreground 이미지 생성 (선택사항)
    print("\n🎨 Android Adaptive Icon 생성 중...")
    for folder, size in android_sizes:
        # Adaptive icon은 108dp, 전경은 72dp (66.67%)
        adaptive_size = int(size * 1.5)  # 108dp에 해당
        output_path = os.path.join(base_path, folder, "ic_launcher_foreground.png")
        create_icon(source_path, adaptive_size, output_path)

def generate_web_icons(source_path):
    """Web용 아이콘 생성"""
    print("\n🌐 Web 아이콘 생성 중...")
    
    web_sizes = [
        (192, "Icon-192.png"),
        (512, "Icon-512.png"),
        (192, "Icon-maskable-192.png"),
        (512, "Icon-maskable-512.png"),
    ]
    
    base_path = "web/icons"
    
    for size, filename in web_sizes:
        output_path = os.path.join(base_path, filename)
        create_icon(source_path, size, output_path)
    
    # Favicon 생성
    favicon_path = "web/favicon.png"
    create_icon(source_path, 16, favicon_path)
    print(f"✅ Favicon 생성됨: {favicon_path}")

def main():
    """메인 함수"""
    source_image = "0_2.png"
    
    print(f"🎯 원본 이미지: {source_image}")
    
    if not os.path.exists(source_image):
        print(f"❌ 에러: {source_image} 파일을 찾을 수 없습니다.")
        return
    
    try:
        # iOS 아이콘 생성
        generate_ios_icons(source_image)
        
        # Android 아이콘 생성
        generate_android_icons(source_image)
        
        # Web 아이콘 생성
        generate_web_icons(source_image)
        
        print("\n✨ 모든 아이콘이 성공적으로 생성되었습니다!")
        print("\n📱 iOS: ios/Runner/Assets.xcassets/AppIcon.appiconset/")
        print("🤖 Android: android/app/src/main/res/mipmap-*/")
        print("🌐 Web: web/icons/")
        
    except Exception as e:
        print(f"\n❌ 에러 발생: {e}")

if __name__ == "__main__":
    main()