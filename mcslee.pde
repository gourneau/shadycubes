class mcslee {
  int lastMillis;  
  float hVal;
  float pos;
  float falloff;
  float rate;
  float sat;
  
  mcslee() {
    lastMillis = millis();
    colorMode(HSB, 360, 100, 100, 100);
    rate = 0;
    hVal = 0;
    pos = 0;
    falloff = 0;
    sat = 0;
  }
  
  void draw() {
    int now = millis();
    int elapsed = now - lastMillis;
    rate += elapsed * 0.0005;
    float rVal = .001 + .004 * (0.5 + 0.5*sin(rate));
    
    sat += elapsed * 0.00004;
    float sVal1 = stripList.size() * (0.5 + 0.5*sin(sat));
    float sVal2 = stripList.size() * (0.5 + 0.5*cos(sat));
    
    hVal = (hVal + elapsed*.003) % 360;
    pos += elapsed * rVal;
    falloff += elapsed * 0.002;
    
    float pVal = 7.5 + 7.5*sin(pos);
    float fVal = 10 + 60*(0.5 + 0.5*sin(falloff));

    int s = 0;
    for (cuPoint[] pArr : stripList) {
      for (int i = 0; i < pArr.length; ++i) {
        pArr[i].setColor(color(
            (hVal + s*.2 + i*3) % 360,
            // min(100, 40 + abs(i - (pArr.length-1)/2.) * 18),
            min(100, min(abs(s - sVal1), abs(s - sVal2))),
            max(0, 100 - fVal*abs(i - pVal))
        ));        
      }
      ++s;
    }
    
    lastMillis = now;
  }
  
}

mcslee m;

void mcslee_setup() {
  m = new mcslee();
}

void mcslee_draw() {
  m.draw();
}

