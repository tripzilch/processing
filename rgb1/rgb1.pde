import java.lang.Math;
int px[];
CMMCRandom RND;

static final int BITS = 6;
static final int W = 512;

static final int D = 1 << BITS,
                 D3 = 1 << (BITS * 3),
                 mask = D3 - 1,
                 H = D3 / W;

void settings() {
    size(W, H + 200);
}

String target_filename = "target2mm.png";
PImage target;
void setup() {
    background(0);
    px = new int[W*H];
    RND = new CMMCRandom();

    // init
    int i = 0;
    for (int b = 0; b < D; b++) {
        for (int r = 0; r < D; r++) {
            for (int g = 0; g < D; g++) {
                px[i++] = r << 16 | g << 8 | b;
            }
        }
    }

    // shuffle
    int a,b,t;
    for (i = 0; i < (50 * D3); i++) {
        a = RND.next() & mask;
        b = RND.next() & mask;
        t = px[a];
        px[a] = px[b];
        px[b] = t;
    }
    loadPixels();
    for (i = 0; i < D3; i++) pixels[i] = (px[i]<<2) | 0xFF000000;
    updatePixels();
    save("allrgb6.png");

    // target
    target = loadImage(target_filename);
    target.loadPixels();
}

int RDIR() { return (RND.next() & 7) - (RND.next() & 7) + W * ((RND.next() & 7) - (RND.next() & 7)); }

double tdiff(int a, int b) {
    int x = px[a & mask] << 2;
    int t = target.pixels[b & mask] & 0x00FFFFFF;
    double dr = (((x & 0xFF0000) >> 16) - ((t & 0xFF0000) >> 16)) / 256.0;
    double dg = (((x & 0x00FF00) >>  8) - ((t & 0x00FF00) >>  8)) / 256.0;
    double db = (((x & 0x0000FF)      ) - ((t & 0x0000FF)      )) / 256.0;
    double dL = dr * 0.2126 + dg * 0.7152 + db * 0.0722;
    return (0.25*dr*dr + 0.6*dg*dg + 0.15*db*db + 1.0*dL*dL) * 8;
}

double adiff(double p[], double q[]) {
    double dr = p[0] - q[0];
    double dg = p[1] - q[1];
    double db = p[2] - q[2];
    double dL = dr * 0.2126 + dg * 0.7152 + db * 0.0722;
    return (0.25*dr*dr + 0.6*dg*dg + 0.15*db*db + 1.0*dL*dL) * 8;
}

double energy(int a, int b) {
    //a &= mask; b &= mask;
    //int pa = px[a] << 2;
    //double cpa[] = {(pa & 0xFF0000) / 16777216.0, (pa & 0x00FF00) / 65536.0, (pa & 0x0000FF) / 256.0};
    //int pb = px[b] << 2;
    //double cpb[] = {(pb & 0xFF0000) / 16777216.0, (pb & 0x00FF00) / 65536.0, (pb & 0x0000FF) / 256.0};
    //int qa = target.pixels[a];
    //double cqa[] = {(qa & 0xFF0000) / 16777216.0, (qa & 0x00FF00) / 65536.0, (qa & 0x0000FF) / 256.0};
    //int qb = target.pixels[b];
    //double cqb[] = {(qb & 0xFF0000) / 16777216.0, (qb & 0x00FF00) / 65536.0, (qb & 0x0000FF) / 256.0};

    //double da = adiff(cpa,cqb) - adiff(cpa,cqa);
    //double db = adiff(cpb,cqa) - adiff(cpb,cqb);
    double da = tdiff(a,b) - tdiff(a,a);
    double db = tdiff(b,a) - tdiff(b,b);
    return da + db;
}

static final int epoch_per_frame = 320, steps_per_epoch = 256;
double swaps_per_frame=-1, explore_pct=-1;

double T = 1.0;
double cooling_halflife = 200*320*256; // steps
double cooling_per_epoch = Math.pow(.5, steps_per_epoch / cooling_halflife);

double leaky_bucket_halflife = 20000;
double leak_per_epoch = Math.pow(.5, steps_per_epoch / leaky_bucket_halflife);

double EE=0, swap_count=0, explore_count=0;

void draw() {
    int i,j,c,d,tmp_,r01,r02,r03;
    double P=-1, dE;
    loadPixels();
    int ix = (1 + (frameCount>>2)) % W;
    int bc = ((frameCount % 100) >> 2) == 0 ? 0xFF444444 : 0xFF000000,
        ac = 0x000000;

    for (i = 0; i < 200; i++) pixels[ix + W*(i+H)] = bc;// + (((i*400)/5000)&1)*0x181614;

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
                tmp_ = px[c];
                px[c] = px[d];
                px[d] = tmp_;
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
        plot(EE / 800.0, r03,r02,r01);
        plot(3 * swap_count / epoch_per_frame, r02,r03,r01);
        plot(300 * explore_count / swap_count, r01,r02|r01,r03|r02);
        // leaky bucket integrate stats
        EE *= leak_per_epoch;
        swap_count *= leak_per_epoch;
        explore_count *= leak_per_epoch;
    }
    if (frameCount % 100 == 0) {
        swaps_per_frame = swap_count / epoch_per_frame;
        explore_pct = (100.0 * explore_count) / swap_count;
        println(timestamp(),
                " | frame", nf(frameCount,5),
                " | swaps/f", nf((float)swaps_per_frame, 2, 3),
                " | explore/swap", nf((float)explore_pct, 2, 1)+"%",
                " | EE", nf((float)EE, 5, 3),
                " | T", nf((float)T, 1, 4),
                "   || halflife(T)", (int)cooling_halflife,
                " | halflife(leaky int.)", (int)leaky_bucket_halflife);
    }
    for (i = 0; i < D3; i++) pixels[i] = (px[i]<<2) | 0xFF000000;
    updatePixels();

}

void plot(double v, int r, int g, int b) {
    setpix((frameCount>>2) % W, height - (int)(v + RND.nextDouble() - RND.nextDouble()) - 1, r, g, b);
}

void setpix(int x, int y, int r, int g, int b) {
    int idx, cc;
    if (x < 0 || x >= width || y < 0 || y >= height) return;
    idx = x + W * y;
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
