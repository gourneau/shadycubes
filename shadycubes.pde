import javax.media.opengl.*;
import javax.media.opengl.glu.*;
import processing.opengl.*;

/* OSC DEPENDENCY -- YES THIS IS A PAIN */
import oscP5.*;
import netP5.*;

OscP5 oscP5;


PGraphicsOpenGL render;
GL gl;
GLU glu;
float ma[] = new float[16];
float mz[] = new float[16];
int count=0;

ArrayList pointList = new ArrayList();
ArrayList stripList = new ArrayList();
ArrayList clipList = new ArrayList();
ArrayList cubeList = new ArrayList();


float min_x=256*256;
float max_x=-256*256;
float min_y=256*256;
float max_y=-256*256;
float min_z=256*256;
float max_z=-256*256;


class cuPoint{
  float r,g,b,a;
  float x,y,z;
  float fx,fy,fz;
  int   ix,iy,iz;
  float m[]  = new float[16];
  cuPoint (float cr, float cg, float cb) {
    r=cr;
    g=cg;
    b=cb;
    a=0.6;
    pointList.add(this);
  }
  cuPoint (float cr, float cg, float cb, float ca) {
    r=cr;
    g=cg;
    b=cb;
    a=ca;
    pointList.add(this);
  }
  void setColor (float cr, float cg, float cb) {
    r=cr;
    g=cg;
    b=cb;
    a=0.6;
  }
  void setColor (int cr, int cg, int cb) {
    r=cr/255.0;
    g=cg/255.0;
    b=cb/255.0;
    a=0.6;
  }
  void setColor (float cr, float cg, float cb, float ca) {
    r=cr;
    g=cg;
    b=cb;
    a=ca;
  }
  void updatePosition(){
     gl.glGetFloatv(GL.GL_MODELVIEW_MATRIX, m, 0);
     x=m[12]-zp.x;
     y=m[13]-zp.y;
     z=m[14]-zp.z;
     if(this!=zp) {
       if(x<min_x) { min_x=x; }
       if(y<min_y) { min_y=y; }
       if(z<min_z) { min_z=z; }
       if(x>max_x) { max_x=x; }
       if(y>max_y) { max_y=y; }
       if(z>max_z) { max_z=z; }
     }
  }
  void draw(boolean do_update) {
   gl.glBegin(GL.GL_POINTS);
     gl.glColor4f(r,g,b,a);
     //gl.glColor4f(x/82,y/192,z/80,0.6);
     gl.glVertex3f(0,0,0);
   gl.glEnd();
   if(do_update) { updatePosition(); }
  }
}    

class cuStrip{
   cuPoint[] points;
   float x,y,z;
   cuStrip(){
     points = new cuPoint[16];
     for(int i=0; i<16; i++){
       points[i] = new cuPoint(1,1,1);
     }
     stripList.add(points);
   }
   void draw(boolean do_update){
     gl.glPushMatrix();
     gl.glTranslatef(2,0,0);
     for(int i=0; i<16; i++){
        points[i].draw(do_update);
        gl.glTranslatef(1,0,0);
     }
     gl.glPopMatrix();
   }
   void updateColor(int pointnum, float r, float g, float b){
      points[pointnum].setColor(r, g, b);
   }
   
}
  
class cuClip{
   cuStrip[] strips;
   cuClip(){
     strips = new cuStrip[3];
     for(int i=0; i<3; i++){
       strips[i] = new cuStrip();          
     }
     strips[0].updateColor(0,1,1,1);
     strips[1].updateColor(0,1,1,1);
     strips[2].updateColor(0,1,1,1);
     
     for(int i=1; i<16; i++){
        strips[0].updateColor(i, i/16.0, 0, 0);
        strips[1].updateColor(i, 0, i/16.0, 0);
        strips[2].updateColor(i, 0, 0, i/16.0);
     }
     
     cuPoint[] c = new cuPoint[3*16];
     for(int i=0; i<3; i++){
       for(int j=0; j<16; j++){
          c[i*16 + j] = strips[i].points[j];
       }
     }       
     clipList.add(c);
   }
   void draw(boolean do_update){
     gl.glPushMatrix();
       strips[0].draw(do_update);
       gl.glTranslatef(20,0,0);
       gl.glRotatef(90,0,0,1);
       strips[1].draw(do_update);
       gl.glTranslatef(20,0,0);
       gl.glRotatef(90,0,0,1);
       strips[2].draw(do_update);
     gl.glPopMatrix();
   }
}

class cuCube{
  cuClip[] clips;
  float x=0;
  float y=0;
  float z=0;
  float a=0;
  float rx=0;
  float ry=0;
  float rz=0;
  
  cuCube(){
    init();
  }
  cuCube(float cx, float cy, float cz, float crx, float cry, float crz){
    x=cx; 
    y=cy; 
    z=cz; 
    rx=crx; 
    ry=cry;
    rz=crz;
    init();
  }
  void init(){  
    clips = new cuClip[4];
    // prolly will have to rotate c's in some odd way
    for(int i=0; i<4; i++){
      clips[i] = new cuClip();
    }
    cubeList.add(this.getPoints());
  }
  void update(float cx, float cy, float cz, float crx, float cry, float crz){
    x=cx; 
    y=cy; 
    z=cz; 
    rx=crx; 
    ry=cry;
    rz=crz;
  }
  void draw(boolean do_update){
      gl.glPushMatrix();
      gl.glTranslatef(x, y, z);
      gl.glRotatef(rx, 1, 0, 0);
      gl.glRotatef(ry, 0, 1, 0);
      gl.glRotatef(rz, 0, 0, 1);
      
      gl.glPushMatrix();
        gl.glTranslatef(0,0,20);
        gl.glRotatef(-90,1,0,0);
        clips[0].draw(do_update);
      gl.glPopMatrix();
      gl.glPushMatrix();
        gl.glTranslatef(0,20,20);
        gl.glRotatef(90,1,0,0);
        gl.glRotatef(180,0,0,1);
        gl.glRotatef(-90,0,1,0);
        clips[1].draw(do_update);
      gl.glPopMatrix();
      gl.glPushMatrix();
        gl.glTranslatef(20,20,20);
        gl.glRotatef(180,0,0,1);
        gl.glRotatef(-90,1,0,0);
        clips[2].draw(do_update);
      gl.glPopMatrix();
      gl.glPushMatrix();
        gl.glTranslatef(20,0,20);
        gl.glRotatef(90,1,0,0);
        gl.glRotatef(180,0,0,1);
        gl.glRotatef(90,0,1,0);
        clips[3].draw(do_update);
      gl.glPopMatrix();
      
      gl.glPopMatrix();
  }
  cuPoint[] getPoints(){
    cuPoint[] c = new cuPoint[4*3*16];
    for(int i=0; i<4; i++){
      for(int j=0; j<3; j++){
        for(int k=0; k<16; k++){
           c[i*16*3 + j*16 + k] = (clips[i].strips[j].points[k]);
        }
      }
    }
    return c;
  }
}
  

float rot=0;
int s=20;
cuCube cubes[];

float xr=-0.9299996, yr=0.32999998, zr=1.559999;
float xt=114.0, yt=-81.0, zt=138.0;
cuPoint zp;

//ArrayList[][][] volume = new ArrayList[128][256][128];
//ArrayList[][] surface = new ArrayList[128][256];
byte[][][][] volume = new byte[128][256][128][3];
byte[][][] surface = new byte[128][256][3];

void setup(){
 
  size(640,480,OPENGL);
  frameRate(30);
  hint(ENABLE_OPENGL_4X_SMOOTH); 
  xr=yr=zr=0;

  render = (PGraphicsOpenGL) g;
  gl = render.beginGL();
  glu = ((PGraphicsOpenGL)g).glu;
  
 gl.glMatrixMode(GL.GL_MODELVIEW);
 gl.glLoadIdentity();
 
 zp = new cuPoint(1,1,1);
 cubes = new cuCube[80];
 cubes[1] = new cuCube(17.25, 0, 0, 0, 0, 80);
 cubes[2] = new cuCube(50.625, -1.5, 0, 0, 0, 55);
 cubes[3] = new cuCube(70.75, 12.375, 0, 0, 0, 55);
 cubes[4] = new cuCube(49.75, 24.375, 0, 0, 0, 48);
 cubes[5] = new cuCube(14.25, 32, 0, 0, 0, 80);
 cubes[6] = new cuCube(50.375, 44.375, 0, 0, 0, 0);
 cubes[7] = new cuCube(67.5, 64.25, 0, 27, 0, 0);
 cubes[8] = new cuCube(44, 136, 0, 0, 0, 0);
 cubes[9] = new cuCube(39, 162, 0, 0, 0, 0);
 cubes[10]= new cuCube(58, 192, 0, 0, -12, 0);
 cubes[11]= new cuCube(28, 192, 0, 0, -12, 0);
 cubes[12]= new cuCube(0, 192, 0, 0, -12, 0);
 cubes[13]= new cuCube(18.75, 162, 0, 0, 0, 0);
 cubes[14]= new cuCube(13.5, 136, 0, 0, 0, 0);
 cubes[15]= new cuCube(6.5, -8.25, 0, 0, 0, 25);
 cubes[16]= new cuCube(42, 15, 20, 0, 0, 4);
 cubes[17]= new cuCube(67, 24, 20, 0, 0, 25);
 cubes[18]= new cuCube(56, 41, 20, 0, 0, 30);
 cubes[19]= new cuCube(24, 2, 20, 0, 0, 25);
 cubes[20]= new cuCube(26, 26, 20, 0, 0, 70);
 cubes[21]= new cuCube(3.5, 10.5, 20, 0, 0, 35);
 cubes[22]= new cuCube(63, 133, 20, 0, 0, 80);
 cubes[23]= new cuCube(56, 159, 20, 0, 0, 65);
 cubes[24]= new cuCube(68, 194, 20, 350, 35, 0);
 cubes[25]= new cuCube(34, 194, 20, 340, 0, 35);
 cubes[26]= new cuCube(10, 194, 20, 340, 0, 35);
 cubes[27]= new cuCube(28, 162, 20, 0, 0, 65);
 cubes[28]= new cuCube(15.5, 134, 20, 0, 0, 20);
 cubes[29]= new cuCube(13, 29, 40, 0, 0, 0);
 cubes[30]= new cuCube(55, 15, 40, 0, 0, 50);
 cubes[31]= new cuCube(78, 9, 40, 0, 0, 60);
 cubes[32]= new cuCube(80, 39, 40, 0, 0, 80);
 cubes[33]= new cuCube(34, 134, 40, 0, 0, 50);
 cubes[34]= new cuCube(42, 177, 40, 0, 0, 0);
 cubes[35]= new cuCube(41, 202, 40, 340, 0, 80);
 cubes[36]= new cuCube(21, 178, 40, 0, 0, 35);
 cubes[37]= new cuCube(18, 32, 60, 0, 0, 65);
 cubes[38]= new cuCube(44, 20, 60, 0, 0, 20);
 cubes[39]= new cuCube(39, 149, 60, 0, 0, 15);
 cubes[40]= new cuCube(60, 186, 60, 0, 0, 45);
 cubes[41]= new cuCube(48, 213, 56, 340, 0, 25);
 cubes[42]= new cuCube(22, 52, 60, 350, 10, 15);
 cubes[43]= new cuCube(28, 198, 60, 340, 0, 20);
 cubes[44]= new cuCube(12, 178, 60, 0, 0, 50);
 cubes[45]= new cuCube(18, 156, 60, 0, 0, 40);
 cubes[46]= new cuCube(30, 135, 60, 0, 0, 45);
 cubes[47]= new cuCube(10, 42, 80, 0, 0, 17);
 cubes[48]= new cuCube(34, 23, 80, 0, 0, 45);
 cubes[49]= new cuCube(77, 28, 80, 0, 0, 45);
 cubes[50]= new cuCube(53, 22, 80, 0, 0, 45);
 cubes[51]= new cuCube(48, 175, 80, 0, 0, 45);
 cubes[52]= new cuCube(66, 192, 80, 0, 0, 355);
 cubes[53]= new cuCube(33, 202, 80, 335, 0, 85);
 cubes[54]= new cuCube(32, 176, 80, 0, 0, 20);
 cubes[55]= new cuCube(5.75, 69.5, 0, 0, 0, 80);
 cubes[56]= new cuCube(1, 53, 0, 40,70, 70);
 cubes[57]= new cuCube(-15, 24, 0, 15, 0, 0);
 cubes[60]= new cuCube(40, 164, 120, 0, 0, 12.5);
 cubes[61]= new cuCube(32, 148, 100, 0, 0, 3);
 cubes[62]= new cuCube(30, 132, 90, 10, 350, 5);
 cubes[63]= new cuCube(22,112,95, 330, 355, 0);
 cubes[64]= new cuCube(35,70,95,0,0,0);
 cubes[65]= new cuCube(38,112,98,335,0,0);
 cubes[66]= new cuCube(70,164,100,0,0,22);
 cubes[68]= new cuCube(29,94,105,345,350,350);
 cubes[69]= new cuCube(30,96,97,325,335,350);
 cubes[70]= new cuCube(38,96,95,30,0,355);
 cubes[71]= new cuCube(38,96,95,30,0,355);
 cubes[72]= new cuCube(44,20,100,0,0,345);
 cubes[73]= new cuCube(28,24,100,0,0,13);
 cubes[74]= new cuCube(8,38,100,350,0,0);
 cubes[75]= new cuCube(20,58,100,0,0,355);
 cubes[76]= new cuCube(22, 32, 120, 345, 327, 345);  
 
 zp.draw(true);
 for(int i=1; i<cubes.length; i++){
     try{cubes[i].draw(true);} catch (Exception e){};
 } 
 
//ArrayList[][][] volume = new ArrayList[90][200][100];
 /*for(int i=0; i<128; i++){
   for(int j=0; j<256; j++){
     for(int k=0; k<128; k++){
       volume[i][j][k]=new ArrayList();
     }
   }
 }
 for(int i=0; i<128; i++){
   for(int j=0; j<256; j++){
       surface[i][j]=new ArrayList();
   }
 }*/
 
//(p.x+abs(min_x))/(max_x+abs(min_x)) < x
println("x");
 println(min_x);
 println(max_x);
 
 for(int i=0; i<pointList.size(); i++){
   cuPoint p = (cuPoint)pointList.get(i);
   float fx, fy, fz;
   
   fx = (p.x + abs(min_x));
   fx/=(max_x+abs(min_x));
   fx*=127;
   
   fy = p.y + abs(min_y);
   fy/=(max_y+abs(min_y));
   fy*=255;

   fz = (p.z + abs(min_z));
   fz/=(max_z+abs(min_z));
   fz*=127;
   
   p.fx=fx;
   p.fy=fy;
   p.fz=fz;
      
   int ix = (int)fx;
   int iy = (int)fy;
   int iz = (int)fz;
   
   p.ix=ix;
   p.iy=iy;
   p.iz=iz;
   
   //these used to be valuable data structures, but it's better to do
   //the inverse -- iterate across just 17,000 points, and grab
   //from the static arrays.  however the ADDRESSES are nice.
   
   //volume[ix][iy][iz].add(p);
   //surface[iz][iy].add(p);
 }  

 matrixread_setup();
 render.endGL(); 

}  

float n=0.01;
void draw(){
 
 background(0);

 translate(width/2+xt,height/2+yt,150+zt);
 rotateX(-0.9299996+xr);
 rotateY( 0.32999998+yr);
 rotateZ( 1.559999+zr);
 
 gl.glMatrixMode(GL.GL_MODELVIEW);
 gl.glLoadIdentity();
 
 gl.glPointSize(3);
 
 render.beginGL();
 gl.glEnable(GL.GL_POINT_SMOOTH);

 
 int n=0;
 
 gl.glBegin(GL.GL_POLYGON);
    gl.glColor4f(1,1,1,0.25);
    gl.glVertex2f(0,0);
    gl.glVertex2f(0,192);
    gl.glVertex2f(82,192);
    gl.glVertex2f(82,0);
 gl.glEnd();
  
 for(int i=1; i<cubes.length; i++){
     try{cubes[i].draw(false);} catch (Exception e){};
 } 
 /*for(int i=0; i<cubes.length; i++){
    cubes[i]=new cuCube(i*16*5,0,i*5,0,0,0,0);
    cubes[i].draw();
 }*/


 matrixread_draw();
 //randomwalklovers_draw();
 render.endGL();
 rot+=10;
}

float norm(float fi){
   int ii = int(fi);
   return fi-ii;
}

float pr=1, pg=1, pb=1;
int ax=0;
void keyPressed() {
  int keyIndex = -1;
  if (key >= 'A' && key <= 'Z') {
    keyIndex = key - 'A';
  } else if (key >= 'a' && key <= 'z') {
    keyIndex = key - 'a';
  }
  if(key == 'w') { yr+=0.03; }
  if(key == 's') { yr-=0.03; }
  if(key == 'a') { xr+=0.03; }
  if(key == 'd') { xr-=0.03; }
  if(key == 'q') { zr+=0.03; }
  if(key == 'e') { zr-=0.03; }
  if(key == 'h') { xt-=3; }
  if(key == 'k') { xt+=3; }
  if(key == 'u') { yt-=3; }
  if(key == 'j') { yt+=3; }
  if(key == 'y') { zt-=3; }
  if(key == 'i') { zt+=3; }
  
  n+=0.01;
  /*for(int i=0; i<pointList.size(); i++){
    cuPoint p = (cuPoint)pointList.get(i);
    p.setColor(norm(p.x/82.0 + n), norm(p.y/192.0 + n), norm(p.z/80.0 + n));
  }*/
  
  if(key==' ') {
    randomwalklovers_draw();
//    ax = (ax+1) % 127;
//    pr=random(1); pg=random(1.0); pb=random(1.0);
//    for(int ay=0; ay<256; ay++){
//      for(int az=0; az<128; az++){
//        for(int ap=0; ap<volume[ax][ay][az].size(); ap++){
//          cuPoint p = (cuPoint)volume[ax][ay][az].get(ap);
//          p.setColor(pr,pg,pb);
//        }
//      }
//    }
  }
  
//  for(int i=0; i<cubeList.size(); i++){
//    cuPoint[] pl = (cuPoint[])cubeList.get(i);
//    println(pl.length);
//    for(int j=0; j<pl.length; j++){
//      pl[j].setColor(pr,pg,pb);   
//    }
//  }     
    
  //cuPoint p = (cuPoint)pointList.get(0);
  /*print(zp.x); print(" "); print(zp.y); print(" ");print(zp.z); print(" "); print("\n");
  cuPoint q = (cuPoint)pointList.get(1000);
  print(q.x); print(" "); print(q.y); print(" ");print(q.z); print(" "); print("\n");
  
  println(min_x);
  println(max_x);
  println(min_y);
  println(max_y);
  println(min_z);
  println(max_z);*/
  
//  print(xr); print(" "); print(yr); print(" "); print(zr); print("\n");
  print(xt); print(" "); print(yt); print(" "); print(zt); print("\n");

}

void oscEvent(OscMessage om) {
  print("### received an osc message.");
  print(" addrpattern: "+om.addrPattern());
  println(" typetag: "+om.typetag());
  oapi_oscEvent(om);
  matrixread_oscEvent(om);
}


