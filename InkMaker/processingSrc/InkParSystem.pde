
class InkParSystem {
  ArrayList<InkPar> list = new ArrayList<InkPar>();
  DataBoard db = null;
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

  InkParSystem(int w,int h) {
    out = createImage(w, h, ARGB);
    db = new DataBoard(w,h);
    view = new PImage(w, h);
    resetImage();
  }

  void copyToView() {
    synchronized(InkParSystem.class){
    view.loadPixels();
    for (int i = 0; i < db.length; i++) {
      view.pixels[i] = color(255 - db.getLevel(i));
    }
    view.updatePixels();
    }
  }

  void resetImage() {
    view.loadPixels();
    out.loadPixels();
    for (int i = 0; i < db.length; i++) {
      view.pixels[i] = color(255);
      out.pixels[i] = color(0,0);
    }
    out.updatePixels();
    view.updatePixels();
    db.reset();
    if (!recording)
      frameId = 0;
  }

  void touch(int x, int y) {

    addPar(new InkPar(x, y, db.max));

  }

  void line(int x, int y, int x2, int y2) {
    float dis = PApplet.dist(x, y, x2, y2);

    for (int i = 0; i < dis; i++) {
      addPar(new InkPar(Math.round(x + (i / dis) * (x2 - x)), Math.round(y + (i / dis) * (y2 - y)), db.max));
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
              if (recording) {
                synchronized(InkParSystem.class){
                db.toImage(out).save("output/frames" + getFrameCount() + ".png");
                }
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
    minData = map(minl,0,255,0,1);
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
      if (curPar.level < minData) {
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


  void render(InkPar t) {
    db.set(t.x, t.y, max(db.get(t.x,t.y),t.level));
  }

  void generate(int x, int y, float level) {
    if (Math.random() < wh || !insideScreen(x, y) || db.get(x, y) >= level) {
      return;
    }
    
    addPar(new InkPar(x, y, Math.random() < ldh
        ? (level * ldd * random(0.7f, 1f)) : level));

  }

  boolean insideScreen(int x, int y) {
    if (x >= db.width || y >= db.height || x < 0 || y < 0) {
      return false;
    }
    return true;
  }

  // 获取整齐含0的帧id
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