package system;

import processing.core.PApplet;
import processing.core.PVector;

public class InkMaker extends PApplet {
	InkParSystem ips;//粒子系统
	int option = 0;//当前控制选项
	boolean recording = false;//是否输出画面
	PVector lastMouse = new PVector(-1, -1);//上一次鼠标的位置
	float renderR = 0.0f;//渲染完成比率

	//入口
	public static void main(String[] args) {
		InkMaker soft = new InkMaker();//创建Processing Sketch
		soft.runSketch();//运行Processing Sketch
	}

	public void settings() {
		size(1280, 720);//界面尺寸大小设定
	}

	@Override
	public void setup() {
		background(255);//起始背景颜色
		size(1280, 720);//界面尺寸大小设定
		noStroke();//接下来的形状不描边
		textSize(25);//接下来的文字尺寸
		ips = new InkParSystem(createImage(1280, 720, ARGB), this);
		//创建粒子系统
		ips.updateThread();
		//启动粒子计算线程
	}

	public void draw() {
		//用户绘制
		if (mousePressed) {
			if (lastMouse.x == -1) {
				ips.touch(mouseX, mouseY, (char) 255);
			} else {
				ips.line(mouseX, mouseY, (int) lastMouse.x, (int) lastMouse.y, (char) 255);
			}
			lastMouse.set(mouseX, mouseY);
		} else {
			lastMouse.set(-1, -1);
		}
		//渲染缓存图片
		image(ips.view, 0, 0);
		//填充颜色
		fill(100, 150);
		//绘制矩形
		rect(0, 0, width, 120);
		
		//修正renderR
		if (ips.list.size() != 0) {
			renderR = min((float) (1 - (ips.curPro * 1.0) / ips.curSize), 1f);
		} else {
			renderR = 1f;
		}

		//渲染文字
		fill(255);
		text("fps : " + round(frameRate), 50, 30);
		text("parNum : " + ips.list.size(), 200, 30);
		text("frameCount : " + ips.frameId, 1000, 30);
		text("Press 's' to stop render, Press 'c' to clear screen,\nPress 'r' to save frames", 50, 70);
		text("By ZzStarSound", 1080, 110);
		text("render : " + round(renderR * 100) + "%", 500, 30);
		
		//渲染 渲染进度条
		noFill();
		stroke(255);
		rect(700, 20, 100, 5);
		noStroke();
		fill(255);
		rect(700, 20, 100 * renderR, 5);

		//调用函数
		renderOption();

		//渲染特殊状态文字
		if (ips.imageClear) {
			fill(0, 255, 0);
			text("ImageClear Waiting", 700, 70);
		}
		if (ips.listClear) {
			fill(0, 255, 0);
			text("Stop Render Waiting", 1000, 70);
		}

		if (recording) {
			fill(0, 255, 255);
			if (ips.over) {
				fill(255, 0, 0);
			}
			text("Saved " + ips.getFrameCount(), 820, 110);
			ellipse(1050, 100, 25, 25);
		}
		
		
		if (ips.over) {
			ips.over = false;
		}

	}

	//渲染UI
	void renderOption() {
		pushMatrix();
		translate(50, 100);
		fill(0);
		text("Dying Probability " + ips.wh, 0, 50);
		text("Fading Probability " + ips.ldh, 0, 100);
		text("Fading Ratio " + ips.ldd, 0, 150);
		text("Min Level " + (int) ips.minl, 0, 200);
		ellipse(-30, option * 50 + 40, 25, 25);
		popMatrix();
	}

	//设定数值
	void setOption(int mode, boolean plus) {
		switch (mode) {
		case 0:
			ips.wh += (plus ? 1 : -1) / 100f;
			if (ips.wh > 1)
				ips.wh = 1f;
			else if (ips.wh < 0)
				ips.wh = 0f;
			break;
		case 1:
			ips.ldh += (plus ? 1 : -1) / 100f;
			if (ips.ldh > 1)
				ips.ldh = 1f;
			else if (ips.ldh < 0)
				ips.ldh = 0f;
			break;
		case 2:
			ips.ldd += (plus ? 1 : -1) / 100f;
			if (ips.ldd > 1)
				ips.ldd = 1f;
			else if (ips.ldd < 0)
				ips.ldd = 0f;
			break;
		case 3:
			ips.minl += plus ? 1 : -1;
			break;
		}
	}
	
	//设定默认值
	void setDefaultOption() {
		switch (option) {
		case 0:
			ips.wh = ips.whf;
			break;
		case 1:
			ips.ldh = ips.ldhf;
			break;
		case 2:
			ips.ldd = ips.lddf;
			break;
		case 3:
			ips.minl = ips.minlf;
			break;
		}
	}

	//键盘按键回调
	public void keyPressed() {
		if (key == 'c') {
			ips.imageClear = true;
		} else if (key == 's') {
			ips.listClear = true;
		} else if (key == 'r') {
			recording = !recording;
		}
		if (keyCode == 38) {
			option--;
			if (option < 0)
				option = 3;
		} else if (keyCode == 40) {
			option++;
			if (option > 3)
				option = 0;
		} else if (keyCode == 37) {
			setOption(option, false);
		} else if (keyCode == 39) {
			setOption(option, true);
		} else if (keyCode == 10) {
			setDefaultOption();
		}

	}

}
