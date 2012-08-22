class procedural extends Generator {
 
  public String getTitle() {
    return "Procedural Pattern Generator";
  }
  
  Pattern[] patterns = {
    new StripMod(),
    new Blinders(),
    new Fire(),
    new Rain(),
    new CrossSection(),
    new CubeIterator(),
    new SpaceTime(),
    new RandomWalk("cube", 10,2),
    new RandomWalk("point", 1000,50),
    new RandomWalk("point", 100,1),
    new FillErUp("x","cube",5),
    new FillErUp("y","cube",5),
    new FillErUp("z","cube",7),
    new FillErUp("x","point",10),
    new FillErUp("y","point",10),
    new FillErUp("z","point",10),
    new SearchLight(),
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
      clips[i] = new Mod(Mod.TRI, 80000 + i*4000, 0, clipList.size()).randomBasis();
      hues[i] = new Mod(Mod.SAW, 9000 + i*3000, 0, 360).randomBasis();
    }
    addMods(clips);
    addMods(hues);
  }
   
  void draw(int deltaMs) {
    int cIdx = 0;
    for (cuPoint[] pts : clipList) {
      for (cuPoint p : pts) {
        p.setColor(0);
        color c = 0;
        for (int i = 0; i < clips.length; ++i) {
          c = blendColor(c, color(
            hues[i].value(),
            min(100, 40 + 20*abs(cIdx - clips[i].value())),
            max(0, 100 - 12*abs(cIdx - clips[i].value()))),
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


class Fire extends Pattern {
  
  class Flame {
    Mod m;
    Mod r;
    Mod b;
    float lv;

    Flame() {
      addMod(m = new Mod(Mod.SINE, random(1000, 2000), 40, 100).randomBasis());
      addMod(r = new Mod(Mod.TRI, 17000, 1000, 4000).randomBasis());
      addMod(b = new Mod(Mod.TRI, random(500, 3000), 40, 100));
      lv = m.value();
    }
    
    void go() {
      m.setPeriod(r.value());
    }
    
    float distance(cuPoint p) {
      return max(0, p.fz - m.value());
    }
  }
  
  Flame[] flames;
  final int NUM = 45;
  Mod offset = new Mod(Mod.SINE, 19000, 10, 50);
  Mod hOff = new Mod(Mod.TRI, random(9000, 13000), 0, 24).randomBasis();

    
  Fire() {
    flames = new Flame[NUM];
    for (int i = 0; i < NUM; ++i) {
      flames[i] = new Flame();
    }
    addMod(offset);
    addMod(hOff);
  }
  
  void draw(int deltaMs) {
    for (Flame f : flames) {
      f.go();
    }
    
    for (cuPoint p : pointList) {
      int idx = floor((((p.y + offset.value()) % 255) / 256.) * NUM);
      p.setColor(color(
        (355 + hOff.value()) % 360,
        max(0, 120 - p.fz),
        max(0, flames[idx].b.value() - 3*flames[idx].distance(p))
      ));
    }
  }
}

class Blinders extends Pattern {
  Mod m, r, s, h, hs;

  public Blinders() {
    addMod(m = new Mod(Mod.SINE, 9000, 0.5, 80));
    addMod(r = new Mod(Mod.TRI, 21000, 3000, 9000));
    addMod(s = new Mod(Mod.SINE, 4000, -20, 275));
    addMod(h = new Mod(Mod.SAW, 29000, 0, 360));
    addMod(hs = new Mod(Mod.TRI, 15000, 0.1, 0.5));
  }
  
  public void draw(int deltaMs) {
    m.setPeriod(r.value());
    for (cuPoint[] pts : stripList) {
      int i = 0;
      for (cuPoint p : pts) {
        p.setColor(color(
          (h.value() + p.fx + p.fz*hs.value()) % 360,
          min(100, abs(p.fy-s.value())/2.),
          max(0, 100 - m.value() * abs(i - 7.5))
        ));
        ++i;
      }
    }
  }
}


class SearchLight extends Pattern {
  //revert to the sparkle pony
  int r = 0;
  int g = 128;
  int b = 255;
  //random start
  int s = 0;
  int t = 0;
  int t1 = 0;
  int t2 = 0;

  public void draw(int deltaMs) {
    for(cuPoint p : pointList) {
      t += 1;
      t1 += 1;
      t2 += 1;
      
      //total reset sometimes
      if (t2 == 876 * 30 * 30){
         t2 = 0;
         r = floor(random(255));
         g = floor(random(255)); 
         b = floor(random(255)); 
         println("Reset");
        
         for(cuPoint p1 : pointList) {
           p1.setColor(r,g,b);
         }
      }
      if (t1 == 300){
         t1 = 0;
         r = floor(random(255));
         b = floor(random(255)); 
      }
      if (t == 30){
        g = floor(random(255));
        t = 0;
        if (r < 255){
          r += 1 ;
          b -= 1;
        }else{
          r = 0;
          b = 255;
        }
  
        p.setColor(r,g,b);
      }
    }
  }
  
}

class StripMod extends Pattern {
  
  final int NUM = 3;
  Mod m = new Mod(Mod.SINE, 9000, -0.5, NUM-0.5);
  Mod s = new Mod(Mod.SINE, 11000, -20, 147);
  Mod h = new Mod(Mod.TRI, 19000, 0, 240);
  Mod c = new Mod(Mod.TRI, 31000, -4, 2);
  
  StripMod() {
    addMod(m);
    addMod(s);
    addMod(h);
    addMod(c);
  }
  
  void draw(int deltaMs) {
    int i = 0;
    for (cuPoint[] pts : stripList) {
      for (cuPoint p : pts) {
        p.setColor(color(
          (h.value() + i*constrain(c.value(), 0, 2) + p.fx/2. + p.fy/4.) % 360,
          min(100, abs(p.fz-s.value())),
          max(0, 100 - 50*abs((i%NUM) - m.value()))
        ));
      }
      ++i;
    }
  }
}

