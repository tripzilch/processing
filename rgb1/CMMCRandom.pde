import java.util.Random;

public class CMMCRandom {
    // from http://stackoverflow.com/questions/397867/port-of-random-generator-from-c-to-java
    // * Choose 4096 random 32-bit integers
    private long[] Q;

    // * choose random initial c<809430660
    private long c = 362436;

    private int i;

    public CMMCRandom() {
        Random r = new Random(1);
        Q = new long[4096];

        // TODO initialize with real random 32bit values
        for (int i = 0; i < 4096; ++i) {
            long v = r.nextInt();
            v -= Integer.MIN_VALUE;
            Q[i] = v;
        }
        i = 4095;
    }

    int next() {
        i = (i + 1) & 4095;
        long t = 18782 * Q[i] + c;
        c = t >>> 32;
        long x = (t + c) & 0xffffffffL;
        if (x < c) {
            ++x;
            ++c;
        }

        long v = 0xfffffffeL - x;
        Q[i] = v;
        return (int) v;
    }

    double nextDouble() {
        return (double)(RND.next() & 0xFFFFFFF) / 0x10000000;
    }

    boolean chance(double P) { return nextDouble() < P; }

}
