
void fillVolume(){
  for(int ap=0; ap<pointList.size(); ap++){
    cuPoint p = (cuPoint) pointList.get(ap);
    int r = volume[p.ix][p.iy][p.iz][0];
    int g = volume[p.ix][p.iy][p.iz][1];
    int b = volume[p.ix][p.iy][p.iz][2];
    p.setColor(r,g,b);     
  }  
}

