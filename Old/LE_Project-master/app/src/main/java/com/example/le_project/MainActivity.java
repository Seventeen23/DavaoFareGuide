package com.example.le_project;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.WindowManager;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;
import android.widget.TextView;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;

public class MainActivity extends AppCompatActivity {

    public File file, histFile;

    public Animation topAnim, botAnim;
    public ImageView usepLogo, logo;
    public TextView introText, introText2;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.bootsplash);

        // load directories
        file = new File(getFilesDir(), "UserData.txt");
        histFile = new File(getFilesDir(), "HistoryData.txt");

        // sets animations
        topAnim = AnimationUtils.loadAnimation(this, R.anim.top_animation);
        botAnim = AnimationUtils.loadAnimation(this, R.anim.bot_animation);

        logo = findViewById(R.id.LOGO);

        introText = findViewById(R.id.INTRO_TEXT);
        introText2 = findViewById(R.id.INTRO_TEXT2);

        // apply animation to objects
        logo.setAnimation(topAnim);

        introText.setAnimation(botAnim);
        introText2.setAnimation(botAnim);

        // checks directory
        if(checkDir()) {
            loadUser();
            loadHist();
            toMainFrame();
        }
        else {
            toNewUserFrame();
        }
    }

    // checks if directory exist
    public boolean checkDir() {
        boolean isExist = true;

        // if file exist and has value
        if(file.exists()) {
            if(hasText(file)) {
                return true;
            }
            return false;
        }
        // else creates files in the directory
        else {
            try {
                file.createNewFile();
                histFile.createNewFile();
                isExist = false;
                Log.d("FILE", "EXIST");
            }
            catch(IOException e) {
                Log.e("FILE", "Error creating file: " + e.getMessage());
            }
        }

        Log.d("FILE", "Directory exists: ");
        return isExist;
    }

    // if files in directory exist loads the files
    // loads user data
    public void loadUser() {
        String filename = "UserData.txt";

        try {
            FileInputStream fileInputStream = openFileInput(filename);
            InputStreamReader inputStreamReader = new InputStreamReader(fileInputStream);
            BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
            String str;

            while((str = bufferedReader.readLine()) != null) {
                String[] parts = str.split(",");

                ClassController.createUser(parts[0], parts[1], parts[2], Integer.parseInt(parts[3]), parts[4]);
            }
            bufferedReader.close();
        }
        catch(FileNotFoundException e) {
           Log.e("FILE", "Error: " + e.getMessage());
        }
        catch(IOException e) {
            Log.e("FILE", "Error: " + e.getMessage());
        }
        Log.i("FILE", "Loaded Successfully" + ClassController.newUser.getFname());
    }

    // loads history data
    public void loadHist() {
        String filename = "HistoryData.txt";

        try {
            FileInputStream fileInputStream = openFileInput(filename);
            InputStreamReader inputStreamReader = new InputStreamReader(fileInputStream);
            BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
            String str;

            while((str = bufferedReader.readLine()) != null) {
                String[] parts = str.split(",");
                if(parts.length >= 7) {
                    History h = new History(parts[0],
                            parts[1], parts[2], parts[3],
                            parts[4], parts[5], parts[6]);
                    ClassController.HistMap.createHistory(h);
                }
            }
            bufferedReader.close();
        }
        catch(FileNotFoundException e) {
            Log.e("FILE", "Error: " + e.getMessage());
        }
        catch(IOException e) {
            Log.e("FILE", "Error: " + e.getMessage());
        }
        Log.i("FILE", "Loaded Successfully" + ClassController.newUser.getFname());
    }

    // checker for files
    public boolean hasText(File file) {
        try {
            FileInputStream fileInputStream = new FileInputStream(file);
            BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(fileInputStream));

            String line;
            while((line = bufferedReader.readLine()) != null) {
                if (!line.trim().isEmpty()) {
                    // The file has text. Close the reader and return true.
                    bufferedReader.close();
                    return true;
                }
            }

            // The file does not have text. Close the reader and return false.
            bufferedReader.close();
            return false;

        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    public void toMainFrame() {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                Intent intent = new Intent(MainActivity.this, MainFrame.class);
                startActivity(intent);
                finish();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        }, 2000);
    }

    public void toNewUserFrame() {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                Intent intent = new Intent(MainActivity.this, LoginFrame.class);
                startActivity(intent);
                finish();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        }, 2000);
    }
}