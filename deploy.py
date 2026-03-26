#!/usr/bin/env python3
"""
Saaleh OS — Netlify Deployment Wrapper
Deploys the current directory to Netlify via the Netlify CLI.

Prerequisites:
  - Node.js and npm installed
  - Netlify CLI installed:  npm install -g netlify-cli
  - Authenticated:          netlify login

Usage:
  python deploy.py              # Deploy draft (preview URL)
  python deploy.py --prod       # Deploy to production
"""

import subprocess
import sys
import os


def run(cmd: list[str]) -> int:
    """Run a shell command and stream output."""
    print(f"▸ {' '.join(cmd)}")
    result = subprocess.run(cmd, cwd=os.path.dirname(os.path.abspath(__file__)))
    return result.returncode


def check_cli() -> bool:
    """Verify that the Netlify CLI is installed and accessible."""
    try:
        subprocess.run(
            ["netlify", "--version"],
            capture_output=True,
            check=True,
        )
        return True
    except (FileNotFoundError, subprocess.CalledProcessError):
        return False


def main() -> None:
    if not check_cli():
        print("✗ Netlify CLI not found. Install it with:  npm install -g netlify-cli")
        sys.exit(1)

    prod = "--prod" in sys.argv

    # Build step — Saaleh OS is static HTML, so no build is needed.
    # If a build step is added later, insert it here.

    deploy_cmd = ["netlify", "deploy", "--dir", "."]
    if prod:
        deploy_cmd.append("--prod")
        print("⚡ Deploying to PRODUCTION...")
    else:
        print("⚡ Deploying preview draft...")

    exit_code = run(deploy_cmd)
    if exit_code == 0:
        print("✓ Deployment complete.")
    else:
        print("✗ Deployment failed.")
        sys.exit(exit_code)


if __name__ == "__main__":
    main()
