# Flutter Web 中文字符乱码解决方案

## 问题描述

在首次打开或重启 Flutter Web 项目时，所有中文字符显示为方块（□□□），这是由于：

1. **CanvasKit 渲染器字体加载问题**
   - Flutter Web 默认使用 CanvasKit 渲染器
   - 中文字体文件较大，需要时间下载
   - UI 渲染早于字体下载完成

2. **Google Fonts 访问问题**
   - 依赖外部 CDN 可能被墙或网络延迟
   - 首次访问需要下载字体

## 解决方案：自托管中文字体

我们采用了 **方案 3：使用自托管中文字体**，这是生产环境推荐的最佳方案。

### 实施内容

#### 1. 下载并部署字体文件

**字体选择：** Noto Sans SC（思源黑体简体中文）

**部署位置：** `web/fonts/`

**字体文件：**
```
web/fonts/
├── NotoSansSC-Regular.otf  (7.9MB) - 常规字重 400
├── NotoSansSC-Medium.otf   (8.0MB) - 中等字重 500
├── NotoSansSC-Bold.otf     (8.1MB) - 粗体字重 700
└── README.md               - 字体说明文档
```

**总大小：** 约 24MB

#### 2. 修改 `web/index.html`

**添加 @font-face 声明：**

```html
<style>
  /* ==================== 自托管字体定义 ==================== */
  @font-face {
    font-family: 'Noto Sans SC';
    font-style: normal;
    font-weight: 400;
    font-display: swap; /* 重要：避免首次加载时不显示文字 */
    src: url('fonts/NotoSansSC-Regular.otf') format('opentype');
  }
  
  @font-face {
    font-family: 'Noto Sans SC';
    font-style: normal;
    font-weight: 500;
    font-display: swap;
    src: url('fonts/NotoSansSC-Medium.otf') format('opentype');
  }
  
  @font-face {
    font-family: 'Noto Sans SC';
    font-style: normal;
    font-weight: 700;
    font-display: swap;
    src: url('fonts/NotoSansSC-Bold.otf') format('opentype');
  }
  
  /* ==================== 全局字体设置 ==================== */
  * {
    font-family: 'Noto Sans SC', 'PingFang SC', 'Microsoft YaHei', sans-serif !important;
  }
</style>
```

**优化字体加载脚本：**

```javascript
// 确保自托管字体和 Flutter 完全加载后再显示内容
let flutterLoaded = false;
let fontsLoaded = false;

// 等待自托管字体加载完成
if (document.fonts && document.fonts.ready) {
  document.fonts.ready.then(function() {
    console.log('✅ 字体加载完成');
    fontsLoaded = true;
    checkAndRemoveLoading();
  });
  
  // 预加载字体（提前触发字体下载）
  document.fonts.load('400 16px "Noto Sans SC"');
  document.fonts.load('500 16px "Noto Sans SC"');
  document.fonts.load('700 16px "Noto Sans SC"');
}
```

## 方案优势

### ✅ 完全离线
- 不依赖外部 CDN（Google Fonts、jsDelivr 等）
- 适合内网或离线部署

### ✅ 访问速度快
- 字体文件与应用同域，无跨域问题
- 国内访问不受墙影响
- 可以利用 CDN 加速

### ✅ 加载可控
- 可以精确控制字体加载时机
- 使用 `font-display: swap` 避免 FOIT（Flash of Invisible Text）
- 通过 JavaScript 确保字体加载完成后再显示内容

### ✅ 稳定可靠
- 不受第三方服务影响
- 字体版本固定，不会自动更新导致问题

## 效果验证

### 测试步骤

1. **清除浏览器缓存**
   - Chrome: `Cmd/Ctrl + Shift + Delete`
   - 选择"缓存的图片和文件"

2. **刷新应用**
   ```bash
   flutter run -d chrome --web-port=3000
   ```

3. **检查控制台**
   - 应该看到：`✅ 字体加载完成`
   - 中文字符正常显示，不再是方块

4. **测试场景**
   - ✅ 首次打开
   - ✅ 刷新页面
   - ✅ Hot Restart
   - ✅ 关闭浏览器重新打开

### 预期结果

- 加载遮罩显示约 1-2 秒（字体下载时间）
- 加载遮罩消失后，所有中文字符正常显示
- 不再出现方块（□□□）

## 性能优化建议

### 如果需要进一步优化加载速度：

#### 1. 转换为 WOFF2 格式（推荐）

WOFF2 压缩率更高，可以减少 30-50% 的文件大小：

```bash
# 安装工具
npm install -g woff2

# 转换字体
cd web/fonts
woff2_compress NotoSansSC-Regular.otf
woff2_compress NotoSansSC-Medium.otf
woff2_compress NotoSansSC-Bold.otf
```

然后修改 `web/index.html` 中的 `src` 路径：
```css
src: url('fonts/NotoSansSC-Regular.woff2') format('woff2');
```

#### 2. 字体子集化

只包含实际使用的字符（常用 3500 个汉字）：

```bash
# 安装工具
pip install fonttools

# 子集化（示例：只保留常用汉字）
pyftsubset NotoSansSC-Regular.otf \
  --text-file=常用汉字.txt \
  --output-file=NotoSansSC-Regular-Subset.woff2 \
  --flavor=woff2
```

可以将字体大小减少到 500KB 以内。

#### 3. 按需加载

只加载 Regular 字重，Medium 和 Bold 通过 CSS 合成：

```css
* {
  font-family: 'Noto Sans SC', sans-serif !important;
  font-synthesis: weight; /* 允许浏览器合成字重 */
}
```

#### 4. 使用 CDN

将字体文件部署到 CDN（如阿里云 OSS、腾讯云 COS）：

```css
src: url('https://cdn.yourdomain.com/fonts/NotoSansSC-Regular.otf');
```

## 备选方案对比

| 方案 | 优点 | 缺点 | 适用场景 |
|------|------|------|----------|
| **方案 1: HTML 渲染器** | 立即生效，无需下载字体 | 性能略低 | 快速解决，开发环境 |
| **方案 2: Google Fonts** | 无需自己维护字体 | 可能被墙，依赖外网 | 海外部署 |
| **方案 3: 自托管字体** ⭐ | 完全可控，稳定可靠 | 初次下载慢（24MB） | 生产环境推荐 |

## 相关资源

### 字体来源
- [Noto CJK GitHub](https://github.com/googlefonts/noto-cjk)
- [Google Fonts - Noto Sans SC](https://fonts.google.com/noto/specimen/Noto+Sans+SC)

### 工具
- [woff2](https://github.com/google/woff2) - WOFF2 压缩工具
- [fonttools](https://github.com/fonttools/fonttools) - 字体子集化工具

### 文档
- [Flutter Web 渲染模式](https://docs.flutter.dev/platform-integration/web/renderers)
- [CSS font-display](https://developer.mozilla.org/en-US/docs/Web/CSS/@font-face/font-display)

## 许可证

Noto Sans SC 使用 [SIL Open Font License 1.1](https://scripts.sil.org/OFL)，允许商业使用、修改和分发。

---

**实施日期：** 2024-11-03  
**维护者：** NanoBamboo Team  
**状态：** ✅ 已完成并测试通过

