package com.example.le_project;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.Spinner;
import android.widget.TextView;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;

public class RouteSelectionFrame extends AppCompatActivity {

    public TextView jeepText;
    public Button generateButton;
    public ImageButton backButton, aboutButton;
    public Spinner startSpinner, endSpinner;
    public String startPoint, endPoint;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_route_selection_frame);

        jeepText = findViewById(R.id.jeep_head_text);

        backButton = findViewById(R.id.route_selection_back_button);
        aboutButton = findViewById(R.id.route_selection_about_button);
        generateButton = findViewById(R.id.resource_selection_generate_button);

        startSpinner = findViewById(R.id.start_point_spinner);
        endSpinner = findViewById(R.id.end_point_spinner);

        jeepText.setText(ClassController.selectedJeep);

        // populates the snippers
        mapStartSpinner();
        mapEndSpinner();

        setActionButton();

    }

    // maps buttons with actions
    public void setActionButton() {
        backButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                writeHistFile();
                toMainFrame();
                AlgoHandler.RouteHashMap.clear();
            }
        });
        generateButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                AlgoHandler.calculate();
                ReceiptDialogue receiptFrame = ReceiptDialogue.newInstance("Receipt");
                receiptFrame.show(getSupportFragmentManager(), "ReceiptFragment");
            }
        });
        aboutButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                toAboutFrame();
            }
        });
    }

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

    // populate startpos spinner
    public void mapStartSpinner() {
        // list of items for spinners
        ArrayList<String> startItems = new ArrayList<>();

        // items loaded from hashmap
        for(String s : AlgoHandler.getStartList()) {
            Log.i("TEST", s);
            startItems.add(s);
        }

        // create an arrayAdapter for the spinner using the list of items
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, R.layout.snipper_route, startItems);

        // set the dropdown layout for the spinner
        adapter.setDropDownViewResource(R.layout.snipper_dropdown_routes);

        // set the adapter for the spinner
        startSpinner.setAdapter(adapter);

        // action for spinner
        startSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                AlgoHandler.setStartPos(parent.getItemAtPosition(position).toString());
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
                // Do nothing or show a default item
            }
        });
    }

    // populates the endpos spinner
    public void mapEndSpinner() {
        // list of items for spinners
        ArrayList<String> endItems = new ArrayList<>();

        // loads items from hashmap
        for(String s : AlgoHandler.getEndList()) {
            endItems.add(s);
        }

        // create an arrayAdapter for the spinner using the list of items
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, R.layout.snipper_route, endItems);

        // set the dropdown layout for the spinner
        adapter.setDropDownViewResource(R.layout.snipper_dropdown_routes);

        // set the adapter for the spinner
        endSpinner.setAdapter(adapter);


        // action for spinner
        endSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                AlgoHandler.setEndPos(parent.getItemAtPosition(position).toString());
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
                // Do nothing or show a default item
            }
        });
    }
    public void toMainFrame() {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                Intent intent = new Intent(RouteSelectionFrame.this, MainFrame.class);
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
                Intent intent = new Intent(RouteSelectionFrame.this, About.class);
                startActivity(intent);
                finish();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        }, 0);
    }

    // overrides the back adnd home function of the phone
    @Override
    public void onBackPressed() {
        toMainFrame();
    }

    @Override
    protected void onUserLeaveHint() {
        super.onUserLeaveHint();
        if (isFinishing()) {
            if(ClassController.isSave) {
                writeHistFile();
            }
        }
    }

}