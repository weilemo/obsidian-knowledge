from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_JUSTIFY, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import Paragraph, Preformatted, SimpleDocTemplate, Spacer


BASE_DIR = Path(__file__).resolve().parent
OUTPUT = BASE_DIR / "莫炜乐Prenom_Opt_DM1.pdf"
FONT_PATH = "/Library/Fonts/Arial Unicode.ttf"


def register_font() -> str:
    name = "ArialUnicode"
    pdfmetrics.registerFont(TTFont(name, FONT_PATH))
    return name


def build_pdf() -> None:
    font_name = register_font()
    styles = getSampleStyleSheet()
    title = ParagraphStyle(
        "TitleCustom",
        parent=styles["Title"],
        fontName=font_name,
        fontSize=15,
        leading=19,
        alignment=TA_LEFT,
        spaceAfter=10,
    )
    heading = ParagraphStyle(
        "HeadingCustom",
        parent=styles["Heading2"],
        fontName=font_name,
        fontSize=11.2,
        leading=14,
        spaceBefore=6,
        spaceAfter=4,
        textColor=colors.HexColor("#1f2937"),
    )
    body = ParagraphStyle(
        "BodyCustom",
        parent=styles["BodyText"],
        fontName=font_name,
        fontSize=9.6,
        leading=13.4,
        alignment=TA_JUSTIFY,
        spaceAfter=4,
    )
    mono = ParagraphStyle(
        "MonoCustom",
        parent=styles["Code"],
        fontName="Courier",
        fontSize=8.6,
        leading=10.8,
        spaceAfter=5,
    )

    story = [
        Paragraph("Compte rendu de compréhension - Optimisation", title),
        Paragraph(
            "Après le premier cours, j'ai compris qu'un problème d'optimisation consiste à chercher la meilleure "
            "valeur possible d'une fonction objectif sur un domaine réalisable. Un modèle d'optimisation comporte "
            "toujours trois éléments essentiels : les variables de décision, la fonction objectif et les contraintes. "
            "Les contraintes peuvent être explicites, comme des limites de temps, de budget ou de ressources, mais "
            "aussi implicites, comme la non-négativité des variables.",
            body,
        ),
        Paragraph(
            "J'ai aussi compris que l'on distingue les problèmes sans contrainte et sous contraintes, ainsi que "
            "l'optimisation linéaire et non linéaire selon la nature de la fonction objectif et des contraintes. "
            "La forme standard me semble très importante, car elle permet d'écrire différents problèmes dans un "
            "langage mathématique unifié et donc de préparer leur résolution.",
            body,
        ),
        Paragraph("Exemple de modélisation : alimentation saine à coût minimal", heading),
        Paragraph(
            "Je choisis comme problème pratique la planification d'une alimentation quotidienne pour un étudiant. "
            "L'objectif est de minimiser le coût total des repas tout en garantissant un apport nutritionnel suffisant.",
            body,
        ),
        Paragraph(
            "On note x1 le nombre de portions de riz, x2 le nombre de portions de poulet et x3 le nombre de portions "
            "de légumes. Les coûts unitaires sont respectivement 2, 8 et 3 yuans par portion. Une portion de riz "
            "apporte 200 calories et 4 grammes de protéines, une portion de poulet 250 calories et 30 grammes de "
            "protéines, et une portion de légumes 50 calories et 2 grammes de protéines.",
            body,
        ),
        Preformatted(
            "Fonction objectif :\n"
            "    min f(x) = 2x1 + 8x2 + 3x3\n\n"
            "Contraintes explicites :\n"
            "    200x1 + 250x2 + 50x3 >= 2000\n"
            "    4x1 + 30x2 + 2x3 >= 60\n"
            "    x1 + x2 + x3 <= 10\n\n"
            "Contraintes implicites :\n"
            "    x1 >= 0, x2 >= 0, x3 >= 0",
            mono,
        ),
        Paragraph(
            "Ce modèle est un problème d'optimisation linéaire sous contraintes, car la fonction objectif est "
            "linéaire et toutes les contraintes sont linéaires.",
            body,
        ),
        Paragraph("Mise sous forme standard", heading),
        Paragraph(
            "Pour obtenir la forme standard, on transforme les inégalités en égalités à l'aide de variables "
            "d'excès et d'écart s1, s2, s3 >= 0 :",
            body,
        ),
        Preformatted(
            "200x1 + 250x2 + 50x3 - s1 = 2000\n"
            "4x1 + 30x2 + 2x3 - s2 = 60\n"
            "x1 + x2 + x3 + s3 = 10",
            mono,
        ),
        Paragraph(
            "En posant z = (x1, x2, x3, s1, s2, s3)^T, le problème devient min c^T z avec c = (2, 8, 3, 0, 0, 0)^T, "
            "sous la contrainte Az = b et z >= 0, où",
            body,
        ),
        Preformatted(
            "A = [200 250  50 -1  0  0]\n"
            "    [  4  30   2  0 -1  0]\n"
            "    [  1   1   1  0  0  1]\n\n"
            "b = (2000, 60, 10)^T",
            mono,
        ),
        Paragraph("Réflexion personnelle", heading),
        Paragraph(
            "Cet exercice m'a aidé à mieux comprendre la logique du cours. Avant, je voyais surtout l'optimisation "
            "comme un ensemble de formules. Maintenant, je comprends mieux qu'il s'agit d'abord d'un travail de "
            "modélisation : choisir les bonnes variables, exprimer clairement l'objectif et traduire les limites "
            "réelles en contraintes mathématiques. J'aimerais approfondir, dans les prochains cours, la question "
            "suivante : une fois le modèle construit, comment choisir la méthode la plus adaptée pour le résoudre "
            "efficacement ?",
            body,
        ),
        Spacer(1, 0.2 * cm),
        Paragraph(
            "Nom du fichier à remettre : remplacez simplement \"Prenom\" par votre prénom français avant dépôt.",
            ParagraphStyle(
                "Note",
                parent=body,
                fontSize=8.5,
                leading=11,
                textColor=colors.HexColor("#4b5563"),
            ),
        ),
    ]

    doc = SimpleDocTemplate(
        str(OUTPUT),
        pagesize=A4,
        leftMargin=1.8 * cm,
        rightMargin=1.8 * cm,
        topMargin=1.5 * cm,
        bottomMargin=1.4 * cm,
        title="Compte rendu de comprehension - Optimisation",
        author="moweile",
    )
    doc.build(story)


if __name__ == "__main__":
    build_pdf()
