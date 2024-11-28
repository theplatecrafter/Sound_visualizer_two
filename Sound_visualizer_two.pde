import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer player;

// Variables for visualization
int numParticles = 300;
Particle[] particles = new Particle[numParticles];
boolean realTimeMode = false; // Toggle between real-time and pre-render modes





int renderFPS = 60; // Set FPS for pre-render mode
float songProgress = 0; // To track the exact point in the song during pre-render mode

// Frame saving for video rendering
int frameCounter = 0;

void setup() {
  size(1280, 720, P3D); // 3D canvas
  
  // Minim setup
  minim = new Minim(this);
  player = minim.loadFile("kienromance.wav"); // Add your music file in the "data" folder
  
  // Initialize particles
  for (int i = 0; i < numParticles; i++) {
    particles[i] = new Particle(random(width), random(height), random(-500, 500));
  }
  
  // Real-time mode settings
  if (realTimeMode) {
    player.play();
  } else {
    frameRate(renderFPS);
  }
}

void draw() {
  background(0);
  translate(width / 2, height / 2, -500); // Center visualization
  
  float[] spectrum = new float[player.bufferSize()];
  for (int i = 0; i < player.bufferSize(); i++) {
    spectrum[i] = player.mix.get(i); // Access each value directly
  }


 visualize(spectrum);

  
  // Save frames in pre-render mode
  if (!realTimeMode) {
    songProgress = (float)frameCounter / (renderFPS * player.length() / 1000.0);
    player.cue((int)(songProgress * player.length()));
    saveFrame("output/frame-######.png");
    frameCounter++;
    
    if (songProgress >= 1.0) {
      exit(); // Stop rendering when the song is fully processed
    }
  }
}

void visualize(float[] spectrum){
    // Visualize audio
  float spectrumScale = 200;
  for (int i = 0; i < spectrum.length; i++) {
    float angle = map(i, 0, spectrum.length, 0, TWO_PI);
    float radius = map(spectrum[i], 0, 1, 50, 300);
    
    pushMatrix();
    rotateY(frameCount * 0.01);
    rotateX(frameCount * 0.01);
    stroke(255, 100, 150, 150);
    noFill();
    ellipse(cos(angle) * radius, sin(angle) * radius, 10, 10);
    popMatrix();
  }
  
  // Particle system
  for (int i = 0; i < numParticles; i++) {
    particles[i].update(spectrum[i % spectrum.length] * 50);
    particles[i].display();
  }
}

void stop() {
  player.close();
  minim.stop();
  super.stop();
}

// Particle class
class Particle {
  float x, y, z;
  float vx, vy, vz;
  
  Particle(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.vx = random(-1, 1);
    this.vy = random(-1, 1);
    this.vz = random(-1, 1);
  }
  
  void update(float speed) {
    x += vx * speed;
    y += vy * speed;
    z += vz * speed;
    
    if (x > width / 2 || x < -width / 2) vx *= -1;
    if (y > height / 2 || y < -height / 2) vy *= -1;
    if (z > 500 || z < -500) vz *= -1;
  }
  
  void display() {
    pushMatrix();
    translate(x, y, z);
    noStroke();
    fill(100, 150, 255);
    sphere(5);
    popMatrix();
  }
}
