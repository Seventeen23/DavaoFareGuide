package com.example.le_project;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;

import android.content.Intent;
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
import android.widget.TextView;

public class SearchedHistoryFrame extends AppCompatActivity {

    public ImageButton homeButton, historyButton, aboutButton, searchButton;

    // this class and activity is a copy of the historyframe class
    // only loads history user searched

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_search_history_frame);

        LinearLayout linearLayout = findViewById(R.id.linear_layout4);

        ViewGroup.LayoutParams params = new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                200
        );

        for(int i = 0; i < ClassController.HistMap.getMap().size(); i++) {
            if(ClassController.HistMap.getMap().get("H" + i).getDate().contains(ClassController.searchedHistory) ||
                    ClassController.HistMap.getMap().get("H" + i).getJeep().toLowerCase().contains(ClassController.searchedHistory) ||
                    ClassController.HistMap.getMap().get("H" + i).getStart().toLowerCase().contains(ClassController.searchedHistory) ||
                    ClassController.HistMap.getMap().get("H" + i).getEnd().toLowerCase().contains(ClassController.searchedHistory)) {
                String text = "";

                LinearLayout newLayout = new LinearLayout(this);
                LinearLayout newLayout2 = new LinearLayout(this);
                LinearLayout newLayout3 = new LinearLayout(this);

                newLayout.setPadding(3, 0, 2, 0);
                newLayout2.setPadding(3, 0, 2, 0);
                newLayout3.setPadding(3, 0, 2, 0);

                TextView text1 = new TextView(this);
                TextView text2 = new TextView(this);
                TextView text3 = new TextView(this);

                text1.setPadding(50, 0, 20, 0);
                text2.setPadding(50, 0, 20, 0);
                text3.setPadding(50, 0, 20, 0);

                text1.setTextColor(getResources().getColor(android.R.color.black));
                text2.setTextColor(getResources().getColor(android.R.color.black));
                text3.setTextColor(getResources().getColor(android.R.color.black));

                text1.setGravity(Gravity.LEFT | Gravity.TOP | Gravity.CENTER_VERTICAL);
                text2.setGravity(Gravity.LEFT | Gravity.TOP | Gravity.CENTER_VERTICAL);
                text3.setGravity(Gravity.LEFT | Gravity.TOP | Gravity.CENTER_VERTICAL);

                text1.setText(ClassController.HistMap.getMap().get("H" + i).getDate());

                text2.setText(ClassController.newUser.getCategory() + "\n" +
                        ClassController.HistMap.getMap().get("H" + i).getJeep() + "\n" +
                        ClassController.HistMap.getMap().get("H" + i).getStart() + "-" +
                        ClassController.HistMap.getMap().get("H" + i).getEnd());

                text3.setText(ClassController.HistMap.getMap().get("H" + i).getFare() + " PHP");

                text1.setTextAppearance(R.style.buttonHistoryBold);
                text2.setTextAppearance(R.style.buttonHistory);
                text3.setTextAppearance(R.style.buttonHistoryBold);

                Button gap = new Button(this);
                gap.setPadding(20,20,20,20);
                gap.setBackgroundResource(R.drawable.transparent_bg);

                newLayout.setBackgroundColor(ContextCompat.getColor(this, R.color.white));
                newLayout2.setBackgroundColor(ContextCompat.getColor(this, R.color.white));
                newLayout3.setBackgroundColor(ContextCompat.getColor(this, R.color.white));
                newLayout.addView(text1);
                newLayout2.addView(text2);
                newLayout3.addView(text3);

                linearLayout.addView(newLayout);
                linearLayout.addView(newLayout2);
                linearLayout.addView(newLayout3);

                linearLayout.addView(gap);

                Log.i("DRAW","SUCCESS");
            }

        }

        homeButton = findViewById(R.id.searched_history_home_button);
        historyButton = findViewById(R.id.searched_history_history_button);
        aboutButton = findViewById(R.id.searched_history_about_button);
        searchButton = findViewById(R.id.searched_history_search_button);
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
        aboutButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                toAboutFrame();
            }
        });
        searchButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                HistorySearchDialogue searchFrame = HistorySearchDialogue.newInstance("Search");
                searchFrame.show(getSupportFragmentManager(), "SearchFragment");
            }
        });
    }

    public void toMainFrame() {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                Intent intent = new Intent(SearchedHistoryFrame.this, MainFrame.class);
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
                Intent intent = new Intent(SearchedHistoryFrame.this, About.class);
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
                Intent intent = new Intent(SearchedHistoryFrame.this, HistoryFrame.class);
                startActivity(intent);
                finish();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        }, 0);
    }

    @Override
    public void onBackPressed() {
        toHistoryFrame();
    }
}