#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
pdflatex -interaction=nonstopmode -halt-on-error Report_StudentName_Lab1_StudentID.tex
pdflatex -interaction=nonstopmode -halt-on-error Report_StudentName_Lab1_StudentID.tex
echo "Built: Report_StudentName_Lab1_StudentID.pdf"
