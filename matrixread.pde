
void matrixread_setup() {
    oscP5 = new OscP5(this,10000);
}

void matrixread_draw() {
   
}

byte unsignedByte( int val ) { return (byte)( val > 127 ? val - 256 : val ); }
byte[] bpack(int[] ii){
  byte[] ret = new byte[ii.length];
  for(int i=0; i<ii.length;i++){
    ret[i]=unsignedByte(ii[i]);
  }
  return ret;
}


void matrixread_oscEvent(OscMessage om){
  float x,y,z,r,g,b;
  x=y=z=r=g=b=0;
  if(om.addrPattern()=="/something/message"){
    int cn = om.get(0).intValue(); println(cn);
    r = om.get(1).floatValue(); println(r);
    g = om.get(2).floatValue(); println(g);
    b = om.get(3).floatValue(); println(b);
    try {
       cuPoint[] pl = (cuPoint[])cubeList.get(cn);
       for(int i=0; i<pl.length; i++){
          pl[i].setColor(r,g,b); 
       }
    } catch(Exception e) { println(e); }
  }
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
  if(om.checkAddrPattern("/5/push1")==true){
    int[] icolors = new int[16*3];
    for(int i=0; i<16*3; i+=3){ icolors[(i)]=255; icolors[(i)+1]=255; icolors[(i)+2]=255; }
    byte[] colors = bpack(icolors);
    oapi_shady_strip((int)random(864),colors);
  }  
  if(om.checkAddrPattern("/5/push2")==true){
    int[] icolors = new int[3*16*3];
    for(int i=0; i<3*16*3; i+=3){ icolors[(i)]=255; icolors[(i)+1]=255; icolors[(i)+2]=255; }
    byte[] colors = bpack(icolors);
    oapi_shady_clip((int)random(288),colors);
  }  
  if(om.checkAddrPattern("/5/push3")==true){
    int[] icolors = new int[4*3*16*3];
    for(int i=0; i<4*3*16*3; i+=3){ icolors[(i)]=255; icolors[(i)+1]=255; icolors[(i)+2]=255; }
    byte[] colors = bpack(icolors);
    oapi_shady_cube((int)random(72),colors);
  }  

  if(om.checkAddrPattern("/5/push4")==true){
    int[] icolors = new int[3*16*3];
    for(int i=0; i<3*16*3; i+=3){ icolors[(i)]=255; icolors[(i)+1]=255; icolors[(i)+2]=255; }
    byte[] colors = bpack(icolors);
    oapi_shady_cube_clip((int)random(72), 0, colors); // random cube, but always same clip
  }  

  if(om.checkAddrPattern("/5/push5")==true){
    int[] icolors = new int[16*3];
    for(int i=0; i<16*3; i+=3){ icolors[(i)]=255; icolors[(i)+1]=255; icolors[(i)+2]=255; }
    byte[] colors = bpack(icolors);
    oapi_shady_cube_clip_strip((int)random(72), 3, 0, colors); // ...but always same strip
  }  

}

