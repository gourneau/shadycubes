
    
    class RandomWalk extends Pattern {

        Walker[] walkers;
        String walkerType;
        int animationTick = 0;
        int tailLength;
        java.util.List elems;
                
        float globalAlpha = 1.0;
        Random rand = new java.util.Random(42);

        public String getTitle() {
           return "Random Walkers " + walkerType + "(" + walkers.length + ")"; 
        }

        RandomWalk(String walkerType, int nWalkers, int tailLength) {           
           this.walkerType = walkerType;
           this.elems = null;
           this.tailLength = tailLength;
           if (walkerType == "cube") {
             this.elems  = cubeList;
           }
           if (walkerType == "strip") {
               this.elems  = stripList;
           }
           walkers = new Walker[nWalkers];
           for (int idx=0; idx < walkers.length; ++idx) {
            walkers[idx] = new Walker();
            walkerInit(walkers[idx],true);
          }  
       }
    
                                        
        float interp(float r, float decay) {
          return decay*r + (1.0-decay)*0.5; 
        }
    
        class Walker {
          int idx;    // indexed in stripList
          int walkerDelta; // +1 or -1 for direction
          int mateTimeout; // how much longer to pause
          float r,g,b,a;  // color
          double tailDecay = 0.9;
            
          void tick(boolean animateHead) {
            if (animateHead) {
               int oldIdx = idx;
               idx = (idx + walkerDelta + elems.size()) % elems.size(); 
               colorPoints((cuPoint[])elems.get(idx), r,g,b,globalAlpha * 1.0f); 
               tailDecay = 0.7;  
            }
             int MAX_DELTA = 2;
             for (int delta=0; delta < tailLength; ++delta) {
                  int si = (idx - (delta+1)*walkerDelta + elems.size()) % elems.size();
                  float decay = (float) Math.exp(-0.3*(delta+1));
                 colorPoints((cuPoint[])elems.get(si), interp(r,decay),interp(g,decay),interp(b,decay),globalAlpha);
             }   
             tailDecay *= 0.9;            
          }
        }
    
    
        void walkerInit(Walker w, boolean genPosition) {
              if (genPosition) {
                w.idx = rand.nextInt(elems.size());
                w.walkerDelta = rand.nextBoolean() ? 1 : -1;            
              }
              w.r = rand.nextFloat();
              w.g = rand.nextFloat();
              w.b = rand.nextFloat();
              w.a = 1.0;
        }
                   
         
       void draw(int deltaMS) {
         animationTick += 1;
         if (animationTick % 200 == 0) {    
            for (int idx=0; idx < walkers.length; ++idx) {              
              walkerInit(walkers[idx],false);
            }  
         }  
        if (animationTick % 5 == 0) { 
          globalAlpha = 1.0;
          for (int idx=0; idx < cubeList.size(); ++idx) {
             colorPoints((cuPoint[])elems.get(idx), 0.25, 0.25, 0.25, 1); 
          }
          for (int idx=0; idx < walkers.length; ++idx) {
            walkers[idx].tick(true);    
          }  
        }
       }
   }

   
class FillErUp extends Pattern {
  int animationTick = 0;
  java.util.Random rand = new java.util.Random(0);
  Map zBucektToCubes;
  int levelIdx;
  java.util.List colorRGBs;

  FillErUp() {
    zBucektToCubes = new HashMap();
    java.util.List cubesByZ = new ArrayList();
    for (int idx=0; idx < cubes.length; ++idx) {
       if (cubes[idx] != null) cubesByZ.add(cubes[idx]); 
    }
    java.util.Collections.sort(cubesByZ, new Comparator() {
      int compare(Object o1, Object o2) {
        cuCube c1 = (cuCube) o1;
        cuCube c2 = (cuCube) o2;
        return (int) (c1.z - c2.z);
      }
    });
    cuCube minCube = (cuCube) cubesByZ.get(0);
    cuCube maxCube = (cuCube) cubesByZ.get(cubesByZ.size()-1);    
    double range = Math.abs(minCube.z-maxCube.z);
    double bucketSize = range / 7.0;
    for (int idx=0; idx < cubesByZ.size(); ++idx) {
      cuCube c = (cuCube) cubesByZ.get(idx);
      int bucketIdx = (int) Math.round((c.z - minCube.z) / bucketSize);
      java.util.List levelBuckets = (java.util.List) zBucektToCubes.get(bucketIdx);
      if (levelBuckets == null) {
        levelBuckets = new ArrayList();
        zBucektToCubes.put(bucketIdx, levelBuckets);
      }
      levelBuckets.add(c);
    }
    levelIdx = 8;
    println("zBucketsToCubes: " + zBucektToCubes.toString());
  }

  void draw(int deltaMS) {
      animationTick += 1;
      if (animationTick % 5 == 0) {
           levelIdx = (levelIdx - 1 + 8) % 8;
           if (levelIdx == 7) {
               colorRGBs = new java.util.ArrayList();
               for (int idx=0; idx < 8; ++idx) {
                 float r = rand.nextFloat();
                 float g = rand.nextFloat();
                 float b = rand.nextFloat();
                 colorRGBs.add(new float[]{r,g,b});                   
               }
           }
           java.util.List cs =(java.util.List) zBucektToCubes.get(levelIdx);
           if (cs != null) {
             for (Object o: cs) {
               cuCube c = (cuCube) o;
               float[] rgb = (float[])colorRGBs.get(levelIdx);
               colorPoints(c.getPoints(),rgb[0],rgb[1],rgb[2],1.0);
             }             
           }
      }
  }
}  
