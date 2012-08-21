
    
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
           if (walkerType == "point") {
              this.elems = new java.util.ArrayList();
              for (cuPoint p: pointList) {
                this.elems.add(new cuPoint[]{p});
              } 
           }
           walkers = new Walker[nWalkers];
           for (int idx=0; idx < walkers.length; ++idx) {
            walkers[idx] = new Walker();
            walkerInit(walkers[idx],true);
          }  
       }
    
                                        
        float interp(float r, float decay) {
          return decay*r + (1.0-decay)*0.0; 
        }
    
        class Walker {
          int idx;    // indexed in stripList
          int walkerDelta; // +1 or -1 for direction
          int mateTimeout; // how much longer to pause
          float r,g,b,a;  // color
          double tailDecay = 0.9;
            
          void tick(boolean animateHead) {
            if (animateHead) {
               //int oldIdx = idx;
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
             colorPoints((cuPoint[])elems.get(idx), 0.1, 0.1, 0.1, 1); 
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
  Map bucketToElems;
  int levelIdx;
  java.util.List colorRGBs;
  String axis; // x,y, or z
  String walkerType; // cube, strip, point
  int numBuckets;
  
  float getValue(Object o) {
       if (walkerType == "cube") {
         cuCube c = (cuCube) o;
         if (axis == "x") return c.x;
         if (axis == "y") return c.y;
         if (axis == "z") return c.z;
         throw new RuntimeException("not a valid axis: " + axis);       
       }
       if (walkerType == "point") {
         cuPoint p = (cuPoint) o;
         if (axis == "x") return p.x;
         if (axis == "y") return p.y;
         if (axis == "z") return p.z;
         throw new RuntimeException("not a valid axis: " + axis);       
       }
       
       throw new RuntimeException("not a valid walker: " + walkerType);       
  }

  FillErUp(String axis, String walkerType, int numBuckets) {
    this.axis = axis;
    this.walkerType = walkerType;
    this.numBuckets = numBuckets;
    bucketToElems = new HashMap();
    java.util.List elemsByAxis = new ArrayList();
    if (walkerType == "cube") {
      for (int idx=0; idx < cubes.length; ++idx) {
         if (cubes[idx] != null) elemsByAxis.add(cubes[idx]); 
      }      
    }
    if (walkerType == "point") {
      for (int idx=0; idx < pointList.size(); ++idx) {
         elemsByAxis.add(pointList.get(idx)); 
      }      
    }
    
    
    java.util.Collections.sort(elemsByAxis, new Comparator() {
      int compare(Object o1, Object o2) {
        return (int) (getValue(o1) - getValue(o2));
      }
    });
    Object minElem = elemsByAxis.get(0);
    Object maxElem = elemsByAxis.get(elemsByAxis.size()-1);    
    double range = Math.abs(getValue(minElem)-getValue(maxElem));
    double bucketSize = range / (double) numBuckets;
    for (int idx=0; idx < elemsByAxis.size(); ++idx) {
      Object o = elemsByAxis.get(idx);
      int bucketIdx = (int) Math.round((getValue(o) - getValue(minElem)) / bucketSize);
      java.util.List levelBuckets = (java.util.List) bucketToElems.get(bucketIdx);
      if (levelBuckets == null) {
        levelBuckets = new ArrayList();
        bucketToElems.put(bucketIdx, levelBuckets);
      }
      levelBuckets.add(o);
    }
    levelIdx = numBuckets ;
    
  }

  void draw(int deltaMS) {
      animationTick += 1;
      if (animationTick % 5 == 0) {
           levelIdx = (levelIdx - 1 + numBuckets) % numBuckets;
           if (levelIdx == (numBuckets-1)) {
               colorRGBs = new java.util.ArrayList();
               for (int idx=0; idx < numBuckets; ++idx) {
                 float r = rand.nextFloat();
                 float g = rand.nextFloat();
                 float b = rand.nextFloat();
                 colorRGBs.add(new float[]{r,g,b});                   
               }
           }
           java.util.List cs =(java.util.List) bucketToElems.get(levelIdx);
           if (cs != null) {
             for (Object o: cs) {
               float[] rgb = (float[])colorRGBs.get(levelIdx);
               if (walkerType == "cube") {
                 cuCube c = (cuCube) o;               
                 colorPoints(c.getPoints(),rgb[0],rgb[1],rgb[2],1.0);                 
               }
               if (walkerType == "point") {
                 colorPoints(new cuPoint[]{(cuPoint)o},rgb[0],rgb[1],rgb[2],1.0);                 
               }
              
             }             
           }
      }
  }
}  
