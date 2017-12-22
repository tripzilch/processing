
int debugnum = 25;

void pixaa(double x, double y, double k, int chan) {
  int xi = (int) x, yi = (int) y;
  if (x >= 0 && x < width - 1 && y >= 0 && y < height - 1) {
    double p;
    int idx = yi * width + xi;
    int chan8 = chan * 8;
    int mask = 0xFF << chan8;
    int mask1 = mask & 0x010101;
    double k255 = k * 255;

    double xf = x % 1.0, yf = y % 1.0;
    double xg = 1.0 - xf, yg = 1.0 - yf;
    p = Math.min(255.0, (k255 * xg * yg) + ((pixels[idx] & mask) >> chan8));
    pixels[idx] = (pixels[idx] & (~mask)) | (((int) p) * mask1) | 0xFF000000;
    idx++;
    p = Math.min(255.0, (k255 * xf * yg) + ((pixels[idx] & mask) >> chan8));
    pixels[idx] = (pixels[idx] & (~mask)) | (((int) p) * mask1) | 0xFF000000;
    idx += width - 1;
    p = Math.min(255.0, (k255 * xf * yf) + ((pixels[idx] & mask) >> chan8));
    pixels[idx] = (pixels[idx] & (~mask)) | (((int) p) * mask1) | 0xFF000000;
    idx++;
    p = Math.min(255.0, (k255 * xg * yf) + ((pixels[idx] & mask) >> chan8));
    pixels[idx] = (pixels[idx] & (~mask)) | (((int) p) * mask1) | 0xFF000000;    
  } 
}

double getpixaa(double x, double y, int chan) {
  int xi = (int) x, yi = (int) y;
  if (x >= 0 && x < width - 1 && y >= 0 && y < height - 1) {
    double a = 0;
    int idx = yi * width + xi;
    int chan8 = chan * 8;
    int mask = 0xFF << chan8;

    double xf = x % 1.0, yf = y % 1.0;
    double xg = 1.0 - xf, yg = 1.0 - yf;
    a +=  xg * yg * ((pixels[idx] & mask) >> chan8);
    idx++;
    a +=  xf * yg * ((pixels[idx] & mask) >> chan8);
    idx += width - 1;
    a +=  xf * yf * ((pixels[idx] & mask) >> chan8);
    idx++;
    a +=  xg * yf * ((pixels[idx] & mask) >> chan8);
    return a / 255.0;
  } else { 
    return 0.0; 
  }
}

//    (1 - xf) * (1 - yf) == 1 - yf - xf + xfyf
//         xf  * (1 - yf) ==          xf - xfyf
//         xf  *      yf  ==               xfyf
//    (1 - xf) *      yf  ==     yf      - xfyf
