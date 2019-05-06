import java.util.Date;
import java.util.ArrayList;
import java.text.*;

public static final int WIDTH = 1200;
public static final int HEIGHT = 960;
public static final int TX_SIZE = 100;

final String FILE_NAME = "tosyokan.kra";
String[] kasi = null;

String regex = "\\[(.+?)\\]";
SimpleDateFormat format = new SimpleDateFormat("mm:ss:SS");
SimpleDateFormat msformat = new SimpleDateFormat("SSSSSSSSS");

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


void setup(){
    size(1200 , 960);
    background(100);
    //String[] fontList = PFont.list();
    //printArray(fontList);
    PFont font = createFont("コーポレート・ロゴＢ", TX_SIZE);
    textFont(font);
    textSize(TX_SIZE);
    textAlign(CENTER, CENTER);
    fill(0);
    kasi = loadStrings( FILE_NAME );
    if( kasi == null ){
        //読み込み失敗
        println( FILE_NAME + " 読み込み失敗" );
        exit();
    }

    switch(getSuffix(FILE_NAME)){
        case "txt":
            mode = 0;
            break;
        case "kra":
            mode = 1;
            break;
    }
   
   stMillis = millis();

}



void draw(){
    background(255);
    if(kasiNo < kasi.length){

        if(kasi[kasiNo].length() != 0){

            if(endFlag == 1){   //initialize
                if(mode == 1){
                    String[][] timeTags = matchAll(kasi[kasiNo], regex);
                    String[] kasiSpl = split(kasi[kasiNo].replaceAll(regex, "[**]"), "[**]");
                    kasi[kasiNo] = kasi[kasiNo].replaceAll(regex, ""); 
                    // ArrayList<String> aryTimeTags = new ArrayList<String>();
                    // for(int k = 0; k < timeTags.length; k++){
                    //     try{
                    //         aryTimeTags.add(format.parse(timeTags[k][1]));
                    //     } catch(java.text.ParseException e){
                    //         e.printStackTrace();
                    //     }
                    // }

                    ArrayList<Integer> msTimeTags = new ArrayList<Integer>();
                    for(int k = 0; k < timeTags.length; k++){
                        String[] buff = split(timeTags[k][1], ":");
                        msTimeTags.add(Integer.parseInt(buff[0])*60000 + Integer.parseInt(buff[1])*1000 + Integer.parseInt(buff[2])*10);
                    }
                    
                    // startTime = aryTimeTags.get(0).getTime();
                    // endTime = aryTimeTags.get(aryTimeTags.size()-1).getTime();
                    // timeDiff = endTime - startTime;

                    startTime = msTimeTags.get(0);
                    endTime = msTimeTags.get(msTimeTags.size()-1);
                    timeDiff = endTime - startTime;              
                    
                    println("st: "+startTime+"  end:"+endTime+"  diff:"+timeDiff);

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

            println("start: "+ startTime + "   now:"+ nowTime );

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

void charAppearLeftToRight(){
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

void strScroll(){
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

void strScroll(long timeDiff){
    
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

void strFromUpDown(){
    
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