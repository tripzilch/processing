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
        long xorshifted = ((oldstate >>> 18) ^ oldstate) >>> 27;
        long rot = oldstate >> 59;
        return (int) ((xorshifted >>> rot) | (xorshifted << ((-rot) & 31)));
    }

    double nextDouble() {
        return (double)(RND.next() & 0xFFFFFFF) / 0x10000000;
    }

    boolean chance(double P) { return nextDouble() < P; }
}

