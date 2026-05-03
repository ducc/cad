#!/usr/bin/env bash
# Image regression test runner for the CAD repo.
#
# Renders each defined shot via OpenSCAD and compares pixel-by-pixel
# (with a small fuzz tolerance) against the committed baseline PNG.
#
# Usage:
#   tests/run.sh             # run tests, fail on any diff
#   tests/run.sh --update    # regenerate baselines (use after intentional changes)
#
# Run inside `nix develop` so openscad-unstable + imagemagick are pinned.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SNAPSHOTS_DIR="$REPO_ROOT/tests/snapshots"
DIFFS_DIR="$REPO_ROOT/tests/diffs"

UPDATE=0
if [[ "${1:-}" == "--update" ]]; then
    UPDATE=1
fi

mkdir -p "$SNAPSHOTS_DIR" "$DIFFS_DIR"
TMP_DIR="$(mktemp -d)"
trap "rm -rf $TMP_DIR" EXIT

# OpenSCAD's offscreen renderer still needs a display. On CI / headless
# machines, wrap it with xvfb-run so it gets a virtual one. Pass GLX +
# RENDER + 24-bit depth so Mesa's software GL can attach.
if [[ -n "${DISPLAY:-}" ]]; then
    OSCAD=(openscad)
else
    OSCAD=(xvfb-run -a -s "-screen 0 1024x768x24 +extension GLX +extension RENDER -noreset" openscad)
fi

# Each shot: scad_file shot_name camera imgsize
# Camera is OpenSCAD gimbal: tx,ty,tz,rx,ry,rz,dist
SHOTS=(
    "usb_eth_mount.scad iso  31.75,29.75,15.875,60,0,225,250 1200,900"
    "usb_eth_mount.scad top  31.75,29.75,15.875,0,0,0,200    900,900"
    "usb_eth_mount.scad end  31.75,29.75,15.875,90,0,90,200  1200,900"

    "level1_kvm_mount.scad iso  84,53,33,55,0,225,400 1400,1000"
    "level1_kvm_mount.scad top  84,53,33,0,0,0,250    1400,900"
    "level1_kvm_mount.scad side 84,53,33,90,0,90,260  1400,700"
    "level1_kvm_mount.scad front 84,53,33,90,0,0,300  1400,700"

    "snap_fit_test.scad top 0,0,0,0,0,0,80    1200,1200"
    "snap_fit_test.scad iso 0,0,0,55,0,225,150 1400,1000"
)

# Pixel-difference tolerance.
# AE counts pixels that differ by more than --fuzz in any channel.
# 5% fuzz absorbs trivial antialiasing jitter.
FUZZ_PERCENT=5
# Allow up to FAIL_RATIO of total pixels to differ before failing a shot.
FAIL_RATIO_BPS=50   # 50 basis points = 0.5%

fail_count=0
pass_count=0
update_count=0
new_count=0

REPORT_MD="$REPO_ROOT/tests/report.md"
{
    echo "<!-- image-regression-report -->"
    echo "## 🖼️ Image regression results"
    echo ""
    echo "| Shot | Status | Pixels differ |"
    echo "|---|---|---|"
} > "$REPORT_MD"

for shot in "${SHOTS[@]}"; do
    # Whitespace-separated: scad shot_name camera imgsize
    read -r scad shot_name camera imgsize _ <<< "$shot"
    base="${scad%.scad}-${shot_name}"
    snapshot="$SNAPSHOTS_DIR/$base.png"
    rendered="$TMP_DIR/$base.png"

    printf "%-40s " "$base"

    # Render
    render_log="$TMP_DIR/$base.log"
    if ! "${OSCAD[@]}" --colorscheme=Cornfield \
                       --imgsize="$imgsize" \
                       --camera="$camera" \
                       -o "$rendered" \
                       "$REPO_ROOT/$scad" >"$render_log" 2>&1; then
        echo "RENDER FAIL"
        cat "$render_log"
        echo "| \`$base\` | 💥 RENDER FAIL | — |" >> "$REPORT_MD"
        fail_count=$((fail_count + 1))
        continue
    fi
    if grep -qE "(WARNING|ERROR)" "$render_log"; then
        echo "RENDER WARN"
        grep -E "(WARNING|ERROR)" "$render_log"
        echo "| \`$base\` | ⚠️ RENDER WARN | — |" >> "$REPORT_MD"
        fail_count=$((fail_count + 1))
        continue
    fi
    if [[ ! -s "$rendered" ]]; then
        echo "EMPTY OUTPUT"
        echo "| \`$base\` | 💥 EMPTY OUTPUT | — |" >> "$REPORT_MD"
        fail_count=$((fail_count + 1))
        continue
    fi

    # Update mode: copy rendered as new baseline
    if [[ $UPDATE -eq 1 ]]; then
        cp "$rendered" "$snapshot"
        echo "UPDATED"
        update_count=$((update_count + 1))
        continue
    fi

    if [[ ! -f "$snapshot" ]]; then
        cp "$rendered" "$snapshot"
        echo "NEW BASELINE"
        echo "| \`$base\` | 🆕 NEW BASELINE | — |" >> "$REPORT_MD"
        new_count=$((new_count + 1))
        continue
    fi

    # Compare
    diff_img="$DIFFS_DIR/$base.png"
    # `compare` returns the AE count on stderr and exits 1 on any difference;
    # don't let set -e abort the script on that exit code.
    ae_raw=$(compare -metric AE -fuzz "${FUZZ_PERCENT}%" \
                     "$snapshot" "$rendered" "$diff_img" 2>&1 || true)
    # Output format: just a number, or "<count> (<normalized>)", or an error.
    # Extract the first whitespace-separated token.
    ae="${ae_raw%% *}"
    if ! [[ "$ae" =~ ^[0-9]+$ ]]; then
        echo "COMPARE FAIL: $ae_raw"
        echo "| \`$base\` | 💥 COMPARE FAIL | — |" >> "$REPORT_MD"
        fail_count=$((fail_count + 1))
        continue
    fi

    # Compute total pixels
    read -r W H <<< "$(identify -format "%w %h" "$snapshot")"
    total=$((W * H))
    threshold=$((total * FAIL_RATIO_BPS / 10000))

    # Pretty-print numbers with thousands separators for the report.
    ae_fmt=$(printf "%'d" "$ae")
    total_fmt=$(printf "%'d" "$total")

    if (( ae > threshold )); then
        printf "FAIL — %d / %d px differ (>%d) — see %s\n" \
               "$ae" "$total" "$threshold" "${diff_img#$REPO_ROOT/}"
        echo "| \`$base\` | ❌ FAIL | $ae_fmt / $total_fmt |" >> "$REPORT_MD"
        fail_count=$((fail_count + 1))
    else
        printf "ok    — %d / %d px differ\n" "$ae" "$total"
        echo "| \`$base\` | ✅ ok | $ae_fmt / $total_fmt |" >> "$REPORT_MD"
        pass_count=$((pass_count + 1))
        rm -f "$diff_img"
    fi
done

# Append summary footer to the markdown report.
{
    echo ""
    echo "**Summary:** ✅ $pass_count passed · ❌ $fail_count failed · 🆕 $new_count new"
    if [[ -n "${GITHUB_RUN_ID:-}" ]]; then
        echo ""
        echo "📥 [Download diff images](${GITHUB_SERVER_URL:-https://github.com}/${GITHUB_REPOSITORY:-}/actions/runs/${GITHUB_RUN_ID})"
    fi
} >> "$REPORT_MD"

echo
echo "─────────────────────────────────────────────"
if [[ $UPDATE -eq 1 ]]; then
    echo "Updated $update_count baselines."
    exit 0
fi
echo "Passed: $pass_count   Failed: $fail_count   New: $new_count"
if (( fail_count > 0 )); then
    echo "Diff images written to $DIFFS_DIR/"
    exit 1
fi
