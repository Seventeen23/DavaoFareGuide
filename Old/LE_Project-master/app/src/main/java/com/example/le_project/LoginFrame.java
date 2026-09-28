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
import android.text.Editable;
import android.text.SpannableString;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class LoginFrame extends AppCompatActivity {

    public String fname, lname, age, category;
    public EditText emailText, fnameText, lnameText, ageText;
    public Spinner categorySpinner;
    public Button createButton;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_login_frame);

        //sets the profile picture to round
        ImageView profilePicture = findViewById(R.id.profile);
        profilePicture.setImageBitmap(getCircularBitmap(BitmapFactory.decodeResource(getResources(),
                                                        R.drawable.profile_picture)));

        emailText = findViewById(R.id.email_text);
        fnameText = findViewById(R.id.fname_text);
        lnameText = findViewById(R.id.lname_text);
        ageText = findViewById(R.id.age_text);

        createButton = findViewById(R.id.create_user_button);

        categorySpinner = findViewById(R.id.category_spinner);
        mapCategorySpinner();

        actionSaveButton();

    }

    // maps button with action
    public void actionSaveButton() {
        createButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // condition where texts are acceptable
                if(emailText.getText().toString() != null && fnameText.getText().toString() != null &&
                            lnameText.getText().toString() != null && ageText.getText().toString() != null &&
                            ageText.getText().toString().matches("[0-9]++") && category != null) {

                    // initializes the user upon creation
                    ClassController.createUser(emailText.getText().toString(),
                                                fnameText.getText().toString(),
                                                lnameText.getText().toString(),
                                                Integer.parseInt(ageText.getText().toString()),
                                                category);
                    // saves user to directory
                    writeUserFile();
                    toMainFrame();
                }
                else {
                    Toast.makeText(LoginFrame.this, "Invalid Information", Toast.LENGTH_SHORT).show();
                }

            }
        });
    }

    // writes to the directory of the phone
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

    // populate snipper with values
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
                // Do nothing or show a default item
            }
        });
    }

    // front end design for circle edge
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
                Intent intent = new Intent(LoginFrame.this, MainFrame.class);
                startActivity(intent);
                finish();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        }, 0);
    }


}