/*
 * PCG Random Number Generation for Java / Processing.
 *
 * For additional information about the PCG random number generation scheme,
 * including its license and other licensing options, visit
 *
 *       http://www.pcg-random.org
 */

class PCG32Random {
    long state, inc;
    PCG32Random() {
        state = 0x853c49e6748fea9bL;
        inc = 0xda3e39cb94b95bdbL;
    }
    PCG32Random(long seed, long seq) {
        state = 0;
        inc = (seq << 1) | 1;
        next();
        state += seed;
        next();
    }

    int next() {
        long oldstate = state;
        state = oldstate * 6364136223846793005L + inc;
        int xorshifted = (int) (((oldstate >>> 18) ^ oldstate) >>> 27);
        int rot = (int) (oldstate >>> 59);
        return (int) ((xorshifted >>> rot) | (xorshifted << ((-rot) & 31)));
    }

    double nextDouble() {
        long r = (next() & 0xFFFFFFFFL);
        r = r << 21;
        r ^= (next() & 0xFFFFFFFFL);
        //r ^= (next() & 0xFFFFFFFFL);
        //r ^= (next() & 0xFFFFFFFFL);
        //return r / (double) 0x100000000L;
        // r ^= next() & 0xFFFFFFFFL;
        // r = r << 32;
        // r ^= next() & 0xFFFFFFFFL;
        // r ^= next() & 0xFFFFFFFFL;
        // r ^= next() & 0xFFFFFFFFL;
        return (r & 0x1fffffffffffffL) / ((double) (1L << 53));
    }

    boolean chance(double P) { return nextDouble() < P; }
}

