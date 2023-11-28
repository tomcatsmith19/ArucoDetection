#define RED_LED 5
#define BLUE_LED 6
#define GREEN_LED 9

int brightness = 255;
int gBright = 0;
int rBright = 0;
int bBright = 0;
int fadeSpeed = 0;

void setup() {
  // put your setup code here, to run once:
  pinMode(GREEN_LED, OUTPUT);
  pinMode(RED_LED, OUTPUT);
  pinMode(BLUE_LED, OUTPUT);
  
}


void TurnOn() {
  for (int i = 0; i < 256; i++) {
    analogWrite(RED_LED, rBright);
    rBright += 10;
   
  }

}

void TurnOff() {
  for (int i = 0; i < 256; i++) {
    analogWrite(GREEN_LED, brightness);
    analogWrite(RED_LED, brightness);
    analogWrite(BLUE_LED, brightness);

    brightness -= 1;
    delay(5000);
  }
  
}
void loop() {
  // put your main code here, to run repeatedly:
  TurnOn();
  delay(5000);
  TurnOff();

}
