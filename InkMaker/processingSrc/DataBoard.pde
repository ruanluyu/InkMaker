class DataBoard{
float[] data;
int width;
int height;
int length;
float min = 0.0f;
float max = 1.0f;
DataBoard(int w,int h){
  width = w;
  height = h;
  length = w*h;
  data = new float[w*h];
  reset();
}
float get(int id){
  return data[id];
}
float get(int x,int y){
  return data[x+y*width];
}
char getLevel(int id){
  return (char)round(map(data[id],min,max,0,255));
}
char getLevel(int x,int y){
  return getLevel(x+y*width);
}
void set(int id,float d){
  if(id>=data.length)return;
  data[id] = constrain(d,min,max);
}
void set(int x,int y,float d){
  if(x>=width||x<0||y>=height||y<0){
    
    return;    
}

data[x+y*width] =   constrain(d,min,max);
}
void reset(){
  for(int i = 0;i<length;i++){
    data[i] = 0.0f;
  }
}
PImage toImage(PImage in){
  if(in == null)return null;
  in.loadPixels();
  for(int i =0;i<data.length;i++){
    in.pixels[i] = color(0,round((map(data[i],min,max,0,255))));
  }
  in.updatePixels();
  return in;
}


}