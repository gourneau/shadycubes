class procedural extends Generator {
 
  public String getTitle() {
    return "Procedural Pattern Generator";
  }
  
  Pattern[] patterns = {
    new Rain(),
    new CrossSection(),
    new CubeIterator(),
    new SpaceTime(),
  };
  
  int activePattern = 0;
  
  procedural() {
    colorMode(HSB, 360, 100, 100, 100);
  }
  
  void goNext() {
    activePattern = (activePattern+1) % patterns.length;
  }
  
  void goPrev() {
    --activePattern;
    if (activePattern < 0) {
      activePattern = patterns.length - 1;
    }
  }
  
  void run(int deltaMs) {
    patterns[activePattern].run(deltaMs);
  }
}

class Mod {
  
  final static int SINE = 1;
  final static int COSINE = 2;
  final static int TRI = 3;
  final static int SAW = 4;

  private float basis = 0;
  private float mn;
  private float mx;
  private float mid;
  private float rate;
  private int tp;
  private float value;
  
  Mod(int type, float period, float minVal, float maxVal) {
    tp = type;
    mn = minVal;
    mx = maxVal;
    mid = (mn + mx) / 2.;
    setPeriod(period);
    value = 0;
  }
  
  Mod randomBasis() {
    basis = random(0, TWO_PI);
    return this;
  }
  
  Mod setPeriod(float period) {
    rate = TWO_PI / period;
    return this;
  }
  
  Mod advance(int deltaMs) {
    basis = (basis + deltaMs * rate) % TWO_PI;
    value = computeValue();
    return this;
  }
  
  public float value() {
    return value;
  }
  
  private float computeValue() {
    switch (tp) {
      case SINE:
        return mid + (mx-mid) * sin(basis);
      case COSINE:
        return mid + (mx-mid) * cos(basis);
      case TRI:
        if (basis < HALF_PI) {
          return mid + (mx-mid) * (basis / HALF_PI);
        } else if (basis < PI + HALF_PI) {
          return mx - (mx-mid) * ((basis - HALF_PI) / HALF_PI);
        } else {
          return mn + (mx-mid) * ((basis - PI - HALF_PI) / HALF_PI);
        }
       case SAW:
         return mn + (mx-mn) * (basis / TWO_PI);
    }
    return 0;
  }
    
}

abstract class Pattern {

  private ArrayList<Mod> mods = new ArrayList<Mod>();
  
  protected final Mod addMod(Mod m) {
    mods.add(m);
    return m;
  }
  
  protected final void addMods(Mod[] ms) {
    for (Mod m : ms) {
      mods.add(m);
    }
  }
  
  public final void run(int deltaMs) {
    for (Mod m : mods) {
      m.advance(deltaMs);
    }
    draw(deltaMs);
  }

  abstract void draw(int deltaMs);
}

class SpaceTime extends Pattern {
  float sat = 0;
  Mod pos = new Mod(Mod.SINE, 3000, 0, 15);
  Mod rate = new Mod(Mod.SINE, 13000, 1000, 9000);
  Mod falloff = new Mod(Mod.SINE, 5000, 10, 70);
  Mod hBase = new Mod(Mod.SAW, 11000, 0, 360);
  
  SpaceTime() {
    addMods(new Mod[] {
      pos, rate, falloff, hBase
    });
  }
  
  void draw(int deltaMs) {
    pos.setPeriod(rate.value());
        
    sat += deltaMs * 0.00004;
    float sVal1 = stripList.size() * (0.5 + 0.5*sin(sat));
    float sVal2 = stripList.size() * (0.5 + 0.5*cos(sat));
    
    float hVal = hBase.value();    
    float pVal = pos.value();
    float fVal = falloff.value();

    int s = 0;
    for (cuPoint[] pArr : stripList) {
      for (int i = 0; i < pArr.length; ++i) {
        pArr[i].setColor(color(
            (hVal + s*.2 + i*3) % 360,
            min(100, min(abs(s - sVal1), abs(s - sVal2))),
            max(0, 100 - fVal*abs(i - pVal))
        ));        
      }
      ++s;
    }
  }
}

class CubeIterator extends Pattern {
  
  Mod[] clips;
  Mod[] hues;
  
  CubeIterator() {
    int NUM = 5;
    clips = new Mod[NUM];
    hues = new Mod[NUM];
    for (int i = 0; i < NUM; ++i) {
      clips[i] = new Mod(Mod.TRI, 30000 + i*4000, 0, cubeList.size()).randomBasis();
      hues[i] = new Mod(Mod.SAW, 9000 + i*3000, 0, 360).randomBasis();
    }
    addMods(clips);
    addMods(hues);
  }
   
  void draw(int deltaMs) {
    int cIdx = 0;
    for (cuPoint[] pts : cubeList) {
      for (cuPoint p : pts) {
        p.setColor(0);
        color c = 0;
        for (int i = 0; i < clips.length; ++i) {
          c = blendColor(c, color(
            hues[i].value(),
            min(100, 40 + 20*abs(cIdx - clips[i].value())),
            max(0, 100 - 15*abs(cIdx - clips[i].value()))),
            ADD);
        }
        p.setColor(c);
      }
      ++cIdx;
    }
  }
}

class CrossSection extends Pattern {
  
  Mod y = new Mod(Mod.SINE, 5000, 0, 255);
  Mod z = new Mod(Mod.SINE, 6000, 0, 127);
  Mod x = new Mod(Mod.SINE, 7000, 0, 127);
  Mod h = new Mod(Mod.SAW, 9000, 0, 360);
  
  CrossSection() {
    addMod(x);
    addMod(y);
    addMod(z);
    addMod(h);
  }
  
  void draw(int deltaMs) {
    for (cuPoint p : pointList) {
      color c = 0;
      c = blendColor(c, color(
        (h.value() + p.fy/10 + p.fz/3) % 360,
        constrain(140 - 1.1*abs(p.fy - 127), 0, 100),
        max(0, 100 - 4*abs(p.fy - y.value()))
        ), ADD);
      c = blendColor(c, color(
        (h.value() + 80 + p.fz/10) % 360,
        constrain(140 - 2.2*abs(p.fz - 64), 0, 100),
        max(0, 100 - 8*abs(p.fz - z.value()))
        ), ADD); 
      c = blendColor(c, color(
        (h.value() + 160 + p.fx / 10 + p.fz/2) % 360,
        constrain(140 - 2.2*abs(p.fx - 64), 0, 100),
        max(0, 100 - 8*abs(p.fx - x.value()))
        ), ADD); 
      p.setColor(c);
    }
  }
}

class Rain extends Pattern {
  
  class Drop {
    Mod m;
    float lv;
    
    Drop() {
      addMod(m = new Mod(Mod.SAW, random(1000, 2000), 200, -50).randomBasis());
      lv = m.value();
    }
    
    void go() {
      if (m.value() > lv) {
        m.setPeriod(random(masterRate.value() - 200, masterRate.value() + 1400));
      }
      lv = m.value();
    }
    
    float distance(cuPoint p) {
      return abs(p.fz - m.value());
    }
  }
  
  Drop[] drops;
  final int NUM = 45;
  Mod offset = new Mod(Mod.SINE, 19000, 10, 50);
  Mod masterRate = new Mod(Mod.TRI, 21000, 1000, 4000);
    
  Rain() {
    drops = new Drop[NUM];
    for (int i = 0; i < NUM; ++i) {
      drops[i] = new Drop();
    }
    addMod(offset);
    addMod(masterRate);
  }
  
  void draw(int deltaMs) {
    for (Drop d : drops) {
      d.go();
    }
    
    for (cuPoint p : pointList) {
      int idx = floor((((p.y + offset.value()) % 255) / 256.) * NUM);
      p.setColor(color(
        220,
        max(0, 120 - p.fz),
        max(0, 100 - 3*drops[idx].distance(p))
      ));
    }
  }
}

