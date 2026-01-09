---
geometry: margin=2cm, bottom=3cm, top=2cm
fontsize: 11pt
header-includes: |
  \usepackage{graphicx}
  \usepackage{tikz}
  \usepackage{fancyhdr}
  \usepackage{fontawesome5}
  \pagestyle{empty}
  \widowpenalty=10000
  \clubpenalty=10000
---

```{=latex}
\noindent
\begin{minipage}[t]{0.63\textwidth}
\vspace{0pt}
\raggedright
{\Huge\bfseries [YOUR NAME]}\\[0.3cm]
{\Large [YOUR TITLE]}\\[0.4cm]
\small
\faGithub\ \href{https://github.com/[USERNAME]}{@[USERNAME]}\\
\faLinkedin\ \href{https://www.linkedin.com/in/[USERNAME]}{[USERNAME]}\\
\faGlobe\ \href{https://[YOURSITE].github.io/about}{[YOURSITE].github.io/about}
\end{minipage}\hfill%
\begin{minipage}[t]{0.33\textwidth}
\vspace{0pt}
\raggedleft
\begin{tikzpicture}
\node[circle, minimum size=3cm, path picture={
    \node at (path picture bounding box.center){
        \includegraphics[width=3cm]{images/[YOUR-PROFILE-IMAGE].jpeg}
    };
}]{};
\end{tikzpicture}
\end{minipage}

\vspace{1cm}
```


[YOUR INTRODUCTION PARAGRAPH - 3-5 sentences about your experience and philosophy]

\vspace{0.5cm}

## Education

**[DEGREE]**  
[UNIVERSITY]  
[YEARS]

## Technical Skills

**Languages:** [List your programming languages]

**Core Strengths:** [List your core technical strengths]

**Leadership & Soft Skills:** [List your leadership and soft skills]

**Technologies:** [List technologies, platforms, tools you use]

## Professional Experience

### [YEARS]: [TITLE] @ [COMPANY]

[Brief role description]

**[SECTION HEADING]:**

- [Achievement or responsibility 1]
- [Achievement or responsibility 2]
- [Achievement or responsibility 3]

[Narrative paragraph about what you learned or accomplished]

---

### [YEARS]: [TITLE] @ [COMPANY]

[Continue with more roles...]

---

<!-- 
TEMPLATE USAGE INSTRUCTIONS:
========================

1. Replace all placeholders in [BRACKETS] with your actual information
2. Keep the LaTeX header section unchanged (lines 1-39) - this controls the layout
3. The two-column header is in the ```{=latex} block - edit carefully:
   - Left column: Name, title, contact links (63% width)
   - Right column: Profile image (33% width)
   - Both use \vspace{0pt} for top alignment - don't remove!
4. Use --- horizontal rules between job roles for visual separation
5. Generate PDF with: 
   eval "$(/usr/libexec/path_helper)" && pandoc cv.md --standalone -o cv.tex && pdflatex -interaction=nonstopmode cv.tex && pdflatex -interaction=nonstopmode cv.tex

LAYOUT FEATURES:
================
- All pages: 2cm top margin, 3cm bottom margin, 2cm side margins
- Page 1: Two-column header with name/title/links and profile image
- Pages 2+: No header, consistent top margin (no blank space)
- Widow/orphan penalties set to prevent mid-sentence page breaks
- Empty page style (no page numbers)
- Font: 11pt default

CUSTOMIZATION OPTIONS:
======================
To adjust margins: Change line 2 geometry settings
  geometry: margin=2cm, bottom=3cm, top=2cm

To change font size: Change line 3
  fontsize: 11pt

To adjust header spacing: Change \vspace{1cm} on line 38

To change column widths: Adjust percentages in lines 16 and 26
  Currently: 0.63\textwidth (left) and 0.33\textwidth (right)

To change profile image size: Adjust width=3cm in line 32

-->
