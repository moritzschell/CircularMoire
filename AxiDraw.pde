boolean SerialOnline;
boolean doSerialConnect = true;
Serial myPort; 

float MotorSpeed = 2300.0;  // Steps per second, 1500 default
boolean reverseMotorX = false;
boolean reverseMotorY = false;

int ServoUpPct = 70;    // Brush UP position, %  (higher number lifts higher). 
int ServoPaintPct = 30;    // Brush DOWN position, %  (higher number lifts higher). 
int ServoUp;    // Brush UP position, native units
int ServoPaint;    // Brush DOWN position, native units. 

int NextMoveTime;          //Time we are allowed to begin the next movement (i.e., when the current move will be complete).

boolean BrushDown;

int delayAfterRaisingBrush = 300; //ms
int delayAfterLoweringBrush = 220; //ms

int xLocAtPause;
int yLocAtPause;

int MotorX;  // Position of X motor
int MotorY;  // Position of Y motor
int MotorLocatorX;  // Position of motor locator
int MotorLocatorY; 
PVector lastPosition; // Record last encoded position for drawing

int raiseBrushStatus;
int lowerBrushStatus;
int moveStatus;

int MoveDestX;
int MoveDestY; 

int MotorMinX;
int MotorMinY;
int MotorMaxX;
int MotorMaxY;

int MousePaperLeft =  0; //30
int MousePaperRight =  770; //770
int MousePaperTop =  0; //62
int MousePaperBottom =  600; //600

float MotorStepsPerPixel = 32.1;// Good for 1/16 steps-- standard behavior.
float PixelsPerInch = 63.3; 

PVector[] ToDoList;  // Queue future events in an array; Coordinate/command

int indexDone;    // Index in to-do list of last action performed

boolean Paused;

int yBrushRestPositionPixels = 6; //6

boolean PaperSizeA4 = true; // true for A4. false for US letter.

int portNumber = 9;

void raiseBrush() {  
  int waitTime = NextMoveTime - millis();
  if (waitTime > 0)
  {
    raiseBrushStatus = 1; // Flag to raise brush when no longer busy.
  } else
  {
    if (BrushDown == true) {
      if (SerialOnline) {
        myPort.write("SP,0," + str(delayAfterRaisingBrush) + "\r");           
        BrushDown = false;
        NextMoveTime = millis() + delayAfterRaisingBrush;
      }
      //      if (debugMode) println("Raise Brush.");
    }
    raiseBrushStatus = -1; // Clear flag.
  }
}

void lowerBrush() {
  int waitTime = NextMoveTime - millis();
  if (waitTime > 0) {
    lowerBrushStatus = 1;  // Flag to lower brush when no longer busy.
    // delay (waitTime);  // Wait for prior move to finish:
  } else { 
    if  (BrushDown == false) {      
      if (SerialOnline) {
        myPort.write("SP,1," + str(delayAfterLoweringBrush) + "\r");           

        BrushDown = true;
        NextMoveTime = millis() + delayAfterLoweringBrush;
        //lastPosition = new PVector(-1,-1);
      }
      //      if (debugMode) println("Lower Brush.");
    }
    lowerBrushStatus = -1; // Clear flag.
  }
}

// Manage checking if the brush needs servicing, and moving to the next path
void checkServiceBrush() {

  if (serviceBrush() == false)

    if (millis() > NextMoveTime)
    {

      boolean actionItem = false;
      int intTemp = -1;
      float inputTemp = -1.0;
      PVector toDoItem;

      if ((ToDoList.length > (indexDone + 1)) && (Paused == false))
      {
        actionItem = true;
        toDoItem = ToDoList[1 + indexDone];
        inputTemp = toDoItem.x;
        indexDone++;
      }

      if (actionItem)
      {  // Perform next action from ToDoList::

        if (inputTemp >= 0)
        { // Move the carriage to draw a path segment!

          toDoItem = ToDoList[indexDone];  
          float x2 = toDoItem.x;
          float y2 = toDoItem.y;

          int x1 = round( (x2 - float(MousePaperLeft)) * MotorStepsPerPixel);
          int y1 = round( (y2 - float(MousePaperTop)) * MotorStepsPerPixel); 

          MoveToXY(x1, y1);
          //println("Moving to: " + str(x2) + ", " + str(y2));

          if (lastPosition.x == -1) {
            lastPosition = toDoItem; 
            //println("Starting point: Init.");
          }

          lastPosition = toDoItem;

          /*
           IF next item in ToDoList is ALSO a move, then calculate the next move and queue it to the EBB at this time.
           Save the duration of THAT move as "SubsequentWaitTime."
           
           When the first (pre-existing) move completes, we will check to see if SubsequentWaitTime is defined (i.e., >= 0).
           If SubsequentWaitTime is defined, then (1) we add that value to the NextMoveTime:
           
           NextMoveTime = millis() + SubsequentWaitTime; 
           SubsequentWaitTime = -1;
           
           We also (2) queue up that segment to be drawn.
           
           We also (3) queue up the next move, if there is one that could be queued. 
           
           */
        } else
        {
          intTemp = round(-1 * inputTemp);

          if ((intTemp > 9) && (intTemp < 20)) 
          {  // Change paint color  
            intTemp -= 10;
          } else if (intTemp == 30) 
          {
            raiseBrush();
          } else if (intTemp == 31) 
          {  
            lowerBrush();
          } else if (intTemp == 35) 
          {  
            MoveToXY(0, 0);
          }
        }
      }
    }
}


boolean serviceBrush() {
  // Manage processes of getting paint, water, and cleaning the brush,
  // as well as general lifts and moves.  Ensure that we allow time for the
  // brush to move, and wait respectfully, without local wait loops, to
  // ensure good performance for the artist.

  // Returns true if servicing is still taking place, and false if idle.

  boolean serviceStatus = false;

  int waitTime = NextMoveTime - millis();
  if (waitTime >= 0) {
    serviceStatus = true;
    // We still need to wait for *something* to finish!
  } else {
    if (raiseBrushStatus >= 0) {
      raiseBrush();
      serviceStatus = true;
    } else if (lowerBrushStatus >= 0) {
      lowerBrush();
      serviceStatus = true;
    } else if (moveStatus >= 0) {
      MoveToXY(); // Perform next move, if one is pending.
      serviceStatus = true;
    }
  }
  return serviceStatus;
}

void MoveToXY(int xLoc, int yLoc)
{
  MoveDestX = xLoc;
  MoveDestY = yLoc;

  MoveToXY();
}

void MoveToXY()
{
  int traveltime_ms;

  // Absolute move in motor coordinates, with XY limit checking, time management, etc.
  // Use MoveToXY(int xLoc, int yLoc) to set destinations.

  int waitTime = NextMoveTime - millis();
  if (waitTime > 0)
  {
    moveStatus = 1;  // Flag this move as not yet completed.
  } else
  {
    if ((MoveDestX < 0) || (MoveDestY < 0))
    { 
      // Destination has not been set up correctly.
      // Re-initialize varaibles and prepare for next move.  
      MoveDestX = -1;
      MoveDestY = -1;
    } else {

      moveStatus = -1;
      if (MoveDestX > MotorMaxX) 
        MoveDestX = MotorMaxX; 
      else if (MoveDestX < MotorMinX) 
        MoveDestX = MotorMinX; 

      if (MoveDestY > MotorMaxY) 
        MoveDestY = MotorMaxY; 
      else if (MoveDestY < MotorMinY) 
        MoveDestY = MotorMinY; 

      int xD = MoveDestX - MotorX;
      int yD = MoveDestY - MotorY;

      if ((xD != 0) || (yD != 0))
      {   

        MotorX = MoveDestX;
        MotorY = MoveDestY;

        int MaxTravel = max(abs(xD), abs(yD)); 
        traveltime_ms = int(floor( float(1000 * MaxTravel)/MotorSpeed));

        NextMoveTime = millis() + traveltime_ms -   ceil(1000 / frameRate);
        // Important correction-- Start next segment sooner than you might expect,
        // because of the relatively low framerate that the program runs at.

        if (SerialOnline) {
          if (reverseMotorX)
            xD *= -1;
          if (reverseMotorY)
            yD *= -1; 

          myPort.write("XM," + str(traveltime_ms) + "," + str(xD) + "," + str(yD) + "\r");
          //General command "XM,duration,axisA,axisB<CR>"
        }

        // Calculate and animate position location cursor
        //int[] pos = getMotorPixelPos();
        //float sec = traveltime_ms/1000.0;

        //Ani.to(this, sec, "MotorLocatorX", pos[0]);
        //Ani.to(this, sec, "MotorLocatorY", pos[1]);

        //        if (debugMode) println("Motor X: " + MotorX + "  Motor Y: " + MotorY);
      }
    }
  }

  // Need 
  // SubsequentWaitTime
}


// Return the [x,y] of the motor position in pixels
int[] getMotorPixelPos() {
  int[] out = {

    int (float (MotorX) / MotorStepsPerPixel) + MousePaperLeft, 
    int (float (MotorY) / MotorStepsPerPixel) + MousePaperTop + yBrushRestPositionPixels

  };
  return out;
}

void scanSerial() {  

  // Serial port search string:  
  int PortCount = 0;
  String portName;
  String str1, str2;
  int j;

  int OpenPortList[]; 
  OpenPortList = new int[0]; 

  SerialOnline = false;
  boolean serialErr = false;


  try {
    PortCount = Serial.list().length;
  } 
  catch (Exception e) {
    e.printStackTrace(); 
    serialErr = true;
  }

  if (!serialErr) {
    println("\nI found "+PortCount+" serial ports, which are:");
    printArray(Serial.list());

    String  os=System.getProperty("os.name").toLowerCase();

    println("Discovered OS: " + os);

    portName = Serial.list()[portNumber]; ///Hier den Port einstellen
    boolean portErr = false;

    try {    
      myPort = new Serial(this, portName, 38400);
    }
    catch (Exception e) {
      SerialOnline = false;
      portErr = true;
      println("Serial port "+portName+" could not be activated.");
    }

    if (portErr == false) {
      myPort.buffer(1);
      myPort.clear(); 
      println("Serial port "+portName+" found and activated.");

      String inBuffer = "";

      myPort.write("v\r");  //Request version number
      delay(50);  // Delay for EBB to respond!

      while (myPort.available () > 0) {
        inBuffer = myPort.readString();   
        if (inBuffer != null) {
          println("Version Number: "+inBuffer);
        }
      }

      str1 = "EBB";
      if (inBuffer.length() > 2) {
        str2 = inBuffer.substring(0, 3); 
        if (str1.equals(str2) == true)
        {
          // EBB Identified! 
          SerialOnline = true;    // confirm that this port is good
          j = OpenPortList.length; // break out of loop

          println("Serial port "+portName+" confirmed to have EBB.");
        } else
        {
          myPort.clear(); 
          myPort.stop();
          println("Serial port "+portName+": No EBB detected.");
        }
      }
    }
  }
}
