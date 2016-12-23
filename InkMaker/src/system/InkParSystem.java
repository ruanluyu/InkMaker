package system;

import java.util.ArrayList;

import processing.core.PApplet;
import processing.core.PImage;

public class InkParSystem {
	float wh = 0.4f;// ratio of happenning//wait
	final float whf = 0.4f;
	float ldh = 0.3f;// ratio of happenning//level
	final float ldhf = 0.3f;
	float ldd = 0.9f;// ratio of decreasing//level
	final float lddf = 0.9f;
	char minl = 25;
	final char minlf = 25;
	InkMaker parent = null;
	ArrayList<InkPar> list = new ArrayList<InkPar>();
	PImage out = null;
	PImage view = null;
	boolean listClear = false;
	boolean imageClear = false;
	int curPro;
	int curSize;
	int frameId = 0;
	boolean over = false;

	InkParSystem() {
	}

	InkParSystem(PImage img, InkMaker parent) {
		out = img;
		view = new PImage(img.width, img.height, parent.RGB);
		this.parent = parent;
		resetImage();
	}

	void copyToView() {
		view.loadPixels();
		for (int i = 0; i < view.pixels.length; i++) {
			view.pixels[i] = parent.color(255 - parent.alpha(out.pixels[i]));
		}
		view.updatePixels();
	}

	void resetImage() {
		out.loadPixels();
		view.loadPixels();
		for (int i = 0; i < out.width * out.height - 1; i++) {
			view.pixels[i] = parent.color(255);
			out.pixels[i] = parent.color(0, 0);
		}
		out.updatePixels();
		view.updatePixels();
		if (!parent.recording)
			frameId = 0;
	}

	void touch(int x, int y, char level) {

		addPar(new InkPar(x, y, level));

	}

	void line(int x, int y, int x2, int y2, char level) {
		float dis = PApplet.dist(x, y, x2, y2);

		for (int i = 0; i < dis; i++) {
			addPar(new InkPar(Math.round(x + (i / dis) * (x2 - x)), Math.round(y + (i / dis) * (y2 - y)), level));
		}

	}

	void addPar(InkPar par) {
		list.add(par);
	}

	void updateThread() {
		new Thread() {
			@Override
			public void run() {
				try {
					while (true) {
						if (list.size() != 0 && !over) {
							update();
							if (parent.recording) {
								out.save("output/frames" + getFrameCount() + ".png");
							}
							copyToView();
							over = true;
						} else
							Thread.sleep(16);
						clearCheck();
					}
				} catch (Exception e) {
					e.printStackTrace();
				}

			}

		}.start();
	}

	private void clearCheck() {
		if (imageClear) {
			resetImage();
			imageClear = false;
		}
		if (listClear) {
			list.clear();
			listClear = false;
			return;
		}
	}

	void update() {
		InkPar curPar = null;

		if (list.size() == 0) {
			return;
		}

		curSize = list.size();
		curPro = curSize - 1;
		for (; curPro >= 0; curPro--) {
			curPar = list.get(curPro);
			if (curPar == null) {
				list.remove(curPro);
				continue;
			}
			if (curPar.level < minl) {
				curPar = null;
				list.remove(curPro);
				continue;
			}
			list.remove(curPro);
			render(curPar);
			generate(curPar.x - 1, curPar.y, curPar.level);
			generate(curPar.x + 1, curPar.y, curPar.level);
			generate(curPar.x, curPar.y - 1, curPar.level);
			generate(curPar.x, curPar.y + 1, curPar.level);
			curPar = null;

		}
		frameId++;
	}

	char getLevel(int x, int y) {
		return (char) parent.alpha(out.get(x, y));
	}

	void render(InkPar t) {
		out.set(t.x, t.y, parent.color(0, Math.max(t.level, parent.alpha(out.get(t.x, t.y)))));
	}

	void generate(int x, int y, char level) {
		if (Math.random() < wh || !insideScreen(x, y) || getLevel(x, y) >= level) {
			return;
		}
		InkPar ink = new InkPar(x, y, level);

		addPar(ink);

		if (Math.random() < ldh) {
			ink.level = (char) (((float) ink.level) * (float) (ldd * parent.random(0.7f, 1f)));
		}
	}

	boolean insideScreen(int x, int y) {
		if (x >= out.width || y >= out.height || x < 0 || y < 0) {
			return false;
		}
		return true;
	}

	String getFrameCount() {
		int x = frameId;
		String xs = String.valueOf(x);
		String[] ss = { "0000000", "000000", "00000", "0000", "000", "00", "0" };
		if (xs.length() <= ss.length - 1)
			xs = ss[xs.length() - 1] + xs;
		else
			return "-1OverIndex";
		return xs;
	}
}
