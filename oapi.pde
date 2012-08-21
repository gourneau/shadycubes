void oapi_setRange(cuPoint[] pl, byte[] colors){
  for(int i=0; i<pl.length; i++){
    println("i " + i);
    int r = colors[i*3+0]&0xff;
    println("r "+r);
    int g = colors[i*3+1]&0xff;
    println("g "+g);
    int b = colors[i*3+2]&0xff;
        println("b "+b);
    pl[i].setColor(r,g,b);
  }
}  

void oapi_shady_strip(int stripnum, byte[] colors){
    cuPoint[] pl = (cuPoint[]) stripList.get(stripnum);
    oapi_setRange(pl, colors);
}


void oapi_shady_clip(int clipnum, byte[] colors){
    cuPoint[] pl = (cuPoint[]) clipList.get(clipnum);
    oapi_setRange(pl, colors);
}

void oapi_shady_cube(int cubenum, byte[] colors){
    cuPoint[] pl = (cuPoint[]) cubeList.get(cubenum);
    oapi_setRange(pl, colors);
}

void oapi_shady_cube_clip(int cubenum, int stripnum, byte[] colors){
    cuClip cu = cubes[cubenum].clips[stripnum];
    cuPoint[] pl = new cuPoint[16*3];
    for(int i=0; i<3; i++){
      for(int j=0; j<16; j++){
        pl[i*16 + j] = cu.strips[i].points[j];
      }
    }    
    oapi_setRange(pl, colors);  
}

void oapi_shady_cube_clip_strip(int cubenum, int clipnum, int stripnum, byte[] colors){
    cuStrip cu = cubes[cubenum].clips[clipnum].strips[stripnum];
    cuPoint[] pl = new cuPoint[16];
    for(int i=0; i<16; i++){
        pl[i] = cu.points[i];
    }    
    oapi_setRange(pl, colors);
}

void oapi_shady_point(int cubenum, int clipnum, int stripnum, int pointnum, byte[] colors){
    cuStrip cu = cubes[cubenum].clips[clipnum].strips[stripnum];
    cuPoint[] pl = new cuPoint[1];
    pl[0] = cu.points[pointnum];
    
    oapi_setRange(pl, colors);
}

void oapi_oscEvent(OscMessage om){

  if(om.checkAddrPattern("/shady/strip")){  
    int n = om.get(0).intValue();
    byte[] by = om.get(1).blobValue();
    oapi_shady_strip(n, by);
  }

  if(om.checkAddrPattern("/shady/clip")){  
    int n = om.get(0).intValue();
    byte by[] = om.get(1).blobValue();
    oapi_shady_clip(n, by);
  }
  
  if(om.checkAddrPattern("/shady/cube")){  
    int n = om.get(0).intValue();
    byte by[] = om.get(1).blobValue();
    oapi_shady_cube(n, by);
  }

  if(om.checkAddrPattern("/shady/cube_clip")){  
    int n = om.get(0).intValue();
    int n2 = om.get(1).intValue();
    byte by[] = om.get(2).blobValue();
    oapi_shady_cube_clip(n, n2, by);
  }

  if(om.checkAddrPattern("/shady/cube_clip_strip")){  
    int n = om.get(0).intValue();
    int n2 = om.get(1).intValue();
    int n3 = om.get(2).intValue();
    byte by[] = om.get(3).blobValue();
    oapi_shady_cube_clip_strip(n, n2, n3, by);
  }
  
  if(om.checkAddrPattern("/shady/point")){  
    int n = om.get(0).intValue();
    int n2 = om.get(1).intValue();
    int n3 = om.get(2).intValue();
    int n4 = om.get(3).intValue();
    byte by[] = om.get(4).blobValue();
    oapi_shady_point(n, n2, n3, n4, by);
  }  
}


