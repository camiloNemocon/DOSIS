   
//julio 2018
//By. Camilo Nemocon

//-----------------------Librerias-------------------
import cc.arduino.*;
import org.firmata.*;
import processing.serial.*;
import processing.serial.*;


//------------------------Variables-------------------
Arduino arduino;


//Port numbre Arduino///////////////////////////////////
int portArduino = 0;

ServoDosis servoPin2;
ServoDosis servoPin4;
ServoDosis servoPin7;
ServoDosis servoPin8;
ServoDosis servoPin12;
ServoDosis servoPin13;

StepperDosis motorPaso;
boolean motorPasoActivo = false;

boolean servoActivoPin2 = false;
boolean servoActivoPin4 = false;
boolean servoActivoPin7 = false;
boolean servoActivoPin8 = false;
boolean servoActivoPin12 = false;
boolean servoActivoPin13 = false;

// inverse of screen dimensions
float invWidth, invHeight;    
  
PFont fuente;

int leftmargin = 10;
int rightmargin = 10;

//texto que se envia al servidor
String buff = "";
//texto que se muestra en este canvas
String buff1 = "";
//variable que guarda los caracteres cuando se le da backspace
String letrasSinBorrar="";

//ubicación en y del historial del codigo 
int y=370;

//arreglo con los mensajes enviados
ArrayList<String> codigos;

//a partir de la palabra detectada escrita por el usuario se determina la instruccion a colocar
int palabraInstruccion = 0;

//arreglo con los mensajes enviados
ArrayList<String> codigosArduino;

//texto con serparacion con , para poder hacer split posteriormente
String buff2 = "";

//genera el envio de datos en forma de loop
boolean enviarDatos = false;

//genera el envio de datos solo cuando se le da enter, no todo el tiempo
boolean enviarDatosEnter = false;

//manejo del envio de los datos a arduino cada medio segundo
int tiempoEspera = 500; 
int tiempoInicio = 0;

int totalBytes = 12;
int contadorBytes = 0;

 
 String msnUnidoArduino="";
 
 String[] translate;
 int[] datoSend;
 
 int tempContador = 0;
 boolean activarArduino = false;
 boolean activarArduino2 = false;
 
 //tiempo en que se envian los datos a Arduino para que prendan los pines al tiempo
 String timeSend = "";
 
 //genera el envio de datos a Arduino para que prendan los pines al tiempo usando la funcion SameTime
 boolean enviarDatos2 = false;
 
 //determina si usa el teclado para activar el arduino en vivo
 boolean tecladoLive = false;

 //Tecla del teclado para tecladoLive
 String TeclaLive;

 //variable que determina si se envia loopArduino o sameTime o TimeStart
 int tempSendParameter = 0;

 //genera el envio de datos a Arduino para que prendan los pines al tiempo usando la funcion TimeStart
 boolean enviarDatos3 = false;
 boolean empezar3 = false;
 // tiempo para TimeStart
 int tiempoReiniciar3 = 0;
 
 //genera el envio de datos a Arduino para que se mantengan prendidos los pines todo el tiempo usando la funcion OnArduino
 boolean enviarDatos4 = false;
 IntList prendidos;

 //genera el envio de datos a Arduino para que se apaguen los pines usando la funcion OffArduino
 IntList apagados;

 //tiempo para same Time
 int[] tiempoReiniciar;
 boolean empezar = false;

 //tiempo que mantiene prendido los pines y que se reinicia 
 int[] tiempoReiniciarV2;

 //manejo del envio de los datos a arduino cada tanto tiempo, donde este tiempo se puede modificar con las flechas
 int tiempoFlechas = 0;

 
//------------------------Setup-------------------
void setup() 
{
  size(400,768);
  frameRate(30);
  
  noCursor();
  
  //tipografia
  fuente = loadFont("AgencyFB-Reg-48.vlw");
  //tamaño de la fuente
  textFont(fuente, 25);
  
  //inicializa el arreglo de los mensajes a enviar
  codigos = new ArrayList<String>();
  
  //fondo
  background(0);
  
  invWidth = 1.0f/width ;
  invHeight = 1.0f/( height/2 );
    
  //inicializa el arreglo de los mensajes a enviar
  codigosArduino = new ArrayList<String>();
  
  // imprime el puerto en el que esta conectado arduino
  println(Arduino.list());
  
  //puerto serial por donde le va a enviar los datos a arduino para Windows
  arduino = new Arduino(this, Arduino.list()[portArduino], 57600);
  
  //puerto serial por donde le va a enviar los datos a arduino para MAC
  //arduino = new Arduino(this, "/dev/cu.usbmodem1411", 57600); 
 
  //le digo que todos los pines sean de salida
  for (int i = 0; i <= 22; i++)
  {
    arduino.pinMode(i, Arduino.OUTPUT);
    
    //apago todos lo pines
    arduino.digitalWrite(i, Arduino.LOW);
    arduino.analogWrite( i, 0 );
  }
  
  stopArduino();
  
  tiempoReiniciar = new int [9];    
  tiempoReiniciarV2 = new int [9];  
}


//------------------------Draw-------------------
void draw() 
{  
  //fondo
  fill(0);
  rect(0, 0, width, (height/2)-50);
  
  //color para titilar el cuadrado
  if((millis() % 500) < 250)
  {
    noFill();
  }
  else
  {
    fill(#D3EAE3);
    stroke(#D3EAE3);
  }
  
  
  pushMatrix();

  //ubicacion del rectangulo que titila
  float rPos;
  rPos = textWidth(buff1)+leftmargin;
  rect(rPos+1, 19, 10, 21);

  translate(rPos,10+25);
  char k;
 
  //color de las palabras
  fill(#D3EAE3);

  //coloca en orden las letras escritas a costado izquierdo del canvas
  for(int i=0;i<buff1.length();i++)
  {
    k = buff1.charAt(i);
    translate(-textWidth(k),0);
    text(k,0,0);
  }
  
  
  popMatrix();
  
  //muestra los mensajes enviados a costado derecho del canvas
  historialCodigo();
  
  instrucciones();
  
  if(enviarDatos==true)
  {
    enviarArduino();
  }
  
  if(enviarDatos2==true)
  {
    enviarArduinoSameTime(timeSend);
  }
  
  if(enviarDatos3==true)
  {
    enviarArduinoTimeStart(timeSend);
  }
  
  if(enviarDatos4==true)
  {
    prenderArduino();
  }
    
  if(servoActivoPin2==true)
  {
    servoPin2.update();
  }
  if(servoActivoPin4==true)
  {
    servoPin4.update();
  }
  if(servoActivoPin7==true)
  {
    servoPin7.update();
  }
  if(servoActivoPin8==true)
  {
    servoPin8.update();
  }
  if(servoActivoPin12==true)
  {
    servoPin12.update();
  }
  if(servoActivoPin13==true)
  {
    servoPin13.update();
  }
  
  if(motorPasoActivo==true)
  {
    motorPaso.update();
  }
  
  //test pines numeros
  /*for( int i = 2; i < 10; i++ ) 
  { 
        arduino.digitalWrite( i, Arduino.HIGH );
        arduino.analogWrite( i, 255 );
  }
  
  //test pines letras
  for( int i = 11; i < 22; i++ ) 
  { 
        arduino.digitalWrite( i, Arduino.HIGH );
  }*/
  
  
  
}




void enviarArduino()
{
  //cada medio segundo envia el dato
  if (millis() - tiempoInicio > tiempoEspera) 
  {
    arduino.digitalWrite(datoSend[contadorBytes], Arduino.HIGH);
        
    if( datoSend[contadorBytes] < 19  )
    {
       arduino.analogWrite( datoSend[contadorBytes], 255 );
    }     
    
    if(contadorBytes > 0)
    {
      arduino.digitalWrite(datoSend[contadorBytes-1], Arduino.LOW);  
      arduino.analogWrite( datoSend[contadorBytes-1], 0 );
    }
    
    if(contadorBytes == 0)
    {
      arduino.digitalWrite(datoSend[datoSend.length-1], Arduino.LOW);  
      arduino.analogWrite( datoSend[datoSend.length-1], 0 );
    }
    
    println(datoSend[contadorBytes]);
       
    contadorBytes++;
    
    
    if(contadorBytes>=totalBytes)
    {
       contadorBytes = 0;
    }
  
     tiempoInicio = millis();
  } 
  
  if(contadorBytes==0 && enviarDatosEnter == true)
  {  
    arduino.digitalWrite(datoSend[datoSend.length-1], Arduino.LOW);  
    arduino.analogWrite( datoSend[datoSend.length-1], 0 );
    enviarDatos = false;
    activarArduino = false;
    enviarDatosEnter = false;
  }
 
}

void prenderArduino()
{
  for(int i=0; i<prendidos.size(); i++)
  {    
    arduino.digitalWrite(prendidos.get(i), Arduino.HIGH);
  }
}

void apagarArduino()
{
  for(int i=0; i<apagados.size(); i++)
  {
    arduino.digitalWrite(apagados.get(i), Arduino.LOW);
  }
}



void keyPressed()
{  
    char k;    
    k = (char)key;
    
    TeclaLive = str(k);
    
    switch(k)
    {    
      //cuando se le da backspace
      case 8:    
      if(buff1.length()>0)
      {
        buff1 = buff1.substring(1);
      }
      
      if(buff2.length()>0)
      {
         //buff2 = buff2.substring(0,buff2.length()-2);
         buff2 = buff2.substring(0,buff2.length()-1);
      } 
      
      if(buff.length()>0)
      {
        for(int i=0;i<buff.length()-1;i++)
        {
          k = buff.charAt(i);
          letrasSinBorrar += str(k);
        }
        buff = letrasSinBorrar;
        letrasSinBorrar="";
      }
      break;
    
      case 13:  // Avoid special keys
      case 10:
      case 65535:
      case 127:
      case 27:
      break;
      
    default:
      //el texto que esta dentro del margen
      if(textWidth(buff1+k)+leftmargin < width-rightmargin)
      {
        //texto que se escribe en el orden correcto en el canvas
        buff1=k+buff1;     
      }
      else
      {
         if(tecladoLive == true)
         { 
            codigos.add(buff1);
            buff1 = "";
            //coloca el mensaje del historial abajo de la otra palabra
            y+=30; 
         }
      }
      
      
      if(textWidth(buff+k)+leftmargin < width-rightmargin)
      {
        //mensaje en el orden correcto de caracteres para enviar
        buff=buff+k;
        
        if(buff.equals("Once") || buff.equals("Loop") || buff.equals("PararA"))
        {
          tecladoLive = false;
          palabraInstruccion = 13; 
        }        
        else if (buff.equals("Same") ||  buff.equals("Time"))
        {
          palabraInstruccion = 14;
        }
        else if(buff.equals("Tecla")|| buff.equals("PararT"))
        {
          palabraInstruccion = 15; 
        }
        if(buff.equals("Servo"))
        {
          palabraInstruccion = 16; 
        }
        if(buff.equals("Paso"))
        {
          palabraInstruccion = 18; 
        }
        if(buff.equals("On") || buff.equals("Off"))
        {
          palabraInstruccion = 20; 
        }
        
      }
      
      if(tecladoLive == false)
      {  
        //buff para arduino
        if(textWidth(buff2+k)+leftmargin < width-rightmargin)
        {
          //mensaje que se le incluye la , para hacer posteriormente un split
          //buff2=buff2+k+",";
          buff2=buff2+k;
        }      
      }
      else
      {       
        arduino.digitalWrite(int(TeclaLive), Arduino.HIGH);   
      }
        
      break;
    }
}


//muestra los mensajes enviados a costado derecho del canvas
void historialCodigo()
{
  textSize(25);
    //color y ubicación de cada letra que se coloca
    fill(#45DB0B);
    //dibuja cada texto enviado uno debajo del otro
    for(int i=0; i<codigos.size();i++)
    {  
        text(codigos.get(codigos.size()-1),10,y); 
    }
    
    //cuando los textos lleguen al final del canvas
    if(y >= height-170)
    {
      //borre el historial
      background(0);
      //inicie el texto al comienzo del canvas
      y = 370; 
    }
}

void instrucciones()
{
  fill(#8B8A8B);
  noStroke();
  rect(0,600,width,height);
  
  fill(#550F90);  
  
  if(palabraInstruccion == 13)
  {
    textSize(25);
    text("OnceArduino() => envia la data una vez.",10,630);
    
    textSize(16);
    text("Ej: OnceArduino()             3,4,5,6(pines)",10,650);
    
    textSize(25);
    text("LoopArduino() => envia la data todo el tiempo",10,680);
    
    textSize(16);
    text("Ej: LoopArduino()             3,4,5,6(pines)",10,700);
    
    textSize(25);    
    text("PararArduino() => para el envio de la data",10,730);
  }
  if(palabraInstruccion == 14)
  {
    textSize(25);
    text("SameTime(int(timeStart)|int(timeOn))",10,630);
    
    textSize(16);
    text("(tiempo empieza a prender cada pin|tiempo dura prendido cada pin)",10,650);
    text("Ej: SameTime(2,4|5,5)        4,8(pines)",10,670);
    
    textSize(25);
    text("TimeStart(int(timeStart)|int(timeOn))",10,700);
    
    textSize(16);
    text("(UN # tiempo empieza a prender los pines|tiempo dura prendido cada pin)",10,720);
    text("Ej: TimeStart(2|3,2)        4,8(pines)",10,740);
    
    textSize(25);
    text("         ",10,750);
  }
  else if(palabraInstruccion == 15)
  {
    textSize(25);
    text("Teclado() =>Activa Arduino con las teclas",10,630);
    text("PararTeclado() =>Desactiva Arduino con las teclas",10,660);
  }
  else if(palabraInstruccion == 16)
  {
    textSize(22);
    text("ServoArduino() outPin,AngIn,estado,AngFin,tiempo",10,620);
    textSize(14);
    text("Ej: ServoArduino()          2,1,0,70,0 ",10,640);
    text("int outPin => pin al que esta conectado el servo",10,660);
    text("int AngIn => donde empieza el giro (usado en el estado: 1,2,3)",10,680);
    text("int estado => estados desde el 0 hasta el 5",10,700);
    text("int AngFin => donde termina o el angulo de giro (usado en el estado: 0,1,2,3,4)",10,720);
    text("int tiempo => (usado en el estado: 3)",10,740);
    textSize(25);
    text("         ",10,750);
  }
  else if(palabraInstruccion == 17)
  {
    textSize(20);
    text("ServoArduino()",10,620);
    textSize(14);
    text("estado=0 (giro desde 0° hasta AngFin, luego retorna a 0° rápido)",10,640);
    text("estado=1 (giro desde AngIn hasta AngFin, retorna a AngIn con el mismo tiempo de giro)",10,660);
    text("estado=2 (giro desde AngIn hasta 180°, donde el giro se realiza con el AngFin dado, luego retorna rápido y espera TimeWait para empezar)",10,680);
    text("estado=3 (giro desde AngIn hasta AngFin rápidamente, luego espera Tiempo y vuelve a AngIn)",10,700);
    text("estado=4 (giro al AngFin)",10,720);
    text("estado=5 (giro a 0°)",10,740);
    textSize(25);
    text("         ",10,770);
  }
  else if(palabraInstruccion == 18)
  {
    textSize(25);
    text("PasoArduino()",10,630);
    textSize(16);
    text("Ej: PasoArduino()   in1,in2,in3,in4,analog,estado,vel",140,630);
    text("Ej: 2,3,4,5,0,3,5",10,650);
    text("int in => pin al que esta conectado el paso a paso",10,670);
    text("int analog => pin al que esta conectado el pulsador",10,690);
    text("int estado => estados desde el 0 hasta el 3",10,710);
    text("int vel => velocidad para rotar, 3 hasta 11",10,730);
    textSize(25);
    text("         ",10,750);
  }
  else if(palabraInstruccion == 19)
  {
    textSize(20);
    text("PasoArduino()",10,620);
    textSize(14);
    text("estado=0 (no gira, detiene el motor)",10,640);
    text("estado=1 (giro a la derecha y para presionando pulsador)",10,660);
    text("estado=2 (giro a la izquierda y para presionando pulsador)",10,680);
    text("estado=3 (giro a una lado y luego al otro cuando presiona el pulsador)",10,700);
    textSize(25);
    text("         ",10,770);
  }
  if(palabraInstruccion == 20)
  {
    textSize(25);
    text("OnArduino() => prende los pines escritos",10,630);
    
    textSize(16);
    text("Ej: OnArduino()      7,8,9    (pines)",10,650);
    
    textSize(25);
    text("OffArduino() => apaga los pines escritos",10,680);
    
    textSize(16);
    text("Ej: OffArduino()      7,8,9    (pines)",10,700);
    
    textSize(25);    
    text("  ",10,730);
  }
  
}

void keyReleased() 
{
  if(tecladoLive == true)
  {
    arduino.digitalWrite(int(TeclaLive), Arduino.LOW);  
  }
  
  //cuando opriman enter
  if(keyCode==ENTER)
  {    
    //adiciona el string al arreglo de mensajes enviados para dibujarlos
    codigos.add(buff); 
    
    if(buff.equals("PasoArduino()"))
    {  
      if(tecladoLive == true)
      {
        tecladoLive = false;  
      }
      
      buff = "";
      buff1 = "";
      buff2 = "";
      tempSendParameter = 4;
      datosArduino1(tempSendParameter);  
   //   timeSend="";      
    }
    
    if(buff.equals("ServoArduino()"))
    {  
      if(tecladoLive == true)
      {
        tecladoLive = false;  
      }
      
      buff = "";
      buff1 = "";
      buff2 = "";
      tempSendParameter = 3;
      datosArduino1(tempSendParameter);  
      //timeSend="";
    }
    
    if(buff.equals("PararArduino()"))
    {
      if(tecladoLive == true)
      {
        tecladoLive = false;  
      }
      
      stopArduino();
    }
    
    if(buff.equals("Teclado()"))
    {
       //stopArduino();
       tecladoLive = true; 
    }
    
    if(buff.equals("PararTeclado()"))
    {
       //stopArduino();
       tecladoLive = false; 
    }
    
    if(buff.equals("OnArduino()"))
    {  
      //stopArduino();
      buff = "";
      buff1 = "";
      buff2 = "";
      tempSendParameter = 5;
      datosArduino1(tempSendParameter);  
      //timeSend="";
    }
    
    if(buff.equals("OffArduino()"))
    {  
      //stopArduino();
      buff = "";
      buff1 = "";
      buff2 = "";
      tempSendParameter = 6;
      datosArduino1(tempSendParameter);  
      //timeSend="";
    }
    
    if(buff.equals("LoopArduino()"))
    {  
      stopArduino();
      buff = "";
      buff1 = "";
      buff2 = "";
      tempSendParameter = 0;
      datosArduino(tempSendParameter);  
      timeSend="";
    }
    
    if(buff.equals("OnceArduino()"))
    { 
      stopArduino();
      buff = "";
      buff1 = "";
      buff2 = "";
      tempSendParameter = 0;
      datosArduino(tempSendParameter);
      timeSend="";
      enviarDatosEnter = true;
    }
    
    if(!buff.equals(""))
    {
      String temp = "";
      String[] mensaje;
      boolean mensajeValido = false;
  
      if(buff.substring(buff.length()-1).equals(")"))
      {
        temp = buff.substring(0,buff.length()-1);    
        mensajeValido = true;
      }
      
       if(mensajeValido == true )
        {
            mensaje = split(temp,'(');                  
            
            if (mensaje[0].equals("SameTime"))
            {
              stopArduino();
              timeSend = mensaje[1];
              buff = "";
              buff1 = "";
              buff2 = "";
              tempSendParameter = 1;
              datosArduino(tempSendParameter);
            }
            
            if (mensaje[0].equals("TimeStart"))
            {
              stopArduino();
              timeSend = mensaje[1];
              buff = "";
              buff1 = "";
              buff2 = "";
              tempSendParameter = 2;
              datosArduino(tempSendParameter);
            }
        }
    }
    
    if(!buff.equals("") && activarArduino2 == true)
    {
      datosArduino1(tempSendParameter);
    }
    
    if(!buff.equals("") && activarArduino == true)
    {
      datosArduino(tempSendParameter);
      if(tempSendParameter == 1)
      {       
        for(int i=0; i<tiempoReiniciar.length; i++)
        {          
          tiempoReiniciar[i] = millis();
          tiempoReiniciarV2[i] = millis();
        }
        empezar = true;
      }
      if(tempSendParameter == 2)
      {       
        tiempoReiniciar3 = millis();
        for(int i=0; i<tiempoReiniciarV2.length; i++)
        { 
          tiempoReiniciarV2[i] = millis();
        }
        empezar3 = true;
      }
    }
    
    //limpia los strings del mensaje que se envia y del que se aparece en el canvas
    buff = "";
    buff1 = "";
    buff2 = "";
    palabraInstruccion = 0;
    
    //coloca el mensaje del historial abajo de la otra palabra
    y+=30;    
  }
  
  
  if(keyCode==RIGHT)
  {  
    if(palabraInstruccion == 0)
    {
      palabraInstruccion = 13;
    }
    
    palabraInstruccion ++;
    
    if(palabraInstruccion > 20)
    {
      palabraInstruccion = 13;
    }
  }
  
  if(keyCode==LEFT)
  {
     palabraInstruccion --;
    
    if(palabraInstruccion < 13)
    {
      palabraInstruccion = 20;
    }
  }
  
  if(keyCode == UP)
  {
    if(enviarDatos==true)
    {
      tiempoEspera = tiempoEspera + 50; 
    }
    
    if(enviarDatos2 == true || enviarDatos3 == true)
    {
      tiempoFlechas = tiempoFlechas + 1;
    }
  }
  
  if(keyCode == DOWN)
  {
    if(enviarDatos==true)
    {
      tiempoEspera = tiempoEspera - 50; 
    }
    
    if(enviarDatos2 == true || enviarDatos3 == true)
    {
      tiempoFlechas = tiempoFlechas - 1;
    }
  }
}

void stopArduino()
{
  /*
  if(motorPasoActivo == false)
  {
    for (int i = 0; i <= 5; i++)
    {
      arduino.analogWrite( i, 0 );
    } 
  }
  else */
  
  if(motorPasoActivo == true)
  {
    motorPaso.pararMotorPaso();
    motorPasoActivo = false;
  } 
  
  activarArduino = false;
  activarArduino2 = false;
  
  if(enviarDatos == true)
  {
    for(int i=0; i<datoSend.length; i++)
    {
      arduino.digitalWrite(datoSend[i], Arduino.LOW);  
      arduino.analogWrite( datoSend[i], 0 );
    } 
    enviarDatos = false;
  }
  
  enviarDatos2 = false;
  enviarDatos3 = false;
  enviarDatos4 = false;
  
  servoActivoPin2 = false;
  servoActivoPin4 = false;
  servoActivoPin7 = false;
  servoActivoPin8 = false;
  servoActivoPin12 = false;
  servoActivoPin13 = false;  
  
  
  for (int i = 0; i <= 13; i++)
  {
    //apago todos lo pines
    arduino.digitalWrite(i, Arduino.LOW);
  }
  
}

void datosArduino1(int sendTime)
{ 
  if(!buff2.equals(""))      
  {      
    if(sendTime==3)
    {
      servo(buff2);
    }
    if(sendTime==4)
    {
      MotorpasoApaso(buff2);     
    }    
    if(sendTime==5)
    {      
      String[] mensajeDatos1;
    
      mensajeDatos1 = split(buff2,',');      
      
      prendidos = new IntList();
      
      for(int i=0; i<mensajeDatos1.length; i++)
      {
        prendidos.append(int(mensajeDatos1[i]));
      }
       
      enviarDatos4 = true;
    }
    
    if(sendTime==6)
    {
      if(enviarDatos4 == true)
      {
        String[] mensajeDatos1;
      
        mensajeDatos1 = split(buff2,',');      
        
        apagados = new IntList();
        
        for(int i=0; i<mensajeDatos1.length; i++)
        {
          apagados.append(int(mensajeDatos1[i]));
        }
        
        for(int k=0; k<prendidos.size(); k++)
        {
          if(apagados.hasValue(prendidos.get(k)) == true) 
          {
            prendidos.remove(k); 
          } 
        }
        
        apagarArduino();
      }
    }
  }
    
  activarArduino2 = true;  
}

void datosArduino(int sendTime)
{ 
  if(!buff2.equals(""))      
  {    
   //adiciona el string al arreglo de mensajes enviados para enviarlos a Arduino
   codigosArduino.add(buff2);
   
    msnUnidoArduino="";
    
    for (int i = 0; i <= 22; i++)
    {
      //apago todos lo pines
      arduino.digitalWrite(i, Arduino.LOW);
      //arduino.analogWrite( i, 0 );
    }
    
    if(codigosArduino.size()>0)
    {
      msnUnidoArduino = codigosArduino.get(codigosArduino.size()-1);
    }
    else
    {
      msnUnidoArduino = buff2;
    }  
    
    translate = split(msnUnidoArduino,',');
    
    datoSend = new int [translate.length];
    
    for (int i = 0; i<translate.length; i++)
    {
      if(translate[i].equals("2") || translate[i].equals("3") || translate[i].equals("4") || translate[i].equals("5") || translate[i].equals("6") || translate[i].equals("7") || translate[i].equals("8") || translate[i].equals("9")|| translate[i].equals("10")|| translate[i].equals("11")|| translate[i].equals("12")|| translate[i].equals("13"))
      {
        datoSend[i] = int(translate[i]); 
      }
      else if(translate[i].equals("a") || translate[i].equals("i") || translate[i].equals("p") || translate[i].equals("x"))
      {
        datoSend[i] = 10; 
      }
      else if(translate[i].equals("b") || translate[i].equals("j") || translate[i].equals("q") || translate[i].equals("y"))
      {
        datoSend[i] = 11; 
      }
      else if(translate[i].equals("c") || translate[i].equals("k") || translate[i].equals("r") || translate[i].equals("z"))
      {
        datoSend[i] = 12; 
      }
      else if(translate[i].equals("d") || translate[i].equals("l") || translate[i].equals("s"))
      {
        datoSend[i] = 13; 
      }
      else if(translate[i].equals("e") || translate[i].equals("m") || translate[i].equals("t"))
      {
        datoSend[i] = 18; 
      }
      else if(translate[i].equals("f") || translate[i].equals("n") || translate[i].equals("u"))
      {
        datoSend[i] = 19; 
      }
      else if(translate[i].equals("g") || translate[i].equals("ñ") || translate[i].equals("v"))
      {
        datoSend[i] = 20; 
      }
      else if(translate[i].equals("h") || translate[i].equals("o") || translate[i].equals("w"))
      {
        datoSend[i] = 21; 
      }
    }    
    
    totalBytes = datoSend.length;
    contadorBytes = 0;
    
    
    if(sendTime==0)
    {
      enviarDatos = true;
    }
    if(sendTime==1)
    {
      enviarDatos2 = true;
    }
    if(sendTime==2)
    {
      enviarDatos3 = true;
    }
  } 
  
  activarArduino = true;
}

void MotorpasoApaso(String data)
{
   String[] mensajeDatos1;
    
   mensajeDatos1 = split(data,',');
   
  //si la cantidad de parametros son correctos  
  if(mensajeDatos1.length == 7)
  {
    motorPaso = new StepperDosis(int(mensajeDatos1[0]),int(mensajeDatos1[1]),int(mensajeDatos1[2]),int(mensajeDatos1[3]),int(mensajeDatos1[4]),int(mensajeDatos1[5]),int(mensajeDatos1[6]));
    motorPasoActivo = true;
  }  
  else
  {
    println("Son 7 parametros: pinOut1,pinOut2,pinOut3,pinOut4,pinIn1,Estado,Vel");
  }
  
}

void servo(String data)
{
    String[] mensajeDatos1;
    
    mensajeDatos1 = split(data,',');
    
    //si la cantidad de parametros son correctos  
    if(mensajeDatos1.length == 5)
    {
      if(int(mensajeDatos1[0])==2)
      {        
        servoPin2 = new ServoDosis(int(mensajeDatos1[0]),int(mensajeDatos1[1]),int(mensajeDatos1[2]),int(mensajeDatos1[3]),int(mensajeDatos1[4]));   
        servoActivoPin2 = true;
      }
      if(int(mensajeDatos1[0])==4)
      {
        servoPin4 = new ServoDosis(int(mensajeDatos1[0]),int(mensajeDatos1[1]),int(mensajeDatos1[2]),int(mensajeDatos1[3]),int(mensajeDatos1[4]));   
        servoActivoPin4 = true;
      }
      if(int(mensajeDatos1[0])==7)
      {
        servoPin7 = new ServoDosis(int(mensajeDatos1[0]),int(mensajeDatos1[1]),int(mensajeDatos1[2]),int(mensajeDatos1[3]),int(mensajeDatos1[4]));   
        servoActivoPin7 = true;
      }
      if(int(mensajeDatos1[0])==8)
      {
        servoPin8 = new ServoDosis(int(mensajeDatos1[0]),int(mensajeDatos1[1]),int(mensajeDatos1[2]),int(mensajeDatos1[3]),int(mensajeDatos1[4]));   
        servoActivoPin8 = true;
      }
      if(int(mensajeDatos1[0])==12)
      {
        servoPin12 = new ServoDosis(int(mensajeDatos1[0]),int(mensajeDatos1[1]),int(mensajeDatos1[2]),int(mensajeDatos1[3]),int(mensajeDatos1[4]));   
        servoActivoPin12 = true;
      }
      if(int(mensajeDatos1[0])==13)
      {
        servoPin13 = new ServoDosis(int(mensajeDatos1[0]),int(mensajeDatos1[1]),int(mensajeDatos1[2]),int(mensajeDatos1[3]),int(mensajeDatos1[4]));   
        servoActivoPin13 = true;
      }            
    }
    //si la cantidad de parametros dentro del parentesis no son correctos
    else
    {
      println("Faltan los 5 parametros");
    }
}

void enviarArduinoSameTime(String timeSend)
{     
  String[] mensajeTimeSendCompleto;  
  mensajeTimeSendCompleto = split(timeSend,'|');
  
  String[] mensajeTimeSend;  
  mensajeTimeSend = split(mensajeTimeSendCompleto[0],','); 
  
  String[] mensajeTimePrendido;  
  mensajeTimePrendido = split(mensajeTimeSendCompleto[1],','); 
  
  
  int[] tiempoIndependiente = new int [mensajeTimeSend.length]; 
  int[] tiempoPrendido = new int [mensajeTimePrendido.length];
  
  if(mensajeTimePrendido.length == mensajeTimeSend.length)
  {
    for(int i=0; i<mensajeTimeSend.length; i++)
    {
      tiempoIndependiente[i] = int(mensajeTimeSend[i]);
      tiempoPrendido[i] = int(mensajeTimePrendido[i]);
    }
  } 
  
  
  
  if(mensajeTimeSend.length == (totalBytes) && mensajeTimeSend.length == mensajeTimePrendido.length)
  {
    if(mensajeTimeSend.length >= 1)
    {
      if(empezar==true)
      {
        for(int j=0; j<mensajeTimeSend.length; j++)
        {
           tiempoIndependiente[j] = (((int(mensajeTimeSend[j])*1000)-(millis()-tiempoReiniciar[j]))/1000)+tiempoFlechas;
                     
          if(tiempoIndependiente[j] < 0)
          {
            arduino.digitalWrite(datoSend[j], Arduino.HIGH);        
            
            tiempoPrendido[j] = ((int(mensajeTimePrendido[j])*1000)-(millis()-tiempoReiniciarV2[j]))/1000;
          
            if(tiempoPrendido[j] < 0)
            {
              arduino.digitalWrite(datoSend[j], Arduino.LOW); 
              tiempoReiniciar[j] = millis();
              tiempoReiniciarV2[j] = millis();
            }
          }
          else
          {
            tiempoReiniciarV2[j] = millis();           
          }
        } 
      }      
    }  
  }
  else
  {
    println("la cantidad de variables de tiempo no corresponde a la cantidad de pines a activar"); 
    println("parametros iniciales "+ mensajeTimeSend.length);
    println("parametros finales "+ mensajeTimePrendido.length);
    println("cantidad de pines " + (totalBytes));
    println("buff " + msnUnidoArduino);
    
    /*for (int i = 0; i<datoSend.length; i++)
    {
      println(datoSend[i]); 
    }*/
  }  
}

void enviarArduinoTimeStart(String timeSend)
{
  String[] mensajeTimeSendCompleto;  
  mensajeTimeSendCompleto = split(timeSend,'|');
  
  String[] mensajeTimeSend;  
  mensajeTimeSend = split(mensajeTimeSendCompleto[0],','); 
  
  int tempMayor = 0;
  int idMayor = 0;
    
  if(mensajeTimeSend.length == 1)
  {
    int tiempoEmpezar = 0;

    String[] mensajeTimePrendido;  
    mensajeTimePrendido = split(mensajeTimeSendCompleto[1],',');    
    
    int[] tiempoPrendido = new int [mensajeTimePrendido.length];
  
    for(int i=0; i<mensajeTimePrendido.length; i++)
    {
      tiempoPrendido[i] = int(mensajeTimePrendido[i]);
      
      //se establece cual pin tiene el mayor tiempo
      if(int(mensajeTimePrendido[i]) > tempMayor)
      {
        tempMayor = int(mensajeTimePrendido[i]);
        idMayor = i;
      }
    }
   
    if(empezar3==true && mensajeTimePrendido.length == (totalBytes))
    {    
      tiempoEmpezar = (((int(mensajeTimeSend[0])*1000)-(millis()-tiempoReiniciar3))/1000)+tiempoFlechas;
      
      if(tiempoEmpezar < 0)
      {       
        for(int j=0; j<mensajeTimePrendido.length; j++)
        {      
          //los prende todos
          arduino.digitalWrite(datoSend[j], Arduino.HIGH);             
          
          //corre el tiempo de prendido de cada pin
          tiempoPrendido[j] = ((int(mensajeTimePrendido[j])*1000)-(millis()-tiempoReiniciarV2[j]))/1000;
                   
          if(tiempoPrendido[j] < 0)
          {
            arduino.digitalWrite(datoSend[j], Arduino.LOW); 
          }
          
          //apenas acabe el tiempo del pin con mayorTiempoPrendido entonces reinicia el tiempo de todo para que prenda
          if(tiempoPrendido[j] < 0 && j == idMayor)
          {
            tiempoReiniciar3 = millis();
          }
        }
      } 
      else
      {
        for(int i=0; i<mensajeTimePrendido.length; i++)
        {
          tiempoReiniciarV2[i] = millis();
        }
      }
    } 
    else
    {
      println("la cantidad de variables de tiempo no corresponde a la cantidad de pines a activar");
      println("parametros finales "+ mensajeTimePrendido.length);
      println("cantidad de pines " + (totalBytes));
      println("buff " + msnUnidoArduino);
      
      for (int i = 0; i<datoSend.length; i++)
      {
        println(datoSend[i]); 
      }
    }
  }
  else
  {
    println("la cantidad de variables del primer parametro sólo debe ser 1 antes del  simbolo |"); 
  }
}
