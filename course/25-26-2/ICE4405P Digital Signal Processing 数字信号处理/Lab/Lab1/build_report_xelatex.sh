#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
xelatex -interaction=nonstopmode -halt-on-error Report_StudentName_Lab1_StudentID.tex
xelatex -interaction=nonstopmode -halt-on-error Report_StudentName_Lab1_StudentID.tex
echo "Built: Report_StudentName_Lab1_StudentID.pdf"
