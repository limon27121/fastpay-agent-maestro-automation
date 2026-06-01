#!/bin/bash

# --- Configuration ---

PIN="5890"
#------------------------------------
# $User         = "7701111111"
# $Password     = "Password100@902"
# $Agent        = "1000000077"
# $Merchant     = "3434343434"
# $Pin          = "1235"
# $Amount       = "254"
# $New_Password = "Password100@903"
# $New_Pin      = "1236"


# --- Ubuntu Dynamic Path Configuration ---
# $HOME expands to /home/limon automatically
# PROJECT_ROOT="$HOME/FastPayAgent_Maestro"
# SCRIPT_DIR="$PROJECT_ROOT/suites"
# REGRESSION_FILE="$SCRIPT_DIR/test.yaml"
PROJECT_ROOT="$HOME/FastPayAgent_Maestro"
SCRIPT_DIR="$PROJECT_ROOT/suits"
REGRESSION_FILE="$SCRIPT_DIR/test.yaml"
REPORT_DIR="$PROJECT_ROOT/reports"
# Create report directory if it doesn't exist
mkdir -p "$REPORT_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
START_TIME=$(date +%s)

# Define flows (Name|File)
flows=(
  
    "Login|LogIn_success.yaml"
    "Deposit Money|Limit_Exceed.yaml"
    "Buy Balance|Successful_Buy_Balance.yaml"
)

echo -e "\e[36m============================================="
echo -e "   FastPay - Regression Test Suite           "
echo -e "   App: com.sslwireless.fastpay              "
echo -e "=============================================\e[0m"

echo -e "\e[33mChecking device connection...\e[0m"
adb devices
echo ""

# Check if the regression file actually exists before starting
if [[ ! -f "$REGRESSION_FILE" ]]; then
    echo -e "\e[31mERROR: run_regression.yaml not found at: $REGRESSION_FILE\e[0m"
    echo -e "\e[31mPlease check if the folder name and file name are correct.\e[0m"
    exit 1
fi

TEMP_OUTPUT="$PROJECT_ROOT/_maestro_out.txt"

echo -e "\e[33mRunning full regression suite...\e[0m"

# Run Maestro and capture output
maestro test \
  -e User="$USER_ID" \
  -e Password="$PASSWORD" \
  -e Agent="$AGENT" \
  -e Merchant="$MERCHANT" \
  -e Pin="$PIN" \
  -e Amount="$AMOUNT" \
  -e New_Password="$NEW_PASSWORD" \
  -e New_Pin="$NEW_PIN" \
  "$REGRESSION_FILE" > "$TEMP_OUTPUT" 2>&1

EXIT_CODE=$?
END_TIME=$(date +%s)
TOTAL_DURATION=$((END_TIME - START_TIME))

# Print Maestro output to terminal so you can see progress
cat "$TEMP_OUTPUT"

# --- Process Results for HTML Report ---
RESULTS_HTML=""
FAILURE_FOUND=false
FAILED_FLOW_NAME=""
PASSED_COUNT=0
FAILED_COUNT=0
NOT_RUN_COUNT=0
INDEX=1

for flow_item in "${flows[@]}"; do
    IFS="|" read -r NAME FILE <<< "$flow_item"
    STATUS="NOT RUN"
    
    if [ "$EXIT_CODE" -eq 0 ]; then
        STATUS="PASSED"
    elif [ "$FAILURE_FOUND" = true ]; then
        STATUS="NOT RUN"
    else
        # Match flow status in log output
        if grep -qi "Run .*$FILE.*" "$TEMP_OUTPUT"; then
            if grep -qi "Run .*$FILE.*FAILED" "$TEMP_OUTPUT"; then
                STATUS="FAILED"
                FAILURE_FOUND=true
                FAILED_FLOW_NAME="$NAME"
            else
                STATUS="PASSED"
            fi
        fi
    fi

    # Formatting logic based on Status
    case $STATUS in
        "PASSED")
            BG="#f9fff9"; COLOR="#2e7d32"; ICON="✅ Passed"; ((PASSED_COUNT++)) ;;
        "FAILED")
            BG="#fff5f5"; COLOR="#c62828"; ICON="❌ Failed"; ((FAILED_COUNT++)) ;;
        *)
            BG="#fffbf0"; COLOR="#e65100"; ICON="⚠️ Not Run"; ((NOT_RUN_COUNT++)) ;;
    esac

    RESULTS_HTML+="<tr style='background:$BG;'><td style='text-align:center;font-weight:bold;color:#555;'>$INDEX</td><td style='font-weight:600;'>$NAME</td><td style='color:#888;font-size:12px;'>$FILE</td><td style='color:$COLOR;font-weight:bold;text-align:center;'>$ICON</td></tr>"
    ((INDEX++))
done

# Set the Banner message
if [ "$EXIT_CODE" -eq 0 ]; then
    BANNER="<div class='banner pass'>✅&nbsp; ALL TESTS PASSED</div>"
elif [ "$FAILED_COUNT" -gt 0 ]; then
    BANNER="<div class='banner fail'>❌&nbsp; REGRESSION FAILED &nbsp;|&nbsp; Stopped at: $FAILED_FLOW_NAME</div>"
else
    BANNER="<div class='banner warn'>⚠️&nbsp; SOME TESTS DID NOT RUN</div>"
fi

# Use Python to handle HTML character escaping for the log section
ESCAPED_LOG=$(python3 -c "import html, sys; print(html.escape(sys.stdin.read()))" < "$TEMP_OUTPUT")

# --- Build the Styled HTML Report ---
HTML_REPORT="<!DOCTYPE html><html lang='en'><head><meta charset='UTF-8'><style>
* { box-sizing:border-box; margin:0; padding:0; }
body { font-family:'Segoe UI',Arial,sans-serif; background:#f0f2f5; padding:24px; color:#333; }
.header { background:linear-gradient(135deg,#1a237e,#1565c0); color:white; padding:32px; border-radius:16px; margin-bottom:24px; }
.header h1 { font-size:28px; margin-bottom:10px; }
.header p { font-size:13px; opacity:0.85; margin-top:5px; }
.banner { text-align:center; padding:20px; border-radius:12px; margin-bottom:24px; font-size:20px; font-weight:bold; }
.banner.pass { background:#e8f5e9; color:#1b5e20; border:2px solid #81c784; }
.banner.fail { background:#ffebee; color:#b71c1c; border:2px solid #ef9a9a; }
.banner.warn { background:#fff8e1; color:#e65100; border:2px solid #ffcc02; }
.cards { display:flex; gap:16px; margin-bottom:24px; }
.card { background:white; padding:24px 16px; border-radius:14px; box-shadow:0 2px 12px rgba(0,0,0,0.08); flex:1; text-align:center; }
.card h2 { font-size:44px; margin-bottom:8px; }
.card p { font-size:13px; color:#888; font-weight:500; }
.card.total h2 { color:#1565c0; }
.card.passed h2 { color:#2e7d32; }
.card.failed h2 { color:#c62828; }
.card.time h2 { color:#6a1b9a; font-size:32px; }
.table-wrap { background:white; border-radius:14px; overflow:hidden; box-shadow:0 2px 12px rgba(0,0,0,0.08); margin-bottom:24px; }
table { width:100%; border-collapse:collapse; }
th { background:#283593; color:white; padding:14px 20px; text-align:left; font-size:13px; }
td { padding:13px 20px; border-bottom:1px solid #f0f0f0; font-size:13px; }
.log-body { background:#1e1e1e; color:#d4d4d4; padding:20px; font-size:12px; max-height:400px; overflow:auto; white-space:pre-wrap; border-radius:14px; }
</style></head><body>
<div class='header'>
    <h1>📋 FastPay Regression Test Report</h1>
    <p>📱 App ID : com.sslwireless.fastpay</p>
    <p>📅 Date   : $TIMESTAMP</p>
    <p>🚀 Home   : $HOME</p>
</div>
$BANNER
<div class='cards'>
    <div class='card total'><h2>${#flows[@]}</h2><p>Total Tests</p></div>
    <div class='card passed'><h2>$PASSED_COUNT</h2><p>Passed</p></div>
    <div class='card failed'><h2>$FAILED_COUNT</h2><p>Failed</p></div>
    <div class='card time'><h2>${TOTAL_DURATION}s</h2><p>Duration</p></div>
</div>
<div class='table-wrap'>
    <table><thead><tr><th>#</th><th>Feature Name</th><th>File</th><th style='text-align:center;'>Status</th></tr></thead>
    <tbody>$RESULTS_HTML</tbody></table>
</div>
<h3>Execution Log</h3>
<div class='log-body'>$ESCAPED_LOG</div>
</body></html>"

REPORT_PATH="$REPORT_DIR/RegressionReport_$TIMESTAMP.html"
echo "$HTML_REPORT" > "$REPORT_PATH"

echo -e "\n\e[36m============================================="
echo -e "  Report saved:"
echo -e "  \e[32m$REPORT_PATH\e[0m"
echo -e "\e[36m=============================================\e[0m\n"

# Clean up temporary files
rm "$TEMP_OUTPUT"

# Open report in the default browser
xdg-open "$REPORT_PATH" 2>/dev/null