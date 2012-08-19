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
  float a = om.get(0).floatValue(); println(a);
  float b = om.get(1).floatValue(); println(b);
  
}

