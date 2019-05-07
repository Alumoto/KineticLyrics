import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Date; 
import java.util.ArrayList; 
import java.text.*; 
import ddf.minim.*; 

import javazoom.jl.converter.*; 
import javazoom.jl.decoder.*; 
import javazoom.jl.player.*; 
import javazoom.jl.player.advanced.*; 
import ddf.minim.javasound.*; 
import ddf.minim.*; 
import ddf.minim.analysis.*; 
import ddf.minim.effects.*; 
import ddf.minim.signals.*; 
import ddf.minim.spi.*; 
import ddf.minim.ugens.*; 
import javazoom.spi.*; 
import javazoom.spi.mpeg.sampled.convert.*; 
import javazoom.spi.mpeg.sampled.file.*; 
import javazoom.spi.mpeg.sampled.file.tag.*; 
import org.tritonus.sampled.file.*; 
import org.tritonus.share.*; 
import org.tritonus.share.midi.*; 
import org.tritonus.share.sampled.*; 
import org.tritonus.share.sampled.convert.*; 
import org.tritonus.share.sampled.file.*; 
import org.tritonus.share.sampled.mixer.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class KineticLyrics extends PApplet {






Minim minim;
AudioPlayer player;


public static final int WIDTH = 1200;
public static final int HEIGHT = 980;
public static final int TX_SIZE = 100;

final String LYRICS_FILE = "Who Put the Bomp.kra";
final String MUSIC_FILE = "Who Put The Bomp.mp3";
String[] kasi = null;

String regex = "\\[(.+?)\\]";
SimpleDateFormat format = new SimpleDateFormat("mm:ss:SS");
SimpleDateFormat msformat = new SimpleDateFormat("SSSSSSSSSS");

int mode = 0;
int stMillis = 0;
int nowMillis = 0;

int animeNo = 0;
int kasiNo = 0;

int cnt = 0;
double sp = 1;

int a = 0;
int b = 0;
int i = 0;

int endFlag = 1;

int x = WIDTH/2;
int y = HEIGHT/2;

boolean firstRun = true;

int startTime;
int endTime;
int timeDiff;

int nowTime;

public void settings(){
    size(WIDTH, HEIGHT);
}

public void setup(){
    smooth();
    background(100);
    //String[] fontList = PFont.list();
    //printArray(fontList);
    PFont font = createFont("コーポレート・ロゴＢ", TX_SIZE);
    textFont(font);
    textSize(TX_SIZE);
    textAlign(CENTER, CENTER);
    fill(0);
    kasi = loadStrings( LYRICS_FILE );
    if( kasi == null ){
        //読み込み失敗
        println( LYRICS_FILE + " 読み込み失敗" );
        exit();
    }

    minim=new Minim(this);
    player = minim.loadFile("../music/"+MUSIC_FILE);

    switch(getSuffix(LYRICS_FILE)){
        case "txt":
            mode = 0;
            break;
        case "kra":
            mode = 1;
            break;
    }
    
    

    stMillis = millis();
    player.play();
}



public void draw(){
    background(255);
    if(kasiNo < kasi.length){

        if(kasi[kasiNo].length() != 0){

            if(endFlag == 1){   //initialize
                if(mode == 1){
                    String[][] timeTags = matchAll(kasi[kasiNo], regex);
                    String[] kasiSpl = split(kasi[kasiNo].replaceAll(regex, "[**]"), "[**]");
                    kasi[kasiNo] = kasi[kasiNo].replaceAll(regex, ""); 

                    ArrayList<Integer> msTimeTags = new ArrayList<Integer>();
                    for(int k = 0; k < timeTags.length; k++){
                        String[] buff = split(timeTags[k][1], ":");
                        msTimeTags.add(Integer.parseInt(buff[0])*60000 + Integer.parseInt(buff[1])*1000 + Integer.parseInt(buff[2])*10);
                    }

                    startTime = msTimeTags.get(0);
                    endTime = msTimeTags.get(msTimeTags.size()-1);
                    timeDiff = endTime - startTime;              
                    
                    //println("st: "+startTime+"  end:"+endTime+"  diff:"+timeDiff);

                    firstRun = true;
                }
                animeNo = (int)random(3);
                animeNo = 0;
                endFlag = 0;
                // for(int k = 0;k<aryTimeTags.size(); k++){
                //     println(format.format(aryTimeTags.get(k)));
                // }
                // for(int k = 0;k<kasiSpl.length; k++){
                //     println(kasiSpl[k]);
                // }
            }

            nowTime = millis() - stMillis;

            //println("start: "+ startTime + "   now:"+ nowTime );

            if(startTime <= nowTime){
                switch(animeNo){
                    case 0:
                        strScroll(timeDiff);
                        break;
                    case 1:
                        strFromUpDown();
                        break;
                    case 2:
                        charAppearLeftToRight();
                        break;
                }

            }  

        }else{
            kasiNo++;
        }

    }else{
        background(255);
    }
    
}

public void stop(){
    player.close();
    minim.stop();
    super.stop();
}

public void charAppearLeftToRight(){
    textAlign(CENTER, CENTER);
    float txWidth = textWidth(kasi[kasiNo]);
    int txLength = kasi[kasiNo].length();
    

    sp = 3;
    int div = 15;
    int stop = 90;

    if(b < txLength){

        if(cnt % div == 0)b++;
    }else if(cnt > (txLength*div) + stop){
        if(cnt % div == 0)a++;
    }

    text(kasi[kasiNo].substring(a, b), WIDTH/2, HEIGHT/2);
    cnt += sp;

    if(a == txLength){
        kasiNo++;
        cnt=0;
        endFlag = 1;
        a = 0;
        b = 0;
    }

}

public void strScroll(){
    textAlign(CENTER, CENTER);
    float txWidth = textWidth(kasi[kasiNo]);
    text(kasi[kasiNo], (WIDTH+txWidth/2)-(cnt), HEIGHT/2);
    cnt += 10;
    if(WIDTH+txWidth-cnt <= 0){
        cnt = 0;
        kasiNo++;
        endFlag = 1;
    }
}

public void strScroll(long timeDiff){
    
    textAlign(CENTER, CENTER);
    double txWidth = (double)textWidth(kasi[kasiNo]);
    text(kasi[kasiNo], (int)((WIDTH+txWidth/2)-cnt), HEIGHT/2);
    double W =(double) WIDTH + txWidth;
    sp = W * (1000 / (60 * (double)timeDiff));
    if(sp < 1){
        sp = 1;
    }

    cnt += (int)sp;

    if(WIDTH+txWidth-cnt <= 0){
        cnt = 0;
        kasiNo++;
        endFlag = 1;
    }
}

public void strFromUpDown(){
    
    sp = 8;

    int f = (i % 2 == 0) ?  0 : 1 ;
    if(cnt == 0){
        y = (-1+f*2) * (TX_SIZE/2) + (height * f) ;
    }
    else if(cnt > 0&&cnt < 22){
        y += sp * ((-2*f)+1);
    }
    else if(cnt>=98 && cnt < 120){
        y -= sp * ((-2*f)+1);
    }
    textAlign(CENTER, CENTER);
    text(kasi[kasiNo], x, y);
    cnt++;
    if(cnt > 120){
        i++;
        kasiNo++;
        cnt=0;
        endFlag = 1;
    }
    
}

public static String getSuffix(String fileName) {
    if (fileName == null)
        return null;
    int point = fileName.lastIndexOf(".");
    if (point != -1) {
        return fileName.substring(point + 1);
    }
    return fileName;
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "KineticLyrics" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
