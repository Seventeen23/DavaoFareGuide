package com.example.le_project;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;

import android.content.Context;
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

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

public class HistoryFrame extends AppCompatActivity {

    public ImageButton homeButton, historyButton, aboutButton, searchButton, userButton, deleteButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_history_frame);

        // checks the classcontroller to write history file
        if(ClassController.isDelete) {
            writeHistFile();
        }
        // resets the variable
        ClassController.isDelete = false;

        // front end design
        LinearLayout linearLayout = findViewById(R.id.linear_layout1);

        ViewGroup.LayoutParams params = new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                200
        );
        ViewGroup.LayoutParams linearparams = new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                112
        );

        // loads the history transactions and front end design
        for(int i = 0; i < ClassController.HistMap.getMap().size(); i++) {
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

        homeButton = findViewById(R.id.history_home_button);
        historyButton = findViewById(R.id.history_history_button);
        aboutButton = findViewById(R.id.history_about_button);
        searchButton = findViewById(R.id.history_search_button);
        userButton = findViewById(R.id.history_user_button);
        deleteButton = findViewById(R.id.history_frame_delete_button);

        setActionButtons();
    }

    // maps the buttons with actions
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
                // do nothing
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

        userButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                toUserFrame();
            }
        });

        // delete action calls a verification fragment
        deleteButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                DBoxDeleteHistory deleteFrame = DBoxDeleteHistory.newInstance("Delete");
                deleteFrame.show(getSupportFragmentManager(), "DeleteFragment");
            }
        });
    }

    // writes to the directory of the phone
    public void writeHistFile() {
        File histFile = new File(getFilesDir(), "HistoryData.txt");

        StringBuilder textBuilder = new StringBuilder();

        for(History h : ClassController.HistMap.getMap().values()) {
            String text = h.getId() + "," + h.getDate() + "," +
                    h.getJeep() + "," +
                    h.getStart() + "," +
                    h.getEnd() + "," +
                    h.getKM() + "," +
                    h.getFare() + "\n";
            textBuilder.append(text);
        }

        try {
            FileOutputStream fileOutputStream = openFileOutput("HistoryData.txt", Context.MODE_PRIVATE);
            fileOutputStream.write(textBuilder.toString().getBytes());
            fileOutputStream.close();
        }
        catch(FileNotFoundException e) {
            Log.e("FILE", "Error: " + e.getMessage());
        }
        catch(IOException e) {
            Log.e("FILE", "Error: " + e.getMessage());
        }
        Log.i("FILE", "Write Success");
    }

    public void toMainFrame() {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                Intent intent = new Intent(HistoryFrame.this, MainFrame.class);
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
                Intent intent = new Intent(HistoryFrame.this, About.class);
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
                Intent intent = new Intent(HistoryFrame.this, UserFrame.class);
                startActivity(intent);
                finish();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        }, 0);
    }

    // overrides the back and home functions of the phone
    @Override
    public void onBackPressed() {
        toMainFrame();
    }

    @Override
    protected void onUserLeaveHint() {
        super.onUserLeaveHint();
        if (isFinishing()) {
            if(ClassController.isDelete) {
                writeHistFile();
            }
        }
    }
}