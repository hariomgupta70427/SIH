#!/usr/bin/env python3
"""
QR Code Generator for Demo Parts P-001 to P-020
"""

import qrcode
import os
from pathlib import Path

def generate_qr_codes():
    """Generate QR codes for parts P-001 to P-020"""
    
    # Create output directory
    output_dir = Path('../sample_qr')
    output_dir.mkdir(exist_ok=True)
    
    print("🔲 Generating QR codes for demo parts...")
    
    for i in range(1, 21):
        part_id = f"P-{i:03d}"
        
        # Create QR code
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_L,
            box_size=10,
            border=4,
        )
        qr.add_data(part_id)
        qr.make(fit=True)
        
        # Create image
        img = qr.make_image(fill_color="black", back_color="white")
        
        # Save image
        filename = output_dir / f"{part_id}.png"
        img.save(filename)
        
        print(f"✓ Generated {filename}")
    
    print(f"\n🎉 Generated 20 QR codes in {output_dir}")
    print("📱 You can now scan these QR codes with the Flutter app!")

if __name__ == "__main__":
    try:
        generate_qr_codes()
    except ImportError:
        print("❌ qrcode library not found. Install with: pip install qrcode[pil]")
    except Exception as e:
        print(f"❌ Error generating QR codes: {e}")