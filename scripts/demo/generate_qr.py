#!/usr/bin/env python3
"""SMRITI Dynamic LAN IP Detection & High-Contrast QR Code Generator.

Detects the active LAN IPv4 address on the current network interface
and generates both a high-contrast PNG and an ASCII QR code for phone testing.
NEVER uses localhost or 127.0.0.1.
"""
import sys
import socket
import argparse
from pathlib import Path

def get_lan_ip() -> str:
    """Dynamically determine the active LAN IPv4 address."""
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # Connect to an external address (doesn't actually send packets)
        # to determine which interface route is active for LAN/Internet.
        s.connect(('10.254.254.254', 1))
        ip = s.getsockname()[0]
    except Exception:
        # Fallback: inspect hostname resolution
        try:
            hostname = socket.gethostname()
            ip_list = socket.gethostbyname_ex(hostname)[2]
            routable = [i for i in ip_list if not i.startswith("127.") and not i == "0.0.0.0"]
            ip = routable[0] if routable else "127.0.0.1"
        except Exception:
            ip = "127.0.0.1"
    finally:
        s.close()

    if ip.startswith("127.") or ip == "0.0.0.0":
        raise RuntimeError(
            f"Unable to resolve a valid LAN IPv4 address (detected {ip}). "
            "Please ensure you are connected to a local Wi-Fi or Ethernet network."
        )
    return ip

def print_text_qr(qr):
    """Prints a terminal-friendly ASCII representation safe on Windows cp1252."""
    matrix = qr.get_matrix()
    # Use standard 7-bit ASCII characters '##' and '  '
    for row in matrix:
        line = "".join("##" if cell else "  " for cell in row)
        print(line)

def generate_qr(port: int = 8080, output_path: str = None) -> str:
    lan_ip = get_lan_ip()
    target_url = f"http://{lan_ip}:{port}"

    if output_path is None:
        script_dir = Path(__file__).parent.resolve()
        output_path = script_dir / "smriti_phone_demo_qr.png"
    else:
        output_path = Path(output_path).resolve()

    try:
        import qrcode
        from qrcode.constants import ERROR_CORRECT_M

        qr = qrcode.QRCode(
            version=1,
            error_correction=ERROR_CORRECT_M,
            box_size=10,
            border=2,
        )
        qr.add_data(target_url)
        qr.make(fit=True)

        # Generate high-contrast PNG (deep navy on cream for SMRITI branding)
        img = qr.make_image(fill_color="#0F172A", back_color="#FDFBF7")
        img.save(str(output_path))

        print("=" * 60)
        print(" SMRITI PHONE DEMO - LOCAL PREVIEW READY")
        print("=" * 60)
        print(f" Detected LAN IPv4 : {lan_ip}")
        print(f" Target Web URL    : {target_url}")
        print(f" Saved QR Code PNG : {output_path}")
        print("=" * 60)
        print("\nScan this QR representation with your phone:\n")
        
        try:
            print_text_qr(qr)
        except Exception as ex:
            print(f"(Terminal ASCII preview skipped: {ex})")

        print("\n" + "=" * 60)
        print("Ensure your phone is connected to the SAME Wi-Fi network.")
        print("=" * 60 + "\n")

    except ImportError:
        print(f"WARNING: 'qrcode' module not installed. URL: {target_url}")
        print("Run: pip install qrcode pillow")

    return target_url

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate SMRITI Phone Demo QR")
    parser.add_argument("--port", type=int, default=8080, help="Web server port (default: 8080)")
    parser.add_argument("--output", type=str, default=None, help="QR code PNG output path")
    args = parser.parse_args()

    try:
        url = generate_qr(port=args.port, output_path=args.output)
    except Exception as e:
        print(f"Error generating demo QR: {e}", file=sys.stderr)
        sys.exit(1)
