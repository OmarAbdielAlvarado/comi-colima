#!/bin/bash
F0=~/proyectos/comi_colima/nodos/video/frame0_16oct.png
F600=~/proyectos/comi_colima/nodos/video/frame600_16oct.png
echo "=== veredicto de llava (VLM local) ==="
ollama run llava:7b "Two images: first is frame 0, second is frame 600 (10s later) from a robot POV camera. The robot was supposed to move toward a white pillar. Did the pillar get visibly LARGER in the second image? Answer one word: MOVED, STATIC, or MOVED_BACK. Then one sentence describing what changed." << EOF2
 $(base64 -w0 $F0)
 $(base64 -w0 $F600)
EOF2
