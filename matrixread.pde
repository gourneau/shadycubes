class oscgenerator extends Generator {
  
  public String getTitle() {
    return "Shady OSC Matrix Listener";
  }
  
  public void run(int deltaMs) {
    // All actions handled by OSC
  }
  
  public void oscEvent(OscMessage om) {
    matrixread_oscEvent(om);
    oapi_oscEvent(om);
  }
}

class exponentialfadeout extends Modulator {
  
  public String getTitle() {
    return "Exponential Fadeout";
  }
  
  public void modulate(int deltaMs) {
    // Fade out over time
    for (cuPoint p : pointList) {
      // NOTE: these values should be parameterized by deltaMs so the
      // fade is independent of framerate
      p.r*=0.99;
      p.g*=0.98;
      p.b*=0.97;
    }
  }
}

byte unsignedByte( int val ) {
  return (byte)( val > 127 ? val - 256 : val );
}

byte[] bpack(int[] ii) {
  byte[] ret = new byte[ii.length];
  for (int i=0; i<ii.length;i++) {
    ret[i]=unsignedByte(ii[i]);
  }
  return ret;
}


float ex=0, ey=0, ez=0; // it's cross-tick
int then=0;
int now=0;
float sr,sg,sb,sr2,sg2,sb2;
void matrixread_oscEvent(OscMessage om){
  println("IN MATRIXREAD_OSCEVENT");
  float x,y,z,r,g,b;
  x=y=z=r=g=b=0;
  now=millis();
  if (now-then>1000) {
    sr=random(1);
    sg=random(1);
    sb=random(1);
    sr2=random(1);
    sg2=random(1);
    sb2=random(1);
    then=millis();
  }
  if(om.checkAddrPattern("/something/message")){
    int cn = om.get(0).intValue(); println(cn);
    r = om.get(1).floatValue(); println(r);
    g = om.get(2).floatValue(); println(g);
    b = om.get(3).floatValue(); println(b);
    try {
      cuPoint[] pl = (cuPoint[])cubeList.get(cn);
      for (int i=0; i<pl.length; i++) {
        pl[i].setColor(sr, sg, sb);
      }
    } 
    catch(Exception e) { 
      println(e);
    }
  }
  if (om.checkAddrPattern("/5/xy1")==true) {
    ez = om.get(0).floatValue(); 
    ey = 1-om.get(1).floatValue();
    ez*=128;
    ey*=256;
    for (int i=0; i<pointList.size(); i++) {
      cuPoint p = (cuPoint)pointList.get(i);
      if (p.ix>ex-16 && p.ix<ex+16 &&
        p.iy>ey-16 && p.iy<ey+16 &&
        p.iz>ez-16 && p.iz<ez+16 ) {
        p.setColor(sr2, sg2, sb2);
      }
    }
  }
  if (om.checkAddrPattern("/5/xy2")==true) {
    ex = om.get(0).floatValue(); 
    ey = 1-om.get(1).floatValue();
    ex*=128;
    ey*=256;
    for (int i=0; i<pointList.size(); i++) {
      cuPoint p = (cuPoint)pointList.get(i);
      if (p.ix>ex-16 && p.ix<ex+16 &&
        p.iy>ey-16 && p.iy<ey+16 &&
        p.iz>ez-16 && p.iz<ez+16 ) {
        p.setColor(sr2, sg2, sb2);
      }
    }
  }
  if (om.checkAddrPattern("/5/xy3")==true) {
    r = om.get(0).floatValue(); 
    g = om.get(1).floatValue();
    for (int i=0; i<pointList.size(); i++) {
      cuPoint p = (cuPoint)pointList.get(i);
      p.setColor(r, g, 0);
    }
  }
  if (om.checkAddrPattern("/5/xy4")==true) {
    g = om.get(0).floatValue(); 
    b = om.get(1).floatValue();
    for (int i=0; i<pointList.size(); i++) {
      cuPoint p = (cuPoint)pointList.get(i);
      p.setColor(0, g, b);
    }
  }
  if (om.checkAddrPattern("/gyrosc/gyr")==true) {
    x = om.get(0).floatValue();
    y = om.get(0).floatValue();
    z = om.get(0).floatValue();
    xr+=x/100;
    yr+=y/100;
    zr+=z/100;
  }
  if (om.checkAddrPattern("/5/push1")==true) {
    int[] icolors = new int[16*3];
    for (int i=0; i<16*3; i+=3) { 
      icolors[(i)]=255; 
      icolors[(i)+1]=255; 
      icolors[(i)+2]=255;
    }
    byte[] colors = bpack(icolors);
    oapi_shady_strip((int)random(864), colors);
  }  
  if (om.checkAddrPattern("/5/push2")==true) {
    int[] icolors = new int[3*16*3];
    for (int i=0; i<3*16*3; i+=3) { 
      icolors[(i)]=255; 
      icolors[(i)+1]=255; 
      icolors[(i)+2]=255;
    }
    byte[] colors = bpack(icolors);
    oapi_shady_clip((int)random(288), colors);
  }  
  if (om.checkAddrPattern("/5/push3")==true) {
    int[] icolors = new int[4*3*16*3];
    for (int i=0; i<4*3*16*3; i+=3) { 
      icolors[(i)]=255; 
      icolors[(i)+1]=255; 
      icolors[(i)+2]=255;
    }
    byte[] colors = bpack(icolors);
    oapi_shady_cube((int)random(72), colors);
  }  

  if (om.checkAddrPattern("/5/push4")==true) {
    int[] icolors = new int[3*16*3];
    for (int i=0; i<3*16*3; i+=3) { 
      icolors[(i)]=255; 
      icolors[(i)+1]=255; 
      icolors[(i)+2]=255;
    }
    byte[] colors = bpack(icolors);
    oapi_shady_cube_clip((int)random(72), 0, colors); // random cube, but always same clip
  }  

  if (om.checkAddrPattern("/5/push5")==true) {
    int[] icolors = new int[16*3];
    for (int i=0; i<16*3; i+=3) { 
      icolors[(i)]=255; 
      icolors[(i)+1]=255; 
      icolors[(i)+2]=255;
    }
    byte[] colors = bpack(icolors);
    oapi_shady_cube_clip_strip((int)random(72), 3, 0, colors); // ...but always same strip
  }  
  if (om.checkAddrPattern("/5/push6")==true) {
    for (int i=0; i<pointList.size(); i++) {
      cuPoint p = (cuPoint)pointList.get(i);
      p.setColor(0, 0, 1);
    }
  }
}

