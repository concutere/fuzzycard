import java.util.*;

ArrayList<Point> points = new ArrayList<Point>();
ArrayList<Point> rs;
ArrayList<Point> gs;
ArrayList<Point> ws;
  
ArrayList<Point> irs;
ArrayList<Point> igs;
ArrayList<Point> iws;
 
int tick = 0;
int th = 200;

int minD = 5;
int md = 5;
boolean textPhase = false;

void setup() {
  int txtSize = 72;

  size(800, 600);
  background(0);
  frameRate(10);
  noStroke();

  PGraphics txt = createGraphics(width, height);
  PFont f = createFont("Arial Black", txtSize, true);
  textSize(txtSize);
  txt.beginDraw();
  //txt.background(0);
  txt.textFont(f, txtSize);
  txt.fill(0, 222, 0);
  txt.text("Merry ", 295, th+77);
  txt.fill(222, 0, 0);
  txt.text("Christmas", 200, th+137);
  txt.fill(246);
  txt.text("I love you", 210, th+200);
  txt.endDraw();
  //image(txt, 0, 0);
  txt.loadPixels();

  //why didn't I do this in 1 pass ???
  rs = reds(txt);
  gs = greens(txt);
  ws = whites(txt);
  
  PImage img = loadImage("image.jpg");
  img.loadPixels();
  irs = reds(img);
  igs = greens(img);
  iws = whites(img);
  sortD(irs);
  sortD(igs);
  sortD(iws);
  image(img,0,0);
  
  /*matchPts(rs, irs);
  matchPts(gs, igs);
  matchPts(ws, iws);
  */

  /*int go = 1 + fillBox(0, height/2+th, height, rs, color(222, 0, 0));
  int wo = 1 + fillBox(0, height/2+th+go, height, gs, color(0, 222, 0));
  fillBox(0, height/2+th+wo, height, ws, color(246));
  */
  
  points.addAll(rs);
  points.addAll(gs);
  points.addAll(ws);
  //print("done w/ setup");
}


void draw() {
 // print("in draw");
  saveFrame("out\\screen-####.png");
  background(0);
  loadPixels();
  if (textPhase) {
    int unstable = 0;
    for (int i = 0; i < points.size(); i++) {
      Point p = points.get(i);
      fillPt(p.x, p.y, p.c);

      int xd = (p._x - p.x);
      int yd = p._y - p.y;
  
      if (abs(xd) < minD && abs(yd) < minD) { 
        p.x = p._x;
        p.y = p._y;
      }
      else {
        unstable++;
        p.x += random(min(xd/md, -md), max(xd, md));
        if (p.x > width) p.x = width;
        else if (p.x < 0) p.x = 0;
  
        p.y += random(min(yd/md, -md), max(yd, md));
        if (p.y > height) p.y = height;
        else if (p.y < -th) p.y = 0;
      }
      fillPt(p.x, p.y, p.c);
    }
  
    if (unstable == 0) {
      //println("pausing");
      pause();
    }
  }
  else {
    //print("not in textphase");
    ArrayList<Point> tmp = new ArrayList<Point>(irs);
    tmp.addAll(igs);
    tmp.addAll(iws);
    for (int j = 0; j < tmp.size(); j++) {
      Point pt = tmp.get(j);
      fillPt(pt.x, pt.y, pt.c);
    }

//println("before remove");
    textPhase = (rs.size() >= irs.size() && gs.size() >= igs.size() && ws.size() >= iws.size());
    if (textPhase) {
      matchPtsSimple(rs, irs);
      matchPtsSimple(gs, igs);
      matchPtsSimple(ws, iws);
    }
    else {
      int factor = irs.size()/16;//irs.size()/12;
      if (irs.size() - factor > rs.size()) removeRandPts(irs, factor);
      else if (irs.size() > rs.size()) removeRandPts(irs, irs.size() - rs.size());
      factor = igs.size()/16;
      if (igs.size() - factor > gs.size()) removeRandPts(igs, factor);
      else if (igs.size() > gs.size()) removeRandPts(igs, igs.size() - gs.size());
      factor = iws.size()/16;
      if (iws.size() - factor > ws.size()) removeRandPts(iws, factor);
      else if (iws.size() > ws.size()) removeRandPts(iws, iws.size() - ws.size());
      //println("after remove");
    }
  }
  updatePixels();
}


//////////////////////////////////////////////////////////////////////////////

ArrayList<Point> removeRandPts(ArrayList<Point> pts, int howMany) {
  int hm = howMany;
  while(howMany-- > 0 && pts.size() > 0) {
    pts.remove(((pts.size())-1));

  }
  //println(pts.size() + " ? " + hm);

  return pts;
}

//todo better matching on color compare
ArrayList<Point> matchPts(ArrayList<Point> o, ArrayList<Point> n) {

  for (int i = 0; i < o.size(); i++) {
    int cd = -1;
    Point cp = null;
    
    Point po = o.get(i);
    for (int j = 0; j < n.size(); j++) {
      Point pn = n.get(j);
      //todo weight on main color?
      int diff = floor(abs(red(po.c) - red(pn.c)) +
             abs(green(po.c) - green(pn.c)));
      if (cp == null || diff < cd) {
        cd = diff;
        cp = pn;
      }
    } 
    
    if (cp != null) {
      n.remove(cp);
      po.x = cp.x;
      po.y = cp.y;
    }
  }
  
  return o;
}

ArrayList<Point> matchPtsSimple(ArrayList<Point> o, ArrayList<Point> n) {
  for (int i = 0; i < o.size(); i++) {
    Point po = o.get(i);
    if (i < n.size()) {
      Point pn = n.get(i);
      po.x = pn.x;
      po.y = pn.y;
    }
    else {
      po.x = floor(random(width));
      po.y = floor(random(height));
    } 
  }
  
  return o;
}

void fillPt(int x, int y, color c) {
  if (x < 0 || y < 0 || y*width + x >= pixels.length)
    return;
  //fill(c);
  //rect(x, y, 1, 1);
  pixels[y*width + x] = c;
}

int fillBox(int minX, int minY, int maxY, ArrayList<Point> points, color c) {
  int count = points.size();
  int x = minX;
  int y = minY;
  //fill(c);
  while (count-- > 0) {
    Point p = points.get(count);
    p.x = x;
    p.y = y;
    //p.c = c;

    fill(c);
    rect(x, y, 1, 1);
    if (x==width) {
      y++;
      x=0;
    }
    else
      x++;
  }
  return y - minY;
}

void sortD(ArrayList<Point> list) {
  Collections.sort(list, new Comparator<Point>() {
    public int compare(Point a, Point b) {
      return floor(b.d - a.d);
    }
  });
}
ArrayList<Point> reds(PImage pimg) {
  ArrayList<Point> rs = new ArrayList<Point>();
  for (int i = 0; i < pimg.pixels.length; i++) {
    Point pt = new Point(i % pimg.width, i / pimg.width);
    float r = red(pimg.pixels[i]);
    float g = green(pimg.pixels[i]);
    float b = blue(pimg.pixels[i]);
    pt.c = pimg.pixels[i];
    if (r > g && r > b) {
      rs.add(pt);
      pt.d = pow(r,2) - pow(g, 2) - pow(b,2);
    }
  }
  return rs;
}

ArrayList<Point> greens(PImage pimg) {
  ArrayList<Point> gs = new ArrayList<Point>();
  for (int i = 0; i < pimg.pixels.length; i++) {
    Point pt = new Point(i % pimg.width, i / pimg.width);
    float r = red(pimg.pixels[i]);
    float g = green(pimg.pixels[i]);
    float b = blue(pimg.pixels[i]);
    pt.c = pimg.pixels[i];
    if (g > r && g > b) {
      gs.add(pt);
      pt.d = pow(g,2) - pow(r,2) - pow(b,2);
    }
  }
  return gs;
}

ArrayList<Point> whites(PImage pimg) {
  ArrayList<Point> ws = new ArrayList<Point>();
  for (int i = 0; i < pimg.pixels.length; i++) {
    Point pt = new Point(i % pimg.width, i / pimg.width);
    float r = red(pimg.pixels[i]);
    float g = green(pimg.pixels[i]);
    float b = blue(pimg.pixels[i]);
    pt.c = pimg.pixels[i];
    if (r > 0 && abs(r - g) < 2 || (b > r && b > g)) {
      ws.add(pt);
      pt.d = pow(abs(b-r),2) + pow(abs(r-g),2) + pow(abs(b-g), 2);
    }
  }
  return ws;
}

class Point {
  public Point(int x, int y) {
    this.x = this._x = x;
    this.y = this._y = y;
  }

  public int x;
  public int y;
  public int _x;
  public int _y;
  public color c;
  private float d;
}

