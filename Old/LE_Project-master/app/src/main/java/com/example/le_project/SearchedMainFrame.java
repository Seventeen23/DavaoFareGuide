package com.example.le_project;

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

public class SearchedMainFrame extends AppCompatActivity {

    public ImageButton homeButton, historyButton, searchButton, navButton;

    // this class and activity is a copy of the main frame class
    // only loads jeepney options that user searched

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_searched_main_frame);

        LinearLayout linearLayout = findViewById(R.id.linear_layout3);

        ViewGroup.LayoutParams params = new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                200
        );

        for(int i = 0; i < ClassController.options.length - 1; i++) {
            if(ClassController.searchedJeep.toLowerCase().equals(ClassController.options[i]) ||
                    ClassController.options[i].toLowerCase().contains(ClassController.searchedJeep)) {
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

                button.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        ClassController.selectedJeep = button.getText().toString();
                        loadRoutes("jeepneys/" + finalText + ".txt");
                        toRouteSelectionFrame();
                    }
                });

            }
        }
        homeButton = findViewById(R.id.searched_home_button);
        historyButton = findViewById(R.id.searched_history_button);
        searchButton = findViewById(R.id.searched_search_button);
        navButton = findViewById(R.id.searched_about_button);

        setActionButtons();
    }

    public void setActionButtons() {
        homeButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                toMainFrame();
            }
        });

        historyButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                toHistoryFrame();
            }
        });

        searchButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                SearchDialogue searchFrame = SearchDialogue.newInstance("Search");
                searchFrame.show(getSupportFragmentManager(), "SearchFragment");
            }
        });

        navButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                toAboutFrame();
            }
        });
    }

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

    public void toMainFrame() {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                Intent intent = new Intent(SearchedMainFrame.this, MainFrame.class);
                startActivity(intent);
                finish();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        }, 0);
    }

    public void toRouteSelectionFrame() {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                Intent intent = new Intent(SearchedMainFrame.this, RouteSelectionFrame.class);
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
                Intent intent = new Intent(SearchedMainFrame.this, HistoryFrame.class);
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
                Intent intent = new Intent(SearchedMainFrame.this, About.class);
                startActivity(intent);
                finish();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        }, 0);
    }

    @Override
    public void onBackPressed() {
        toMainFrame();
    }
}