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
  float x,y,z,r,g,b;
  x=y=z=r=g=b=0;
  if(om.checkAddrPattern("/5/xy1")==true){
    x = om.get(0).floatValue(); 
    y = om.get(1).floatValue();
    for(int i=0; i<pointList.size(); i++){
      cuPoint p = (cuPoint)pointList.get(i);
      p.setColor(0,0,0);
      if((p.x+abs(min_x))/(max_x+abs(min_x)) < x) { p.setColor(1,1,1); }
      if((p.y+abs(min_y))/(max_y+abs(min_y)) < y) { p.setColor(1,1,1); }    
    }  
  }
  if(om.checkAddrPattern("/5/xy2")==true){
    x = om.get(0).floatValue(); 
    z = om.get(1).floatValue();
    for(int i=0; i<pointList.size(); i++){
      cuPoint p = (cuPoint)pointList.get(i);
      p.setColor(0,0,0);
      if((p.x+abs(min_x))/(max_x+abs(min_x)) < x) { p.setColor(1,1,1); }
      if((p.z+abs(min_z))/(max_z+abs(min_z)+1) < z) { p.setColor(1,1,1); }    
    }  
  }
  if(om.checkAddrPattern("/5/xy3")==true){
    r = om.get(0).floatValue(); 
    g = om.get(1).floatValue();
    for(int i=0; i<pointList.size(); i++){
      cuPoint p = (cuPoint)pointList.get(i);
      p.setColor(r,g,0);
    }  
  }
  if(om.checkAddrPattern("/5/xy4")==true){
    g = om.get(0).floatValue(); 
    b = om.get(1).floatValue();
    for(int i=0; i<pointList.size(); i++){
      cuPoint p = (cuPoint)pointList.get(i);
      p.setColor(0,g,b);
    }  
  }
  if(om.checkAddrPattern("/gyrosc/gyr")==true){
    x = om.get(0).floatValue();
    y = om.get(0).floatValue();
    z = om.get(0).floatValue();
    xr+=x/100;
    yr+=y/100;
    zr+=z/100;
        
  }
  
  //println(om.getBytes());
  //byte[] payload = om.getBytes();
  //println(payload.length);
}

