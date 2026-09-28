package com.example.le_project;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.provider.ContactsContract;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;

public class DBoxEditUser extends DialogFragment {

    public Button yesButton, noButton;
    public ImageButton xButton;
    public static String Email, Fname, Lname, Age, Category;

    // actions when new instance is called
    // takes user information
    public static DBoxEditUser newInstance(String editUser, String email, String fname, String lname, String age, String category) {
        DBoxEditUser fragment = new DBoxEditUser();
        Bundle args = new Bundle();

        Email = email;
        Fname = fname;
        Lname = lname;
        Age = age;
        Category = category;

        args.putString("editUser", editUser);
        fragment.setArguments(args);
        return fragment;
    }

    // design when new instance is called
    @NonNull
    @Override
    public Dialog onCreateDialog(@Nullable Bundle savedInstanceState) {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        LayoutInflater inflater = getActivity().getLayoutInflater();
        View view = inflater.inflate(R.layout.dbox_user_edit, null);

        yesButton = view.findViewById(R.id.dbox_user_yes_button);
        noButton = view.findViewById(R.id.dbox_user_no_button);
        xButton = view.findViewById(R.id.dbox_user_x_button);

        setActionButtons();

        builder.setView(view);
        return builder.create();
    }

    // maps button with actions
    public void setActionButtons() {
        yesButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //update the current user account with the new information
                ClassController.newUser.setEmail(Email);
                ClassController.newUser.setFname(Fname);
                ClassController.newUser.setLname(Lname);
                ClassController.newUser.setAge(Integer.parseInt(Age));
                ClassController.newUser.setCategory(Category);

                //dismisses the fragment
                toUserFrame();
                Toast.makeText(getContext(), "Edit Successful", Toast.LENGTH_SHORT).show();
                DBoxEditUser.this.getDialog().dismiss();
            }
        });

        noButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                DBoxEditUser.this.getDialog().dismiss();
            }
        });

        xButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                DBoxEditUser.this.getDialog().dismiss();
            }
        });
    }

    public void toUserFrame() {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                Intent intent = new Intent(getActivity(), UserFrame.class);
                startActivity(intent);
            }
        }, 0);
    }
}
