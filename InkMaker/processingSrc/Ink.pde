InkParSystem ips;
boolean recording = false;
int option = 0;
  float wh = 0.4f;// ratio of happenning//wait
  final float whf = 0.4f;

  float ldh = 0.3f;// ratio of happenning//level
  final float ldhf = 0.3f;

  float ldd = 0.9f;// ratio of decreasing//level
  final float lddf = 0.9f;

  char minl = 25;
  final char minlf = 25;
  float minData;
  
void setup(){
  background(255);
  size(1280,720);
  noStroke();
  textSize(25);
ips = new InkParSystem(1280,720);
ips.updateThread();
}

PVector lastMouse = new PVector(-1,-1);
float renderR = 0.0;
void draw(){synchronized(InkParSystem.class){
    image(ips.view, 0, 0);
    fill(100, 150);
    rect(0, 0, width, 120);
    
    if (ips.list.size() != 0) {
      renderR = min((float) (1 - (ips.curPro * 1.0) / ips.curSize), 1f);
    } else {
      renderR = 1f;
    }

    fill(255);
    text("fps : " + round(frameRate), 50, 30);
    text("parNum : " + ips.list.size(), 200, 30);
    text("frameCount : " + ips.frameId, 1000, 30);
    text("Press 's' to stop render, Press 'c' to clear screen,\nPress 'r' to save frames", 50, 70);
    text("By ZzStarSound", 1080, 110);
    text("render : " + round(renderR * 100) + "%", 500, 30);
    
    noFill();
    stroke(255);
    rect(700, 20, 100, 5);
    noStroke();
    fill(255);
    rect(700, 20, 100 * renderR, 5);

    renderOption();

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
}
void mousePressed(){
  ips.touch(mouseX, mouseY);
  lastMouse.set(mouseX, mouseY);
}
void  mouseDragged(){
  ips.line(mouseX, mouseY, (int) lastMouse.x, (int) lastMouse.y);
  lastMouse.set(mouseX, mouseY);
}



String getFrameCount(){
  int x=ips.frameId; 
  String xs=String.valueOf(x); 
  String [] ss = {"0000000","000000","00000","0000","000","00","0"};
  if(xs.length()<=ss.length-1)
    xs = ss[xs.length()-1] + xs;
  else return "-1OverIndex";
  return xs;
}
  //设定默认值
  void setDefaultOption() {
    switch (option) {
    case 0:
      wh = whf;
      break;
    case 1:
      ldh = ldhf;
      break;
    case 2:
      ldd = lddf;
      break;
    case 3:
      minl = minlf;
      break;
    }
  }
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

void setOption(int mode, boolean plus) {
    switch (mode) {
    case 0:
      wh += (plus ? 1 : -1) / 100f;
      if (wh > 1)
        wh = 1f;
      else if (wh < 0)
        wh = 0f;
      break;
    case 1:
      ldh += (plus ? 1 : -1) / 100f;
      if (ldh > 1)
        ldh = 1f;
      else if (ldh < 0)
        ldh = 0f;
      break;
    case 2:
      ldd += (plus ? 1 : -1) / 100f;
      if (ldd > 1)
        ldd = 1f;
      else if (ldd < 0)
        ldd = 0f;
      break;
    case 3:
      minl += plus ? 1 : -1;
      break;
    }
  }
  
    void renderOption() {
    pushMatrix();
    translate(50, 100);
    fill(0);
    text("Dying Probability " + wh, 0, 50);
    text("Fading Probability " + ldh, 0, 100);
    text("Fading Ratio " + ldd, 0, 150);
    text("Min Level " + (int) minl, 0, 200);
    ellipse(-30, option * 50 + 40, 25, 25);
    popMatrix();
  }