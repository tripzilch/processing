


void pixaa(double x, double y, double k) {
  int xi = (int) x, yi = (int) y;
  if (xi >= 0 && xi < width - 1 && yi >= 0 && yi < height - 1) {
    int idx = yi * width + xi;
    double k255 = k * 255;

    double xf = x % 1, yf = y % 1;
    double xg = 1 - xf, yg = 1 - yf;

    pixels[idx] = (Math.min(0xFF, (pixels[idx] & 0xFF) + (int) (k255 * xg * yg)) * 0x010101) | 0xFF000000;
    idx++;
    pixels[idx] = (Math.min(0xFF, (pixels[idx] & 0xFF) + (int) (k255 * xf * yg)) * 0x010101) | 0xFF000000;
    idx += width - 1;
    pixels[idx] = (Math.min(0xFF, (pixels[idx] & 0xFF) + (int) (k255 * xf * yf)) * 0x010101) | 0xFF000000;
    idx++;
    pixels[idx] = (Math.min(0xFF, (pixels[idx] & 0xFF) + (int) (k255 * xg * yf)) * 0x010101) | 0xFF000000;
  }
}

//    (1 - xf) * (1 - yf) == 1 - yf - xf + xfyf
//         xf  * (1 - yf) ==          xf - xfyf
//         xf  *      yf  ==               xfyf
//    (1 - xf) *      yf  ==     yf      - xfyf
