﻿stop();
stage.quality = "best";


import flash.display.*;
import flash.text.*;
import flash.events.*;
import flash.net.*;


//var loadfont: URLLoader = new URLLoader();
//loadfont.load(new URLRequest("双字体.swf"));


var loadcfg: URLLoader = new URLLoader();
loadcfg.dataFormat = URLLoaderDataFormat.TEXT;
loadcfg.addEventListener(Event.COMPLETE, cfgLoaded);
loadcfg.load(new URLRequest("config.csv"));

var cfg: Array;
var fp: int;

var RKcon: Sprite = new Sprite(); // RankBar 容器
var BKcon: Sprite = new Sprite(); // 背景线容器
var bkList: Array;
var bk: bkgL;

var wid: Number;

function cfgLoaded(evt: Event): void {

	cfg = loadcfg.data.split("\n");
	for(i = 0; i < cfg.length; i++) {
		cfg[i] = cfg[i].split(",");
	}

  stage.color = cfg[2][0];
  var icon: Loader = new Loader();
  icon.contentLoaderInfo.addEventListener(Event.COMPLETE, bkgLoaded);
  icon.load(new URLRequest(cfg[2][2]));

	stage.frameRate = int(cfg[5][0]);
	fp = cfg[6][0]; // 几帧过一个数据

	RKcon.x = cfg[20][0];
	RKcon.y = cfg[21][0];
	addChildAt(RKcon, 1);

	BKcon.x = RKcon.x + Number(cfg[24][0]);
	BKcon.y = RKcon.y - Number(cfg[52][0]);
	addChildAt(BKcon, 0);

	bkList = cfg[48];

	for(i = 0; i < bkList.length; i++) {
		bk = new bkgL();
		bk.initialize(bkList[i], cfg);
		BKcon.addChild(bk);
	}

	tltext.x = cfg[58][0];
	tltext.y = cfg[59][0];
	tltext.text = cfg[60][0];
	var format1: TextFormat = new TextFormat();
	format1.color = cfg[2][1];
	format1.size = cfg[61][0];
	tltext.setTextFormat(format1);

	yeart.x = cfg[76][0];
	yeart.y = cfg[77][0];
  current.x = Number(cfg[79][0]); //yeart.x +
  current.y = Number(cfg[80][0]);
	wid = cfg[78][1] * cfg[81][0];

	kuangmo.x = cfg[91][0];
	kuangmo.y = cfg[92][0];
	shichang.x = kuangmo.x;
	shichang.y = kuangmo.y + 78;
}





// include "data.as";
var loader: URLLoader = new URLLoader();
loader.dataFormat = URLLoaderDataFormat.TEXT;
loader.addEventListener(Event.COMPLETE, dataLoaded);
loader.load(new URLRequest("data.csv"));

var da: Array;
var Num: int;
var rk: rankBar;
var pofix: String; // 所加载图片的后缀

function dataLoaded(evt: Event): void {

	da = loader.data.split("\n");
	for(i = 0; i < da.length; i++) {
		da[i] = da[i].split(",");
	}

  // 从第3行第1列开始过滤非数字
  for(i = 3; i < da.length; i++) {
    for(j = 1; j < da[i].length; j++){
      da[i][j] = Number(da[i][j]);
      if(isNaN(da[i][j])){
        da[i][j]=0;
      }
    }
  }

	pofix = da[0][0];
	Num = da[1].length - 1; // 计算条目数

	for(i = 0; i < Num; i++) {
		rk = new rankBar();
		rk.initialize(i + 1, da[0][i + 1], da[1][i + 1], da[2][i + 1], pofix, cfg, da[3][i + 1]);
		RKcon.addChildAt(rk, i);
	}
	stage.addEventListener(Event.ENTER_FRAME, movie);
}





var i: int;
var j: int;

var t: int = -1;
var T: int = 2; // 数据从第4行开始
var tres: int = 0;

var bar1: rankBar;
var bar2: rankBar;

var po: Number=0.0001; // population

var maxr: Number; // 计算缩放率用
var maxfan: Number; // 只缩不放用
var absmaxr:Number; // 兼容负数据用

var Tcon: Sprite = new Sprite(); // 冠军条容器
addChildAt(Tcon, 3);

var rect: Sprite = new Sprite();
Tcon.addChild(rect);

var lastid: String; // 更新冠军头像
var Icon: Sprite = new Sprite(); // 冠军头像容器
addChildAt(Icon, 0);




var curbub:CurBub = new CurBub(); //当前冠军

function movie(event: Event): void {

	if(t == 0) {
    // 解决某个 as 的 bug
    maxr = 0;
    absmaxr = 0;
    maxfan = 0;
    lastid = "2";

    //stage.frameRate = 0; // 启动时暂停
  }

	if(t < da.length * fp) {
		t++;
	} else {
		stage.removeEventListener(Event.ENTER_FRAME, movie);
	}

	tres = t % fp;
	if(tres == 0) {
		T++;
		if(T < da.length) {
			yeart.text = da[T][0];
		}
    if(T < da.length - 1) {
      if(cfg[14][0]=="1"){
        for(j=1; j<da[T].length; j++){
          da[T+1][j]=Number(da[T+1][j])+Number(da[T][j])
        }
      } // 将数据替换成一阶积分
    }
	}
	for(i = 0; i < RKcon.numChildren; i++) {
		rk = RKcon.getChildAt(i) as rankBar;
		j = rk.n;
		if(T < da.length - 1) {
      if(cfg[13][0]=="2"){ // 关掉线性补间，使用变速缓冲
        po = rk.po + (da[T][j]-rk.po)/Number(cfg[8][0]);
      }else if(cfg[13][0]=="3"){
        po = rk.po + (da[T+1][j]-rk.po)/Number(cfg[8][0]);
      }else{
        po = da[T][j] * (1 - tres/fp) + da[T + 1][j] * tres/fp; // 线性补间
      }
			rk.update(po);
		}
	}

  var RKmax = RKcon.numChildren-1;

if(t%int(cfg[125][0])==1){ // 自定义每几帧更新次水印
  for(i = RKmax; i >= 0; i--) {
    bar1 = RKcon.getChildAt(i) as rankBar;
    bar1.updateWater();
  }
}


if(!isNaN(cfg[15][0])){
if(t%int(cfg[15][0])==1){ // 自定义每几帧更新次排序
  // 冒泡排序法（反转，最大的放最上层
  for(i = RKmax; i >= 0; i--) {
    bar1 = RKcon.getChildAt(i) as rankBar;

    for(j = i + 1; j <= RKmax; j++) {
      var bar2: rankBar = RKcon.getChildAt(j) as rankBar;
      if(bar1.fan > bar2.fan) {
        bar1.rank = RKmax-j;
      }else{
        break;
      }
    }
    RKcon.setChildIndex(bar1, RKmax-bar1.rank);
  }
}
}

  // 可选宽度跟随第几名
	bar1 = RKcon.getChildAt(RKmax-int(cfg[75][1]-1)) as rankBar;

	maxr += (Number(cfg[51][0]) / userfunc(bar1.fan, maxfan, cfg[53][0] == "1") - maxr) / Number(cfg[7][0]); // 加点缓冲
	if(Math.abs(maxfan) < Math.abs(bar1.fan)) {
		maxfan = bar1.fan;
	} else {
		maxfan += (bar1.fan - maxfan) * Number(cfg[54][0]); // 带缓冲地回缩
	}


  absmaxr = Math.abs(maxr);

  for(i = 0; i < RKcon.numChildren; i++) {
    bar1 = RKcon.getChildAt(i) as rankBar;
    bar1.rank = RKmax-i;
    bar1.updatey(bar1.rank, absmaxr); //bkggrid.scaleX
  }


	for(i = 0; i < BKcon.numChildren; i++) {
		bk = BKcon.getChildAt(i) as bkgL;
		bk.updatex(absmaxr);
	}



	// 可选高亮第几名
  bar1 = RKcon.getChildAt(RKmax-int(cfg[75][0]-1)) as rankBar;

  // 冠军条
  yeart.x += Number(cfg[78][0]);
  current.x += Number(cfg[78][1]);
  Tcon.x -= Number(cfg[78][2]);
  if(t % int(cfg[81][0]) == 0) {
		rect.graphics.beginFill(bar1.col);
		// rect.graphics.drawRect(current.x - wid, current.y + 63, wid, cfg[82][0]);
    rect.graphics.drawRect(current.x - wid, current.y + 75-userheight(bar1), wid, userheight(bar1));
		rect.graphics.endFill();
	}
	if(t % fp == 0 && da[T][0].slice(int(cfg[84][0]), int(cfg[84][1])) == cfg[84][2]) {
		var ye: yearL = new yearL();
		ye.te.text = da[T][0].slice(int(cfg[84][3]), int(cfg[84][4]));
		ye.x = current.x;
		ye.y = current.y + Number(cfg[85][0]);
		Tcon.addChildAt(ye, 0);
	}


  kuangmo.text = cfg[93][0] + bar1.cn;
  shichang.text = cfg[94][0] + bar1.fan.toFixed(cfg[95][0]) + cfg[96][0];


  if(t == 2) { // 启动时冠军头像多检查一次更新
    var icon: Loader = new Loader();
    icon.contentLoaderInfo.addEventListener(Event.COMPLETE, iconLoaded);
    icon.load(new URLRequest(bar1.id + pofix));
    lastid = bar1.id;

    Icon.removeChildAt(0);
  }

  if(bar1.id != lastid && t > 2) {

    var icon2: Loader = new Loader();
    icon2.contentLoaderInfo.addEventListener(Event.COMPLETE, iconLoaded);
    icon2.load(new URLRequest(bar1.id + pofix));

    curbub = new CurBub();
    curbub.loadp(bar1.id + pofix);
    curbub.x=current.x-15;
    curbub.y=current.y+75-15;
    Tcon.addChild(curbub);

    lastid = bar1.id;
  }else{
    curbub.x += Number(cfg[78][1])/2;
  }
}




function userfunc(fan: Number, maxf: Number, iflog: Boolean): Number {
	var temp: Number;
	if(Math.abs(maxf) < Math.abs(fan)) {
		temp = fan;
	} else {
		temp = maxf;
	}
	if(iflog) {
		return(Math.log(1 + temp))
	} else {
		return(temp)
	}
}



function userheight(bar1:rankBar):Number{
  if(cfg[82][0]=="A"){
    return(bar1.fan/Number(cfg[82][1]))
  }else if(cfg[82][0]=="D"){
    return((Number(da[T+int(cfg[82][2])][bar1.n])-Number(da[T][bar1.n]))/Number(cfg[82][1]))
  }else{
    return(Number(cfg[82][0]))
  }
}


function iconLoaded(e: Event): void {

	var image: Bitmap = new Bitmap(e.target.content.bitmapData);
	image.x = Number(cfg[97][0]);
	image.y = Number(cfg[98][0]);
  // image.width = cfg[99][0];
  // image.height = cfg[100][0];
  image.scaleX = Number(cfg[99][0])/image.width;
  image.scaleY = image.scaleX;
  image.alpha=0;
  image.addEventListener(Event.ENTER_FRAME, fadein);

	if(Icon.numChildren > 0) {
    Icon.getChildAt(0).addEventListener(Event.ENTER_FRAME, fadeout);
	}


if(cfg[99][1]=="1"){ // 裁圆形
  var maskCircle: Sprite = new Sprite();
  maskCircle.graphics.beginFill(0x000000);
  maskCircle.graphics.drawEllipse(image.x, image.y, image.width, image.width);
  maskCircle.graphics.endFill();
  maskCircle.visible = false;
  Icon.addChild(maskCircle);

  image.mask = maskCircle;
}

	Icon.addChild(image);

}




function fadein(event: Event): void {
  if(event.target.alpha<Number(cfg[100][0])){ event.target.alpha+=Number(cfg[101][0])}
  else{event.target.alpha=Number(cfg[100][0]);event.target.removeEventListener(Event.ENTER_FRAME, fadein);}
}

function fadeout(event: Event): void {
  if(event.target.alpha>0){ event.target.alpha-=Number(cfg[101][0])}
  else{event.target.alpha=0;event.target.removeEventListener(Event.ENTER_FRAME, fadeout);    Icon.removeChildAt(0);}
}



var bkimage: Bitmap;
function bkgLoaded(e: Event): void {

  bkimage = new Bitmap(e.target.content.bitmapData);
  bkimage.scaleX = 1920/bkimage.width;
  bkimage.scaleY = bkimage.scaleX;
  bkimage.alpha=cfg[2][3];
  addChildAt(bkimage,0);
}



var fadeupy:Number = 0;

addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
function keyPressed(event: KeyboardEvent): void {

  if(event.keyCode == Keyboard.SPACE) {
    if(stage.frameRate <= 1){
      stage.frameRate = int(cfg[5][0]);
    }else{
      stage.frameRate = 0;
    }
  }
  // 方向键控制柱子移动
  if(event.keyCode == Keyboard.RIGHT) {
    RKcon.x+=2;
  }
  if(event.keyCode == Keyboard.LEFT) {
    RKcon.x-=2;
  }
  if(event.keyCode == Keyboard.UP) {
    fadeupy = RKcon.y - Number(cfg[16][0]);
    RKcon.addEventListener(Event.ENTER_FRAME, fadeup);
  }
  if(event.keyCode == Keyboard.DOWN) {
    fadeupy = RKcon.y + Number(cfg[16][0]);
    RKcon.addEventListener(Event.ENTER_FRAME, fadeup);
  }
}



function fadeup(event: Event): void {

  RKcon.y -= (RKcon.y-fadeupy)/Number(cfg[16][1]);

  if(Math.abs(RKcon.y-fadeupy)<1){
    RKcon.y = fadeupy;
    event.target.removeEventListener(Event.ENTER_FRAME, fadeup);
  }
}

