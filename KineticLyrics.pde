import java.util.ArrayList;
import java.text.*;
import java.io.File;
import java.net.URI;
import java.nio.file.Path;
import java.nio.file.Paths;
import ddf.minim.*;

Minim minim;
AudioPlayer player;


public static final int WIDTH = 1200;
public static final int HEIGHT = 980;
public static final int TX_SIZE = 100;



Path parentPath = Paths.get(KineticLyrics.class.getResource("KineticLyrics.class").toString().substring(6)).getParent().getParent();

final String LYRICS_DIR = parentPath + "/kra";
final String MUSICS_DIR = parentPath.getParent() + "/music";
String LYRICS_FILE = null;
String MUSIC_FILE = null;
String[] kasi = null;

String regex = "\\[(.+?)\\]";
SimpleDateFormat format = new SimpleDateFormat("mm:ss:SS");
SimpleDateFormat msformat = new SimpleDateFormat("SSSSSSSSSS");

File karDir = new File(LYRICS_DIR);
File mscDir = new File(MUSICS_DIR);


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
String runMode = null;

String karList[] = null;
String mscList[] = null;

void settings(){
    size(WIDTH, HEIGHT);
}

void setup(){
    smooth();
    background(100);
    //String[] fontList = PFont.list();
    //printArray(fontList);
    PFont font = createFont("コーポレート・ロゴＢ", TX_SIZE);
    textFont(font);
    textAlign(CENTER, CENTER);
    fill(0);
    
    println(parentPath);

    minim=new Minim(this);
    
    karList = karDir.list();
    mscList = mscDir.list();
    

    //読み込み成功チェック
    
    if( mscList == null ){
        println( "musicフォルダ内ファイルの取得に失敗");
        exit();
    }
    if( karList == null ){
        println( "kraフォルダ内ファイルの取得に失敗" );
        exit();
    }


    
    
    runMode = "SELECT";
    
}

int selPointer = 0;
int karPointer = 0;
int mscPointer = 0;
int cursorY = 0;
boolean DECIDE = false;

void draw(){

    background(255);
    switch(runMode){

        case "SELECT":
            //歌詞ファイル・音源セレクト
            if(selPointer < 0) selPointer += 1;
            if(selPointer > 1) selPointer -= 1;
            if(karPointer < 0) karPointer += 1;
            if(karPointer > karList.length-1) karPointer -= 1;
            if(mscPointer < 0) mscPointer += 1;
            if(mscPointer > mscList.length-1) mscPointer -= 1;

            textSize(70);
            textAlign(CENTER, CENTER);
            cursorY = (selPointer == 0) ? (HEIGHT / 3 + 10) : (2 * HEIGHT / 3 + 10);

            fill(255,0,0);
            text("____________", WIDTH/2, cursorY);

            fill(0); 
            text(karList[karPointer], WIDTH/2, HEIGHT/3);
            text(mscList[mscPointer], WIDTH/2, HEIGHT*2/3);

            textSize(40);
            text("↑↓ / カーソル移動　←→ / 選択　Enter / 決定", WIDTH/2, HEIGHT - 50);

            if(DECIDE){
                MUSIC_FILE = mscList[mscPointer];
                LYRICS_FILE = karList[karPointer];

                player = minim.loadFile( MUSICS_DIR +"/"+  MUSIC_FILE );
                kasi = loadStrings( LYRICS_DIR +"/"+ LYRICS_FILE );
                
                if( player == null){
                    println( "音楽ファイルが読み込まれていません");
                    exit();
                }
                if( kasi == null ){
                    println( LYRICS_FILE + " 読み込み失敗" );
                    exit();
                }

                for(int k = 0;k<kasi.length;k++){
                    if(kasi[k].length() != 0){
                        if(kasi[k].charAt(0) == '@') kasi[k] = "";
                    }
                }

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
                runMode = "PLAY";
            }

            break;

        case "PLAY":
            //再生
            if(kasiNo < kasi.length){

                if(kasi[kasiNo].length() != 0){

                    if(endFlag == 1){   //initialize
                        if(mode == 1){ //kraファイルのとき
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
                        
                    }

                    nowTime = millis() - stMillis;

                    //println("start: "+ startTime + "   now:"+ nowTime );

                    if(startTime <= nowTime){ //動作きめる
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
                while(player.isPlaying()){
                background(255);
                }
            }
            break;
    }
}

void keyPressed(){
    if(keyCode == RIGHT){
        if(selPointer == 0){
            karPointer += 1;
        }
        if(selPointer == 1){
            mscPointer += 1;
        }
    }
    if(keyCode == LEFT){
        if(selPointer == 0){
            karPointer -= 1;
        }
        if(selPointer == 1){
            mscPointer -= 1;
        }
    }
    if(keyCode == UP){
        selPointer = 0;
    }
    if(keyCode == DOWN){
        selPointer = 1;
    }
    if(keyCode == ENTER || keyCode == RETURN){
        DECIDE = true;
    }
    
} 


void stop(){
    player.close();
    minim.stop();
    super.stop();
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
    textSize(TX_SIZE);
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
    textSize(TX_SIZE);
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
    textSize(TX_SIZE);
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
    textSize(TX_SIZE);
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

