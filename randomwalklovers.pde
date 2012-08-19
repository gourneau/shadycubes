

Random rand = new java.util.Random(42);
List walkerStripes = new ArrayList();

int curStripeIdx;

void randomwalklovers_setup() {
  
    for (int ax=0; ax < 128; ++ax) {
      for(int ay=0; ay<256; ay++){
        for(int az=0; az<128; az++){
          for(int ap=0; ap<volume[ax][ay][az].size(); ap++){
            cuPoint p = (cuPoint)volume[ax][ay][az].get(ap);
            p.setColor(1,1,1);
          }
        }
      } 
   }
   curStripeIdx = rand.nextInt(stripList.size());
}

void fillStrip(cuPoint[] pts,float r, float g, float b,float a) {
  for (int idx=0; idx < pts.length; ++idx) {
    pts[idx].setColor(r,g,b); 
  }
}


void randomwalklovers_tick() {  
  fillStrip(stripList.get(curStripeIdx), 1, 1,1,1);  
  curStripeIdx = (curStripeIdx + 1) % stripList.size();
  fillStrip(stripList.get(curStripeIdx), 1, 1,1,1);
  cuPoint[] curStripe = (cuPoint[]) stripList.get(curStripeIdx);  
}

