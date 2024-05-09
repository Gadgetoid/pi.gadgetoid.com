#define LED_RED 7
#define LED_ORANGE 8
#define LED_YELLOW 9
#define LED_GREEN 10

void setup(){
	Serial.begin(9600);

	//Set all the pins we need to output pins
	pinMode(LED_RED,    OUTPUT);
	pinMode(LED_ORANGE, OUTPUT);
	pinMode(LED_YELLOW, OUTPUT);
	pinMode(LED_GREEN,  OUTPUT);
}

void loop (){
	digitalWrite(LED_RED,    HIGH);
	delay(100);
	digitalWrite(LED_ORANGE, HIGH);
	delay(100);
	digitalWrite(LED_YELLOW, HIGH);
	delay(100);
	digitalWrite(LED_GREEN,  HIGH);
	delay(100);

	digitalWrite(LED_RED,    LOW);
	digitalWrite(LED_ORANGE, LOW);
	digitalWrite(LED_YELLOW, LOW);
	digitalWrite(LED_GREEN,  LOW);

	delay(100);
}