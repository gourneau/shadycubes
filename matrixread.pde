import oscP5.*;
import netP5.*;

OscP5 oscP5;

void matrixread_setup() {
    oscP5 = new OscP5(this,10000);
}

void matrixread_draw() {
   
}

void oscEvent(OscMessage om) {
  print("### received an osc message.");
  print(" addrpattern: "+om.addrPattern());
  println(" typetag: "+om.typetag());
  
  if(om.addrPattern()=="/something/message"){
    println("working");
    int cn = om.get(0).intValue(); println(cn);
    float r = om.get(1).floatValue(); println(r);
    float g = om.get(2).floatValue(); println(g);
    float b = om.get(3).floatValue(); println(b);
    try {
       cuPoint[] pl = (cuPoint[])cubeList.get(cn);
       for(int i=0; i<pl.length; i++){
          pl[i].setColor(r,g,b); 
       }
    } catch(Exception e) { println(e); }
  }
  /*float x = om.get(0).floatValue(); 
  float y = om.get(1).floatValue();
  
  for(int i=0; i<pointList.size(); i++){
    cuPoint p = (cuPoint)pointList.get(i);
    p.setColor(0,0,0);
    if(p.x/max_x < x) { p.setColor(1,1,1); }
    if(p.y/max_y < y) { p.setColor(1,1,1); }    
  }  
  println(pointList.size());*/
  byte[] payload = om.getBytes();
  println(payload.length);
}

