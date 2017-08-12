import java.lang.Math;
CMMCRandom RND;

static final int BITS = 6;
static final int W = 512;

static final int D = 1 << BITS,
                 D3 = 1 << (BITS * 3),
                 mask = D3 - 1,
                 H = D3 / W;

void settings() {
    size(W + 200, H + 200);
}

String target_filename = "point628x418b.png";
String initial_image_filename = "allrgb6-gamma69.png";
PImage target;
PImage px;
void setup() {
    background(0);
    RND = new CMMCRandom();

    // load images
    px = loadImage(initial_image_filename);
    target = loadImage(target_filename);

    px.loadPixels();
    target.loadPixels();

    int i;
    for (i = 0; i < D3; i++) target.pixels[i] = 0xcc000000 | (target.pixels[i] & 0x00FFFFFF);
    px.blend(target, 0,0,W,H,0,0,W,H,BLEND);
    for (i = 0; i < D3; i++) target.pixels[i] |= 0xFF000000;
    // shuffle
    int a,b,t;
    for (i = 0; i < (50 * D3); i++) {
        a = RND.next() & mask;
        b = RND.next() & mask;
        t = px.pixels[a];
        px.pixels[a] = px.pixels[b];
        px.pixels[b] = t;
    }
}

int RDIR7() { return (RND.next() & 7) - (RND.next() & 7) + W * ((RND.next() & 7) - (RND.next() & 7)); }
int RDIR3() { return (RND.next() & 3) - (RND.next() & 3) + W * ((RND.next() & 3) - (RND.next() & 3)); }
int RDIR1() { return (RND.next() & 1) - (RND.next() & 1) + W * ((RND.next() & 1) - (RND.next() & 1)); }

double adiff(double p[], double q[]) {
    double dr = p[0] - q[0];
    double dg = p[1] - q[1];
    double db = p[2] - q[2];
    //double dL = dr * 0.2126 + dg * 0.7152 + db * 0.0722;
    //return (0.25*dr*dr + 0.6*dg*dg + 0.15*db*db + 1.0*dL*dL) * 8;
    //return (0.25*dr*dr + 0.6*dg*dg + 0.15*db*db) * 16;
    return (dr*dr + dg*dg + db*db);
}

double cpa[] = {0,0,0};
double cpb[] = {0,0,0};
double cqa[] = {0,0,0};
double cqb[] = {0,0,0};
double energy(int a, int b) {
    //if (RND.chance(0.05)) a += RDIR1();
    //if (RND.chance(0.05)) b += RDIR1();
    //if (RND.chance(0.05)) a += RDIR3();
    //if (RND.chance(0.05)) b += RDIR3();
    a &= mask; b &= mask;
    int pa = px.pixels[a];
    cpa[0] = (pa & 0xFF0000) / 16777216.0;
    cpa[1] = (pa & 0x00FF00) / 65536.0;
    cpa[2] = (pa & 0x0000FF) / 256.0;
    int pb = px.pixels[b];
    cpb[0] = (pb & 0xFF0000) / 16777216.0;
    cpb[1] = (pb & 0x00FF00) / 65536.0;
    cpb[2] = (pb & 0x0000FF) / 256.0;
    int qa = target.pixels[a];
    cqa[0] = (qa & 0xFF0000) / 16777216.0;
    cqa[1] = (qa & 0x00FF00) / 65536.0;
    cqa[2] = (qa & 0x0000FF) / 256.0;
    int qb = target.pixels[b];
    cqb[0] = (qb & 0xFF0000) / 16777216.0;
    cqb[1] = (qb & 0x00FF00) / 65536.0;
    cqb[2] = (qb & 0x0000FF) / 256.0;

    double da = adiff(cpa,cqb) - adiff(cpa,cqa);
    double db = adiff(cpb,cqa) - adiff(cpb,cqb);
    //double da = tdiff(a,b) - tdiff(a,a);
    //double db = tdiff(b,a) - tdiff(b,b);
    return (da + db)*4;
}

static final int epoch_per_frame = 320, steps_per_epoch = 256;
double swaps_per_frame=-1, explore_pct=-1;

double T = 1.0; //0.125;
double cooling_halflife = 200*320*256; // steps
double cooling_per_epoch = Math.pow(.5, steps_per_epoch / cooling_halflife);

double leaky_bucket_halflife = 20000;
double leak_per_epoch = Math.pow(.5, steps_per_epoch / leaky_bucket_halflife);

double EE=0, swap_count=0, explore_count=0;
double fps_start_time;// = millis() / 1000.0;
int fps_start_frame;// = 0;
void draw() {
    int i,j,c,d,tmp_,r01,r02,r03;
    double P=-1, dE;
    if (frameCount == 100) {
        fps_start_time = millis() / 1000.0;
        fps_start_frame = frameCount;
    }
    loadPixels();
    px.loadPixels();
    int ix = (1 + (frameCount>>2)) % W;
    int bc = ((frameCount % 100) >> 2) == 0 ? 0xFF444444 : 0xFF000000,
        ac = 0x000000;

    for (i = 0; i < 200; i++) pixels[ix + width*(i+H)] = bc;// + (((i*400)/5000)&1)*0x181614;

    // iterate frame
    for (i = 0; i < epoch_per_frame; i++) {
        // iterate epoch
        for (j = 0; j < steps_per_epoch; j++) {
            c = RND.next() & mask;
            d = RND.next() & mask;
            dE = energy(c, d);
            EE += dE;
            P = dE < 0 ? 1.0 : Math.exp(-dE / T);
            if (RND.chance(P)) {
                tmp_ = px.pixels[c];
                px.pixels[c] = px.pixels[d];
                px.pixels[d] = tmp_;
                swap_count += 1.0;
                explore_count += (dE > 0) ? 1.0 : 0.0;
            }
        }
        // cooling
        T *= cooling_per_epoch;
        T = Math.max(T, 1.0E-12);
        // plot stats
        r01 = (RND.next() & 31) < 2 ? 1 : 0;
        r02 = (RND.next() & 31) < 4 ? 1 : 0;
        r03 = (RND.next() & 31) < 8 ? 1 : 0;
        plot(EE / 500.0, r03,r02,r01);
        plot(3 * swap_count / epoch_per_frame, r02,r03,r01);
        plot(300 * explore_count / swap_count, r01,r02|r01,r03|r02);
        // leaky bucket integrate stats
        EE *= leak_per_epoch;
        swap_count *= leak_per_epoch;
        explore_count *= leak_per_epoch;
    }

    if (frameCount % 100 == 0) {
        String fps_text = "        ";
        if (frameCount - fps_start_frame >= 500) {
            double now = millis() / 1000.0;
            double fps = (frameCount - fps_start_frame) / (now - fps_start_time);
            fps_text = "fps " + nf((float)fps, 2, 1);
            fps_start_time = now;
            fps_start_frame = frameCount;
        }
        swaps_per_frame = swap_count / epoch_per_frame;
        explore_pct = (100.0 * explore_count) / swap_count;
        println(timestamp(),
                "frame", nf(frameCount,5),
                " | swaps/f", nf((float)swaps_per_frame, 2, 3),
                " | explore/swap", nf((float)explore_pct, 2, 1)+"%",
                " | EE", nf((float)EE, 5, 3),
                " | T", nf((float)T, 1, 4),
                "   || halflife(T)", (int)cooling_halflife,
                " | halflife(leaky int.)", (int)leaky_bucket_halflife,
                fps_text);
    }
    px.updatePixels();
    c = 0;
    for (i = 0; i < 417 * width; i+=width) {
        for (j = 0; j < 628; j++) {
            pixels[i + j] = px.pixels[c] | 0xFF000000;
            c++;
        }
    }
    //for (i = 0; i < D3; i++) pixels[i] = px.pixels[i] | 0xFF000000;
    updatePixels();
    // image(px,0,0);
}

void plot(double v, int r, int g, int b) {
    setpix((frameCount>>2) % width, height - (int)(v + RND.nextDouble() - RND.nextDouble()) - 1, r, g, b);
}

void setpix(int x, int y, int r, int g, int b) {
    int idx, cc;
    if (x < 0 || x >= width || y < 0 || y >= height) return;
    idx = x + width * y;
    cc = pixels[idx];
    int rr = Math.min(0xFF, r + ((cc & 0xFF0000) >> 16));
    int gg = Math.min(0xFF, g + ((cc & 0x00FF00) >>  8));
    int bb = Math.min(0xFF, b + ((cc & 0x0000FF)      ));

    pixels[idx] = 0xFF000000 | (rr<<16) | (gg<<8) | bb;
}

String timestamp() {
  return nf(year(), 4) + "-" + nf(month(), 2) + "-" + nf(day(), 2) + "_" +nf(hour(), 2) + "." +nf(minute(), 2) + "." + nf(second(), 2);
}

void keyPressed() {
    if (keyCode == 'S' /* 83 */) {

        String now = timestamp();
        String filename = "rgb_" + now;
        String path = "/home/ritz/stack/gfx/code/rgb/";
        String json_filename = "/home/ritz/stack/gfx/code/" + filename + ".json";
        String image_filename = "/home/ritz/stack/gfx/code/" + filename + ".png";

        JSONObject params = new JSONObject();
        params.setString("timestamp", now);
        params.setString("image_filename", image_filename);
        params.setString("initial_image_filename", initial_image_filename);
        params.setString("target_filename", target_filename);
        params.setInt("frameCount", frameCount);
        params.setInt("BITS", BITS);
        params.setInt("W", W);
        params.setInt("H", H);
        params.setFloat("swaps_per_frame", (float)swaps_per_frame);
        params.setFloat("explore_pct", (float)explore_pct);
        params.setFloat("T", (float)T);

        println("=== writing", json_filename);
        println(params.format(4));
        saveJSONObject(params, json_filename);
        print("=== writing", image_filename);
        save(image_filename);
        println(" === ok");
    }
}
