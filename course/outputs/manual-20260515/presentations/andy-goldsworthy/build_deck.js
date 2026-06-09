const fs = require("fs");
const path = require("path");
const pptxgen = require("/Users/moweile/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/pptxgenjs");
const sharp = require("/Users/moweile/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/sharp");

const reportDir = "/Users/moweile/Obsidian/Knowledge/Course/25-26-2/艺术自然工程/报告1";
const imageDir = path.join(reportDir, "images");
const workDir = "/Users/moweile/Obsidian/Knowledge/Course/outputs/manual-20260515/presentations/andy-goldsworthy";
const assetDir = path.join(workDir, "assets");
const outPath = path.join(reportDir, "安迪戈兹沃西大地艺术汇报.pptx");

fs.mkdirSync(assetDir, { recursive: true });

const W = 13.333;
const H = 7.5;
const C = {
  cream: "F4EFE6",
  ink: "1D211A",
  dark: "11140F",
  olive: "4A5A3D",
  moss: "6F7C55",
  leaf: "B75D32",
  gold: "D5A14A",
  stone: "D8D1C3",
  white: "FFFFFF",
};
const FONT = "PingFang SC";
let ShapeType;

function img(name) {
  return path.join(imageDir, name);
}

async function cover(src, name, tint = { r: 0, g: 0, b: 0, alpha: 0.28 }) {
  const out = path.join(assetDir, name);
  await sharp(src)
    .resize(1920, 1080, { fit: "cover", position: "attention" })
    .composite([{ input: { create: { width: 1920, height: 1080, channels: 4, background: tint } }, blend: "over" }])
    .jpeg({ quality: 90 })
    .toFile(out);
  return out;
}

async function panel(src, name, width = 1300, height = 850) {
  const out = path.join(assetDir, name);
  await sharp(src)
    .resize(width, height, { fit: "cover", position: "attention" })
    .jpeg({ quality: 92 })
    .toFile(out);
  return out;
}

function addFooter(slide, n) {
  slide.addText(String(n).padStart(2, "0"), {
    x: 12.55, y: 7.05, w: 0.45, h: 0.18,
    fontFace: "Aptos", fontSize: 7.5, color: "BDB5A7", bold: true,
    margin: 0, align: "right",
  });
}

function addTopKicker(slide, text, n, color = "D8D1C3") {
  slide.addText(text, {
    x: 0.65, y: 0.42, w: 6.8, h: 0.22,
    fontFace: FONT, fontSize: 8.8, color, bold: true,
    charSpace: 0.4, margin: 0,
  });
  addFooter(slide, n);
}

function addClaim(slide, title, subtitle, opts = {}) {
  const x = opts.x ?? 0.75;
  const y = opts.y ?? 4.92;
  const w = opts.w ?? 8.6;
  slide.addText(title, {
    x, y, w, h: opts.h ?? 0.72,
    fontFace: FONT, fontSize: opts.size ?? 25,
    color: opts.color ?? C.white, bold: true,
    breakLine: false, margin: 0.02,
    fit: "shrink",
  });
  if (subtitle) {
    slide.addText(subtitle, {
      x, y: y + (opts.gap ?? 0.78), w: opts.sw ?? w, h: opts.sh ?? 0.65,
      fontFace: FONT, fontSize: opts.subSize ?? 12.5,
      color: opts.subColor ?? "E8E0D2", margin: 0.02,
      breakLine: false, fit: "shrink",
    });
  }
}

function addChip(slide, text, x, y, w, fill = "F4EFE6", color = "2D3327") {
  slide.addShape(ShapeType.roundRect, {
    x, y, w, h: 0.34, rectRadius: 0.04,
    fill: { color: fill, transparency: 8 },
    line: { color: fill, transparency: 100 },
  });
  slide.addText(text, {
    x: x + 0.12, y: y + 0.08, w: w - 0.24, h: 0.13,
    fontFace: FONT, fontSize: 7.9, bold: true, color,
    align: "center", margin: 0,
  });
}

function addTextBlock(slide, title, lines, x, y, w, options = {}) {
  slide.addText(title, {
    x, y, w, h: 0.38, fontFace: FONT, fontSize: options.titleSize ?? 14.5,
    bold: true, color: options.titleColor ?? C.ink, margin: 0, fit: "shrink",
  });
  slide.addText(lines.join("\n"), {
    x, y: y + 0.52, w, h: options.h ?? 1.45,
    fontFace: FONT, fontSize: options.size ?? 10.5,
    color: options.color ?? "4B4E45",
    breakLine: false, fit: "shrink",
    valign: "top", margin: 0,
    paraSpaceAfterPt: 8,
    bullet: options.bullet ? { type: "bullet" } : undefined,
  });
}

function addArtworkLabel(slide, text, opts = {}) {
  const w = opts.w ?? 3.65;
  const x = opts.x ?? (W - w - 0.72);
  const y = opts.y ?? 6.68;
  const fill = opts.fill ?? "000000";
  const color = opts.color ?? "EFE8DD";
  slide.addShape(ShapeType.rect, {
    x, y, w, h: 0.42,
    fill: { color: fill, transparency: opts.transparency ?? 34 },
    line: { color: fill, transparency: 100 },
  });
  slide.addText(text, {
    x: x + 0.12, y: y + 0.09, w: w - 0.24, h: 0.13,
    fontFace: FONT, fontSize: opts.size ?? 7.6,
    color, margin: 0, align: "right", fit: "shrink",
  });
}

function addMiniList(slide, title, lines, x, y, w, h = 1.15, opts = {}) {
  slide.addShape(ShapeType.rect, {
    x, y, w, h,
    fill: { color: opts.fill ?? "11140F", transparency: opts.transparency ?? 18 },
    line: { color: opts.line ?? "FFFFFF", transparency: opts.lineTransparency ?? 88 },
  });
  slide.addText(title, {
    x: x + 0.18, y: y + 0.15, w: w - 0.36, h: 0.2,
    fontFace: FONT, fontSize: opts.titleSize ?? 8.8,
    bold: true, color: opts.titleColor ?? "E7DFC9", margin: 0,
    fit: "shrink",
  });
  slide.addText(lines.join("\n"), {
    x: x + 0.18, y: y + 0.44, w: w - 0.36, h: h - 0.55,
    fontFace: FONT, fontSize: opts.size ?? 8.7,
    color: opts.color ?? "F3EBDD", margin: 0,
    fit: "shrink", breakLine: false,
    paraSpaceAfterPt: 5,
  });
}

function addNotes(slide, notes) {
  slide.addNotes(notes.replace(/\n{3,}/g, "\n\n").trim());
}

async function main() {
  const assets = {
    rowan: await cover(img("00_rowan_leaves_around_hole.jpg"), "bg_rowan.jpg", { r: 20, g: 10, b: 5, alpha: 0.24 }),
    stone: await cover(img("01_stone_river_stanford.jpg"), "bg_stone_river.jpg", { r: 8, g: 10, b: 8, alpha: 0.35 }),
    stoneLight: await panel(img("01_stone_river_stanford.jpg"), "panel_stone_river.jpg"),
    overview: await cover(img("02_stone_river_overview.jpg"), "bg_overview.jpg", { r: 16, g: 20, b: 15, alpha: 0.38 }),
    treeStone: await panel(img("03_treestone_sheepfold.jpg"), "panel_treestone.jpg"),
    wall: await cover(img("05_stone_wall_forest.jpg"), "bg_wall.jpg", { r: 10, g: 16, b: 10, alpha: 0.36 }),
    spire: await cover(img("06_spire_wood.jpg"), "bg_spire.jpg", { r: 5, g: 8, b: 5, alpha: 0.32 }),
    treeFall: await cover(img("07_tree_fall.jpg"), "bg_treefall.jpg", { r: 12, g: 9, b: 6, alpha: 0.38 }),
    cone: await panel(img("08_cone_edinburgh.jpg"), "panel_cone.jpg"),
    cairn: await panel(img("09_cairn_stone.jpg"), "panel_cairn.jpg"),
    hanging: await panel(img("10_hanging_trees.jpg"), "panel_hanging.jpg", 900, 1100),
    slate: await panel(img("12_slate_patterns.jpg"), "panel_slate.jpg"),
    chalk: await cover(img("13_giant_chalk_snowball.jpg"), "bg_chalk.jpg", { r: 15, g: 18, b: 15, alpha: 0.32 }),
    arch: await cover(img("15_striding_arch.jpg"), "bg_arch.jpg", { r: 12, g: 13, b: 10, alpha: 0.32 }),
    ice: await cover(img("16_icicle_star.webp"), "bg_ice.jpg", { r: 4, g: 11, b: 14, alpha: 0.25 }),
  };

  const pptx = new pptxgen();
  ShapeType = pptx.ShapeType;
  pptx.layout = "LAYOUT_WIDE";
  pptx.author = "moweile";
  pptx.subject = "Andy Goldsworthy land art presentation";
  pptx.title = "以自然为材料：安迪·戈兹沃西大地艺术中的自然之美";
  pptx.company = "Codex";
  pptx.lang = "zh-CN";
  pptx.theme = {
    headFontFace: FONT,
    bodyFontFace: FONT,
    lang: "zh-CN",
  };

  let slide;

  slide = pptx.addSlide();
  slide.background = { color: C.dark };
  slide.addImage({ path: assets.rowan, x: 0, y: 0, w: W, h: H });
  slide.addShape(pptx.ShapeType.rect, { x: 0, y: 0, w: W, h: H, fill: { color: "000000", transparency: 45 }, line: { transparency: 100 } });
  slide.addText("以自然为材料", { x: 0.72, y: 4.18, w: 8.5, h: 0.62, fontFace: FONT, fontSize: 31, bold: true, color: C.white, margin: 0 });
  slide.addText("安迪·戈兹沃西大地艺术中的自然之美", { x: 0.76, y: 4.86, w: 8.8, h: 0.44, fontFace: FONT, fontSize: 16.5, color: "EEE7D8", margin: 0 });
  addChip(slide, "自然材料", 0.78, 5.55, 1.15, "F4EFE6");
  addChip(slide, "短暂性", 2.04, 5.55, 1.0, "F4EFE6");
  addChip(slide, "环境共生", 3.15, 5.55, 1.25, "F4EFE6");
  addArtworkLabel(slide, "Rowan Leaves Laid Around a Hole, 1987");
  addFooter(slide, 1);
  addNotes(slide, `大家好，我今天汇报的主题是安迪·戈兹沃西的大地艺术。

我选择这个艺术家，是因为他的作品和我们这门课的主题非常贴合。课程强调艺术、自然和工程之间的结合，而安迪·戈兹沃西的作品并不是简单地画自然、拍自然，或者把自然当作背景，而是直接使用自然本身作为材料。

他会用落叶、石头、树枝、冰块、雪、水流这些非常普通的自然物，创作出有形状、有秩序、有美感的作品。而且很多作品并不会长期保存，它们可能被风吹散，被水冲走，被阳光融化，或者随着季节变化慢慢消失。

所以我今天想围绕一个核心观点展开：安迪·戈兹沃西的大地艺术让我们看到，自然不只是艺术表现的对象，也可以成为艺术创作的材料、过程和合作者。`);

  slide = pptx.addSlide();
  slide.background = { color: C.cream };
  slide.addText("今天只讲一个核心判断", { x: 0.7, y: 0.55, w: 5.5, h: 0.28, fontFace: FONT, fontSize: 11, bold: true, color: C.moss, margin: 0 });
  slide.addText("自然不是背景，\n而是作品的一部分。", { x: 0.68, y: 1.18, w: 5.55, h: 1.62, fontFace: FONT, fontSize: 30, bold: true, color: C.ink, margin: 0.02, breakLine: false, fit: "shrink" });
  slide.addShape(pptx.ShapeType.line, { x: 0.7, y: 3.15, w: 4.7, h: 0, line: { color: C.leaf, width: 2 } });
  addTextBlock(slide, "三条线索", ["自然是材料：落叶、石头、冰、水不是装饰，而是作品主体", "自然是过程：作品会被风、水、温度和时间继续改变", "自然是合作者：艺术家在现场条件中发现、排列和引导"], 0.74, 3.55, 5.35, { size: 10.9, h: 2.0 });
  slide.addImage({ path: assets.stoneLight, x: 6.55, y: 0.0, w: 6.78, h: 7.5 });
  slide.addShape(pptx.ShapeType.rect, { x: 6.45, y: 0, w: 0.22, h: H, fill: { color: C.cream }, line: { transparency: 100 } });
  addArtworkLabel(slide, "Stone River, Stanford University, 2001", { x: 8.9, y: 6.76, w: 3.6 });
  addFooter(slide, 2);
  addNotes(slide, `在正式进入作品之前，我先把今天的核心判断放在这里：自然不是背景，而是作品的一部分。

我们看很多传统艺术时，自然经常是画面里的对象，比如一座山、一片森林、一条河。但戈兹沃西这里不同，自然材料直接构成作品本身。

我会按三条线索展开。第一，自然是材料，落叶、石头、冰、水不是装饰，而是作品主体。第二，自然是过程，风、水、阳光和温度会不断改变作品。第三，自然是合作者，艺术家不是完全控制自然，而是在现场条件中发现、排列和引导。

这三个点也会帮助我们把他的作品和课程里的自然、艺术、工程联系起来。`);

  slide = pptx.addSlide();
  slide.addImage({ path: assets.treeFall, x: 0, y: 0, w: W, h: H });
  addTopKicker(slide, "什么是大地艺术", 3);
  addClaim(slide, "它通常不在美术馆里开始，\n而是在真实自然现场发生。", "大地艺术的重点不只是最后的成品，还包括地点、材料、天气和作品消失的过程。", { y: 4.45, h: 0.95, w: 9.2, size: 24, sh: 0.72 });
  addArtworkLabel(slide, "Tree Fall, Presidio of San Francisco, 2013");
  addNotes(slide, `大地艺术，也可以叫环境艺术或地景艺术，它通常不是放在美术馆里的传统绘画或雕塑，而是发生在自然环境中。艺术家会利用土地、岩石、树叶、树枝、水、冰雪等材料，在自然空间里进行创作。

这种艺术和传统艺术有一个很大的不同：它不一定追求永久保存。比如一幅油画可以挂在博物馆里几十年甚至几百年，但是大地艺术经常是短暂的。它可能只存在几个小时、几天，甚至只有拍照记录下来的一瞬间。

所以，大地艺术的重点不只是最后的成品，还包括它和环境之间的关系。它在哪里发生、使用什么材料、受到什么天气影响、最后怎样消失，这些都是作品的一部分。

这也正是安迪·戈兹沃西作品特别有意思的地方：他让我们重新注意到身边最普通的自然物，比如一片树叶、一块石头、一段冰、一条小溪。`);

  slide = pptx.addSlide();
  slide.addImage({ path: assets.spire, x: 0, y: 0, w: W, h: H });
  slide.addShape(pptx.ShapeType.rect, { x: 0, y: 0, w: 5.65, h: H, fill: { color: "000000", transparency: 32 }, line: { transparency: 100 } });
  addTopKicker(slide, "艺术家与方法", 4);
  slide.addText("Andy Goldsworthy", { x: 0.72, y: 1.28, w: 4.8, h: 0.42, fontFace: "Georgia", italic: true, fontSize: 19, color: "E7DFC9", margin: 0 });
  slide.addText("在现场工作，\n让材料自己说话。", { x: 0.72, y: 2.1, w: 4.75, h: 1.22, fontFace: FONT, fontSize: 26, bold: true, color: C.white, margin: 0, fit: "shrink" });
  addTextBlock(slide, "创作方式", ["他常常先来到一个具体场地，再根据现场已有材料创作。", "树叶的颜色、石头的形状、水流方向、阳光角度都会影响作品。", "因此作品不是艺术家单方面控制，而是自然环境也在参与。"], 0.76, 4.0, 4.55, { titleColor: "E7DFC9", color: "EEE7D8", size: 9.7, h: 1.7 });
  addArtworkLabel(slide, "Spire, Presidio of San Francisco, 2008");
  addNotes(slide, `安迪·戈兹沃西是英国当代艺术家，他最有代表性的创作方式，就是在户外直接使用自然材料进行创作。

他的工作方式很特别。他经常不是先在室内画好草图，再购买材料制作作品，而是来到一个具体的自然场地，根据现场已有的材料进行创作。比如那里有什么颜色的叶子，有什么形状的石头，水流方向怎样，天气冷不冷，阳光从哪个角度照过来，这些都会影响作品最终的样子。

也就是说，他的作品不是完全由艺术家单方面控制的。自然环境本身也在参与创作。风可能改变树叶的位置，温度可能让冰融化，水流可能把作品带走。

我觉得这正是他的作品最有价值的地方。它不是用人工材料去模仿自然，而是承认自然本身有材料、有形态、有规律，也有自己的力量。`);

  slide = pptx.addSlide();
  slide.addImage({ path: assets.rowan, x: 0, y: 0, w: W, h: H });
  slide.addShape(pptx.ShapeType.rect, { x: 0, y: 0, w: W, h: H, fill: { color: "000000", transparency: 58 }, line: { transparency: 100 } });
  addTopKicker(slide, "自然元素一：落叶", 5);
  addClaim(slide, "落叶不是废弃物，\n而是天然的色彩材料。", "每片叶子的颜色、边缘和纹理都不同；通过排列，普通落叶被转化成有秩序的视觉作品。", { y: 4.2, w: 9.3, size: 25, sh: 0.78 });
  addArtworkLabel(slide, "Rowan Leaves Laid Around a Hole, 1987");
  addNotes(slide, `第一个自然元素是落叶。

落叶是非常普通的自然材料。秋天的时候，树叶会变成黄色、红色、橙色、棕色，然后掉落在地上。我们平时可能只是把它看成自然现象，甚至觉得它需要被清扫掉。

但是安迪·戈兹沃西会把落叶看成一种天然的色彩材料。他常常把不同颜色、不同形状的叶子排列成圆形、线条或者渐变图案。比如从深红到橙色，再到黄色，形成一种非常自然的色彩过渡。

这里的美感不是来自昂贵的颜料，而是来自树叶本身。每一片叶子都有细微差别：颜色不同、边缘不同、纹理不同，甚至卷曲程度也不同。艺术家只是通过排列，把这种自然本来就有的美显现出来。

落叶作品还有一个重要特点，就是它带有很强的季节感。落叶意味着秋天，也意味着植物生命过程中的一个阶段。`);

  slide = pptx.addSlide();
  slide.background = { color: "EFE8DD" };
  slide.addImage({ path: assets.stoneLight, x: 0.55, y: 0.58, w: 7.25, h: 6.35 });
  slide.addShape(pptx.ShapeType.rect, { x: 8.18, y: 0.74, w: 4.3, h: 5.65, fill: { color: "EFE8DD" }, line: { transparency: 100 } });
  slide.addText("石头：自然的结构", { x: 8.22, y: 1.0, w: 3.75, h: 0.45, fontFace: FONT, fontSize: 21, bold: true, color: C.ink, margin: 0 });
  slide.addText("坚硬、沉重、稳定，\n也需要重心与支撑。", { x: 8.24, y: 1.82, w: 3.75, h: 0.9, fontFace: FONT, fontSize: 18, bold: true, color: C.olive, margin: 0, fit: "shrink" });
  addTextBlock(slide, "作品看起来简单，但背后有结构判断", ["戈兹沃西常不使用胶水或金属固定，而是依靠石头自身的重量、形状和相互支撑。", "石头仍保留天然纹理和不规则性，因此结构有秩序，却不显得机械。"], 8.28, 3.25, 3.75, { titleSize: 12.4, size: 9.7, h: 1.8 });
  addArtworkLabel(slide, "Stone River, Stanford University, 2001", { x: 3.75, y: 6.55, w: 3.7 });
  addFooter(slide, 6);
  addNotes(slide, `第二个自然元素是石头。

如果说落叶给人的感觉是轻盈、柔软、短暂，那么石头给人的感觉就是坚硬、稳定和古老。安迪·戈兹沃西经常使用石头搭建圆形、拱形、石墙或者石堆。

这些作品看起来很简单，但其实对结构和平衡要求很高。因为他很多时候不会使用水泥、胶水或者金属固定，而是依靠石头自身的重量、形状和相互支撑来完成。

从这个角度看，石头作品里其实包含一种工程感。比如一个石拱为什么不会塌？石头之间怎样互相咬合？重心怎样分布？这些问题都和结构有关。

但它又不是纯粹的工程结构，因为它的目标不是建造房屋或桥梁，而是让自然材料呈现出一种安静、有秩序的美。`);

  slide = pptx.addSlide();
  slide.addImage({ path: assets.ice, x: 0, y: 0, w: W, h: H });
  addTopKicker(slide, "自然元素二：冰", 7, "DDECEC");
  addClaim(slide, "冰的美，\n从一开始就带着消失。", "冰有透明、反光和脆弱的质感；温度升高后，它会慢慢融化，时间也就成了作品的一部分。", { y: 4.45, w: 8.6, size: 26, subColor: "E1F3F2", sh: 0.78 });
  addArtworkLabel(slide, "Icicle Star, Dumfriesshire, 1987");
  addNotes(slide, `第三个元素是冰。

冰是安迪·戈兹沃西作品里非常有代表性的材料。冰很美，因为它透明、干净、能反射光线。但它也非常不稳定，因为只要温度升高，它就会融化。

他有一些作品会用冰块连接成线条、圆环，或者把冰放在树枝、石头、水边。阳光照射时，冰会发亮，看起来非常纯净。但这种美是有时间限制的。随着气温变化，作品会慢慢融化，最后完全消失。

这类作品最打动我的地方，是它把时间变成了作品的一部分。传统艺术常常希望保存下来，但冰的作品从一开始就注定会消失。它不是失败，而是作品本身的意义。

冰的融化也让我们看到自然规律的不可逆。艺术家不能命令冰永远保持原状，只能在它融化之前完成创作和记录。`);

  slide = pptx.addSlide();
  slide.addImage({ path: assets.chalk, x: 0, y: 0, w: W, h: H });
  slide.addShape(pptx.ShapeType.rect, { x: 0, y: 0, w: W, h: H, fill: { color: "000000", transparency: 50 }, line: { transparency: 100 } });
  addTopKicker(slide, "短暂性不是缺点", 8);
  slide.addText("作品会被风吹散、\n被水带走、被阳光改变。", { x: 0.74, y: 1.38, w: 6.65, h: 1.2, fontFace: FONT, fontSize: 25.5, bold: true, color: C.white, margin: 0, fit: "shrink" });
  slide.addText("这些变化不是外部干扰，而是作品生命的一部分。", { x: 0.78, y: 3.0, w: 5.85, h: 0.36, fontFace: FONT, fontSize: 13, color: "E8E0D2", margin: 0 });
  addChip(slide, "过程", 0.78, 4.08, 0.82, "F4EFE6");
  addChip(slide, "时间", 1.76, 4.08, 0.82, "F4EFE6");
  addChip(slide, "不可重复", 2.74, 4.08, 1.18, "F4EFE6");
  slide.addText("短暂性不是失败。摄影记录下来的，是作品与自然环境相遇的某一个瞬间。", {
    x: 0.82, y: 4.72, w: 5.65, h: 0.46,
    fontFace: FONT, fontSize: 10.7, color: "E8E0D2", margin: 0,
    fit: "shrink",
  });
  addArtworkLabel(slide, "Midsummer Snowballs, London, 2000");
  addNotes(slide, `讲到这里，我们会发现一个问题：如果这些作品会消失，那它们还算完整的艺术作品吗？

我认为答案是算的，而且这种短暂性正是安迪·戈兹沃西艺术的重要特点。

他的作品并不追求像建筑或纪念碑那样永久保存。相反，他接受作品会变化、会破坏、会消失。风把叶子吹散，太阳让冰融化，水流把材料带走，这些并不是外部干扰，而是作品生命过程的一部分。

这和自然本身的规律是一致的。自然界中的很多美都是短暂的，比如花开、落日、雪景、秋叶、潮汐。它们不会永远停留，但这并不影响它们具有美感。

安迪·戈兹沃西通常会用摄影记录作品。摄影并不是取代作品本身，而是记录作品在某一个时刻的状态。`);

  slide = pptx.addSlide();
  slide.addImage({ path: assets.wall, x: 0, y: 0, w: W, h: H });
  addTopKicker(slide, "自然不是背景，而是合作者", 9);
  slide.addShape(pptx.ShapeType.rect, { x: 0.65, y: 1.08, w: 4.35, h: 4.8, fill: { color: "11140F", transparency: 18 }, line: { color: "FFFFFF", transparency: 90 } });
  addTextBlock(slide, "自然参与了什么？", ["自然提供材料：树叶、石头、冰、木", "自然规定条件：地点、光线、温度、水流", "自然继续改变作品：风化、融化、漂移、消失", "艺术家的作用更像引导者：发现材料中的秩序，再让环境继续完成作品"], 0.95, 1.48, 3.75, { titleColor: C.white, color: "E9E1D0", size: 9.8, h: 2.85 });
  addArtworkLabel(slide, "Andy Goldsworthy Wall, 2016 photograph");
  addNotes(slide, `我认为安迪·戈兹沃西作品里最核心的一点，是他把自然当成了合作者。

在很多传统艺术里，自然是被表现的对象。比如画家画一座山、一片森林、一条河流，自然是画面内容。但在安迪·戈兹沃西这里，自然不只是画面内容，而是直接参与了作品的生成。

自然提供材料：树叶、石头、冰、树枝、水。自然提供环境：森林、河流、海岸、雪地。自然也决定作品的变化：风、水、阳光、温度都会改变作品。

艺术家的作用不是完全控制这一切，而是在自然已有条件中进行发现、选择和组织。他把散落的树叶排列起来，把石头搭成结构，把冰连接成形态，让我们看到自然材料中隐藏的秩序和美。

这种态度和现代环境保护理念也有联系。它提醒我们，人和自然的关系不一定是单向改造，也可以是理解、合作和共生。`);

  slide = pptx.addSlide();
  slide.addImage({ path: assets.spire, x: 0, y: 0, w: W, h: H });
  slide.addShape(pptx.ShapeType.rect, { x: 0, y: 0, w: W, h: H, fill: { color: "000000", transparency: 42 }, line: { transparency: 100 } });
  addTopKicker(slide, "自然元素三：木与树", 10);
  addClaim(slide, "树木让作品拥有方向感，\n也拥有场地记忆。", "树干、年轮和树皮保留了生命痕迹；作品不是把木材伪装成雕塑，而是让木材继续显露它来自森林的身份。", { y: 4.45, w: 9.45, size: 24.5, sh: 0.82 });
  addArtworkLabel(slide, "Spire, Presidio of San Francisco, 2008");
  addNotes(slide, `除了落叶、石头和冰，树木也是戈兹沃西经常使用的自然元素。

树和木材的特点在于它们有明显的生命痕迹。树干的纹理、断面的年轮、枝干的方向感，都能让人意识到这些材料并不是抽象的工业材料，而是来自某个具体的自然过程。

像这一类作品，往往有很强的垂直感和纪念碑感。但它和一般纪念碑不同，不是用金属或混凝土强调人类力量，而是让树木本身的形态成为视觉中心。

这也说明戈兹沃西不是把自然材料加工到完全看不出原貌，而是尽量保留它原本的性格。木材仍然像木材，石头仍然像石头，叶子仍然像叶子。

这种保留材料原貌的方式，会让作品更容易和周围环境联系在一起。`);

  slide = pptx.addSlide();
  slide.addImage({ path: assets.arch, x: 0, y: 0, w: W, h: H });
  slide.addShape(pptx.ShapeType.rect, { x: 7.15, y: 0, w: 6.18, h: H, fill: { color: "F4EFE6", transparency: 5 }, line: { transparency: 100 } });
  addTopKicker(slide, "与工程思维的联系", 11, C.stone);
  slide.addText("艺术不是工程，\n但这里有工程判断。", { x: 7.55, y: 1.15, w: 4.8, h: 1.04, fontFace: FONT, fontSize: 24, bold: true, color: C.ink, margin: 0, fit: "shrink" });
  addTextBlock(slide, "三个相通点", ["材料特性：理解轻重、硬度、透明度和可变性", "结构关系：判断重心、支撑、咬合与平衡", "环境适应：作品必须面对风、水、温度和光照", "启发：好的工程也可以顺应自然规律，而不是只靠人工控制"], 7.58, 3.02, 4.65, { size: 9.8, h: 2.25 });
  addArtworkLabel(slide, "Striding Arch, Dumfries and Galloway, 2008", { x: 0.9, y: 6.7, w: 3.9 });
  addNotes(slide, `虽然安迪·戈兹沃西是艺术家，不是工程师，但他的作品里其实有很多和工程思维相通的地方。

首先是材料意识。不同材料有不同特性。树叶轻薄，容易被风吹动；石头沉重，可以堆叠支撑；冰透明但会融化；水是流动的，难以固定。艺术家必须理解这些材料特点，才能完成作品。

其次是结构和平衡。尤其是石头作品，如果没有合理的重心和支撑关系，就很容易倒塌。这和工程结构中的稳定性问题有相似之处。

第三是环境适应。他的作品不是在封闭空间里完成的，而是在真实自然环境中完成的。风、水、温度、阳光都会影响作品。因此他必须根据现场条件调整创作方式。

对工程设计来说，这类作品也有启发意义。一个好的工程不应该只追求功能，也要考虑它和自然环境的关系。`);

  slide = pptx.addSlide();
  slide.background = { color: C.cream };
  slide.addText("把课程的三个关键词放回来", { x: 0.72, y: 0.58, w: 7.0, h: 0.34, fontFace: FONT, fontSize: 15, bold: true, color: C.olive, margin: 0 });
  slide.addText("自然、艺术、工程在同一个作品里相遇", { x: 0.72, y: 1.05, w: 8.5, h: 0.5, fontFace: FONT, fontSize: 26, bold: true, color: C.ink, margin: 0, fit: "shrink" });
  slide.addText("戈兹沃西的作品不只是在“表现自然”，而是把自然材料、审美秩序和结构判断放在同一个创作过程中。", {
    x: 0.74, y: 1.6, w: 9.5, h: 0.34,
    fontFace: FONT, fontSize: 10.5, color: "5B5D54", margin: 0,
    fit: "shrink",
  });
  const colY = 2.12, colW = 3.75;
  [
    ["自然", "材料来自自然，也回到自然", assets.rowan],
    ["艺术", "通过排列、色彩和形状创造美", assets.slate],
    ["工程", "通过结构、平衡和环境适应完成作品", assets.cairn],
  ].forEach(([title, body, imagePath], i) => {
    const x = 0.72 + i * 4.15;
    slide.addImage({ path: imagePath, x, y: colY, w: colW, h: 2.42 });
    slide.addText(title, { x, y: colY + 2.72, w: colW, h: 0.32, fontFace: FONT, fontSize: 18, bold: true, color: C.ink, margin: 0 });
    slide.addText(body, { x, y: colY + 3.15, w: colW, h: 0.46, fontFace: FONT, fontSize: 10.8, color: "5B5D54", margin: 0, fit: "shrink" });
  });
  slide.addText("Rowan Leaves, 1987", { x: 0.72, y: 4.38, w: colW, h: 0.14, fontFace: FONT, fontSize: 6.6, color: "8A8478", margin: 0, align: "right" });
  slide.addText("Slate Patterns, 2007 photo", { x: 4.87, y: 4.38, w: colW, h: 0.14, fontFace: FONT, fontSize: 6.6, color: "8A8478", margin: 0, align: "right" });
  slide.addText("Cairn, 1997", { x: 9.02, y: 4.38, w: colW, h: 0.14, fontFace: FONT, fontSize: 6.6, color: "8A8478", margin: 0, align: "right" });
  addFooter(slide, 12);
  addNotes(slide, `回到我们这门课的主题，课程希望我们理解艺术、自然和工程之间的联系。

安迪·戈兹沃西的大地艺术正好可以从这三个方面理解。

第一是自然。他的作品几乎完全来自自然材料，而且常常发生在自然环境中。树叶、石头、冰、水都不是装饰，而是作品的主体。

第二是艺术。他通过排列、组合、对比和结构，让普通自然物产生视觉美感。比如落叶的颜色渐变，石头的圆形结构，冰在阳光下的透明感，这些都体现了艺术家的审美选择。

第三是工程。虽然作品不是工程项目，但其中包含材料特性、结构稳定、环境适应等问题。尤其是石头和冰的作品，都需要对材料和环境有非常细致的判断。

更重要的是，这些作品让我们重新关注自然。它不通过说教来宣传环保，而是让人看到自然本身的美。`);

  slide = pptx.addSlide();
  slide.background = { color: "11140F" };
  slide.addText("PPT 汇报时可以这样收束", { x: 0.72, y: 0.56, w: 5.5, h: 0.32, fontFace: FONT, fontSize: 12, bold: true, color: C.gold, margin: 0 });
  slide.addText("自然不是被复制的对象，\n而是共同创作的伙伴。", { x: 0.72, y: 1.2, w: 6.0, h: 1.3, fontFace: FONT, fontSize: 27, bold: true, color: C.white, margin: 0, fit: "shrink" });
  const items = [["01", "自然是材料"], ["02", "自然是过程"], ["03", "自然是合作者"]];
  items.forEach(([num, txt], i) => {
    slide.addText(num, { x: 0.78, y: 3.25 + i * 0.8, w: 0.48, h: 0.2, fontFace: "Georgia", fontSize: 11, color: C.gold, bold: true, margin: 0 });
    slide.addText(txt, { x: 1.35, y: 3.16 + i * 0.8, w: 3.6, h: 0.28, fontFace: FONT, fontSize: 15.5, color: "EDE5D6", bold: true, margin: 0 });
  });
  slide.addText("落叶有颜色，石头有结构，冰有光感，水有流动。戈兹沃西把这些自然特性组织起来，让我们重新看到自然本身的美。", {
    x: 0.78, y: 5.7, w: 5.5, h: 0.56,
    fontFace: FONT, fontSize: 9.8, color: "D8D1C3", margin: 0,
    fit: "shrink",
  });
  slide.addImage({ path: assets.cone, x: 7.1, y: 0.0, w: 6.23, h: 7.5 });
  slide.addShape(pptx.ShapeType.rect, { x: 6.8, y: 0, w: 0.55, h: H, fill: { color: "11140F" }, line: { transparency: 100 } });
  addArtworkLabel(slide, "Cone, Royal Botanic Garden Edinburgh, 1990", { x: 8.8, y: 6.75, w: 3.75 });
  addFooter(slide, 13);
  addNotes(slide, `最后总结一下。

安迪·戈兹沃西的大地艺术让我印象最深的地方，是它非常简单，却又非常有力量。

他说的不是复杂的理论，而是用最普通的自然材料告诉我们：自然本身就有美。落叶有颜色，石头有结构，冰有光感，水有流动，时间会改变一切。

他的作品不是把自然固定下来，而是接受自然的变化。作品会出现，也会消失；会被创造，也会回到自然之中。

所以我今天的核心观点可以概括为三句话：第一，自然是材料。第二，自然是过程。第三，自然是合作者。

因此，安迪·戈兹沃西的大地艺术不仅让我们看到自然之美，也提醒我们：在未来的艺术和工程设计中，人类应该更多地尊重自然、理解自然，并尝试与自然共同创造。`);

  slide = pptx.addSlide();
  slide.addImage({ path: assets.overview, x: 0, y: 0, w: W, h: H });
  slide.addShape(pptx.ShapeType.rect, { x: 0, y: 0, w: W, h: H, fill: { color: "000000", transparency: 48 }, line: { transparency: 100 } });
  slide.addText("谢谢大家", { x: 0.72, y: 2.68, w: 4.2, h: 0.65, fontFace: FONT, fontSize: 31, bold: true, color: C.white, margin: 0 });
  slide.addText("自然本身拥有色彩、结构、时间和生命力。", { x: 0.78, y: 3.5, w: 6.2, h: 0.34, fontFace: FONT, fontSize: 14, color: "E8E0D2", margin: 0 });
  addArtworkLabel(slide, "Stone River, Stanford University, 2001");
  addFooter(slide, 14);
  addNotes(slide, `我的汇报到这里结束，谢谢大家。

如果最后老师提问，可以围绕一个点回答：我选择戈兹沃西，是因为他的作品把自然元素从“被观看的对象”变成“参与创作的材料”。这和课程中自然、艺术、工程结合的主题最贴合。`);

  await pptx.writeFile({ fileName: outPath });
  console.log(outPath);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
