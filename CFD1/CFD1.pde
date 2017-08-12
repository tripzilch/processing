import java.lang.Math;

double[][][] field;
double[][][] buffer;
double t_run, dt;
int N, counter;

// use enums

void setup() {
	size(250, 250);
	N = width;
	field = new double[N][N][3];
	buffer = new double[N][N][3];
	for (int i=0; i<N; i++) {
		for (int j=0; j<N; j++) {
			field[i][j][0] = 0.0;
			field[i][j][1] = 0.0;
			field[i][j][2] = 0.1;
			buffer = field;
		}
	}
	/*
	for (int i=200; i<300; i++) {
		for (int j=200; j<300; j++) {
			field[i][j][2] = 0.5;
		}
	}
	*/
	t_run = millis();

	dt = 0.01;
	counter = 0;
}

void advection_forward(double dt) {
	double[] cell;
	double x1, y1, fx, fy, vx, vy, p;
	int ix, iy;
	for (int i=0; i<N; i++) {
		for (int j=0; j<N; j++) {
			cell = field[i][j];
			x1 = i+cell[0]*dt;
			y1 = j+cell[1]*dt;
			ix = (int) x1;
			iy = (int) y1;
			fx = x1 % 1.0;
			fy = y1 % 1.0;

			vx = cell[0];
			vy = cell[1];
			p = cell[2];

			buffer[(ix+N)%N][(iy+N)%N][0] += vx*((1-fx)*(1-fy));
			buffer[(ix+N)%N][(iy+N)%N][1] += vy*((1-fx)*(1-fy));
			buffer[(ix+N)%N][(iy+N)%N][2] += p*((1-fx)*(1-fy));

			buffer[(ix+N+1)%N][(iy+N)%N][0] += vx*((fx)*(1-fy));
			buffer[(ix+N+1)%N][(iy+N)%N][1] += vy*((fx)*(1-fy));
			buffer[(ix+N+1)%N][(iy+N)%N][2] += p*((fx)*(1-fy));


			buffer[(ix+N+1)%N][(iy+N+1)%N][0] += vx*((fx)*(fy));
			buffer[(ix+N+1)%N][(iy+N+1)%N][1] += vy*((fx)*(fy));
			buffer[(ix+N+1)%N][(iy+N+1)%N][2] += p*((fx)*(fy));


			buffer[(ix+N)%N][(iy+N+1)%N][0] += vx*((1-fx)*(fy));
			buffer[(ix+N)%N][(iy+N+1)%N][1] += vy*((1-fx)*(fy));
			buffer[(ix+N)%N][(iy+N+1)%N][2] += p*((1-fx)*(fy));


			buffer[i][j][0] -= vx;
			buffer[i][j][1] -= vy;
			buffer[i][j][2] -= p;

		}
	}
}

void advection_backward(double dt) {
	double x1, y1, fx, fy, frac, val;
	int ix, iy;
	for (int i=0; i<N; i++) {
		for (int j=0; j<N; j++) {
			x1 = i-field[i][j][0]*dt;
			y1 = j-field[i][j][1]*dt;
			ix = (int) x1;
			iy = (int) y1;
			fx = x1 % 1.0;
			fy = y1 % 1.0;

			for(int k=0; k<3; k++) {
				frac = (1-fx)*(1-fy);
				val = (field[(ix+N)%N][(iy+N)%N][k]*frac);
				buffer[i][j][k] += val;
				buffer[(ix+N)%N][(iy+N)%N][k] -= val;
			}

			for(int k=0; k<3; k++) {
				frac = (fx)*(1-fy);
				val = (field[(ix+1+N)%N][(iy+N)%N][k]*frac);
				buffer[i][j][k] += val;
				buffer[(ix+1+N)%N][(iy+N)%N][k] -= val;
			}

			for(int k=0; k<3; k++) {
				frac = (fx)*(fy);
				val = (field[(ix+1+N)%N][(iy+1+N)%N][k]*frac);
				buffer[i][j][k] += val;
				buffer[(ix+1+N)%N][(iy+1+N)%N][k] -= val;
			}

			for(int k=0; k<3; k++) {
				frac = (1-fx)*(fy);
				val = (field[(ix+N)%N][(iy+1+N)%N][k]*frac);
				buffer[i][j][k] += val;
				buffer[(ix+N)%N][(iy+1+N)%N][k] -= val;
			}
		}
	}
}

void pressure() {
	double force_x, force_y;
	double a = 0.2;
	for (int i=0; i<N-1; i++) {
		for (int j=0; j<N-1; j++) {
			force_x = field[i][j][2] - field[i+1][j][2];
			force_y = field[i][j][2] - field[i][j+1][2];
			buffer[i][j][0] += a*force_x;
			buffer[i+1][j][0] += a*force_x;
			buffer[i][j][1] += a*force_y;
			buffer[i][j+1][1] += a*force_y;
		}
	}
}

void render() {
	loadPixels();
	double temp_p;
	int k = 0;
	for (int i=0; i<N; i++) {
		for (int j=0; j<N; j++) {
			temp_p = Math.max(0.0, Math.min(1.0, field[i][j][2]));
			pixels[k] = color((int)(255*temp_p), (int)(255*temp_p), (int)(255*temp_p));
			k++;
		}
	}
	updatePixels();
}

double mvx = 0.0, mvy = 0.0;
void draw() {
	dt = (millis()-t_run)/1000.;
	t_run = millis();
	buffer = field;
	if(counter%2 == 0) {
		advection_forward(dt);
	} else {
		advection_backward(dt);
	}
	pressure();
	field = buffer;
	render();

	double mvx = (mouseX - pmouseX);
	double mvy = (mouseY - pmouseY);
	if (mousePressed == true) {
		for (int di = -5; di < 5; di++) {
			for (int dj = -5; dj < 5; dj++) {
				int x = di + mouseX;
				int y = dj + mouseY;
				if(x < N && x >= 0 && y < N && y >= 0)
				{
				if (di*di + dj*dj < 25) {
					field[y][x][2] += 0.5;
					field[y][x][0] += mvx;
					field[y][x][1] += mvy;
				}
			}
			}
		}
	}
	counter ++;
}
