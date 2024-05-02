import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer player;
FFT fft;
BearDetect beat;

float[] smoothedFFT = new float[512];
float smoothedVolume = 0;
boolean beatDetected = false;

//obj vars



void setup() {
  fullScreen(P3D);
  minim = new Minim(this);
  player = minim.loadFile("kienromance.wav");
  player.play();

  // Create an FFT object with a buffer size matching the audio player's buffer size
  fft = new FFT(player.bufferSize(), player.sampleRate());
  beat = new BeatDetect(player.bufferSize(), player.sampleRate());
}

void draw() {
  background(0);

  // analyze
  fft.forward(player.mix);
  for(int i = 0; i < 512; i++){
    smoothedFFT[i] += (fft.getBand(i)-smoothedFFT[i])/2;
  }
  smoothedVolume += (player.mix.level()-smoothedVolume)/2;
  beat.detect(player.mix);
  beatDetected = beat.isOnset()

  pushMatrix()
  
  popMatrix();
}