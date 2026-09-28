package com.example.le_project;

import static android.app.PendingIntent.getActivity;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.content.res.AssetManager;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.LinearLayout;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;

public class MainFrame extends AppCompatActivity {

    public ImageButton homeButton, historyButton, searchButton, aboutButton, userButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_main_frame);

        // front end design
        LinearLayout linearLayout = findViewById(R.id.linear_layout);

        ViewGroup.LayoutParams params = new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                200
        );

        // loads all jeepney options found in the classcontroller
        for(int i = 0; i < ClassController.options.length - 1; i++) {
            String text = ClassController.options[i];

            Button button = new Button(this);
            button.setId(i);
            button.setPadding(50, 40, 80, 20);
            button.setTextColor(getResources().getColor(android.R.color.white));
            button.setBackgroundResource(R.drawable.jeep_button_icon);
            button.setGravity(Gravity.LEFT | Gravity.TOP | Gravity.CENTER_VERTICAL);
            button.setText(text);
            button.setTextAppearance(R.style.buttonText);

            Button gap = new Button(this);
            gap.setPadding(20,20,20,20);
            gap.setBackgroundResource(R.drawable.transparent_bg);

            linearLayout.addView(button);
            linearLayout.addView(gap);

            // cleans the text
            String finalText = text.toLowerCase().replaceAll(" ","_");

            Log.i("DRAW","SUCCESS");

            // maps every jeepney with actions
            button.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    ClassController.selectedJeep = button.getText().toString();
                    loadRoutes("jeepneys/" + finalText + ".txt");
                    toRouteSelectionFrame();
                }
            });

            homeButton = findViewById(R.id.main_frame_home_button);
            historyButton = findViewById(R.id.main_frame_history_button);
            searchButton = findViewById(R.id.search_button);
            aboutButton = findViewById(R.id.main_about_button);
            userButton = findViewById(R.id.main_frame_user_button);

            setActionButtons();

        }
    }

    // maps buttons with actions
    public void setActionButtons() {
        homeButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                // do nothing
            }
        });

        historyButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                toHistoryFrame();
            }
        });

        // creates a search fragment
        searchButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                SearchDialogue searchFrame = SearchDialogue.newInstance("Search");
                searchFrame.show(getSupportFragmentManager(), "SearchFragment");
            }
        });

        aboutButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                toAboutFrame();
            }
        });

        userButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                toUserFrame();
            }
        });
    }

    // when a jeepney is selected
    // all routes within that jeepney is loaded
    public void loadRoutes(String Jeepney) {
        AssetManager assetManager = getAssets();

        try{
            InputStream inputStream = assetManager.open(Jeepney);
            BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(inputStream));
            String line;

            while((line = bufferedReader.readLine()) != null) {
                String[] parts = line.split(",");

                if (parts.length == 2) {
                    String name = parts[0];
                    int index = Integer.parseInt(parts[1]);
                    AlgoHandler.RouteHashMap.put(name, index);
                } else {
                    Log.e("LOADFILE", "Routes Load Fail");
                }
                Log.i("LOADFILE", "Route Load Success");
            }
            bufferedReader.close();
        }
        catch(Exception e) {
            Log.e("LOADFILE", "Routes Load Failed " + e.getMessage());
        }
    }

    public void toRouteSelectionFrame() {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                Intent intent = new Intent(MainFrame.this, RouteSelectionFrame.class);
                startActivity(intent);
                finish();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        }, 0);
    }

    public void toHistoryFrame() {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                Intent intent = new Intent(MainFrame.this, HistoryFrame.class);
                startActivity(intent);
                finish();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        }, 0);
    }

    public void toAboutFrame() {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                Intent intent = new Intent(MainFrame.this, About.class);
                startActivity(intent);
                finish();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        }, 0);
    }

    public void toUserFrame() {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                Intent intent = new Intent(MainFrame.this, UserFrame.class);
                startActivity(intent);
                finish();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        }, 0);
    }
}