#!/bin/bash
cd ~/Sanexis/xfeatSLAM

# 使用 XFeat 特征运行
./examples/Monocular/mono_euroc     ./Vocabulary/ORBvoc.txt     ./examples/Monocular/large_Fri.yaml     ~/Sanexis/dataset/large_Fri_offline     ~/Sanexis/dataset/large_Fri_offline/timestamps.txt

# 如果想用 ORB 特征，运行：
# USE_ORB=1 ./examples/Monocular/mono_euroc #     ./Vocabulary/ORBvoc.txt #     ./examples/Monocular/large_Fri.yaml #     ~/Sanexis/dataset/large_Fri_offline #     ~/Sanexis/dataset/large_Fri_offline/timestamps.txt
