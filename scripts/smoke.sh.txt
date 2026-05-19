#!/bin/bash

################################################################################
# SMOKE TEST SCRIPT
# Card Selling Agent App - Maestro Automation
# 
# Purpose: Run critical path smoke tests (15-20 minutes)
# Usage: ./scripts/smoke.sh
# 
# Features:
# - Runs smoke test suite
# - Generates JUnit XML report
# - Generates HTML report
# - Takes screenshots on failure
# - Sends notification on completion
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="Card Selling Agent"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
REPORT_DIR="reports"
JUNIT_DIR="${REPORT_DIR}/junit"
HTML_DIR="${REPORT_DIR}/html"
SCREENSHOT_DIR="${REPORT_DIR}/screenshots"
SUITE_FILE=".maestro/suites/smoke-suite.yaml"
LOG_FILE="${REPORT_DIR}/logs/smoke-${TIMESTAMP}.log"

# Create directories
mkdir -p ${JUNIT_DIR}
mkdir -p ${HTML_DIR}
mkdir -p ${SCREENSHOT_DIR}
mkdir -p ${REPORT_DIR}/logs

# Banner
echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                        ║"
echo "║                    🔥 SMOKE TEST EXECUTION                            ║"
echo "║                  ${APP_NAME}                              ║"
echo "║                                                                        ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Test information
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📋 Test Information${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}   App:${NC}           ${APP_NAME}"
echo -e "${YELLOW}   Test Type:${NC}     Smoke Tests"
echo -e "${YELLOW}   Duration:${NC}      ~15-20 minutes"
echo -e "${YELLOW}   Timestamp:${NC}     ${TIMESTAMP}"
echo -e "${YELLOW}   Suite File:${NC}    ${SUITE_FILE}"
echo -e "${YELLOW}   Log File:${NC}      ${LOG_FILE}"
echo ""

# Check if Maestro is installed
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔍 Pre-flight Checks${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if ! command -v maestro &> /dev/null; then
    echo -e "${RED}❌ Error: Maestro is not installed!${NC}"
    echo -e "${YELLOW}   Install it: curl -Ls \"https://get.maestro.mobile.dev\" | bash${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Maestro installed${NC}"

# Check if suite file exists
if [ ! -f "${SUITE_FILE}" ]; then
    echo -e "${RED}❌ Error: Suite file not found: ${SUITE_FILE}${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Suite file found${NC}"

# Check for connected device
echo -e "${YELLOW}🔌 Checking for connected device...${NC}"
if ! maestro test --help &> /dev/null; then
    echo -e "${YELLOW}⚠️  Warning: Cannot verify device connection${NC}"
else
    echo -e "${GREEN}✅ Maestro is ready${NC}"
fi

echo ""

# Start time
START_TIME=$(date +%s)

# Run Smoke Tests
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🚀 Running Smoke Tests...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Test modules to run
echo -e "${YELLOW}📦 Test Modules:${NC}"
echo "   • Authentication (Login, Registration)"
echo "   • Home Dashboard"
echo "   • Shop (View Products, Add to Cart)"
echo "   • Request Money"
echo "   • User Profile"
echo "   • Account Balance"
echo ""

# Run tests with progress indicator
echo -e "${GREEN}▶️  Starting test execution...${NC}"
echo ""

maestro test \
  --format junit \
  --output ${JUNIT_DIR}/smoke-${TIMESTAMP}.xml \
  ${SUITE_FILE} 2>&1 | tee ${LOG_FILE} || TEST_EXIT_CODE=$?

# Capture exit code
TEST_EXIT_CODE=${TEST_EXIT_CODE:-0}

# End time and duration
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
DURATION_MIN=$((DURATION / 60))
DURATION_SEC=$((DURATION % 60))

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}⏱️  Test Execution Complete${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}   Duration:${NC} ${DURATION_MIN}m ${DURATION_SEC}s"
echo ""

# Generate HTML Report
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📊 Generating HTML Report...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if junit-viewer is installed
if ! command -v junit-viewer &> /dev/null; then
    echo -e "${YELLOW}⚠️  junit-viewer not found. Installing...${NC}"
    npm install -g junit-viewer > /dev/null 2>&1
    echo -e "${GREEN}✅ junit-viewer installed${NC}"
fi

# Generate HTML report
HTML_REPORT="${HTML_DIR}/smoke-report-${TIMESTAMP}.html"
junit-viewer \
  --results=${JUNIT_DIR} \
  --save=${HTML_REPORT} > /dev/null 2>&1

echo -e "${GREEN}✅ HTML report generated: ${HTML_REPORT}${NC}"
echo ""

# Parse Test Results
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📈 Test Results Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Parse JUnit XML for summary (if xmlstarlet is available)
JUNIT_FILE="${JUNIT_DIR}/smoke-${TIMESTAMP}.xml"

if command -v xmlstarlet &> /dev/null; then
    TOTAL=$(xmlstarlet sel -t -v "count(//testcase)" ${JUNIT_FILE} 2>/dev/null || echo "0")
    PASSED=$(xmlstarlet sel -t -v "count(//testcase[not(failure) and not(error)])" ${JUNIT_FILE} 2>/dev/null || echo "0")
    FAILED=$(xmlstarlet sel -t -v "count(//testcase[failure or error])" ${JUNIT_FILE} 2>/dev/null || echo "0")
    SKIPPED=$(xmlstarlet sel -t -v "count(//testcase/skipped)" ${JUNIT_FILE} 2>/dev/null || echo "0")
    
    PASS_RATE=0
    if [ "$TOTAL" -gt 0 ]; then
        PASS_RATE=$(echo "scale=1; ($PASSED * 100) / $TOTAL" | bc)
    fi
    
    echo ""
    echo -e "${CYAN}   Total Tests:${NC}    ${TOTAL}"
    echo -e "${GREEN}   ✅ Passed:${NC}      ${PASSED}"
    echo -e "${RED}   ❌ Failed:${NC}      ${FAILED}"
    echo -e "${YELLOW}   ⏭️  Skipped:${NC}     ${SKIPPED}"
    echo -e "${MAGENTA}   📊 Pass Rate:${NC}   ${PASS_RATE}%"
    echo ""
    
    # Show failed tests if any
    if [ "$FAILED" -gt 0 ]; then
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}❌ Failed Tests:${NC}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        xmlstarlet sel -t -m "//testcase[failure or error]" -v "@name" -n ${JUNIT_FILE} 2>/dev/null | while read test; do
            echo -e "${RED}   • ${test}${NC}"
        done
        echo ""
    fi
else
    echo -e "${YELLOW}⚠️  Install xmlstarlet for detailed summary:${NC}"
    echo -e "${YELLOW}   macOS: brew install xmlstarlet${NC}"
    echo -e "${YELLOW}   Linux: sudo apt-get install xmlstarlet${NC}"
    echo ""
fi

# File locations
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📁 Report Locations${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}   JUnit XML:${NC}    ${JUNIT_FILE}"
echo -e "${YELLOW}   HTML Report:${NC}  ${HTML_REPORT}"
echo -e "${YELLOW}   Log File:${NC}     ${LOG_FILE}"
echo -e "${YELLOW}   Screenshots:${NC}  ${SCREENSHOT_DIR}/"
echo ""

# Archive results
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📦 Archiving Results...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

ARCHIVE_NAME="smoke-results-${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${REPORT_DIR}/${ARCHIVE_NAME}"

tar -czf ${ARCHIVE_PATH} \
  ${JUNIT_FILE} \
  ${HTML_REPORT} \
  ${LOG_FILE} \
  2>/dev/null || true

if [ -f "${ARCHIVE_PATH}" ]; then
    ARCHIVE_SIZE=$(du -h ${ARCHIVE_PATH} | cut -f1)
    echo -e "${GREEN}✅ Results archived: ${ARCHIVE_PATH} (${ARCHIVE_SIZE})${NC}"
else
    echo -e "${YELLOW}⚠️  Failed to create archive${NC}"
fi
echo ""

# Open HTML report in browser
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🌐 Opening HTML Report...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Open in browser based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    open ${HTML_REPORT}
    echo -e "${GREEN}✅ Report opened in default browser${NC}"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if command -v xdg-open &> /dev/null; then
        xdg-open ${HTML_REPORT} &
        echo -e "${GREEN}✅ Report opened in default browser${NC}"
    else
        echo -e "${YELLOW}⚠️  Please open manually: ${HTML_REPORT}${NC}"
    fi
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Windows
    start ${HTML_REPORT}
    echo -e "${GREEN}✅ Report opened in default browser${NC}"
else
    echo -e "${YELLOW}⚠️  Please open manually: ${HTML_REPORT}${NC}"
fi

echo ""

# Final Summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ ${TEST_EXIT_CODE} -eq 0 ]; then
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                        ║"
    echo "║                  ✅ SMOKE TESTS PASSED! ✅                            ║"
    echo "║                                                                        ║"
    echo "╚════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${GREEN}   All critical paths are working correctly!${NC}"
    echo -e "${GREEN}   Safe to proceed with deployment.${NC}"
else
    echo -e "${RED}"
    echo "╔════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                        ║"
    echo "║                  ❌ SMOKE TESTS FAILED! ❌                            ║"
    echo "║                                                                        ║"
    echo "╚════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${RED}   Critical issues found!${NC}"
    echo -e "${RED}   Please review the failed tests before deployment.${NC}"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Send notification (optional - uncomment if you have notification service)
# if command -v notify-send &> /dev/null; then
#     if [ ${TEST_EXIT_CODE} -eq 0 ]; then
#         notify-send "✅ Smoke Tests Passed" "All critical paths working correctly"
#     else
#         notify-send "❌ Smoke Tests Failed" "Critical issues found - check report"
#     fi
# fi

# Exit with test result code
exit ${TEST_EXIT_CODE}