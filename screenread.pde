import java.awt.image.BufferedImage;
import java.awt.*;

class screenread extends Generator {
  PImage screenShot;
  ArrayList<PImage> screenLog;

  public String getTitle() {
    return "Screenread Generator";
  }
  
  screenread(){
    screenLog = new ArrayList<PImage>();  
    for(int i=0; i<32; i++){
      screenLog.add(new PImage(256, 128));
    }
  }
  
  void vol_screenread_draw(){
    screenShot = getScreen(15,15,256,128);
    screenLog.remove(31);
    screenLog.add(0, screenShot);
    for(int ap=0; ap<pointList.size(); ap++){
      cuPoint p = (cuPoint) pointList.get(ap);
      PImage shot = (PImage) screenLog.get(p.ix/4);
      int pixelColor = shot.get(256-p.iy, 128-p.iz);
      int r = (pixelColor >> 16) & 0xff;
      int g = (pixelColor >> 8) & 0xff;
      int b = pixelColor & 0xff;
      p.setColor(r,g,b);     
    }
  }
  
  public void run(int deltaMs) {
    screenShot = getScreen(165,263,256,128);
    //screenLog.remove(31);
    //screenLog.add(0, screenShot);
    for(cuPoint p : pointList) {
      //PImage shot = (PImage) screenLog.get(p.ix/4);
      int pixelColor = screenShot.get(256-p.iy, 128-p.iz);
      int r = (pixelColor >> 16) & 0xff;
      int g = (pixelColor >> 8) & 0xff;
      int b = pixelColor & 0xff;
      p.setColor(r,g,b);     
    }
  }
  
  PImage getScreen(int x, int y, int w, int h) {
    GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
    GraphicsDevice[] gs = ge.getScreenDevices();
    DisplayMode mode = gs[0].getDisplayMode();
    Rectangle bounds = new Rectangle(x, y, w, h);
    BufferedImage desktop = new BufferedImage(w, w, BufferedImage.TYPE_INT_RGB);
  
    try {
      desktop = new Robot(gs[0]).createScreenCapture(bounds);
    }
    catch(AWTException e) {
      System.err.println("Screen capture failed.");
    }
    return (new PImage(desktop));
  }
}
