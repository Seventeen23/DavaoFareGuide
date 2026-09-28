package com.example.le_project;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.RectF;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.Spinner;
import android.widget.Toast;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;

public class UserFrame extends AppCompatActivity {

    public String fname, lname, age, category;
    public EditText emailText, fnameText, lnameText, ageText;
    public Spinner categorySpinner;
    public Button editButton;
    public ImageButton backButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_user_frame);


        ImageView profilePicture = findViewById(R.id.profile);
        profilePicture.setImageBitmap(getCircularBitmap(BitmapFactory.decodeResource(getResources(),
                R.drawable.profile_picture)));

        // checks the classcontroller if write to user file
        if(ClassController.isSave) {
            writeUserFile();
        }
        // resets the variable
        ClassController.isSave = false;

        emailText = findViewById(R.id.email_text);
        fnameText = findViewById(R.id.fname_text);
        lnameText = findViewById(R.id.lname_text);
        ageText = findViewById(R.id.age_text);

        editButton = findViewById(R.id.create_user_button);
        backButton = findViewById(R.id.backButton);

        emailText.setText(ClassController.newUser.getEmail().toString());
        fnameText.setText(ClassController.newUser.getFname().toString());
        lnameText.setText(ClassController.newUser.getLname().toString());
        ageText.setText(ClassController.newUser.getAge() + "");

        categorySpinner = findViewById(R.id.category_spinner);
        mapCategorySpinner();

        // algorithm for displaying the current category of the user

        int pos = 0;

        ArrayAdapter<String> adapter = (ArrayAdapter<String>) categorySpinner.getAdapter();
        for(int i = 0; i < adapter.getCount(); i++) {
            if(adapter.getItem(i).equalsIgnoreCase(ClassController.newUser.getCategory())) {
                pos = i;
            }
        }
        categorySpinner.setSelection(pos);

        actionSaveButton();

    }

    // maps buttons with actions
    public void actionSaveButton() {
        editButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // condtion where text or data is acceptable
                if(emailText.getText().toString() != null && fnameText.getText().toString() != null &&
                        lnameText.getText().toString() != null && ageText.getText().toString() != null &&
                        ageText.getText().toString().matches("[0-9]++") && category != null) {

                    // calls a fragment with data passed
                    DBoxEditUser editFrame = DBoxEditUser.newInstance("Edit",
                            emailText.getText().toString(),
                            fnameText.getText().toString(),
                            lnameText.getText().toString(),
                            ageText.getText().toString(),
                            category);
                    editFrame.show(getSupportFragmentManager(), "Edit Fragment");
                }
                else {
                    Toast.makeText(UserFrame.this, "Invalid Information", Toast.LENGTH_SHORT).show();
                }
            }
        });

        backButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(ClassController.isSave) {
                    writeUserFile();
                }
                toMainFrame();
            }
        });
    }

    // writes to directory
    public void writeUserFile() {
        File file = new File(getFilesDir(), "UserData.txt");
        String text = ClassController.newUser.getEmail() + "," +
                ClassController.newUser.getFname() + "," +
                ClassController.newUser.getLname() + "," +
                ClassController.newUser.getAge() + "," +
                ClassController.newUser.getCategory();

        try {
            FileOutputStream fileOutputStream = openFileOutput("UserData.txt", Context.MODE_PRIVATE);
            fileOutputStream.write(text.getBytes());
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

    // maps spinner with categories
    public void mapCategorySpinner() {
        // list of items for spinners
        ArrayList<String> categoryItems = new ArrayList<>();
        categoryItems.add("Regular");
        categoryItems.add("Student");
        categoryItems.add("Senior");
        categoryItems.add("PWD");

        // create an arrayAdapter for the spinner using the list of items
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, R.layout.spinner_item, categoryItems);

        // set the dropdown layout for the spinner
        adapter.setDropDownViewResource(R.layout.spinner_dropdown_item);

        // set the adapter for the spinner
        categorySpinner.setAdapter(adapter);

        // action for spinner
        categorySpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                category = parent.getItemAtPosition(position).toString();

            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
                // do nothing
            }
        });
    }

    // front end design
    public Bitmap getCircularBitmap(Bitmap bitmap) {
        Bitmap output = Bitmap.createBitmap(bitmap.getWidth(),
                bitmap.getHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(output);

        final int color = 0xff424242;
        final Paint paint = new Paint();
        final Rect rect = new Rect(0, 0, bitmap.getWidth(), bitmap.getHeight());
        final RectF rectF = new RectF(rect);

        paint.setAntiAlias(true);
        canvas.drawARGB(0, 0, 0, 0);
        paint.setColor(color);
        canvas.drawOval(rectF, paint);

        paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_IN));
        canvas.drawBitmap(bitmap, rect, rect, paint);

        return output;
    }

    public void toMainFrame() {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                Intent intent = new Intent(UserFrame.this, MainFrame.class);
                startActivity(intent);
                finish();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        }, 0);
    }

    // overrides back and home fucntion of the phone
    @Override
    public void onBackPressed() {
        if(ClassController.isSave) {
            writeUserFile();
        }
        toMainFrame();
    }

    @Override
    protected void onUserLeaveHint() {
        super.onUserLeaveHint();
        if (isFinishing()) {
            if(ClassController.isSave) {
                writeUserFile();
            }
        }
    }
}