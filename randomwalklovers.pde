

double globalAlpha = 1.0;
Random rand = new java.util.Random(42);

void fillStrip(int stripIdx,double r, double g, double b,double a) {
  cuPoint[] pts = (cuPoint[]) cubeList.get(stripIdx);
  for (int idx=0; idx < pts.length; ++idx) {
    pts[idx].setColor((float) r,(float)g,(float)b,(float)a); 
  }
}


class StripWalker {
  int stripIdx;    // indexed in stripList
  int walkerDelta; // +1 or -1 for direction
  int mateTimeout; // how much longer to pause
  double r,g,b,a;  // color
  
  void tick() {
    int oldStripIdx = stripIdx;
     stripIdx = (stripIdx + walkerDelta + cubeList.size()) % cubeList.size(); 
     int MAX_DELTA = 3;
     for (int delta=0; delta < MAX_DELTA; ++delta) {
          int si = (stripIdx - (delta+1)*walkerDelta + cubeList.size()) % cubeList.size();
          double decay =  Math.exp(-0.3*(delta+1));          
         fillStrip(si, r*decay,g*decay,b*decay,globalAlpha);
     }   
     fillStrip(stripIdx, r,g,b,globalAlpha * 1.0); 
  }
}


int nWalkers = 10;
StripWalker[] walkers;
int animationTick = 0;


void randomwalklovers_setup() {
     walkers = new StripWalker[nWalkers];
    for (int idx=0; idx < walkers.length; ++idx) {
      walkers[idx] = new StripWalker();
      walkers[idx].stripIdx = rand.nextInt(cubeList.size());
      walkers[idx].walkerDelta = rand.nextBoolean() ? 1 : -1;
      walkers[idx].r = rand.nextDouble();
      walkers[idx].g = rand.nextDouble();
      walkers[idx].b = rand.nextDouble();
      walkers[idx].a = 1.0;
    }  
}



void randomwalklovers_draw() {  
  animationTick += 1;
//  if (animationTick % 100 == 0) {
//      int nWalkers = walkers.length;
//      nWalkers = rand.nextBoolean() ? nWalkers * 2 : nWalkers / 2;
//      initWalkers(nWalkers);
//  }
  
  if (animationTick % 200 == 0) {    
    for (int idx=0; idx < cubeList.size(); ++idx) {
      fillStrip(idx, rand.nextDouble(), rand.nextDouble(), rand.nextDouble(), 1.0);
    }
    for (int idx=0; idx < walkers.length; ++idx) {
      walkers[idx] = new StripWalker();
      walkers[idx].stripIdx = rand.nextInt(cubeList.size());
      walkers[idx].walkerDelta = rand.nextBoolean() ? 1 : -1;
      walkers[idx].r = rand.nextDouble();
      walkers[idx].g = rand.nextDouble();
      walkers[idx].b = rand.nextDouble();
      walkers[idx].a = 1.0;
    }  
  } else if (animationTick % 10 == 0) { 
    globalAlpha = 1.0;
    for (int idx=0; idx < cubeList.size(); ++idx) {
       fillStrip(idx, 0.25, 0.25, 0.25, 1); 
    }
    for (int idx=0; idx < walkers.length; ++idx) {
      walkers[idx].tick();    
    }  
  } 
}

