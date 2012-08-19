

Random rand = new java.util.Random(42);
List walkerStripes = new ArrayList();

void randomwalklovers_setup() {
  
  
}


void randomwalklovers_tick() {
   ax = (ax+1) % 127;
    pr=random(1); pg=random(1.0); pb=random(1.0);
    for(int ay=0; ay<256; ay++){
      for(int az=0; az<128; az++){
        for(int ap=0; ap<volume[ax][ay][az].size(); ap++){
          cuPoint p = (cuPoint)volume[ax][ay][az].get(ap);
          p.setColor(pr,pg,pb);
        }
      }
    } 
}
