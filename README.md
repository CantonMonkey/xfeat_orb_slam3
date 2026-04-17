# XFeat ORB-SLAM3

基于 [xfeatSLAM](https://github.com/udaysankar01/xfeatSLAM) 的改进版本，使用 XFeat 学习特征替代 ORB 特征。

## 功能特性

- **XFeat 特征提取**: 轻量级学习特征，速度快于 SuperPoint
- **兼容 ORB-SLAM3 架构**: 保持原有跟踪、建图、回环检测流程
- **LibTorch 推理**: 使用 PyTorch C++ API 进行模型推理

## 依赖

- OpenCV >= 3.0
- Eigen3
- Pangolin (可视化)
- LibTorch >= 1.8
- CMake >= 3.10
- CUDA (推荐)

## 编译

```bash
cd ~/Sanexis/xfeatSLAM
mkdir -p build && cd build
cmake ..
make -j4
```

## 运行

```bash
cd ~/Sanexis/xfeatSLAM
./run_large_fri.sh
```

或完整命令：

```bash
./examples/Monocular/mono_euroc \
    ./Vocabulary/ORBvoc.txt \
    ./examples/Monocular/large_Fri.yaml \
    ~/Sanexis/dataset/large_Fri_offline \
    ~/Sanexis/dataset/large_Fri_offline/timestamps.txt
```

> **注意**: 需要在有 X display 的环境运行（NoMachine 或本地终端）

## 已知问题

### 1. 初始化失败 (Critical)

**现象**: 在铁栅门场景开始时无法初始化，匹配数极低（~27 matches）

**原因**: 初始化阶段仍使用 `ORBmatcher` (NN ratio test)，而非 XFeat 优化的匹配器

**位置**: `src/Tracking.cc:2527`

```cpp
// 问题代码
ORBmatcher matcher(0.9,true);
int nmatches = matcher.SearchForInitialization(...);
```

**临时方案**: 
- 增加关键点数量 (修改 `examples/Monocular/large_Fri.yaml` 中的 `nFeatures`)
- 降低初始化阈值

**推荐解决方案**:
- 实现 `XFmatcher` 类，支持 XFeat 描述子的正确匹配
- 参考 SP_SLAM3 的 `SPmatcher::SearchForInitialization` 实现

### 2. 未集成 LightGlue

**现象**: 跟踪阶段使用 NN ratio test 匹配，匹配质量不如 LightGlue

**推荐解决方案**:
- 集成 LightGlue 匹配器
- 需要实现 `XFmatcher` 类并加载 LightGlue 模型

### 3. PlaceRecognition 模型缺失

**现象**: 回环检测功能不可用

**解决方案**: 添加预训练的 Place Recognition 模型

## 文件结构

```
xfeatSLAM/
├── examples/Monocular/     # 单目示例
│   ├── mono_euroc.cc       # EuRoC 数据集运行入口
│   └── large_Fri.yaml      # 相机配置文件
├── src/
│   ├── XFeat.cc            # XFeat 模型实现
│   ├── XFextractor.cc      # 特征提取器
│   └── Tracking.cc         # 跟踪模块 (需修改初始化)
├── weights/                # 模型权重目录
├── Vocabulary/             # 词袋文件
└── run_large_fri.sh        # 运行脚本
```

## 与 vismatch 测试对比

| 测试场景 | XFeat+LightGlue (vismatch) | xfeatSLAM 内部 |
|---------|---------------------------|----------------|
| 连续帧匹配 | ~1400 inliers | ~27 matches (初始化) |
| Skip=50 | ~474 inliers | - |

**结论**: XFeat 特征质量足够，但 SLAM 内部匹配器未正确使用。

## 后续开发计划

1. **[High] 修复初始化匹配器** - 使用 XFeat 专用匹配替代 ORBmatcher
2. **[High] 集成 LightGlue** - 提升跟踪匹配质量
3. **[Medium] 添加 Place Recognition** - 启用回环检测
4. **[Low] 优化推理速度** - FP16、TensorRT

## 参考

- 原项目: https://github.com/udaysankar01/xfeatSLAM
- XFeat 论文: https://arxiv.org/abs/2404.00604
- ORB-SLAM3: https://github.com/UZ-SLAMLab/ORB_SLAM3

## License

See LICENSE.txt
