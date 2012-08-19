

Random rand = new java.util.Random(42);
List walkerStripes = new ArrayList();

cuStrip curStripe;

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
}


void randomwalklovers_tick() {
  
  cuPoint[] pts = (cuPoint[]) stripList.get(rand.nextInt(stripList.size()));  
  for (int idx=0; idx < pts.length; ++idx) {
    pts[idx].setColor(0,0,0); 
  }
//   ax = (ax+1) % 127;
//    pr=random(1); pg=random(1.0); pb=random(1.0);

}
